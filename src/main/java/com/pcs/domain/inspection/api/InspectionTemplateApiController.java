package com.pcs.domain.inspection.api;

import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateActiveRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemActiveRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionActiveRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.response.InspectionTemplateDetailResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateSummaryResponse;
import com.pcs.domain.inspection.facade.InspectionTemplateFacade;
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
public class InspectionTemplateApiController {

    private final InspectionTemplateFacade inspectionTemplateFacade;

    public InspectionTemplateApiController(InspectionTemplateFacade inspectionTemplateFacade) {
        this.inspectionTemplateFacade = inspectionTemplateFacade;
    }

    @GetMapping("/workspaces/{companyCode}/inspection-templates")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchInspectionTemplateResponse, SearchInspectionTemplateSummaryResponse>>> searchTemplates(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchInspectionTemplateResponse, SearchInspectionTemplateSummaryResponse> response =
                inspectionTemplateFacade.searchTemplates(
                        principal,
                        companyCode,
                        keyword,
                        categoryId,
                        active,
                        page,
                        size,
                        limit
                );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/inspection-templates")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> createTemplate(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateInspectionTemplateRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.createTemplate(principal, companyCode, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("검수 템플릿을 등록했습니다.", response));
    }

    @GetMapping("/workspaces/{companyCode}/inspection-templates/{templateId}")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> getTemplate(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.getTemplate(principal, companyCode, templateId);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> updateTemplate(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.updateTemplate(
                principal,
                companyCode,
                templateId,
                request
        );
        return ResponseEntity.ok(ApiResultDto.ok("검수 템플릿을 수정했습니다.", response));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/active")
    public ResponseEntity<ApiResultDto<Void>> updateTemplateActive(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateActiveRequest request
    ) {
        inspectionTemplateFacade.updateTemplateActive(principal, companyCode, templateId, request.active());
        return ResponseEntity.ok(ApiResultDto.ok("검수 템플릿 사용 여부를 변경했습니다.", null));
    }

    @PostMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> createItem(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateInspectionTemplateItemRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.createItem(
                principal,
                companyCode,
                templateId,
                request
        );
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("검수 항목을 추가했습니다.", response));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> updateItem(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @PathVariable Long itemId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateItemRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.updateItem(
                principal,
                companyCode,
                templateId,
                itemId,
                request
        );
        return ResponseEntity.ok(ApiResultDto.ok("검수 항목을 수정했습니다.", response));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/active")
    public ResponseEntity<ApiResultDto<Void>> updateItemActive(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @PathVariable Long itemId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateItemActiveRequest request
    ) {
        inspectionTemplateFacade.updateItemActive(principal, companyCode, templateId, itemId, request.active());
        return ResponseEntity.ok(ApiResultDto.ok("검수 항목 사용 여부를 변경했습니다.", null));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/sort-order")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> updateItemSortOrder(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateItemSortOrderRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.updateItemSortOrder(
                principal,
                companyCode,
                templateId,
                request
        );
        return ResponseEntity.ok(ApiResultDto.ok("검수 항목 순서를 저장했습니다.", response));
    }

    @PostMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> createOption(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @PathVariable Long itemId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateInspectionTemplateOptionRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.createOption(
                principal,
                companyCode,
                templateId,
                itemId,
                request
        );
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("검수 선택지를 추가했습니다.", response));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> updateOption(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @PathVariable Long itemId,
            @PathVariable Long optionId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateOptionRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.updateOption(
                principal,
                companyCode,
                templateId,
                itemId,
                optionId,
                request
        );
        return ResponseEntity.ok(ApiResultDto.ok("검수 선택지를 수정했습니다.", response));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}/active")
    public ResponseEntity<ApiResultDto<Void>> updateOptionActive(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @PathVariable Long itemId,
            @PathVariable Long optionId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateOptionActiveRequest request
    ) {
        inspectionTemplateFacade.updateOptionActive(
                principal,
                companyCode,
                templateId,
                itemId,
                optionId,
                request.active()
        );
        return ResponseEntity.ok(ApiResultDto.ok("검수 선택지 사용 여부를 변경했습니다.", null));
    }

    @PatchMapping("/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/sort-order")
    public ResponseEntity<ApiResultDto<InspectionTemplateDetailResponse>> updateOptionSortOrder(
            @PathVariable String companyCode,
            @PathVariable Long templateId,
            @PathVariable Long itemId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateInspectionTemplateOptionSortOrderRequest request
    ) {
        InspectionTemplateDetailResponse response = inspectionTemplateFacade.updateOptionSortOrder(
                principal,
                companyCode,
                templateId,
                itemId,
                request
        );
        return ResponseEntity.ok(ApiResultDto.ok("검수 선택지 순서를 저장했습니다.", response));
    }
}
