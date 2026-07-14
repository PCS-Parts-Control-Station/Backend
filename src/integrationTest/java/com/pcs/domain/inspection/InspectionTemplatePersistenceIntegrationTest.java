package com.pcs.domain.inspection;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.request.SaveInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.SaveInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.facade.InspectionTemplateFacade;
import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import com.pcs.domain.member.type.MemberRole;
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
class InspectionTemplatePersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private InspectionTemplateFacade inspectionTemplateFacade;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Long categoryId;

    @BeforeEach
    void setUpData() {
        jdbcTemplate.update(
                "INSERT INTO tb_part_category (company_id, category_name, created_by) VALUES (1, 'SSD', 7)"
        );
        categoryId = jdbcTemplate.queryForObject("SELECT category_id FROM tb_part_category WHERE company_id = 1", Long.class);
    }

    @Test
    void createTemplate_persistsNestedItemsAndOptionsInOneTransaction() {
        var option = new SaveInspectionTemplateOptionRequest(null, "정상", "PASS", 10, true);
        var item = new SaveInspectionTemplateItemRequest(
                null,
                "외관 상태",
                InspectionItemGroup.BASIC,
                InspectionInputType.SELECT,
                true,
                10,
                GradeImpact.HIGH,
                InspectionFailPolicy.MARK_DEFECTIVE,
                true,
                List.of(option)
        );

        var response = inspectionTemplateFacade.createTemplate(
                principal(),
                "acme",
                new CreateInspectionTemplateRequest(categoryId, "SSD 기본 검수", 1, true, List.of(item))
        );

        assertThat(response.items()).hasSize(1);
        assertThat(response.items().get(0).options()).hasSize(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM tb_inspection_template", Integer.class)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM tb_inspection_template_item", Integer.class)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM tb_inspection_template_item_option", Integer.class)).isEqualTo(1);
    }

    @Test
    void templateVersionConstraint_rejectsNonPositiveVersion() {
        assertThatThrownBy(() -> jdbcTemplate.update(
                "INSERT INTO tb_inspection_template (company_id, category_id, template_name, version, active, created_by) VALUES (1, ?, 'Invalid', 0, TRUE, 7)",
                categoryId
        )).isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void templateItemNameConstraint_rejectsDuplicateNameInSameTemplate() {
        Long templateId = insertTemplate();
        insertItem(templateId, "외관 상태");

        assertThatThrownBy(() -> insertItem(templateId, "외관 상태"))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void templateOptionLabelConstraint_rejectsDuplicateLabelInSameItem() {
        Long templateId = insertTemplate();
        Long itemId = insertItem(templateId, "외관 상태");
        jdbcTemplate.update(
                "INSERT INTO tb_inspection_template_item_option "
                        + "(item_id, option_label, option_value, sort_order, active) VALUES (?, '정상', 'PASS', 10, TRUE)",
                itemId
        );

        assertThatThrownBy(() -> jdbcTemplate.update(
                "INSERT INTO tb_inspection_template_item_option "
                        + "(item_id, option_label, option_value, sort_order, active) VALUES (?, '정상', 'WARN', 20, TRUE)",
                itemId
        )).isInstanceOf(DataIntegrityViolationException.class);
    }

    private Long insertTemplate() {
        jdbcTemplate.update(
                "INSERT INTO tb_inspection_template "
                        + "(company_id, category_id, template_name, version, active, created_by) "
                        + "VALUES (1, ?, '직접 입력 템플릿', 1, TRUE, 7)",
                categoryId
        );
        return jdbcTemplate.queryForObject(
                "SELECT template_id FROM tb_inspection_template WHERE company_id = 1",
                Long.class
        );
    }

    private Long insertItem(Long templateId, String itemName) {
        jdbcTemplate.update(
                "INSERT INTO tb_inspection_template_item "
                        + "(template_id, item_group, item_name, input_type, required, sort_order, grade_impact, fail_policy, active) "
                        + "VALUES (?, 'BASIC', ?, 'SELECT', TRUE, 10, 'LOW', 'NONE', TRUE)",
                templateId,
                itemName
        );
        return jdbcTemplate.queryForObject(
                "SELECT item_id FROM tb_inspection_template_item WHERE template_id = ? AND item_name = ?",
                Long.class,
                templateId,
                itemName
        );
    }

    private PcsPrincipal principal() {
        return new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.OWNER, Instant.now().plusSeconds(600));
    }
}
