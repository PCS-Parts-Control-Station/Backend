package com.pcs.domain.stock;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.service.PartService;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
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
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = {"/pcs-category-part-test-schema.sql", "/pcs-operations-test-schema-extension.sql"})
class StockPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private StockFacade stockFacade;
    @Autowired
    private PartService partService;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Long partId;

    @BeforeEach
    void setUpData() {
        jdbcTemplate.update(
                "INSERT INTO tb_part_category (company_id, category_name, created_by) VALUES (1, 'Memory', 7)"
        );
        Long categoryId = jdbcTemplate.queryForObject("SELECT category_id FROM tb_part_category WHERE company_id = 1", Long.class);
        jdbcTemplate.update(
                "INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1, ?, 7, 'DDR4 RAM', '16GB', 'Samsung', 'RAM-DDR4', 0, TRUE)",
                categoryId
        );
        partId = jdbcTemplate.queryForObject("SELECT part_id FROM tb_pc_part WHERE company_id = 1", Long.class);
    }

    @Test
    void createInbound_persistsDocumentMovementsUnitsAndStockAtomically() {
        var response = stockFacade.createInboundDocument(
                principal(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L,
                        "신규 입고",
                        List.of(new CreateInboundDocumentLineRequest(partId, 2, "RAM 2개"))
                )
        );

        assertThat(response.totalQuantity()).isEqualTo(2);
        assertThat(response.createdUnitCount()).isEqualTo(2);
        assertThat(count("tb_stock_document")).isEqualTo(1);
        assertThat(count("tb_stock_movement")).isEqualTo(1);
        assertThat(count("tb_stock_movement_unit")).isEqualTo(2);
        assertThat(count("tb_pc_part_unit")).isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT quantity FROM tb_part_stock WHERE company_id = 1 AND part_id = ?",
                Integer.class,
                partId
        )).isEqualTo(2);
        assertThat(jdbcTemplate.queryForList(
                "SELECT inspection_status FROM tb_pc_part_unit ORDER BY unit_id",
                String.class
        )).containsOnly("WAITING");
    }

    @Test
    void createInbound_rollsBackEarlierLinesWhenLaterLineFails() {
        var request = new CreateInboundDocumentRequest(
                101L,
                "rollback",
                List.of(
                        new CreateInboundDocumentLineRequest(partId, 1, null),
                        new CreateInboundDocumentLineRequest(99999L, 1, null)
                )
        );

        assertThatThrownBy(() -> stockFacade.createInboundDocument(principal(), "acme", request))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PART_NOT_FOUND);

        assertThat(count("tb_stock_document")).isZero();
        assertThat(count("tb_stock_movement")).isZero();
        assertThat(count("tb_pc_part_unit")).isZero();
        assertThat(count("tb_part_stock")).isZero();
    }

    @Test
    void createOutbound_decrementsStockAndMovesSelectedUnits() {
        stockFacade.createInboundDocument(
                principal(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L, null, List.of(new CreateInboundDocumentLineRequest(partId, 2, null))
                )
        );
        List<Long> unitIds = jdbcTemplate.queryForList("SELECT unit_id FROM tb_pc_part_unit ORDER BY unit_id", Long.class);
        jdbcTemplate.update(
                "UPDATE tb_pc_part_unit SET inspection_status = 'COMPLETED', grade = 'A', sales_status = 'AVAILABLE' WHERE company_id = 1"
        );

        var response = stockFacade.createOutboundDocument(
                principal(),
                "acme",
                new CreateOutboundDocumentRequest(
                        102L,
                        "판매 출고",
                        List.of(new CreateOutboundDocumentLineRequest(partId, unitIds, null))
                )
        );

        assertThat(response.outboundUnitCount()).isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT quantity FROM tb_part_stock WHERE company_id = 1 AND part_id = ?",
                Integer.class,
                partId
        )).isZero();
        assertThat(jdbcTemplate.queryForList(
                "SELECT unit_status FROM tb_pc_part_unit ORDER BY unit_id",
                String.class
        )).containsOnly("OUTBOUND");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_stock_movement WHERE movement_type = 'OUTBOUND'",
                Integer.class
        )).isEqualTo(1);
    }

    @Test
    void cancelInbound_preservesReverseMovementAndCancelsUnits() {
        var inbound = stockFacade.createInboundDocument(
                principal(),
                "acme",
                new CreateInboundDocumentRequest(
                        101L, null, List.of(new CreateInboundDocumentLineRequest(partId, 1, null))
                )
        );

        var canceled = stockFacade.cancelDocument(principal(), "acme", inbound.documentId());

        assertThat(canceled.canceledUnitCount()).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject(
                "SELECT document_status FROM tb_stock_document WHERE document_id = ?",
                String.class,
                inbound.documentId()
        )).isEqualTo("CANCELED");
        assertThat(jdbcTemplate.queryForList(
                "SELECT movement_type FROM tb_stock_movement ORDER BY movement_id",
                String.class
        )).containsExactly("INBOUND", "INBOUND_CANCEL");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT unit_status FROM tb_pc_part_unit",
                String.class
        )).isEqualTo("CANCELED");
        assertThat(jdbcTemplate.queryForObject(
                "SELECT quantity FROM tb_part_stock WHERE company_id = 1 AND part_id = ?",
                Integer.class,
                partId
        )).isZero();

        var canceledUnits = partService.searchPartUnits(
                1L, null, partId, inbound.documentId(), null, "CANCELED", 0, 20, null
        );
        assertThat(canceledUnits.content()).hasSize(1);
        assertThat(canceledUnits.content().get(0).unitStatus().name()).isEqualTo("CANCELED");
        assertThat(canceledUnits.summary().totalCount()).isEqualTo(1);
    }

    @Test
    void partStockConstraint_rejectsNegativeQuantity() {
        assertThatThrownBy(() -> jdbcTemplate.update(
                "INSERT INTO tb_part_stock (company_id, part_id, quantity) VALUES (1, ?, -1)",
                partId
        )).isInstanceOf(DataIntegrityViolationException.class);
    }

    private int count(String table) {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM " + table, Integer.class);
    }

    private PcsPrincipal principal() {
        return new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.OWNER, Instant.now().plusSeconds(600));
    }
}
