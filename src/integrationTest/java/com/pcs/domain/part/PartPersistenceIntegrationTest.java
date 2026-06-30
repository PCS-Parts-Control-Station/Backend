package com.pcs.domain.part;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.category.dto.request.CategorySpecDefinitionRequest;
import com.pcs.domain.category.dto.request.CategorySpecOptionRequest;
import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.response.CategoryDetailResponse;
import com.pcs.domain.category.service.CategoryService;
import com.pcs.domain.part.dto.request.CreatePartRequest;
import com.pcs.domain.part.dto.request.PartSpecValueRequest;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.service.PartService;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.support.MariaDbIntegrationTest;
import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = "/pcs-category-part-test-schema.sql")
class PartPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private CategoryService categoryService;
    @Autowired
    private PartService partService;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void createPart_generatesCodeAndPersistsSpecValues() {
        CategoryDetailResponse category = createGpuCategory();
        Long chipSpecId = specId(category, "gpu_chip");
        Long memorySpecId = specId(category, "memory_gb");
        Long rgbSpecId = specId(category, "rgb");
        Long rtx3060OptionId = optionId(category, "gpu_chip", "RTX_3060");

        var response = partService.createPart(
                1L,
                new CreatePartRequest(
                        category.categoryId(),
                        "RTX 3060 Gaming",
                        "MSI",
                        "RTX 3060 Gaming X",
                        null,
                        List.of(
                                new PartSpecValueRequest(chipSpecId, null, null, null, rtx3060OptionId),
                                new PartSpecValueRequest(memorySpecId, null, new BigDecimal("12"), null, null)
                        )
                ),
                7L
        );

        assertThat(response.partCode()).isNotBlank().hasSizeLessThanOrEqualTo(80);
        assertThat(response.safeQuantity()).isZero();
        assertThat(response.specValues()).hasSize(3);
        assertThat(response.specValues()).extracting("specDefinitionId")
                .containsExactly(chipSpecId, memorySpecId, rgbSpecId);
        assertThat(response.specValues().get(0).selectedOptionValue()).isEqualTo("RTX_3060");
        assertThat(response.specValues().get(2).valueBoolean()).isFalse();
    }

    @Test
    void searchParts_usesDefaultActiveFilterAndSummaryWithStock() {
        CategoryDetailResponse category = createGpuCategory();
        Long chipSpecId = specId(category, "gpu_chip");
        Long memorySpecId = specId(category, "memory_gb");
        Long optionId = optionId(category, "gpu_chip", "RTX_3060");

        var activePart = partService.createPart(
                1L,
                new CreatePartRequest(
                        category.categoryId(),
                        "RTX 3060 Gaming",
                        "MSI",
                        "RTX 3060 Gaming X",
                        5,
                        List.of(
                                new PartSpecValueRequest(chipSpecId, null, null, null, optionId),
                                new PartSpecValueRequest(memorySpecId, null, new BigDecimal("12"), null, null)
                        )
                ),
                7L
        );
        jdbcTemplate.update(
                "INSERT INTO tb_part_stock (company_id, part_id, quantity) VALUES (1, ?, 3)",
                activePart.partId()
        );
        jdbcTemplate.update(
                "INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1, ?, 7, 'Inactive GPU', 'Inactive', 'MSI', 'GPU-INACTIVE-001', 1, FALSE)",
                category.categoryId()
        );

        var response = partService.searchParts(1L, "GPU", category.categoryId(), null, 0, 20, null);

        assertThat(response.content()).hasSize(1);
        assertThat(response.content().get(0).active()).isTrue();
        assertThat(response.content().get(0).currentStockQuantity()).isEqualTo(3);
        assertThat(response.summary().totalCount()).isEqualTo(1);
        assertThat(response.summary().totalStock()).isEqualTo(3);
        assertThat(response.summary().lowStockCount()).isEqualTo(1);
    }

    @Test
    void updatePart_replacesSpecValuesAndRegeneratesPartCode() {
        CategoryDetailResponse category = createGpuCategory();
        Long chipSpecId = specId(category, "gpu_chip");
        Long memorySpecId = specId(category, "memory_gb");
        Long rtx3060OptionId = optionId(category, "gpu_chip", "RTX_3060");
        Long rtx4060OptionId = optionId(category, "gpu_chip", "RTX_4060");

        var created = partService.createPart(
                1L,
                new CreatePartRequest(
                        category.categoryId(),
                        "RTX 3060 Gaming",
                        "MSI",
                        "RTX 3060 Gaming X",
                        5,
                        List.of(
                                new PartSpecValueRequest(chipSpecId, null, null, null, rtx3060OptionId),
                                new PartSpecValueRequest(memorySpecId, null, new BigDecimal("12"), null, null)
                        )
                ),
                7L
        );

        var updated = partService.updatePart(
                1L,
                created.partId(),
                new UpdatePartRequest(
                        category.categoryId(),
                        "RTX 4060 Dual",
                        "ASUS",
                        "DUAL RTX 4060",
                        2,
                        List.of(
                                new PartSpecValueRequest(chipSpecId, null, null, null, rtx4060OptionId),
                                new PartSpecValueRequest(memorySpecId, null, new BigDecimal("8"), null, null)
                        )
                )
        );

        assertThat(updated.partName()).isEqualTo("RTX 4060 Dual");
        assertThat(updated.manufacturer()).isEqualTo("ASUS");
        assertThat(updated.partCode()).isNotEqualTo(created.partCode());
        assertThat(updated.specValues()).hasSize(3);
        assertThat(updated.specValues().get(0).selectedOptionValue()).isEqualTo("RTX_4060");
        assertThat(countSpecValues(created.partId())).isEqualTo(3);
    }

    @Test
    void createPart_failsWhenRequiredSpecIsMissing() {
        CategoryDetailResponse category = createGpuCategory();
        Long chipSpecId = specId(category, "gpu_chip");
        Long optionId = optionId(category, "gpu_chip", "RTX_3060");

        assertThatThrownBy(() -> partService.createPart(
                1L,
                new CreatePartRequest(
                        category.categoryId(),
                        "RTX 3060 Gaming",
                        "MSI",
                        "RTX 3060 Gaming X",
                        1,
                        List.of(new PartSpecValueRequest(chipSpecId, null, null, null, optionId))
                ),
                7L
        ))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createPart_failsWhenCompanyIsInactive() {
        assertThatThrownBy(() -> partService.createPart(
                3L,
                new CreatePartRequest(1L, "Ryzen 5", "AMD", "5600", 1, List.of()),
                7L
        ))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.COMPANY_INACTIVE);
    }

    @Test
    void searchPartUnits_filtersByPartStateAndUsesSameSummaryWhere() {
        CategoryDetailResponse category = createGpuCategory();
        Long chipSpecId = specId(category, "gpu_chip");
        Long memorySpecId = specId(category, "memory_gb");
        Long optionId = optionId(category, "gpu_chip", "RTX_3060");
        var part = partService.createPart(
                1L,
                new CreatePartRequest(
                        category.categoryId(),
                        "RTX 3060 Gaming",
                        "MSI",
                        "RTX 3060 Gaming X",
                        5,
                        List.of(
                                new PartSpecValueRequest(chipSpecId, null, null, null, optionId),
                                new PartSpecValueRequest(memorySpecId, null, new BigDecimal("12"), null, null)
                        )
                ),
                7L
        );
        insertPartUnit(101L, 1L, part.partId(), "PCS-GPU-0001", "MFR-0001", "IN_STOCK", "WAITING", "NONE", "HOLD", true, "2026-01-01 09:00:00.000000");
        insertPartUnit(102L, 1L, part.partId(), "PCS-GPU-0002", "MFR-0002", "IN_STOCK", "COMPLETED", "A", "AVAILABLE", true, "2026-01-02 09:00:00.000000");
        insertPartUnit(103L, 1L, part.partId(), "PCS-GPU-0003", "MFR-0003", "OUTBOUND", "COMPLETED", "B", "AVAILABLE", true, "2026-01-03 09:00:00.000000");
        insertPartUnit(104L, 1L, part.partId(), "PCS-GPU-0004", "MFR-0004", "IN_STOCK", "COMPLETED", "A", "UNAVAILABLE", false, "2026-01-04 09:00:00.000000");

        var all = partService.searchPartUnits(1L, "PCS-GPU", category.categoryId(), null, 0, 20, null);
        assertThat(all.content()).hasSize(3);
        assertThat(all.summary().totalCount()).isEqualTo(3);
        assertThat(all.summary().waitingCount()).isEqualTo(1);
        assertThat(all.summary().outboundAvailableCount()).isEqualTo(1);

        var gradeA = partService.searchPartUnits(1L, "PCS-GPU", category.categoryId(), "A", 0, 20, null);
        assertThat(gradeA.content()).extracting("internalSerialNo").containsExactly("PCS-GPU-0002");
        assertThat(gradeA.content().get(0).salesStatus()).isEqualTo(SalesStatus.AVAILABLE);
        assertThat(gradeA.summary().outboundAvailableCount()).isEqualTo(1);

        var waiting = partService.searchPartUnits(1L, "PCS-GPU", category.categoryId(), "WAITING", 0, 20, null);
        assertThat(waiting.content()).extracting("internalSerialNo").containsExactly("PCS-GPU-0001");
        assertThat(waiting.content().get(0).inspectionStatus()).isEqualTo(InspectionStatus.WAITING);

        var outbound = partService.searchPartUnits(1L, "PCS-GPU", category.categoryId(), "OUTBOUND", 0, 20, null);
        assertThat(outbound.content()).extracting("internalSerialNo").containsExactly("PCS-GPU-0003");
        assertThat(outbound.content().get(0).unitStatus()).isEqualTo(UnitStatus.OUTBOUND);
    }

    @Test
    void getPartUnit_returnsRecentStockAndInspectionHistoriesWithinCompany() {
        CategoryDetailResponse category = createGpuCategory();
        Long chipSpecId = specId(category, "gpu_chip");
        Long memorySpecId = specId(category, "memory_gb");
        Long optionId = optionId(category, "gpu_chip", "RTX_3060");
        var part = partService.createPart(
                1L,
                new CreatePartRequest(
                        category.categoryId(),
                        "RTX 3060 Gaming",
                        "MSI",
                        "RTX 3060 Gaming X",
                        5,
                        List.of(
                                new PartSpecValueRequest(chipSpecId, null, null, null, optionId),
                                new PartSpecValueRequest(memorySpecId, null, new BigDecimal("12"), null, null)
                        )
                ),
                7L
        );
        insertPartUnit(201L, 1L, part.partId(), "PCS-GPU-0201", "MFR-0201", "IN_STOCK", "COMPLETED", "A", "AVAILABLE", true, "2026-01-03 09:00:00.000000");
        insertStockHistory(301L, 401L, 201L, part.partId(), "IN-20260102-0001", "INBOUND", null, "IN_STOCK", "2026-01-02 10:00:00.000000");
        insertInspection(501L, 1L, 201L, "INITIAL", "PASS", "A", "AVAILABLE", "정상", "2026-01-03 09:30:00.000000");

        var detail = partService.getPartUnit(1L, 201L);

        assertThat(detail.unit().internalSerialNo()).isEqualTo("PCS-GPU-0201");
        assertThat(detail.unit().recentEventLabel()).isEqualTo("검수");
        assertThat(detail.stockHistories()).hasSize(1);
        assertThat(detail.stockHistories().get(0).documentNo()).isEqualTo("IN-20260102-0001");
        assertThat(detail.inspectionHistories()).hasSize(1);
        assertThat(detail.inspectionHistories().get(0).grade()).isEqualTo(PartGrade.A);

        assertThatThrownBy(() -> partService.getPartUnit(2L, 201L))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PART_UNIT_NOT_FOUND);
    }

    private CategoryDetailResponse createGpuCategory() {
        return categoryService.createCategory(
                1L,
                new CreateCategoryRequest(
                        "GPU",
                        "Graphic cards",
                        List.of(
                                new CategorySpecDefinitionRequest(
                                        "gpu_chip",
                                        "GPU Chip",
                                        "SELECT",
                                        null,
                                        true,
                                        true,
                                        0,
                                        List.of(
                                                new CategorySpecOptionRequest("RTX 3060", "RTX_3060", 0),
                                                new CategorySpecOptionRequest("RTX 4060", "RTX_4060", 1)
                                        )
                                ),
                                new CategorySpecDefinitionRequest("memory_gb", "Memory", "NUMBER", "GB", true, true, 1, List.of()),
                                new CategorySpecDefinitionRequest("rgb", "RGB", "BOOLEAN", null, false, false, 2, List.of())
                        )
                ),
                7L
        );
    }

    private Long specId(CategoryDetailResponse category, String specKey) {
        return category.specDefinitions().stream()
                .filter(spec -> specKey.equals(spec.specKey()))
                .findFirst()
                .orElseThrow()
                .specDefinitionId();
    }

    private Long optionId(CategoryDetailResponse category, String specKey, String optionValue) {
        return category.specDefinitions().stream()
                .filter(spec -> specKey.equals(spec.specKey()))
                .findFirst()
                .orElseThrow()
                .options()
                .stream()
                .filter(option -> optionValue.equals(option.optionValue()))
                .findFirst()
                .orElseThrow()
                .optionId();
    }

    private int countSpecValues(Long partId) {
        return jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_part_spec_value WHERE part_id = ?",
                Integer.class,
                partId
        );
    }

    private void insertPartUnit(
            Long unitId,
            Long companyId,
            Long partId,
            String internalSerialNo,
            String manufacturerSerialNo,
            String unitStatus,
            String inspectionStatus,
            String grade,
            String salesStatus,
            boolean active,
            String updatedAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_pc_part_unit (
                    unit_id, company_id, part_id, internal_serial_no, manufacturer_serial_no,
                    unit_status, inspection_status, grade, sales_status, active, created_by, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 7, ?, ?)
                """,
                unitId,
                companyId,
                partId,
                internalSerialNo,
                manufacturerSerialNo,
                unitStatus,
                inspectionStatus,
                grade,
                salesStatus,
                active,
                updatedAt,
                updatedAt
        );
    }

    private void insertStockHistory(
            Long movementId,
            Long documentId,
            Long unitId,
            Long partId,
            String documentNo,
            String movementType,
            String beforeUnitStatus,
            String afterUnitStatus,
            String createdAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_document (
                    document_id, company_id, document_no, document_type, document_status, processed_by, created_at
                ) VALUES (?, 1, ?, ?, 'COMPLETED', 7, ?)
                """,
                documentId,
                documentNo,
                movementType.startsWith("OUTBOUND") ? "OUTBOUND" : "INBOUND",
                createdAt
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_movement (
                    movement_id, company_id, document_id, part_id, movement_type, movement_status,
                    quantity, before_quantity, after_quantity, processed_by, created_at
                ) VALUES (?, 1, ?, ?, ?, 'COMPLETED', 1, 0, 1, 7, ?)
                """,
                movementId,
                documentId,
                partId,
                movementType,
                createdAt
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_movement_unit (
                    movement_id, unit_id, before_unit_status, after_unit_status
                ) VALUES (?, ?, ?, ?)
                """,
                movementId,
                unitId,
                beforeUnitStatus,
                afterUnitStatus
        );
    }

    private void insertInspection(
            Long inspectionId,
            Long companyId,
            Long unitId,
            String inspectionType,
            String result,
            String grade,
            String salesStatus,
            String memo,
            String inspectedAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection (
                    inspection_id, company_id, unit_id, inspected_by, inspection_type,
                    sales_status, result, grade, memo, inspected_at
                ) VALUES (?, ?, ?, 7, ?, ?, ?, ?, ?, ?)
                """,
                inspectionId,
                companyId,
                unitId,
                inspectionType,
                salesStatus,
                result,
                grade,
                memo,
                inspectedAt
        );
    }
}
