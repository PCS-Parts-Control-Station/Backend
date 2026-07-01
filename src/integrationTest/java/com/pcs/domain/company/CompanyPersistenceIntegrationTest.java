package com.pcs.domain.company;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.company.dto.request.OwnerSignupRequest;
import com.pcs.domain.company.dto.request.UpdateOwnerCompanyRequest;
import com.pcs.domain.company.dto.response.OwnerCompanyResponse;
import com.pcs.domain.company.dto.response.OwnerSignupResponse;
import com.pcs.domain.company.facade.CompanyFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.time.Instant;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql("/pcs-account-test-schema.sql")
class CompanyPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private CompanyFacade companyFacade;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void signupOwner_persistsCompanyAndOwnerTogether() {
        OwnerSignupResponse response = companyFacade.signupOwner(new OwnerSignupRequest(
                "New Parts",
                "new-parts",
                "4444444444",
                "new@example.com",
                "02-4444-4444",
                "Root Owner",
                "root01",
                "password123"
        ));

        assertThat(response.workspaceLoginUrl()).isEqualTo("/w/new-parts");
        Integer companyCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_company WHERE company_id = ? AND company_code = ?",
                Integer.class,
                response.companyId(),
                "new-parts"
        );
        Integer ownerCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_member WHERE company_id = ? AND member_id = ? AND role = 'OWNER' AND owner_slot = 1",
                Integer.class,
                response.companyId(),
                response.ownerMemberId()
        );
        assertThat(companyCount).isEqualTo(1);
        assertThat(ownerCount).isEqualTo(1);
    }

    @Test
    void signupOwner_rejectsDuplicateCompanyCode() {
        OwnerSignupRequest request = signupRequest("Duplicate Code", "acme", "555-55-55555", "dup01");

        assertThatThrownBy(() -> companyFacade.signupOwner(request))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.COMPANY_CODE_DUPLICATED)
                );
    }

    @Test
    void signupOwner_rejectsDuplicateBusinessRegistrationNo() {
        OwnerSignupRequest request = signupRequest("Duplicate Biz", "dup-biz", "1111111111", "dup02");

        assertThatThrownBy(() -> companyFacade.signupOwner(request))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode())
                                .isEqualTo(ErrorCode.COMPANY_BUSINESS_REGISTRATION_NO_DUPLICATED)
                );
    }

    @Test
    void updateOwnerCompany_updatesOnlyOwnerCompanyFields() {
        OwnerCompanyResponse response = companyFacade.updateOwnerCompany(
                principal(MemberRole.OWNER),
                new UpdateOwnerCompanyRequest(
                        "ACME Updated",
                        "updated@example.com",
                        "02-9999-9999",
                        "9999999999"
                )
        );

        assertThat(response.companyCode()).isEqualTo("acme");
        assertThat(response.companyName()).isEqualTo("ACME Updated");
        assertThat(response.businessRegistrationNo()).isEqualTo("999-99-99999");
    }

    @Test
    void updateOwnerCompany_rejectsNonOwner() {
        assertThatThrownBy(() -> companyFacade.updateOwnerCompany(
                principal(MemberRole.ADMIN),
                new UpdateOwnerCompanyRequest("Nope", null, null, null)
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
        );
    }

    private OwnerSignupRequest signupRequest(String companyName, String companyCode, String businessNo, String loginId) {
        return new OwnerSignupRequest(
                companyName,
                companyCode,
                businessNo,
                loginId + "@example.com",
                "02-0000-0000",
                "Owner",
                loginId,
                "password123"
        );
    }

    private PcsPrincipal principal(MemberRole role) {
        return new PcsPrincipal(1L, 1L, "acme", "owner01", role, Instant.now().plusSeconds(600));
    }
}
