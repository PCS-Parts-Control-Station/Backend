package com.pcs.global.workspace;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.catchThrowableOfType;

import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.service.CategoryService;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.service.InspectionService;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.member.dto.request.UpdateMemberRequest;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.service.PartService;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.service.PartnerService;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.domain.stock.facade.StockFacade;
import com.pcs.domain.stock.service.StockService;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.time.Instant;
import java.util.List;
import org.assertj.core.api.ThrowableAssert.ThrowingCallable;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = "/pcs-category-part-test-schema.sql")
class CompanyDataIsolationIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private PartnerService partnerService;
    @Autowired
    private CategoryService categoryService;
    @Autowired
    private PartService partService;
    @Autowired
    private StockService stockService;
    @Autowired
    private StockFacade stockFacade;
    @Autowired
    private InspectionService inspectionService;
    @Autowired
    private MemberService memberService;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void workspaceCodeMismatch_isRejectedBeforeStockMutation() {
        insertCompanyBResources();

        assertBusinessError(
                ErrorCode.AUTH_WORKSPACE_MISMATCH,
                () -> stockFacade.cancelDocument(acmeOwner(), "other", 2001L)
        );

        assertThat(value("SELECT document_status FROM tb_stock_document WHERE company_id = 2 AND document_id = 2001"))
                .isEqualTo("COMPLETED");
        assertThat(value("SELECT unit_status FROM tb_pc_part_unit WHERE company_id = 2 AND unit_id = 20001"))
                .isEqualTo("OUTBOUND");
    }

    @Test
    void companyA_cannotReadCompanyBResourceIds() {
        insertCompanyBResources();

        assertBusinessError(ErrorCode.PARTNER_NOT_FOUND, () -> partnerService.getPartner(1L, 201L));
        assertBusinessError(ErrorCode.CATEGORY_NOT_FOUND, () -> categoryService.getCategory(1L, 201L));
        assertBusinessError(ErrorCode.PART_NOT_FOUND, () -> partService.getPart(1L, 2001L));
        assertBusinessError(ErrorCode.PART_UNIT_NOT_FOUND, () -> partService.getPartUnit(1L, 20001L));
        assertBusinessError(ErrorCode.STOCK_DOCUMENT_NOT_FOUND, () -> stockService.getDocument(1L, 2001L));
        assertBusinessError(ErrorCode.INSPECTION_NOT_FOUND, () -> inspectionService.getHistoryDetail(1L, 5001L));
        assertBusinessError(ErrorCode.MEMBER_NOT_FOUND, () -> memberService.getMember(1L, MemberRole.OWNER, 9L));
    }

    @Test
    void companyA_listsNeverContainCompanyBRows() {
        insertCompanyBResources();

        assertThat(partnerService.searchPartners(1L, null, null, null, null, 0, 20, null).content()).isEmpty();
        assertThat(categoryService.searchCategories(1L, null, 0, 20, null).content()).isEmpty();
        assertThat(partService.searchParts(1L, null, null, null, 0, 20, null).content()).isEmpty();
        assertThat(partService.searchPartUnits(1L, null, null, null, null, 0, 20, null).content()).isEmpty();
        assertThat(stockService.searchDocuments(1L, null, null, null, null, null, null, 0, 20, null).content())
                .isEmpty();
        assertThat(inspectionService.searchHistories(
                1L, null, null, null, null, null, null, null, null, null, 0, 20, null
        ).content()).isEmpty();
        assertThat(memberService.searchMembers(
                1L, MemberRole.OWNER, null, null, null, null, null, 0, 20, null
        ).content()).isEmpty();
    }

    @Test
    void companyA_mutationsCannotChangeCompanyBRows() {
        insertCompanyBResources();

        assertBusinessError(
                ErrorCode.PARTNER_NOT_FOUND,
                () -> partnerService.updatePartner(
                        1L,
                        201L,
                        new UpdatePartnerRequest(
                                "Changed Partner",
                                PartnerType.COMPANY,
                                PartnerRole.BOTH,
                                null,
                                null,
                                null,
                                null,
                                false
                        )
                )
        );
        assertBusinessError(
                ErrorCode.CATEGORY_NOT_FOUND,
                () -> categoryService.updateCategory(
                        1L,
                        201L,
                        new UpdateCategoryRequest("Changed Category", null, null),
                        7L
                )
        );
        assertBusinessError(ErrorCode.CATEGORY_NOT_FOUND, () -> categoryService.deleteCategory(1L, 201L));
        assertBusinessError(
                ErrorCode.PART_NOT_FOUND,
                () -> partService.updatePart(
                        1L,
                        2001L,
                        new UpdatePartRequest(201L, "Changed Part", "Maker", "Model", 0, List.of())
                )
        );
        assertBusinessError(ErrorCode.STOCK_DOCUMENT_NOT_FOUND, () -> stockService.cancelDocument(1L, 7L, 2001L));
        assertBusinessError(
                ErrorCode.INSPECTION_NOT_FOUND,
                () -> inspectionService.createCorrection(
                        1L,
                        7L,
                        5001L,
                        new CreateInspectionRevisionRequest(
                                null,
                                InspectionResult.PASS,
                                PartGrade.B,
                                SalesStatus.AVAILABLE,
                                "blocked",
                                List.of()
                        )
                )
        );
        assertBusinessError(
                ErrorCode.MEMBER_NOT_FOUND,
                () -> memberService.updateMember(
                        1L,
                        MemberRole.OWNER,
                        9L,
                        new UpdateMemberRequest("Changed Member", MemberRole.STAFF)
                )
        );

        assertThat(value("SELECT partner_name FROM tb_trade_partner WHERE company_id = 2 AND partner_id = 201"))
                .isEqualTo("Company B Partner");
        assertThat(value("SELECT category_name FROM tb_part_category WHERE company_id = 2 AND category_id = 201"))
                .isEqualTo("Company B Category");
        assertThat(value("SELECT part_name FROM tb_pc_part WHERE company_id = 2 AND part_id = 2001"))
                .isEqualTo("Company B Part");
        assertThat(value("SELECT document_status FROM tb_stock_document WHERE company_id = 2 AND document_id = 2001"))
                .isEqualTo("COMPLETED");
        assertThat(value("SELECT grade FROM tb_inspection WHERE company_id = 2 AND inspection_id = 5001"))
                .isEqualTo("A");
        assertThat(value("SELECT name FROM tb_member WHERE company_id = 2 AND member_id = 9"))
                .isEqualTo("Company B Staff");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_part_status_history WHERE company_id = 2 AND unit_id = 20001",
                Integer.class
        )).isEqualTo(1);
    }

    private void insertCompanyBResources() {
        jdbcTemplate.update(
                """
                INSERT INTO tb_member (
                    member_id, company_id, login_id, password_hash, name, role, owner_slot, active
                ) VALUES (9, 2, 'other-staff', '{noop}password', 'Company B Staff', 'STAFF', NULL, TRUE)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_trade_partner (
                    partner_id, company_id, partner_name, partner_type, partner_role, active, created_by
                ) VALUES (201, 2, 'Company B Partner', 'COMPANY', 'BOTH', TRUE, 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_part_category (category_id, company_id, category_name, created_by)
                VALUES (201, 2, 'Company B Category', 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_pc_part (
                    part_id, company_id, category_id, created_by, part_name,
                    model_name, manufacturer, part_code, safe_quantity, active
                ) VALUES (2001, 2, 201, 8, 'Company B Part', 'Model B', 'Maker B', 'PART-B', 0, TRUE)
                """
        );
        jdbcTemplate.update(
                "INSERT INTO tb_part_stock (company_id, part_id, quantity) VALUES (2, 2001, 0)"
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_pc_part_unit (
                    unit_id, company_id, part_id, internal_serial_no, unit_status,
                    grade, inspection_status, sales_status, active, created_by
                ) VALUES (20001, 2, 2001, 'COMPANY-B-UNIT', 'OUTBOUND', 'A', 'COMPLETED', 'AVAILABLE', TRUE, 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection_template (
                    template_id, company_id, category_id, template_name, version, active, created_by
                ) VALUES (2001, 2, 201, 'Company B Template', 1, TRUE, 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_document (
                    document_id, company_id, partner_id, document_no, document_type,
                    document_status, reason, processed_by
                ) VALUES (2001, 2, 201, 'OUT-COMPANY-B', 'OUTBOUND', 'COMPLETED', 'Company B', 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_movement (
                    movement_id, company_id, document_id, part_id, movement_type,
                    movement_status, quantity, before_quantity, after_quantity, processed_by
                ) VALUES (4001, 2, 2001, 2001, 'OUTBOUND', 'COMPLETED', 1, 1, 0, 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_movement_unit (
                    movement_id, unit_id, before_unit_status, after_unit_status
                ) VALUES (4001, 20001, 'IN_STOCK', 'OUTBOUND')
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection (
                    inspection_id, company_id, unit_id, template_id, inspected_by,
                    inspection_type, original_inspection_id, sales_status, result, grade, memo, inspected_at
                ) VALUES (5001, 2, 20001, 2001, 8, 'INITIAL', NULL, 'AVAILABLE', 'PASS', 'A', 'Company B', NOW(6))
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_part_status_history (
                    company_id, unit_id, changed_by, from_inspection_status, to_inspection_status,
                    from_grade, to_grade, from_sales_status, to_sales_status, reason
                ) VALUES (2, 20001, 8, 'WAITING', 'COMPLETED', 'NONE', 'A', 'HOLD', 'AVAILABLE', 'INITIAL')
                """
        );
    }

    private void assertBusinessError(ErrorCode errorCode, ThrowingCallable callable) {
        BusinessException exception = catchThrowableOfType(callable, BusinessException.class);
        assertThat(exception).isNotNull();
        assertThat(exception.getErrorCode()).isEqualTo(errorCode);
    }

    private String value(String sql) {
        return jdbcTemplate.queryForObject(sql, String.class);
    }

    private PcsPrincipal acmeOwner() {
        return new PcsPrincipal(
                7L,
                1L,
                "acme",
                "admin",
                MemberRole.OWNER,
                Instant.now().plusSeconds(3600)
        );
    }
}
