package com.pcs.domain.inspection;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.catchThrowableOfType;

import com.pcs.domain.inspection.dto.request.CreateInspectionItemResultRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.facade.InspectionFacade;
import com.pcs.domain.inspection.service.InspectionService;
import com.pcs.domain.inspection.type.InspectionItemResultStatus;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = "/pcs-category-part-test-schema.sql")
class InspectionPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private InspectionFacade inspectionFacade;
    @Autowired
    private InspectionService inspectionService;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void initialCorrectionAndReinspection_appendHistoryAndKeepLatestUnitState() {
        insertInspectionReferenceData(1L, 101L, 1001L, 10001L, 1001L, 1101L, 7L);

        Long initialId = inspectionFacade.createInitialInspection(
                acmeOwner(),
                "acme",
                initialRequest(10001L, 1001L, 1101L, InspectionResult.PASS, PartGrade.A, SalesStatus.AVAILABLE)
        ).inspectionIds().get(0);

        Long correctionId = inspectionFacade.createCorrection(
                acmeOwner(),
                "acme",
                initialId,
                revisionRequest(1101L, InspectionResult.FAIL, PartGrade.C, SalesStatus.UNAVAILABLE, "correction")
        ).inspectionIds().get(0);

        Long reinspectionId = inspectionFacade.createReinspection(
                acmeOwner(),
                "acme",
                correctionId,
                revisionRequest(1101L, InspectionResult.PASS, PartGrade.B, SalesStatus.AVAILABLE, "reinspection")
        ).inspectionIds().get(0);

        assertThat(jdbcTemplate.queryForList(
                "SELECT inspection_type FROM tb_inspection WHERE company_id = 1 ORDER BY inspection_id",
                String.class
        )).containsExactly("INITIAL", "CORRECTION", "REINSPECTION");
        assertThat(jdbcTemplate.queryForList(
                "SELECT COALESCE(CAST(original_inspection_id AS CHAR), 'NULL') FROM tb_inspection WHERE company_id = 1 ORDER BY inspection_id",
                String.class
        )).containsExactly("NULL", initialId.toString(), initialId.toString());
        assertThat(jdbcTemplate.queryForList(
                "SELECT grade FROM tb_inspection WHERE company_id = 1 ORDER BY inspection_id",
                String.class
        )).containsExactly("A", "C", "B");
        assertThat(List.of(initialId, correctionId, reinspectionId)).doesNotHaveDuplicates();

        assertThat(jdbcTemplate.queryForObject(
                "SELECT CONCAT(inspection_status, ':', grade, ':', sales_status) FROM tb_pc_part_unit WHERE company_id = 1 AND unit_id = 10001",
                String.class
        )).isEqualTo("COMPLETED:B:AVAILABLE");
        assertThat(jdbcTemplate.queryForList(
                "SELECT reason FROM tb_part_status_history WHERE company_id = 1 AND unit_id = 10001 ORDER BY history_id",
                String.class
        )).containsExactly("INITIAL", "CORRECTION", "REINSPECTION");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_inspection_item_result WHERE item_name_snapshot = 'Visual condition'",
                Integer.class
        )).isEqualTo(3);
    }

    @Test
    void itemResultInsertFailure_rollsBackInspectionUnitAndHistory() {
        insertInspectionReferenceData(1L, 101L, 1001L, 10001L, 1001L, 1101L, 7L);
        String oversizedMemo = "x".repeat(1001);

        assertThatThrownBy(() -> inspectionFacade.createInitialInspection(
                acmeOwner(),
                "acme",
                new CreateInspectionRequest(
                        10001L,
                        1001L,
                        InspectionResult.PASS,
                        PartGrade.A,
                        SalesStatus.AVAILABLE,
                        null,
                        List.of(new CreateInspectionItemResultRequest(
                                1101L,
                                InspectionItemResultStatus.PASS,
                                null,
                                null,
                                null,
                                oversizedMemo
                        ))
                )
        )).isInstanceOf(RuntimeException.class);

        assertThat(tableCount("tb_inspection", 1L)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_inspection_item_result",
                Integer.class
        )).isZero();
        assertThat(tableCount("tb_part_status_history", 1L)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT CONCAT(inspection_status, ':', grade, ':', sales_status) FROM tb_pc_part_unit WHERE company_id = 1 AND unit_id = 10001",
                String.class
        )).isEqualTo("WAITING:NONE:HOLD");
    }

    @Test
    void crossCompanyUnitTemplateAndInspection_areNotReadableOrMutable() {
        insertInspectionReferenceData(2L, 201L, 2001L, 20001L, 2001L, 2101L, 8L);
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection (
                    inspection_id, company_id, unit_id, template_id, inspected_by,
                    inspection_type, original_inspection_id, sales_status, result, grade, memo, inspected_at
                ) VALUES (5001, 2, 20001, 2001, 8, 'INITIAL', NULL, 'AVAILABLE', 'PASS', 'A', 'other', NOW(6))
                """
        );

        BusinessException detailException = catchThrowableOfType(
                () -> inspectionService.getHistoryDetail(1L, 5001L),
                BusinessException.class
        );
        BusinessException revisionException = catchThrowableOfType(
                () -> inspectionFacade.createCorrection(
                        acmeOwner(),
                        "acme",
                        5001L,
                        revisionRequest(2101L, InspectionResult.PASS, PartGrade.B, SalesStatus.AVAILABLE, "blocked")
                ),
                BusinessException.class
        );
        BusinessException unitException = catchThrowableOfType(
                () -> inspectionFacade.createInitialInspection(
                        acmeOwner(),
                        "acme",
                        initialRequest(20001L, 2001L, 2101L, InspectionResult.PASS, PartGrade.A, SalesStatus.AVAILABLE)
                ),
                BusinessException.class
        );

        assertThat(detailException.getErrorCode()).isEqualTo(ErrorCode.INSPECTION_NOT_FOUND);
        assertThat(revisionException.getErrorCode()).isEqualTo(ErrorCode.INSPECTION_NOT_FOUND);
        assertThat(unitException.getErrorCode()).isEqualTo(ErrorCode.PART_UNIT_NOT_FOUND);
        assertThat(tableCount("tb_inspection", 2L)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT CONCAT(inspection_status, ':', grade, ':', sales_status) FROM tb_pc_part_unit WHERE company_id = 2 AND unit_id = 20001",
                String.class
        )).isEqualTo("WAITING:NONE:HOLD");
    }

    private CreateInspectionRequest initialRequest(
            Long unitId,
            Long templateId,
            Long itemId,
            InspectionResult result,
            PartGrade grade,
            SalesStatus salesStatus
    ) {
        return new CreateInspectionRequest(
                unitId,
                templateId,
                result,
                grade,
                salesStatus,
                "initial",
                List.of(itemResult(itemId, result))
        );
    }

    private CreateInspectionRevisionRequest revisionRequest(
            Long itemId,
            InspectionResult result,
            PartGrade grade,
            SalesStatus salesStatus,
            String memo
    ) {
        return new CreateInspectionRevisionRequest(
                null,
                result,
                grade,
                salesStatus,
                memo,
                List.of(itemResult(itemId, result))
        );
    }

    private CreateInspectionItemResultRequest itemResult(Long itemId, InspectionResult result) {
        return new CreateInspectionItemResultRequest(
                itemId,
                result == InspectionResult.PASS
                        ? InspectionItemResultStatus.PASS
                        : InspectionItemResultStatus.FAIL,
                null,
                null,
                null,
                null
        );
    }

    private void insertInspectionReferenceData(
            Long companyId,
            Long categoryId,
            Long partId,
            Long unitId,
            Long templateId,
            Long itemId,
            Long memberId
    ) {
        jdbcTemplate.update(
                "INSERT INTO tb_part_category (category_id, company_id, category_name, created_by) VALUES (?, ?, ?, ?)",
                categoryId,
                companyId,
                "Category " + companyId,
                memberId
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_pc_part (
                    part_id, company_id, category_id, created_by, part_name,
                    model_name, manufacturer, part_code, safe_quantity, active
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, TRUE)
                """,
                partId,
                companyId,
                categoryId,
                memberId,
                "Part " + companyId,
                "Model " + companyId,
                "Maker " + companyId,
                "PART-" + companyId
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_pc_part_unit (
                    unit_id, company_id, part_id, internal_serial_no, unit_status,
                    grade, inspection_status, sales_status, active, created_by
                ) VALUES (?, ?, ?, ?, 'IN_STOCK', 'NONE', 'WAITING', 'HOLD', TRUE, ?)
                """,
                unitId,
                companyId,
                partId,
                "UNIT-" + companyId,
                memberId
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection_template (
                    template_id, company_id, category_id, template_name, version, active, created_by
                ) VALUES (?, ?, ?, ?, 1, TRUE, ?)
                """,
                templateId,
                companyId,
                categoryId,
                "Template " + companyId,
                memberId
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection_template_item (
                    item_id, template_id, item_group, item_name, input_type, required,
                    sort_order, grade_impact, fail_policy, active
                ) VALUES (?, ?, 'BASIC', 'Visual condition', 'CHECK', TRUE, 0, 'LOW', 'NONE', TRUE)
                """,
                itemId,
                templateId
        );
    }

    private int tableCount(String tableName, Long companyId) {
        return jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM " + tableName + " WHERE company_id = ?",
                Integer.class,
                companyId
        );
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
