package com.pcs.domain.category.service;

import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.mapper.CategoryMapper;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CategoryService {

    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 100;

    private final CategoryMapper categoryMapper;

    public CategoryService(CategoryMapper categoryMapper) {
        this.categoryMapper = categoryMapper;
    }

    public PageResultDto<SearchCategoryResponse, Void> searchCategories(
            Long companyId,
            String keyword,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);

        String normalizedKeyword = normalizeOptional(keyword);
        int normalizedPage = normalizePage(page);
        int normalizedSize = normalizeSize(size, limit);
        int offset = normalizedPage * normalizedSize;

        long totalElements = categoryMapper.countCategories(companyId, normalizedKeyword);
        List<SearchCategoryResponse> items = totalElements == 0
                ? List.of()
                : categoryMapper.searchCategories(companyId, normalizedKeyword, normalizedSize, offset);

        return PageResultDto.of(items, normalizedPage, normalizedSize, totalElements, null);
    }

    @Transactional
    public SearchCategoryResponse createCategory(Long companyId, CreateCategoryRequest request, Long memberId) {
        validateCompanyActive(companyId);
        String categoryName = normalizeRequired(request.categoryName());
        if (categoryMapper.existsByName(companyId, categoryName, null)) {
            throw new BusinessException(ErrorCode.CATEGORY_NAME_DUPLICATED);
        }

        PartCategory category = new PartCategory(
                companyId,
                categoryName,
                normalizeOptional(request.description()),
                memberId
        );
        categoryMapper.insert(category);

        return categoryMapper.findResponseById(companyId, category.getCategoryId());
    }

    public SearchCategoryResponse getCategory(Long companyId, Long categoryId) {
        validateCompanyActive(companyId);
        SearchCategoryResponse response = categoryMapper.findResponseById(companyId, categoryId);
        if (response == null) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }
        return response;
    }

    @Transactional
    public SearchCategoryResponse updateCategory(Long companyId, Long categoryId, UpdateCategoryRequest request) {
        validateCompanyActive(companyId);
        PartCategory category = categoryMapper.findById(companyId, categoryId);
        if (category == null) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }

        String categoryName = normalizeRequired(request.categoryName());
        if (categoryMapper.existsByName(companyId, categoryName, categoryId)) {
            throw new BusinessException(ErrorCode.CATEGORY_NAME_DUPLICATED);
        }

        category.setCategoryName(categoryName);
        category.setDescription(normalizeOptional(request.description()));
        categoryMapper.update(category);

        return categoryMapper.findResponseById(companyId, categoryId);
    }

    private void validateCompanyActive(Long companyId) {
        if (!categoryMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
    }

    private String normalizeRequired(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private int normalizePage(Integer page) {
        if (page == null || page < 0) {
            return 0;
        }
        return page;
    }

    private int normalizeSize(Integer size, Integer limit) {
        Integer requestedSize = size == null ? limit : size;
        if (requestedSize == null || requestedSize < 1) {
            return DEFAULT_SIZE;
        }
        return Math.min(requestedSize, MAX_SIZE);
    }
}
