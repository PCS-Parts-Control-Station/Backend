package com.pcs.domain.inspection.facade;

import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.response.InspectionTemplateDetailResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateSummaryResponse;
import com.pcs.domain.inspection.service.InspectionTemplateService;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class InspectionTemplateFacade {

    private final InspectionTemplateService inspectionTemplateService;

    public InspectionTemplateFacade(InspectionTemplateService inspectionTemplateService) {
        this.inspectionTemplateService = inspectionTemplateService;
    }

    public PageResultDto<SearchInspectionTemplateResponse, SearchInspectionTemplateSummaryResponse> searchTemplates(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long categoryId,
            Boolean active,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.searchTemplates(
                principal.companyId(),
                keyword,
                categoryId,
                active,
                page,
                size,
                limit
        );
    }

    public InspectionTemplateDetailResponse getTemplate(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.getTemplate(principal.companyId(), templateId);
    }

    @Transactional
    public InspectionTemplateDetailResponse createTemplate(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateInspectionTemplateRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.createTemplate(principal.companyId(), principal.memberId(), request);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateTemplate(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            UpdateInspectionTemplateRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.updateTemplate(principal.companyId(), templateId, request);
    }

    @Transactional
    public void updateTemplateActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            boolean active
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        inspectionTemplateService.updateTemplateActive(principal.companyId(), templateId, active);
    }

    @Transactional
    public InspectionTemplateDetailResponse createItem(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            CreateInspectionTemplateItemRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.createItem(principal.companyId(), templateId, request);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateItem(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            UpdateInspectionTemplateItemRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.updateItem(principal.companyId(), templateId, itemId, request);
    }

    @Transactional
    public void updateItemActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            boolean active
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        inspectionTemplateService.updateItemActive(principal.companyId(), templateId, itemId, active);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateItemSortOrder(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            UpdateInspectionTemplateItemSortOrderRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.updateItemSortOrder(principal.companyId(), templateId, request);
    }

    @Transactional
    public InspectionTemplateDetailResponse createOption(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            CreateInspectionTemplateOptionRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.createOption(principal.companyId(), templateId, itemId, request);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateOption(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            Long optionId,
            UpdateInspectionTemplateOptionRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.updateOption(principal.companyId(), templateId, itemId, optionId, request);
    }

    @Transactional
    public void updateOptionActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            Long optionId,
            boolean active
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        inspectionTemplateService.updateOptionActive(principal.companyId(), templateId, itemId, optionId, active);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateOptionSortOrder(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            UpdateInspectionTemplateOptionSortOrderRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return inspectionTemplateService.updateOptionSortOrder(principal.companyId(), templateId, itemId, request);
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
