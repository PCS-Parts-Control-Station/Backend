package com.pcs.domain.category.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.category.dto.request.CategorySpecDefinitionRequest;
import com.pcs.domain.category.dto.request.CategorySpecOptionRequest;
import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.CategoryDetailResponse;
import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.entity.PartSpecDefinition;
import com.pcs.domain.category.entity.PartSpecOption;
import com.pcs.domain.category.mapper.CategoryMapper;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock
    private CategoryMapper categoryMapper;

    private CategoryService categoryService;

    @BeforeEach
    void setUp() {
        categoryService = new CategoryService(categoryMapper);
    }

    @Test
    void searchCategories_usesKeywordPagingAndIncludesPartCount() {
        Long companyId = 1L;
        SearchCategoryResponse category = new SearchCategoryResponse(
                10L,
                "GPU",
                "그래픽카드",
                3L,
                LocalDateTime.of(2026, 6, 4, 10, 0)
        );

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.countCategories(companyId, "GPU")).thenReturn(1L);
        when(categoryMapper.searchCategories(companyId, "GPU", 10, 20))
                .thenReturn(List.of(category));

        PageResultDto<SearchCategoryResponse, Void> response = categoryService.searchCategories(
                companyId,
                " GPU ",
                2,
                10,
                null
        );

        assertEquals(1, response.content().size());
        assertEquals(3L, response.content().get(0).partCount());
        assertEquals(2, response.page());
        assertEquals(10, response.size());
        assertEquals(1, response.totalElements());
        verify(categoryMapper).searchCategories(companyId, "GPU", 10, 20);
    }

    @Test
    void searchCategories_usesLimitAsSizeAliasAndCapsToMax() {
        Long companyId = 1L;

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.countCategories(companyId, null)).thenReturn(0L);

        PageResultDto<SearchCategoryResponse, Void> response = categoryService.searchCategories(
                companyId,
                " ",
                null,
                null,
                500
        );

        assertEquals(0, response.page());
        assertEquals(100, response.size());
        assertTrue(response.content().isEmpty());
        verify(categoryMapper, never()).searchCategories(companyId, null, 100, 0);
    }

    @Test
    void searchCategories_failsWhenCompanyInactive() {
        Long companyId = 1L;
        when(categoryMapper.isCompanyActive(companyId)).thenReturn(false);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> categoryService.searchCategories(companyId, null, 0, 10, null)
        );

        assertEquals(ErrorCode.COMPANY_INACTIVE, exception.getErrorCode());
    }

    @Test
    void createCategory_savesSpecDefinitionsAndSelectOptions() {
        Long companyId = 1L;
        Long memberId = 7L;
        CreateCategoryRequest request = new CreateCategoryRequest(
                "RAM",
                "메모리",
                List.of(
                        new CategorySpecDefinitionRequest(null, "용량", "NUMBER", "GB", true, true, 0, List.of()),
                        new CategorySpecDefinitionRequest(
                                null,
                                "세대",
                                "SELECT",
                                null,
                                false,
                                true,
                                1,
                                List.of(
                                        new CategorySpecOptionRequest("DDR4", "DDR4", 0),
                                        new CategorySpecOptionRequest("DDR5", "DDR5", 1)
                                )
                        )
                )
        );

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.existsByName(companyId, "RAM", null)).thenReturn(false);
        doAnswer(invocation -> {
            PartCategory category = invocation.getArgument(0);
            category.setCategoryId(10L);
            return null;
        }).when(categoryMapper).insert(any(PartCategory.class));
        doAnswer(invocation -> {
            PartSpecDefinition specDefinition = invocation.getArgument(0);
            specDefinition.setSpecDefinitionId("세대".equals(specDefinition.getSpecName()) ? 102L : 101L);
            return null;
        }).when(categoryMapper).insertSpecDefinition(any(PartSpecDefinition.class));

        when(categoryMapper.findResponseById(companyId, 10L)).thenReturn(new SearchCategoryResponse(
                10L,
                "RAM",
                "메모리",
                0L,
                LocalDateTime.of(2026, 6, 5, 10, 0)
        ));
        when(categoryMapper.findSpecDefinitions(companyId, 10L)).thenReturn(List.of(
                new CategorySpecDefinitionRow(101L, 10L, "spec_1", "용량", "NUMBER", "GB", true, true, 0, true),
                new CategorySpecDefinitionRow(102L, 10L, "spec_2", "세대", "SELECT", null, false, true, 1, true)
        ));
        when(categoryMapper.findSpecOptions(List.of(101L, 102L))).thenReturn(List.of(
                new CategorySpecOptionResponse(201L, 102L, "DDR4", "DDR4", 0, true),
                new CategorySpecOptionResponse(202L, 102L, "DDR5", "DDR5", 1, true)
        ));

        CategoryDetailResponse response = categoryService.createCategory(companyId, request, memberId);

        assertEquals(10L, response.categoryId());
        assertEquals(2, response.specDefinitions().size());
        assertEquals("용량", response.specDefinitions().get(0).specName());
        assertEquals(2, response.specDefinitions().get(1).options().size());
        verify(categoryMapper, times(2)).insertSpecDefinition(any(PartSpecDefinition.class));
        verify(categoryMapper, times(2)).insertSpecOption(any(PartSpecOption.class));
    }

    @Test
    void updateCategory_updatesNameAndDescriptionWhenSpecDefinitionsAreOmitted() {
        Long companyId = 1L;
        Long categoryId = 10L;
        Long memberId = 7L;
        PartCategory category = new PartCategory();
        category.setCompanyId(companyId);
        category.setCategoryId(categoryId);
        category.setCategoryName("RAM");
        category.setDescription("메모리");
        UpdateCategoryRequest request = new UpdateCategoryRequest("Memory", "메모리 부품", null);

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.findById(companyId, categoryId)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(companyId, categoryId)).thenReturn(3L);
        when(categoryMapper.existsByName(companyId, "Memory", categoryId)).thenReturn(false);
        when(categoryMapper.findResponseById(companyId, categoryId)).thenReturn(new SearchCategoryResponse(
                categoryId,
                "Memory",
                "메모리 부품",
                3L,
                LocalDateTime.of(2026, 6, 5, 11, 0)
        ));
        when(categoryMapper.findSpecDefinitions(companyId, categoryId)).thenReturn(List.of());

        CategoryDetailResponse response = categoryService.updateCategory(companyId, categoryId, request, memberId);

        assertEquals("Memory", response.categoryName());
        assertEquals("메모리 부품", response.description());
        verify(categoryMapper).update(category);
        verify(categoryMapper, never()).deleteSpecValuesByCategory(companyId, categoryId);
        verify(categoryMapper, never()).deleteSpecOptionsByCategory(companyId, categoryId);
        verify(categoryMapper, never()).deleteSpecDefinitionsByCategory(companyId, categoryId);
    }

    @Test
    void updateCategory_replacesSpecDefinitionsWhenNoLinkedParts() {
        Long companyId = 1L;
        Long categoryId = 10L;
        Long memberId = 7L;
        PartCategory category = new PartCategory();
        category.setCompanyId(companyId);
        category.setCategoryId(categoryId);
        category.setCategoryName("RAM");
        UpdateCategoryRequest request = new UpdateCategoryRequest(
                "RAM",
                "메모리",
                List.of(new CategorySpecDefinitionRequest(null, "클럭", "NUMBER", "MHz", false, true, 0, List.of()))
        );

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.findById(companyId, categoryId)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(companyId, categoryId)).thenReturn(0L);
        when(categoryMapper.existsByName(companyId, "RAM", categoryId)).thenReturn(false);
        doAnswer(invocation -> {
            PartSpecDefinition specDefinition = invocation.getArgument(0);
            specDefinition.setSpecDefinitionId(301L);
            return null;
        }).when(categoryMapper).insertSpecDefinition(any(PartSpecDefinition.class));
        when(categoryMapper.findResponseById(companyId, categoryId)).thenReturn(new SearchCategoryResponse(
                categoryId,
                "RAM",
                "메모리",
                0L,
                LocalDateTime.of(2026, 6, 5, 12, 0)
        ));
        when(categoryMapper.findSpecDefinitions(companyId, categoryId)).thenReturn(List.of(
                new CategorySpecDefinitionRow(301L, categoryId, "spec_1", "클럭", "NUMBER", "MHz", false, true, 0, true)
        ));
        when(categoryMapper.findSpecOptions(List.of(301L))).thenReturn(List.of());

        CategoryDetailResponse response = categoryService.updateCategory(companyId, categoryId, request, memberId);

        assertEquals(1, response.specDefinitions().size());
        assertEquals("클럭", response.specDefinitions().get(0).specName());
        InOrder inOrder = inOrder(categoryMapper);
        inOrder.verify(categoryMapper).deleteSpecValuesByCategory(companyId, categoryId);
        inOrder.verify(categoryMapper).deleteSpecOptionsByCategory(companyId, categoryId);
        inOrder.verify(categoryMapper).deleteSpecDefinitionsByCategory(companyId, categoryId);
        verify(categoryMapper).insertSpecDefinition(any(PartSpecDefinition.class));
    }

    @Test
    void updateCategory_failsSpecReplaceWhenCategoryHasLinkedParts() {
        Long companyId = 1L;
        Long categoryId = 10L;
        Long memberId = 7L;
        PartCategory category = new PartCategory();
        category.setCompanyId(companyId);
        category.setCategoryId(categoryId);
        UpdateCategoryRequest request = new UpdateCategoryRequest(
                "RAM",
                "메모리",
                List.of(new CategorySpecDefinitionRequest(null, "클럭", "NUMBER", "MHz", false, true, 0, List.of()))
        );

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.findById(companyId, categoryId)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(companyId, categoryId)).thenReturn(2L);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> categoryService.updateCategory(companyId, categoryId, request, memberId)
        );

        assertEquals(ErrorCode.INVALID_INPUT_VALUE, exception.getErrorCode());
        verify(categoryMapper, never()).update(any(PartCategory.class));
        verify(categoryMapper, never()).deleteSpecValuesByCategory(companyId, categoryId);
        verify(categoryMapper, never()).deleteSpecDefinitionsByCategory(companyId, categoryId);
    }

    @Test
    void deleteCategory_deletesWhenNoLinkedParts() {
        Long companyId = 1L;
        Long categoryId = 10L;
        PartCategory category = new PartCategory();
        category.setCompanyId(companyId);
        category.setCategoryId(categoryId);

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.findById(companyId, categoryId)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(companyId, categoryId)).thenReturn(0L);

        categoryService.deleteCategory(companyId, categoryId);

        InOrder inOrder = inOrder(categoryMapper);
        inOrder.verify(categoryMapper).deleteSpecValuesByCategory(companyId, categoryId);
        inOrder.verify(categoryMapper).deleteSpecOptionsByCategory(companyId, categoryId);
        inOrder.verify(categoryMapper).deleteSpecDefinitionsByCategory(companyId, categoryId);
        inOrder.verify(categoryMapper).deleteById(companyId, categoryId);
    }

    @Test
    void deleteCategory_failsWhenCategoryHasLinkedParts() {
        Long companyId = 1L;
        Long categoryId = 10L;
        PartCategory category = new PartCategory();
        category.setCompanyId(companyId);
        category.setCategoryId(categoryId);

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.findById(companyId, categoryId)).thenReturn(category);
        when(categoryMapper.countPartsByCategory(companyId, categoryId)).thenReturn(2L);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> categoryService.deleteCategory(companyId, categoryId)
        );

        assertEquals(ErrorCode.CATEGORY_IN_USE, exception.getErrorCode());
        verify(categoryMapper, never()).deleteById(companyId, categoryId);
    }

    @Test
    void deleteCategory_failsWhenCategoryNotFound() {
        Long companyId = 1L;
        Long categoryId = 10L;

        when(categoryMapper.isCompanyActive(companyId)).thenReturn(true);
        when(categoryMapper.findById(companyId, categoryId)).thenReturn(null);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> categoryService.deleteCategory(companyId, categoryId)
        );

        assertEquals(ErrorCode.CATEGORY_NOT_FOUND, exception.getErrorCode());
        verify(categoryMapper, never()).deleteById(companyId, categoryId);
    }
}
