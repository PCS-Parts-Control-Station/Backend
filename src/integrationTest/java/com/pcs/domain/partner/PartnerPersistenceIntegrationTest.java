package com.pcs.domain.partner;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.partner.dto.request.CreatePartnerRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.entity.Partner;
import com.pcs.domain.partner.mapper.PartnerMapper;
import com.pcs.domain.partner.service.PartnerService;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.support.MariaDbIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = "/pcs-account-test-schema.sql")
class PartnerPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private PartnerService partnerService;
    @Autowired
    private PartnerMapper partnerMapper;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void createPartner_persistsDefaultActiveNormalizedValuesAndCreatedBy() {
        var response = partnerService.createPartner(
                1L,
                new CreatePartnerRequest(
                        " Yongsan Parts ",
                        PartnerType.COMPANY,
                        PartnerRole.SUPPLIER,
                        " 010-1234-5678 ",
                        " ",
                        " Seoul ",
                        " memo ",
                        null
                ),
                7L
        );

        assertThat(response.partnerName()).isEqualTo("Yongsan Parts");
        assertThat(response.active()).isTrue();

        var row = jdbcTemplate.queryForMap(
                "SELECT partner_name, phone, email, address, memo, active, created_by FROM tb_trade_partner WHERE partner_id = ?",
                response.partnerId()
        );
        assertThat(row.get("partner_name")).isEqualTo("Yongsan Parts");
        assertThat(row.get("phone")).isEqualTo("010-1234-5678");
        assertThat(row.get("email")).isNull();
        assertThat(row.get("address")).isEqualTo("Seoul");
        assertThat(row.get("memo")).isEqualTo("memo");
        assertThat(asBoolean(row.get("active"))).isTrue();
        assertThat(((Number) row.get("created_by")).longValue()).isEqualTo(7L);
    }

    @Test
    void searchPartners_appliesCompanyScopeRoleActiveAndPagination() {
        insertPartner(1L, "Supplier A", PartnerType.COMPANY, PartnerRole.SUPPLIER, true);
        insertPartner(1L, "Both A", PartnerType.PERSON, PartnerRole.BOTH, true);
        insertPartner(1L, "Customer A", PartnerType.COMPANY, PartnerRole.CUSTOMER, true);
        insertPartner(1L, "Inactive Supplier", PartnerType.COMPANY, PartnerRole.SUPPLIER, false);
        insertPartner(2L, "Supplier Other", PartnerType.COMPANY, PartnerRole.SUPPLIER, true);

        var response = partnerService.searchPartners(1L, null, null, PartnerRole.SUPPLIER, true, 0, 10, null);

        assertThat(response.totalElements()).isEqualTo(2);
        assertThat(response.content()).extracting("partnerName").containsExactly("Both A", "Supplier A");
        assertThat(response.summary().totalCount()).isEqualTo(2);
        assertThat(response.summary().supplierCount()).isEqualTo(2);
        assertThat(response.summary().activeCount()).isEqualTo(2);
    }

    @Test
    void duplicatePartnerNameIsBlockedPerCompanyOnly() {
        insertPartner(1L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, true);

        assertThatThrownBy(() -> partnerService.createPartner(
                1L,
                new CreatePartnerRequest("Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, null, null, null, null, true),
                7L
        ))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PARTNER_NAME_DUPLICATED);

        Partner otherCompany = new Partner(2L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, null, null, null, null, 7L);
        partnerMapper.insert(otherCompany);
        assertThat(otherCompany.getPartnerId()).isNotNull();
    }

    @Test
    void updatePartner_preservesActiveWhenRequestOmitsActiveAndChangesWhenIncluded() {
        Partner partner = insertPartner(1L, "Old Partner", PartnerType.COMPANY, PartnerRole.SUPPLIER, false);

        var first = partnerService.updatePartner(
                1L,
                partner.getPartnerId(),
                new UpdatePartnerRequest("New Partner", PartnerType.PERSON, PartnerRole.CUSTOMER, null, null, null, "memo", null)
        );
        assertThat(first.active()).isFalse();
        assertThat(first.partnerName()).isEqualTo("New Partner");

        var second = partnerService.updatePartner(
                1L,
                partner.getPartnerId(),
                new UpdatePartnerRequest("New Partner", PartnerType.PERSON, PartnerRole.CUSTOMER, null, null, null, "memo", true)
        );
        assertThat(second.active()).isTrue();
    }

    @Test
    void updatePartnerActiveTogglesRowWithoutDeleting() {
        Partner partner = insertPartner(1L, "Toggle Partner", PartnerType.ETC, PartnerRole.BOTH, true);

        partnerService.updatePartnerActive(1L, partner.getPartnerId(), false);

        Integer active = jdbcTemplate.queryForObject(
                "SELECT active FROM tb_trade_partner WHERE partner_id = ?",
                Integer.class,
                partner.getPartnerId()
        );
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_trade_partner WHERE partner_id = ?",
                Integer.class,
                partner.getPartnerId()
        );
        assertThat(active).isZero();
        assertThat(count).isEqualTo(1);
    }

    @Test
    void mapperUniqueConstraintRejectsDuplicateNameInSameCompany() {
        insertPartner(1L, "Constraint Partner", PartnerType.COMPANY, PartnerRole.SUPPLIER, true);
        Partner duplicate = new Partner(1L, "Constraint Partner", PartnerType.PERSON, PartnerRole.CUSTOMER, null, null, null, null, 7L);

        assertThatThrownBy(() -> partnerMapper.insert(duplicate))
                .isInstanceOf(DuplicateKeyException.class);
    }

    private Partner insertPartner(
            Long companyId,
            String partnerName,
            PartnerType partnerType,
            PartnerRole partnerRole,
            boolean active
    ) {
        Partner partner = new Partner(companyId, partnerName, partnerType, partnerRole, null, null, null, null, 7L);
        partner.setActive(active);
        partnerMapper.insert(partner);
        return partner;
    }

    private boolean asBoolean(Object value) {
        if (value instanceof Boolean booleanValue) {
            return booleanValue;
        }
        if (value instanceof Number numberValue) {
            return numberValue.intValue() != 0;
        }
        return Boolean.parseBoolean(String.valueOf(value));
    }
}
