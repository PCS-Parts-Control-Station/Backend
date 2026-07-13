package com.pcs.domain.dashboard;

import static org.assertj.core.api.Assertions.assertThat;

import com.pcs.domain.dashboard.service.DashboardService;
import com.pcs.support.MariaDbIntegrationTest;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = {"/pcs-category-part-test-schema.sql", "/pcs-operations-test-schema-extension.sql"})
class DashboardPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private DashboardService dashboardService;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private LocalDateTime now;

    @BeforeEach
    void setUpData() {
        now = LocalDateTime.now().withNano(0);
        seedCompanyOne();
        seedOtherCompany();
    }

    @Test
    void dashboardAggregation_excludesCanceledAndOtherCompanyData() {
        var dashboard = dashboardService.getDashboard(1L);

        assertThat(dashboard.summary().todayInboundQuantity()).isEqualTo(5);
        assertThat(dashboard.summary().todayOutboundQuantity()).isEqualTo(2);
        assertThat(dashboard.summary().waitingInspectionQuantity()).isEqualTo(1);
        assertThat(dashboard.summary().availableQuantity()).isEqualTo(1);
        assertThat(dashboard.summary().holdQuantity()).isEqualTo(2);
        assertThat(dashboard.summary().unavailableQuantity()).isEqualTo(1);
        assertThat(dashboard.summary().todayDefectiveInspectionCount()).isEqualTo(1);

        assertThat(dashboard.stockStatus().availableQuantity()).isEqualTo(1);
        assertThat(dashboard.stockStatus().holdQuantity()).isEqualTo(2);
        assertThat(dashboard.stockStatus().unavailableQuantity()).isEqualTo(1);
        assertThat(dashboard.stockStatus().availableRatio()).isEqualTo(25);

        assertThat(dashboard.todos()).extracting("partId").containsOnly(1001L);
        assertThat(dashboard.todos()).extracting("categoryName").containsOnly("Memory");
        assertThat(dashboard.todos()).extracting("label")
                .contains("검수 대기", "판매 보류", "판매 불가");
        assertThat(dashboard.todos())
                .filteredOn(todo -> "STOCK_HOLD".equals(todo.type()))
                .extracting("route", "partState")
                .containsExactly(org.assertj.core.groups.Tuple.tuple("part-units", "STOCK_HOLD"));
        assertThat(dashboard.todos())
                .filteredOn(todo -> "STOCK_UNAVAILABLE".equals(todo.type()))
                .extracting("route", "partState")
                .containsExactly(org.assertj.core.groups.Tuple.tuple("part-units", "STOCK_UNAVAILABLE"));
        assertThat(dashboard.recentActivities()).extracting("documentNo")
                .contains("IN-TEST-001", "OUT-TEST-001")
                .doesNotContain("IN-CANCELED-001", "IN-OTHER-001");
    }

    private void seedCompanyOne() {
        jdbcTemplate.update("INSERT INTO tb_part_category (category_id, company_id, category_name, created_by) VALUES (101, 1, 'Memory', 7)");
        jdbcTemplate.update("INSERT INTO tb_pc_part (part_id, company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1001, 1, 101, 7, 'DDR4 RAM', '16GB', 'Samsung', 'RAM-16', 0, TRUE)");

        insertUnit(2001, 1, 1001, "WAITING", "NONE", "HOLD");
        insertUnit(2002, 1, 1001, "COMPLETED", "A", "AVAILABLE");
        insertUnit(2003, 1, 1001, "COMPLETED", "B", "HOLD");
        insertUnit(2004, 1, 1001, "COMPLETED", "DEFECTIVE", "UNAVAILABLE");

        insertDocument(3001, 1, 101, "IN-TEST-001", "INBOUND", "COMPLETED", 7, now.minusMinutes(30));
        insertDocument(3002, 1, 102, "OUT-TEST-001", "OUTBOUND", "COMPLETED", 7, now.minusMinutes(10));
        insertDocument(3003, 1, 101, "IN-CANCELED-001", "INBOUND", "CANCELED", 7, now.minusMinutes(5));
        insertMovement(4001, 1, 3001, 1001, "INBOUND", "COMPLETED", null, 5, now.minusMinutes(30));
        insertMovement(4002, 1, 3002, 1001, "OUTBOUND", "COMPLETED", null, 2, now.minusMinutes(10));
        insertMovement(4003, 1, 3003, 1001, "INBOUND", "CANCELED", 4001L, 9, now.minusMinutes(5));

        jdbcTemplate.update(
                "INSERT INTO tb_inspection (inspection_id, company_id, unit_id, inspected_by, inspection_type, sales_status, result, grade, inspected_at) VALUES (5001, 1, 2004, 7, 'INITIAL', 'UNAVAILABLE', 'FAIL', 'DEFECTIVE', ?)",
                Timestamp.valueOf(now.minusMinutes(20))
        );
    }

    private void seedOtherCompany() {
        jdbcTemplate.update("INSERT INTO tb_part_category (category_id, company_id, category_name, created_by) VALUES (201, 2, 'Other', 8)");
        jdbcTemplate.update("INSERT INTO tb_pc_part (part_id, company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1101, 2, 201, 8, 'Other RAM', '32GB', 'Other', 'OTHER-32', 0, TRUE)");
        insertUnit(2101, 2, 1101, "COMPLETED", "A", "AVAILABLE");
        insertDocument(3101, 2, 201, "IN-OTHER-001", "INBOUND", "COMPLETED", 8, now.minusMinutes(1));
        insertMovement(4101, 2, 3101, 1101, "INBOUND", "COMPLETED", null, 100, now.minusMinutes(1));
    }

    private void insertUnit(long unitId, long companyId, long partId, String inspectionStatus, String grade, String salesStatus) {
        jdbcTemplate.update(
                "INSERT INTO tb_pc_part_unit (unit_id, company_id, part_id, internal_serial_no, unit_status, inspection_status, grade, sales_status, active, created_by) VALUES (?, ?, ?, ?, 'IN_STOCK', ?, ?, ?, TRUE, ?)",
                unitId, companyId, partId, "UNIT-" + unitId, inspectionStatus, grade, salesStatus, companyId == 1 ? 7 : 8
        );
    }

    private void insertDocument(long documentId, long companyId, long partnerId, String documentNo, String type, String status, long memberId, LocalDateTime createdAt) {
        jdbcTemplate.update(
                "INSERT INTO tb_stock_document (document_id, company_id, partner_id, document_no, document_type, document_status, processed_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                documentId, companyId, partnerId, documentNo, type, status, memberId, Timestamp.valueOf(createdAt)
        );
    }

    private void insertMovement(long movementId, long companyId, long documentId, long partId, String type, String status, Long canceledMovementId, int quantity, LocalDateTime createdAt) {
        boolean increasesStock = "INBOUND".equals(type) || "OUTBOUND_CANCEL".equals(type);
        int beforeQuantity = increasesStock ? 0 : quantity;
        int afterQuantity = increasesStock ? quantity : 0;
        jdbcTemplate.update(
                "INSERT INTO tb_stock_movement (movement_id, company_id, document_id, part_id, movement_type, movement_status, canceled_movement_id, quantity, before_quantity, after_quantity, processed_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                movementId, companyId, documentId, partId, type, status, canceledMovementId, quantity,
                beforeQuantity, afterQuantity, companyId == 1 ? 7 : 8, Timestamp.valueOf(createdAt)
        );
    }
}
