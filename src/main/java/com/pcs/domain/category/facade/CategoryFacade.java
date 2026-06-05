package com.pcs.domain.category.facade;

import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.service.CategoryService;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import org.springframework.stereotype.Component;

@Component
public class CategoryFacade {

    private final CategoryService categoryService;

    public CategoryFacade(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    public PageResultDto<SearchCategoryResponse, Void> searchCategories(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return categoryService.searchCategories(
                principal.companyId(),
                keyword,
                page,
                size,
                limit
        );
    }

    public SearchCategoryResponse createCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateCategoryRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return categoryService.createCategory(principal.companyId(), request, principal.memberId());
    }

    public SearchCategoryResponse getCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long categoryId
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return categoryService.getCategory(principal.companyId(), categoryId);
    }

    public SearchCategoryResponse updateCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long categoryId,
            UpdateCategoryRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return categoryService.updateCategory(principal.companyId(), categoryId, request);
    }

    public void deleteCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long categoryId
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        categoryService.deleteCategory(principal.companyId(), categoryId);
    }

    private void validateAuthenticated(PcsPrincipal principal) {
        if (principal == null) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }
    }

    private void validateWorkspace(String pathCompanyCode, String tokenCompanyCode) {
        if (pathCompanyCode == null || pathCompanyCode.isBlank()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "업체 코드가 필요합니다.");
        }
        if (!tokenCompanyCode.equals(pathCompanyCode.trim().toLowerCase())) {
            throw new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH);
        }
    }
}
