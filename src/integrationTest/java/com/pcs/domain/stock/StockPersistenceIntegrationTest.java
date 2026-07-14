package com.pcs.domain.stock;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.catchThrowableOfType;

import com.pcs.domain.inspection.dto.request.CreateInspectionItemResultRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.facade.InspectionFacade;
import com.pcs.domain.inspection.type.InspectionItemResultStatus;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
import com.pcs.domain.stock.facade.StockFacade;
import com.pcs.domain.stock.service.StockService;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = "/pcs-category-part-test-schema.sql")
class StockPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private StockService stockService;
    @Autowired
    private StockFacade stockFacade;
    @Autowired
    private InspectionFacade inspectionFacade;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void inboundInspectionOutboundAndCancel_keepsStockAndUnitStatesConsistent() {
        insertReferenceData();
        insertInspectionTemplate();

        var inbound = stockFacade.createInboundDocument(
                acmeOwner(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L,
                        "integration inbound",
                        List.of(new CreateInboundDocumentLineRequest(1001L, 2, null))
                )
        );
        List<Long> unitIds = jdbcTemplate.queryForList(
                "SELECT unit_id FROM tb_pc_part_unit WHERE company_id = 1 ORDER BY unit_id",
                Long.class
        );

        assertThat(inbound.totalQuantity()).isEqualTo(2);
        assertThat(stockService.getDocumentType(1L, inbound.documentId())).isEqualTo(StockDocumentType.INBOUND);
        assertThat(unitIds).hasSize(2);
        assertStockConsistency(1L, 1001L, 2);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_pc_part_unit WHERE company_id = 1 AND inspection_status = 'WAITING' AND grade = 'NONE' AND sales_status = 'HOLD'",
                Integer.class
        )).isEqualTo(2);

        for (Long unitId : unitIds) {
            inspectionFacade.createInitialInspection(
                    acmeOwner(),
                    "acme",
                    new CreateInspectionRequest(
                            unitId,
                            1001L,
                            InspectionResult.PASS,
                            PartGrade.A,
                            SalesStatus.AVAILABLE,
                            "initial inspection",
                            List.of(new CreateInspectionItemResultRequest(
                                    1101L,
                                    InspectionItemResultStatus.PASS,
                                    null,
                                    null,
                                    null,
                                    null
                            ))
                    )
            );
        }

        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_pc_part_unit WHERE company_id = 1 AND inspection_status = 'COMPLETED' AND grade = 'A' AND sales_status = 'AVAILABLE'",
                Integer.class
        )).isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_part_status_history WHERE company_id = 1 AND reason = 'INITIAL'",
                Integer.class
        )).isEqualTo(2);

        var outbound = stockFacade.createOutboundDocument(
                acmeOwner(),
                "acme",
                new CreateOutboundDocumentRequest(
                        102L,
                        "integration outbound",
                        List.of(new CreateOutboundDocumentLineRequest(1001L, List.of(unitIds.get(0)), null))
                )
        );

        assertStockConsistency(1L, 1001L, 1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT unit_status FROM tb_pc_part_unit WHERE company_id = 1 AND unit_id = ?",
                String.class,
                unitIds.get(0)
        )).isEqualTo("OUTBOUND");

        stockFacade.cancelDocument(acmeOwner(), "acme", outbound.documentId());

        assertStockConsistency(1L, 1001L, 2);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT document_status FROM tb_stock_document WHERE company_id = 1 AND document_id = ?",
                String.class,
                outbound.documentId()
        )).isEqualTo("CANCELED");
        assertThat(jdbcTemplate.queryForList(
                "SELECT movement_type FROM tb_stock_movement WHERE company_id = 1 AND document_id = ? ORDER BY movement_id",
                String.class,
                outbound.documentId()
        )).containsExactly("OUTBOUND", "OUTBOUND_CANCEL");
        assertThat(jdbcTemplate.queryForList(
                "SELECT movement_status FROM tb_stock_movement WHERE company_id = 1 AND document_id = ? ORDER BY movement_id",
                String.class,
                outbound.documentId()
        )).containsExactly("CANCELED", "COMPLETED");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT unit_status FROM tb_pc_part_unit WHERE company_id = 1 AND unit_id = ?",
                String.class,
                unitIds.get(0)
        )).isEqualTo("IN_STOCK");
    }

    @Test
    void inboundFailureOnCrossCompanyPart_rollsBackAllEarlierWrites() {
        insertReferenceData();

        BusinessException exception = catchThrowableOfType(
                () -> stockFacade.createInboundDocument(
                        acmeOwner(),
                        "acme",
                        new CreateInboundDocumentRequest(
                                101L,
                                null,
                                List.of(
                                        new CreateInboundDocumentLineRequest(1001L, 1, null),
                                        new CreateInboundDocumentLineRequest(2001L, 1, null)
                                )
                        )
                ),
                BusinessException.class
        );

        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.PART_NOT_FOUND);
        assertThat(tableCount("tb_stock_document", 1L)).isZero();
        assertThat(tableCount("tb_stock_movement", 1L)).isZero();
        assertThat(tableCount("tb_part_stock", 1L)).isZero();
        assertThat(tableCount("tb_pc_part_unit", 1L)).isZero();
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_stock_movement_unit",
                Integer.class
        )).isZero();
    }

    @Test
    void inboundCancel_marksUnitsInactiveAndCanceledWhileKeepingHistory() {
        insertReferenceData();
        var inbound = stockFacade.createInboundDocument(
                acmeOwner(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L,
                        null,
                        List.of(new CreateInboundDocumentLineRequest(1001L, 2, null))
                )
        );

        stockFacade.cancelDocument(acmeOwner(), "acme", inbound.documentId());

        assertStockConsistency(1L, 1001L, 0);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_pc_part_unit WHERE company_id = 1 AND unit_status = 'CANCELED' AND active = FALSE",
                Integer.class
        )).isEqualTo(2);
        assertThat(jdbcTemplate.queryForList(
                "SELECT movement_type FROM tb_stock_movement WHERE company_id = 1 AND document_id = ? ORDER BY movement_id",
                String.class,
                inbound.documentId()
        )).containsExactly("INBOUND", "INBOUND_CANCEL");
        assertThat(jdbcTemplate.queryForList(
                "SELECT movement_status FROM tb_stock_movement WHERE company_id = 1 AND document_id = ? ORDER BY movement_id",
                String.class,
                inbound.documentId()
        )).containsExactly("CANCELED", "COMPLETED");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_stock_movement_unit mu JOIN tb_stock_movement m ON m.movement_id = mu.movement_id WHERE m.company_id = 1 AND m.document_id = ?",
                Integer.class,
                inbound.documentId()
        )).isEqualTo(4);
    }

    @Test
    void inboundCancelAfterInspection_isRejectedWithoutPartialChanges() {
        insertReferenceData();
        insertInspectionTemplate();
        var inbound = stockFacade.createInboundDocument(
                acmeOwner(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L,
                        null,
                        List.of(new CreateInboundDocumentLineRequest(1001L, 1, null))
                )
        );
        Long unitId = jdbcTemplate.queryForObject(
                "SELECT unit_id FROM tb_pc_part_unit WHERE company_id = 1",
                Long.class
        );
        inspectionFacade.createInitialInspection(
                acmeOwner(),
                "acme",
                new CreateInspectionRequest(
                        unitId,
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
                                null
                        ))
                )
        );

        BusinessException exception = catchThrowableOfType(
                () -> stockFacade.cancelDocument(acmeOwner(), "acme", inbound.documentId()),
                BusinessException.class
        );

        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
        assertStockConsistency(1L, 1001L, 1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT document_status FROM tb_stock_document WHERE company_id = 1 AND document_id = ?",
                String.class,
                inbound.documentId()
        )).isEqualTo("COMPLETED");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT CONCAT(unit_status, ':', inspection_status, ':', active) FROM tb_pc_part_unit WHERE company_id = 1 AND unit_id = ?",
                String.class,
                unitId
        )).isEqualTo("IN_STOCK:COMPLETED:1");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_stock_movement WHERE company_id = 1 AND document_id = ?",
                Integer.class,
                inbound.documentId()
        )).isEqualTo(1);
    }

    @Test
    void searchDocuments_usesExclusiveEndDateAndKeepsCompanyScope() {
        insertReferenceData();
        insertDocument(1001L, 1L, 101L, "IN-20260630-A", "2026-06-30 23:59:59.999999");
        insertDocument(1002L, 1L, 101L, "IN-20260701-A", "2026-07-01 00:00:00.000000");
        insertDocument(2001L, 2L, null, "IN-20260630-B", "2026-06-30 12:00:00.000000");
        insertMovement(3001L, 1L, 1001L, 1001L, 2);
        insertMovement(3002L, 1L, 1002L, 1001L, 3);
        insertMovement(4001L, 2L, 2001L, 2001L, 4);

        var result = stockService.searchDocuments(
                1L,
                StockDocumentType.INBOUND,
                "GPU",
                101L,
                StockDocumentStatus.COMPLETED,
                LocalDate.of(2026, 6, 30),
                LocalDate.of(2026, 6, 30),
                0,
                20,
                null
        );

        assertThat(result.content()).extracting("documentId").containsExactly(1001L);
        assertThat(result.totalElements()).isEqualTo(1);
        assertThat(result.summary().totalCount()).isEqualTo(1L);
        assertThat(result.summary().totalQuantity()).isEqualTo(2L);
    }

    @Test
    void stockListIndexes_arePresentInIntegrationSchema() {
        Integer indexCount = jdbcTemplate.queryForObject(
                """
                SELECT COUNT(DISTINCT index_name)
                FROM information_schema.statistics
                WHERE table_schema = DATABASE()
                  AND index_name IN (
                      'idx_stock_document_company_created',
                      'idx_stock_movement_company_document_current'
                  )
                """,
                Integer.class
        );

        assertThat(indexCount).isEqualTo(2);
    }

    private void insertReferenceData() {
        jdbcTemplate.update(
                """
                INSERT INTO tb_trade_partner (
                    partner_id, company_id, partner_name, partner_type, partner_role, active, created_by
                ) VALUES
                    (101, 1, 'GPU Supplier', 'COMPANY', 'SUPPLIER', TRUE, 7),
                    (102, 1, 'GPU Customer', 'COMPANY', 'CUSTOMER', TRUE, 7)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_part_category (
                    category_id, company_id, category_name, created_by
                ) VALUES (101, 1, 'GPU', 7), (201, 2, 'Other GPU', 8)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_pc_part (
                    part_id, company_id, category_id, created_by, part_name,
                    model_name, manufacturer, part_code, safe_quantity, active
                ) VALUES
                    (1001, 1, 101, 7, 'GPU', 'RTX 4060', 'NVIDIA', 'GPU-001', 0, TRUE),
                    (2001, 2, 201, 8, 'Other GPU', 'RX 7600', 'AMD', 'GPU-002', 0, TRUE)
                """
        );
    }

    private void insertInspectionTemplate() {
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection_template (
                    template_id, company_id, category_id, template_name, version, active, created_by
                ) VALUES (1001, 1, 101, 'GPU Inspection', 1, TRUE, 7)
                """
        );
        jdbcTemplate.update(
                """
                INSERT INTO tb_inspection_template_item (
                    item_id, template_id, item_group, item_name, input_type, required,
                    sort_order, grade_impact, fail_policy, active
                ) VALUES (1101, 1001, 'BASIC', 'Visual condition', 'CHECK', TRUE, 0, 'LOW', 'NONE', TRUE)
                """
        );
    }

    private void assertStockConsistency(Long companyId, Long partId, int expectedQuantity) {
        Integer stockQuantity = jdbcTemplate.queryForObject(
                "SELECT quantity FROM tb_part_stock WHERE company_id = ? AND part_id = ?",
                Integer.class,
                companyId,
                partId
        );
        Integer inStockUnitCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_pc_part_unit WHERE company_id = ? AND part_id = ? AND active = TRUE AND unit_status = 'IN_STOCK'",
                Integer.class,
                companyId,
                partId
        );
        assertThat(stockQuantity).isEqualTo(expectedQuantity);
        assertThat(inStockUnitCount).isEqualTo(expectedQuantity);
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

    private void insertDocument(
            Long documentId,
            Long companyId,
            Long partnerId,
            String documentNo,
            String createdAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_document (
                    document_id, company_id, partner_id, document_no, document_type,
                    document_status, processed_by, created_at
                ) VALUES (?, ?, ?, ?, 'INBOUND', 'COMPLETED', ?, ?)
                """,
                documentId,
                companyId,
                partnerId,
                documentNo,
                companyId.equals(1L) ? 7L : 8L,
                createdAt
        );
    }

    private void insertMovement(
            Long movementId,
            Long companyId,
            Long documentId,
            Long partId,
            int quantity
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_stock_movement (
                    movement_id, company_id, document_id, part_id, movement_type,
                    movement_status, quantity, before_quantity, after_quantity, processed_by
                ) VALUES (?, ?, ?, ?, 'INBOUND', 'COMPLETED', ?, 0, ?, ?)
                """,
                movementId,
                companyId,
                documentId,
                partId,
                quantity,
                quantity,
                companyId.equals(1L) ? 7L : 8L
        );
    }
}
