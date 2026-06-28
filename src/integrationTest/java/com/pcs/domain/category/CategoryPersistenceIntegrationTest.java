package com.pcs.domain.category;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.category.dto.request.CategorySpecDefinitionRequest;
import com.pcs.domain.category.dto.request.CategorySpecOptionRequest;
import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.entity.PartSpecDefinition;
import com.pcs.domain.category.entity.PartSpecOption;
import com.pcs.domain.category.mapper.CategoryMapper;
import com.pcs.domain.category.mapper.PartSpecMapper;
import com.pcs.domain.category.service.CategoryService;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.support.MariaDbIntegrationTest;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.jdbc.Sql;

@Sql(scripts = "/pcs-category-part-test-schema.sql")
class CategoryPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private CategoryService categoryService;
    @Autowired
    private CategoryMapper categoryMapper;
    @Autowired
    private PartSpecMapper partSpecMapper;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void createCategory_persistsSpecDefinitionsAndOptionsInOrder() {
        var response = categoryService.createCategory(
                1L,
                new CreateCategoryRequest(
                        "GPU",
                        "Graphic cards",
                        List.of(
                                new CategorySpecDefinitionRequest(null, "GPU Chip", "SELECT", null, true, true, 2, List.of(
                                        new CategorySpecOptionRequest("RTX 3060", "RTX_3060", 2),
                                        new CategorySpecOptionRequest("RTX 4060", "RTX_4060", 1)
                                )),
                                new CategorySpecDefinitionRequest("memory_gb", "Memory", "NUMBER", "GB", true, true, 1, List.of())
                        )
                ),
                7L
        );

        var definitions = partSpecMapper.findDefinitionsByCategory(1L, response.categoryId());
        var options = partSpecMapper.findOptionsByDefinitionIds(
                definitions.stream().map(definition -> definition.specDefinitionId()).toList()
        );

        assertThat(response.categoryName()).isEqualTo("GPU");
        assertThat(definitions).extracting("specKey").containsExactly("memory_gb", "spec_1");
        assertThat(options).extracting("optionValue").containsExactly("RTX_4060", "RTX_3060");
    }

    @Test
    void categoryNameUniqueConstraintAppliesPerCompanyOnly() {
        PartCategory first = new PartCategory(1L, "RAM", "Memory", 7L);
        PartCategory duplicate = new PartCategory(1L, "RAM", "Duplicated", 7L);
        PartCategory otherCompany = new PartCategory(2L, "RAM", "Other", 7L);

        categoryMapper.insert(first);

        assertThatThrownBy(() -> categoryMapper.insert(duplicate))
                .isInstanceOf(DuplicateKeyException.class);

        categoryMapper.insert(otherCompany);
        assertThat(otherCompany.getCategoryId()).isNotNull();
    }

    @Test
    void searchCategories_countsOnlyPartsInSameCompanyAndCategory() {
        PartCategory gpu = new PartCategory(1L, "GPU", "Graphic cards", 7L);
        PartCategory gpuOtherCompany = new PartCategory(2L, "GPU", "Other", 7L);
        categoryMapper.insert(gpu);
        categoryMapper.insert(gpuOtherCompany);

        jdbcTemplate.update(
                "INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1, ?, 7, 'RTX 3060', 'RTX 3060', 'MSI', 'GPU-1', 2, TRUE)",
                gpu.getCategoryId()
        );
        jdbcTemplate.update(
                "INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (2, ?, 7, 'RTX 4060', 'RTX 4060', 'ASUS', 'GPU-2', 2, TRUE)",
                gpuOtherCompany.getCategoryId()
        );

        var page = categoryService.searchCategories(1L, "GPU", 0, 10, null);

        assertThat(page.content()).hasSize(1);
        assertThat(page.content().get(0).categoryName()).isEqualTo("GPU");
        assertThat(page.content().get(0).partCount()).isEqualTo(1L);
    }

    @Test
    void deleteCategory_removesSpecChildrenBeforeCategoryWhenNoPartsAreLinked() {
        PartCategory category = new PartCategory(1L, "SSD", "Storage", 7L);
        categoryMapper.insert(category);

        PartSpecDefinition definition = new PartSpecDefinition(
                1L,
                category.getCategoryId(),
                "capacity",
                "Capacity",
                "NUMBER",
                "GB",
                true,
                true,
                0,
                7L
        );
        categoryMapper.insertSpecDefinition(definition);
        PartSpecOption option = new PartSpecOption(definition.getSpecDefinitionId(), "1TB", "1TB", 0);
        categoryMapper.insertSpecOption(option);
        jdbcTemplate.update(
                "INSERT INTO tb_part_spec_value (company_id, part_id, spec_definition_id, value_number) VALUES (1, 999, ?, 1000)",
                definition.getSpecDefinitionId()
        );

        categoryService.deleteCategory(1L, category.getCategoryId());

        assertThat(count("tb_part_spec_value")).isZero();
        assertThat(count("tb_part_spec_option")).isZero();
        assertThat(count("tb_part_spec_definition")).isZero();
        assertThat(count("tb_part_category")).isZero();
    }

    @Test
    void deleteCategory_failsWhenPartsAreLinked() {
        PartCategory category = new PartCategory(1L, "CPU", "Processors", 7L);
        categoryMapper.insert(category);
        jdbcTemplate.update(
                "INSERT INTO tb_pc_part (company_id, category_id, created_by, part_name, model_name, manufacturer, part_code, safe_quantity, active) VALUES (1, ?, 7, 'Ryzen 5', '5600', 'AMD', 'CPU-1', 1, TRUE)",
                category.getCategoryId()
        );

        assertThatThrownBy(() -> categoryService.deleteCategory(1L, category.getCategoryId()))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.CATEGORY_IN_USE);
    }

    private int count(String tableName) {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM " + tableName, Integer.class);
    }
}
