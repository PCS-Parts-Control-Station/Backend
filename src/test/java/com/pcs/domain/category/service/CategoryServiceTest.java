package com.pcs.domain.category.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.mapper.CategoryMapper;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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

        verify(categoryMapper).deleteById(companyId, categoryId);
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
