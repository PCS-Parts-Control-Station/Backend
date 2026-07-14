package com.pcs.domain.category.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.category.dto.request.CategorySpecDefinitionRequest;
import com.pcs.domain.category.dto.request.CategorySpecOptionRequest;
import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.entity.PartSpecDefinition;
import com.pcs.domain.category.entity.PartSpecOption;
import com.pcs.domain.category.mapper.CategoryMapper;
import com.pcs.domain.category.mapper.PartSpecMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.IntStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    private static final Long COMPANY_ID = 1L;
    private static final Long MEMBER_ID = 7L;

    @Mock
    private CategoryMapper categoryMapper;
    @Mock
    private PartSpecMapper partSpecMapper;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private CategoryService categoryService;

    @BeforeEach
    void setUp() {
        categoryService = new CategoryService(categoryMapper, partSpecMapper, workspaceAccessValidator);
    }

    @Test
    void searchCategories_trimsKeywordAndUsesPageQuery() {
        SearchCategoryResponse category = categoryResponse(10L, "GPU", 3L);
        when(categoryMapper.countCategories(COMPANY_ID, "GPU")).thenReturn(1L);
        when(categoryMapper.searchCategories(COMPANY_ID, "GPU", 10, 20)).thenReturn(List.of(category));

        var response = categoryService.searchCategories(COMPANY_ID, " GPU ", 2, 10, null);

        assertThat(response.content()).containsExactly(category);
        assertThat(response.page()).isEqualTo(2);
        assertThat(response.size()).isEqualTo(10);
        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.content().get(0).partCount()).isEqualTo(3L);
        verify(categoryMapper).searchCategories(COMPANY_ID, "GPU", 10, 20);
    }

    @Test
    void searchCategories_usesLimitAsSizeAliasAndCapsToMaxSize() {
        when(categoryMapper.countCategories(COMPANY_ID, null)).thenReturn(0L);

        var response = categoryService.searchCategories(COMPANY_ID, " ", null, null, 500);

        assertThat(response.page()).isZero();
        assertThat(response.size()).isEqualTo(100);
        assertThat(response.content()).isEmpty();
        verify(categoryMapper, never()).searchCategories(eq(COMPANY_ID), isNull(), anyInt(), anyInt());
    }

    @Test
    void searchCategories_failsWhenCompanyInactive() {
        doThrow(new BusinessException(ErrorCode.COMPANY_INACTIVE))
                .when(workspaceAccessValidator).validateCompanyActive(COMPANY_ID);

        assertThatThrownBy(() -> categoryService.searchCategories(COMPANY_ID, null, 0, 10, null))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.COMPANY_INACTIVE);
    }

    @Test
    void createCategory_normalizesSpecKeysAndOptionValues() {
        CreateCategoryRequest request = new CreateCategoryRequest(
                "Memory",
                "Memory category",
                List.of(
                        new CategorySpecDefinitionRequest(null, "Capacity", "NUMBER", "GB", true, true, null, List.of()),
                        new CategorySpecDefinitionRequest(
                                " Memory Type ",
                                "Type",
                                "SELECT",
                                null,
                                false,
                                true,
                                5,
                                List.of(
                                        new CategorySpecOptionRequest("DDR4", null, null),
                                        new CategorySpecOptionRequest("DDR5", "DDR5_VALUE", 3)
                                )
                        )
                )
        );

        stubCategoryInsert(10L);
        stubSpecDefinitionInsert();
        stubCategoryDetail(10L);
        when(categoryMapper.existsByName(COMPANY_ID, "Memory", null)).thenReturn(false);

        categoryService.createCategory(COMPANY_ID, request, MEMBER_ID);

        ArgumentCaptor<PartSpecDefinition> definitionCaptor = ArgumentCaptor.forClass(PartSpecDefinition.class);
        ArgumentCaptor<PartSpecOption> optionCaptor = ArgumentCaptor.forClass(PartSpecOption.class);
        verify(categoryMapper, times(2)).insertSpecDefinition(definitionCaptor.capture());
        verify(categoryMapper, times(2)).insertSpecOption(optionCaptor.capture());

        assertThat(definitionCaptor.getAllValues())
                .extracting(PartSpecDefinition::getSpecKey)
                .containsExactly("spec_1", "memory_type");
        assertThat(definitionCaptor.getAllValues())
                .extracting(PartSpecDefinition::getSortOrder)
                .containsExactly(0, 5);
        assertThat(optionCaptor.getAllValues())
                .extracting(PartSpecOption::getOptionValue)
                .containsExactly("DDR4", "DDR5_VALUE");
        assertThat(optionCaptor.getAllValues())
                .extracting(PartSpecOption::getSortOrder)
                .containsExactly(0, 3);
    }

    @Test
    void createCategory_failsWhenCategoryNameDuplicated() {
        when(categoryMapper.existsByName(COMPANY_ID, "GPU", null)).thenReturn(true);

        CreateCategoryRequest request = new CreateCategoryRequest(" GPU ", null, List.of());

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.CATEGORY_NAME_DUPLICATED);
        verify(categoryMapper, never()).insert(any(PartCategory.class));
    }

    @Test
    void createCategory_failsWhenSpecNameDuplicated() {
        stubCategoryInsert(10L);
        when(categoryMapper.existsByName(COMPANY_ID, "GPU", null)).thenReturn(false);
        CreateCategoryRequest request = new CreateCategoryRequest(
                "GPU",
                null,
                List.of(
                        new CategorySpecDefinitionRequest(null, "Chip", "TEXT", null, true, true, 0, List.of()),
                        new CategorySpecDefinitionRequest(null, " chip ", "TEXT", null, true, true, 1, List.of())
                )
        );

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createCategory_failsWhenSpecKeyDuplicatedAfterNormalization() {
        stubCategoryInsert(10L);
        when(categoryMapper.existsByName(COMPANY_ID, "GPU", null)).thenReturn(false);
        CreateCategoryRequest request = new CreateCategoryRequest(
                "GPU",
                null,
                List.of(
                        new CategorySpecDefinitionRequest("Memory Clock", "Clock", "NUMBER", "MHz", false, true, 0, List.of()),
                        new CategorySpecDefinitionRequest("memory_clock", "Clock2", "NUMBER", "MHz", false, true, 1, List.of())
                )
        );

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createCategory_failsWhenSelectSpecHasNoOptions() {
        stubCategoryInsert(10L);
        when(categoryMapper.existsByName(COMPANY_ID, "RAM", null)).thenReturn(false);
        CreateCategoryRequest request = new CreateCategoryRequest(
                "RAM",
                null,
                List.of(new CategorySpecDefinitionRequest(null, "Type", "SELECT", null, true, true, 0, List.of()))
        );

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createCategory_failsWhenSortOrderIsNegative() {
        stubCategoryInsert(10L);
        when(categoryMapper.existsByName(COMPANY_ID, "RAM", null)).thenReturn(false);
        CreateCategoryRequest request = new CreateCategoryRequest(
                "RAM",
                null,
                List.of(new CategorySpecDefinitionRequest(null, "Capacity", "NUMBER", "GB", true, true, -1, List.of()))
        );

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createCategory_failsWhenSpecCountExceedsTwenty() {
        stubCategoryInsert(10L);
        when(categoryMapper.existsByName(COMPANY_ID, "GPU", null)).thenReturn(false);
        List<CategorySpecDefinitionRequest> definitions = IntStream.rangeClosed(1, 21)
                .mapToObj(index -> new CategorySpecDefinitionRequest(
                        "spec_" + index,
                        "Spec " + index,
                        "TEXT",
                        null,
                        false,
                        false,
                        index,
                        List.of()
                ))
                .toList();

        assertThatThrownBy(() -> categoryService.createCategory(
                COMPANY_ID,
                new CreateCategoryRequest("GPU", null, definitions),
                MEMBER_ID
        ))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        verify(categoryMapper, never()).insertSpecDefinition(any(PartSpecDefinition.class));
    }

    @Test
    void createCategory_failsWhenSelectOptionCountExceedsThirty() {
        stubCategoryInsert(10L);
        stubSpecDefinitionInsert();
        when(categoryMapper.existsByName(COMPANY_ID, "GPU", null)).thenReturn(false);
        List<CategorySpecOptionRequest> options = IntStream.rangeClosed(1, 31)
                .mapToObj(index -> new CategorySpecOptionRequest("Option " + index, "OPTION_" + index, index))
                .toList();
        CreateCategoryRequest request = new CreateCategoryRequest(
                "GPU",
                null,
                List.of(new CategorySpecDefinitionRequest(
                        "chip",
                        "Chip",
                        "SELECT",
                        null,
                        true,
                        true,
                        0,
                        options
                ))
        );

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        verify(categoryMapper, never()).insertSpecOption(any(PartSpecOption.class));
    }

    @Test
    void createCategory_failsWhenSelectOptionValueIsDuplicatedIgnoringCase() {
        stubCategoryInsert(10L);
        stubSpecDefinitionInsert();
        when(categoryMapper.existsByName(COMPANY_ID, "GPU", null)).thenReturn(false);
        CreateCategoryRequest request = new CreateCategoryRequest(
                "GPU",
                null,
                List.of(new CategorySpecDefinitionRequest(
                        "chip",
                        "Chip",
                        "SELECT",
                        null,
                        true,
                        true,
                        0,
                        List.of(
                                new CategorySpecOptionRequest("RTX 4060", "RTX_4060", 0),
                                new CategorySpecOptionRequest("RTX 4060 Duplicate", "rtx_4060", 1)
                        )
                ))
        );

        assertThatThrownBy(() -> categoryService.createCategory(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        verify(categoryMapper, times(1)).insertSpecOption(any(PartSpecOption.class));
    }

    @Test
    void updateCategory_updatesOnlyBaseFieldsWhenSpecDefinitionsAreOmitted() {
        PartCategory category = category(10L, "RAM");
        UpdateCategoryRequest request = new UpdateCategoryRequest("Memory", "Updated", null);
        when(categoryMapper.findById(COMPANY_ID, 10L)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(COMPANY_ID, 10L)).thenReturn(3L);
        when(categoryMapper.existsByName(COMPANY_ID, "Memory", 10L)).thenReturn(false);
        when(categoryMapper.findResponseById(COMPANY_ID, 10L)).thenReturn(categoryResponse(10L, "Memory", 3L));
        when(partSpecMapper.findDefinitionsByCategory(COMPANY_ID, 10L)).thenReturn(List.of());

        var response = categoryService.updateCategory(COMPANY_ID, 10L, request, MEMBER_ID);

        assertThat(response.categoryName()).isEqualTo("Memory");
        assertThat(category.getDescription()).isEqualTo("Updated");
        verify(categoryMapper).update(category);
        verify(categoryMapper, never()).deleteSpecValuesByCategory(COMPANY_ID, 10L);
        verify(categoryMapper, never()).deleteSpecDefinitionsByCategory(COMPANY_ID, 10L);
    }

    @Test
    void updateCategory_replacesSpecDefinitionsWhenNoPartsAreLinked() {
        PartCategory category = category(10L, "RAM");
        UpdateCategoryRequest request = new UpdateCategoryRequest(
                "RAM",
                "Updated",
                List.of(new CategorySpecDefinitionRequest(null, "Clock", "NUMBER", "MHz", false, true, 0, List.of()))
        );
        when(categoryMapper.findById(COMPANY_ID, 10L)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(COMPANY_ID, 10L)).thenReturn(0L);
        when(categoryMapper.existsByName(COMPANY_ID, "RAM", 10L)).thenReturn(false);
        stubSpecDefinitionInsert();
        stubCategoryDetail(10L);

        categoryService.updateCategory(COMPANY_ID, 10L, request, MEMBER_ID);

        InOrder inOrder = inOrder(categoryMapper);
        inOrder.verify(categoryMapper).deleteSpecValuesByCategory(COMPANY_ID, 10L);
        inOrder.verify(categoryMapper).deleteSpecOptionsByCategory(COMPANY_ID, 10L);
        inOrder.verify(categoryMapper).deleteSpecDefinitionsByCategory(COMPANY_ID, 10L);
        verify(categoryMapper).insertSpecDefinition(any(PartSpecDefinition.class));
    }

    @Test
    void updateCategory_failsSpecReplaceWhenPartsAreLinked() {
        when(categoryMapper.findById(COMPANY_ID, 10L)).thenReturn(category(10L, "RAM"));
        when(categoryMapper.countPartsByCategory(COMPANY_ID, 10L)).thenReturn(1L);
        UpdateCategoryRequest request = new UpdateCategoryRequest(
                "RAM",
                null,
                List.of(new CategorySpecDefinitionRequest(null, "Clock", "NUMBER", "MHz", false, true, 0, List.of()))
        );

        assertThatThrownBy(() -> categoryService.updateCategory(COMPANY_ID, 10L, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        verify(categoryMapper, never()).deleteSpecDefinitionsByCategory(COMPANY_ID, 10L);
    }

    @Test
    void deleteCategory_deletesChildRowsBeforeCategoryWhenNoPartsAreLinked() {
        when(categoryMapper.findById(COMPANY_ID, 10L)).thenReturn(category(10L, "RAM"));
        when(categoryMapper.countPartsByCategory(COMPANY_ID, 10L)).thenReturn(0L);

        categoryService.deleteCategory(COMPANY_ID, 10L);

        InOrder inOrder = inOrder(categoryMapper);
        inOrder.verify(categoryMapper).deleteSpecValuesByCategory(COMPANY_ID, 10L);
        inOrder.verify(categoryMapper).deleteSpecOptionsByCategory(COMPANY_ID, 10L);
        inOrder.verify(categoryMapper).deleteSpecDefinitionsByCategory(COMPANY_ID, 10L);
        inOrder.verify(categoryMapper).deleteById(COMPANY_ID, 10L);
    }

    @Test
    void deleteCategory_failsWhenPartsAreLinked() {
        when(categoryMapper.findById(COMPANY_ID, 10L)).thenReturn(category(10L, "RAM"));
        when(categoryMapper.countPartsByCategory(COMPANY_ID, 10L)).thenReturn(2L);

        assertThatThrownBy(() -> categoryService.deleteCategory(COMPANY_ID, 10L))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.CATEGORY_IN_USE);
        verify(categoryMapper, never()).deleteById(COMPANY_ID, 10L);
    }

    @Test
    void deleteCategory_failsWhenCategoryDoesNotExist() {
        when(categoryMapper.findById(COMPANY_ID, 10L)).thenReturn(null);

        assertThatThrownBy(() -> categoryService.deleteCategory(COMPANY_ID, 10L))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.CATEGORY_NOT_FOUND);
    }

    private void stubCategoryInsert(Long categoryId) {
        doAnswer(invocation -> {
            PartCategory category = invocation.getArgument(0);
            category.setCategoryId(categoryId);
            return null;
        }).when(categoryMapper).insert(any(PartCategory.class));
    }

    private void stubSpecDefinitionInsert() {
        AtomicLong sequence = new AtomicLong(100);
        doAnswer(invocation -> {
            PartSpecDefinition specDefinition = invocation.getArgument(0);
            specDefinition.setSpecDefinitionId(sequence.incrementAndGet());
            return null;
        }).when(categoryMapper).insertSpecDefinition(any(PartSpecDefinition.class));
    }

    private void stubCategoryDetail(Long categoryId) {
        when(categoryMapper.findResponseById(COMPANY_ID, categoryId)).thenReturn(categoryResponse(categoryId, "Memory", 0L));
        when(partSpecMapper.findDefinitionsByCategory(COMPANY_ID, categoryId)).thenReturn(List.of(
                definitionRow(101L, categoryId, "spec_1", "Capacity", "NUMBER"),
                definitionRow(102L, categoryId, "memory_type", "Type", "SELECT")
        ));
        when(partSpecMapper.findOptionsByDefinitionIds(List.of(101L, 102L))).thenReturn(List.of(
                new CategorySpecOptionResponse(201L, 102L, "DDR4", "DDR4", 0, true),
                new CategorySpecOptionResponse(202L, 102L, "DDR5", "DDR5_VALUE", 3, true)
        ));
    }

    private PartCategory category(Long categoryId, String name) {
        PartCategory category = new PartCategory();
        category.setCompanyId(COMPANY_ID);
        category.setCategoryId(categoryId);
        category.setCategoryName(name);
        return category;
    }

    private SearchCategoryResponse categoryResponse(Long categoryId, String name, Long partCount) {
        return new SearchCategoryResponse(
                categoryId,
                name,
                name + " description",
                partCount,
                LocalDateTime.of(2026, 6, 5, 10, 0)
        );
    }

    private CategorySpecDefinitionRow definitionRow(
            Long specDefinitionId,
            Long categoryId,
            String specKey,
            String specName,
            String inputType
    ) {
        return new CategorySpecDefinitionRow(
                specDefinitionId,
                categoryId,
                specKey,
                specName,
                inputType,
                null,
                true,
                true,
                0,
                true
        );
    }
}
