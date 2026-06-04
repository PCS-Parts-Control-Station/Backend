package com.pcs.domain.category.api;

import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.facade.CategoryFacade;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class CategoryApiController {

    private final CategoryFacade categoryFacade;

    public CategoryApiController(CategoryFacade categoryFacade) {
        this.categoryFacade = categoryFacade;
    }

    @GetMapping("/workspaces/{companyCode}/categories")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchCategoryResponse, Void>>> searchCategories(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchCategoryResponse, Void> response = categoryFacade.searchCategories(
                principal,
                companyCode,
                keyword,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/categories")
    public ResponseEntity<ApiResultDto<SearchCategoryResponse>> createCategory(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateCategoryRequest request
    ) {
        SearchCategoryResponse response = categoryFacade.createCategory(principal, companyCode, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("카테고리 등록이 완료되었습니다.", response));
    }

    @GetMapping("/workspaces/{companyCode}/categories/{categoryId}")
    public ResponseEntity<ApiResultDto<SearchCategoryResponse>> getCategory(
            @PathVariable String companyCode,
            @PathVariable Long categoryId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        SearchCategoryResponse response = categoryFacade.getCategory(principal, companyCode, categoryId);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PatchMapping("/workspaces/{companyCode}/categories/{categoryId}")
    public ResponseEntity<ApiResultDto<SearchCategoryResponse>> updateCategory(
            @PathVariable String companyCode,
            @PathVariable Long categoryId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateCategoryRequest request
    ) {
        SearchCategoryResponse response = categoryFacade.updateCategory(principal, companyCode, categoryId, request);
        return ResponseEntity.ok(ApiResultDto.ok("카테고리 수정이 완료되었습니다.", response));
    }
}
