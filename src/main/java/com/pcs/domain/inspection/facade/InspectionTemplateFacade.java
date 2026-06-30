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
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class InspectionTemplateFacade {

    private final InspectionTemplateService inspectionTemplateService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public InspectionTemplateFacade(
            InspectionTemplateService inspectionTemplateService,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.inspectionTemplateService = inspectionTemplateService;
        this.workspaceAccessValidator = workspaceAccessValidator;
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
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.searchTemplates(
                checkedPrincipal.companyId(),
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
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.getTemplate(checkedPrincipal.companyId(), templateId);
    }

    @Transactional
    public InspectionTemplateDetailResponse createTemplate(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateInspectionTemplateRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.createTemplate(checkedPrincipal.companyId(), checkedPrincipal.memberId(), request);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateTemplate(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            UpdateInspectionTemplateRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.updateTemplate(checkedPrincipal.companyId(), templateId, request);
    }

    @Transactional
    public void updateTemplateActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            boolean active
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        inspectionTemplateService.updateTemplateActive(checkedPrincipal.companyId(), templateId, active);
    }

    @Transactional
    public InspectionTemplateDetailResponse createItem(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            CreateInspectionTemplateItemRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.createItem(checkedPrincipal.companyId(), templateId, request);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateItem(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            UpdateInspectionTemplateItemRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.updateItem(checkedPrincipal.companyId(), templateId, itemId, request);
    }

    @Transactional
    public void updateItemActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            boolean active
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        inspectionTemplateService.updateItemActive(checkedPrincipal.companyId(), templateId, itemId, active);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateItemSortOrder(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            UpdateInspectionTemplateItemSortOrderRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.updateItemSortOrder(checkedPrincipal.companyId(), templateId, request);
    }

    @Transactional
    public InspectionTemplateDetailResponse createOption(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            CreateInspectionTemplateOptionRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.createOption(checkedPrincipal.companyId(), templateId, itemId, request);
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
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.updateOption(checkedPrincipal.companyId(), templateId, itemId, optionId, request);
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
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        inspectionTemplateService.updateOptionActive(checkedPrincipal.companyId(), templateId, itemId, optionId, active);
    }

    @Transactional
    public InspectionTemplateDetailResponse updateOptionSortOrder(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long templateId,
            Long itemId,
            UpdateInspectionTemplateOptionSortOrderRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionTemplateService.updateOptionSortOrder(checkedPrincipal.companyId(), templateId, itemId, request);
    }

    private PcsPrincipal validatePrincipal(PcsPrincipal principal, String pathCompanyCode) {
        return workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
    }
}
