package com.pcs.domain.inspection;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.inspection.dto.request.CreateBulkInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.facade.InspectionFacade;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.facade.StockFacade;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = {"/pcs-category-part-test-schema.sql", "/pcs-operations-test-schema-extension.sql"})
class InspectionOperationsPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private StockFacade stockFacade;
    @Autowired
    private InspectionFacade inspectionFacade;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Long partId;

    @BeforeEach
    void setUpData() {
        jdbcTemplate.update(
                "INSERT INTO tb_part_category (company_id, category_name, created_by) VALUES (1, 'GPU', 7)"
        );
        Long categoryId = jdbcTemplate.queryForObject(
                "SELECT category_id FROM tb_part_category WHERE company_id = 1",
                Long.class
        );
        jdbcTemplate.update(
                "INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1, ?, 7, 'RTX 4060', 'Dual', 'ASUS', 'GPU-4060', 0, TRUE)",
                categoryId
        );
        partId = jdbcTemplate.queryForObject(
                "SELECT part_id FROM tb_pc_part WHERE company_id = 1",
                Long.class
        );
    }

    @Test
    void createInitialInspection_persistsHistoryAndUpdatesUnitState() {
        List<Long> unitIds = createInboundUnits(1);

        var response = inspectionFacade.createInitialInspection(
                principal(),
                "acme",
                new CreateInspectionRequest(
                        unitIds.get(0), null, InspectionResult.PASS, PartGrade.A,
                        SalesStatus.AVAILABLE, "정상", List.of()
                )
        );

        assertThat(response.savedCount()).isEqualTo(1);
        assertThat(count("tb_inspection")).isEqualTo(1);
        assertThat(count("tb_part_status_history")).isEqualTo(1);
        assertThat(jdbcTemplate.queryForMap(
                "SELECT inspection_status, grade, sales_status FROM tb_pc_part_unit WHERE unit_id = ?",
                unitIds.get(0)
        )).containsEntry("inspection_status", "COMPLETED")
                .containsEntry("grade", "A")
                .containsEntry("sales_status", "AVAILABLE");
    }

    @Test
    void createBulkInspection_rollsBackAllUnitsWhenOneUnitIsInvalid() {
        List<Long> unitIds = createInboundUnits(2);
        var request = new CreateBulkInspectionRequest(
                List.of(unitIds.get(0), 99999L),
                null,
                InspectionResult.PASS,
                PartGrade.B,
                SalesStatus.AVAILABLE,
                null,
                List.of()
        );

        assertThatThrownBy(() -> inspectionFacade.createBulkInitialInspection(principal(), "acme", request))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PART_UNIT_NOT_FOUND);

        assertThat(count("tb_inspection")).isZero();
        assertThat(count("tb_part_status_history")).isZero();
        assertThat(jdbcTemplate.queryForList(
                "SELECT inspection_status FROM tb_pc_part_unit ORDER BY unit_id",
                String.class
        )).containsOnly("WAITING");
    }

    private List<Long> createInboundUnits(int quantity) {
        stockFacade.createInboundDocument(
                principal(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L,
                        "검수 대상",
                        List.of(new CreateInboundDocumentLineRequest(partId, quantity, null))
                )
        );
        return jdbcTemplate.queryForList("SELECT unit_id FROM tb_pc_part_unit ORDER BY unit_id", Long.class);
    }

    private int count(String table) {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM " + table, Integer.class);
    }

    private PcsPrincipal principal() {
        return new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.OWNER, Instant.now().plusSeconds(600));
    }
}
