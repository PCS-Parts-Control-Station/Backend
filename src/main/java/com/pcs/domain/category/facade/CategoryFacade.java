package com.pcs.domain.category.facade;

import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.CategoryDetailResponse;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.service.CategoryService;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.stereotype.Component;

@Component
public class CategoryFacade {

    private final CategoryService categoryService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public CategoryFacade(CategoryService categoryService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.categoryService = categoryService;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchCategoryResponse, Void> searchCategories(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return categoryService.searchCategories(
                checkedPrincipal.companyId(),
                keyword,
                page,
                size,
                limit
        );
    }

    public CategoryDetailResponse createCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateCategoryRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return categoryService.createCategory(checkedPrincipal.companyId(), request, checkedPrincipal.memberId());
    }

    public CategoryDetailResponse getCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long categoryId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return categoryService.getCategory(checkedPrincipal.companyId(), categoryId);
    }

    public CategoryDetailResponse updateCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long categoryId,
            UpdateCategoryRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return categoryService.updateCategory(checkedPrincipal.companyId(), categoryId, request, checkedPrincipal.memberId());
    }

    public void deleteCategory(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long categoryId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        categoryService.deleteCategory(checkedPrincipal.companyId(), categoryId);
    }
}
