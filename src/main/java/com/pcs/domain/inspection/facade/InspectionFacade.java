package com.pcs.domain.inspection.facade;

import com.pcs.domain.inspection.dto.request.CreateBulkInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.dto.response.CreateInspectionResponse;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailResponse;
import com.pcs.domain.inspection.dto.response.InspectionWaitingDocumentDetailResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentSummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.service.InspectionService;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class InspectionFacade {

    private final InspectionService inspectionService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public InspectionFacade(InspectionService inspectionService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.inspectionService = inspectionService;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchWaitingInspectionDocumentResponse, SearchWaitingInspectionDocumentSummaryResponse> searchWaitingDocuments(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long partnerId,
            String inspectionStatus,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.searchWaitingDocuments(
                checkedPrincipal.companyId(),
                keyword,
                partnerId,
                inspectionStatus,
                dateFrom,
                dateTo,
                page,
                size,
                limit
        );
    }

    public InspectionWaitingDocumentDetailResponse getWaitingDocumentUnits(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long documentId
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.getWaitingDocumentUnits(checkedPrincipal.companyId(), documentId);
    }

    @Transactional
    public CreateInspectionResponse createInitialInspection(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateInspectionRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.createInitialInspection(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                request
        );
    }

    @Transactional
    public CreateInspectionResponse createBulkInitialInspection(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateBulkInspectionRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.createBulkInitialInspection(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                request
        );
    }

    @Transactional
    public CreateInspectionResponse createCorrection(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long inspectionId,
            CreateInspectionRevisionRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.createCorrection(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                inspectionId,
                request
        );
    }

    @Transactional
    public CreateInspectionResponse createReinspection(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long inspectionId,
            CreateInspectionRevisionRequest request
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.createReinspection(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                inspectionId,
                request
        );
    }

    public PageResultDto<SearchInspectionHistoryResponse, SearchInspectionHistorySummaryResponse> searchHistories(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long documentId,
            Long unitId,
            Long partId,
            InspectionType inspectionType,
            InspectionResult result,
            PartGrade grade,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.searchHistories(
                checkedPrincipal.companyId(),
                keyword,
                documentId,
                unitId,
                partId,
                inspectionType,
                result,
                grade,
                dateFrom,
                dateTo,
                page,
                size,
                limit
        );
    }

    public PageResultDto<SearchInspectionHistoryDocumentResponse, SearchInspectionHistoryDocumentSummaryResponse> searchHistoryDocuments(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long partId,
            InspectionType inspectionType,
            InspectionResult result,
            PartGrade grade,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.searchHistoryDocuments(
                checkedPrincipal.companyId(),
                keyword,
                partId,
                inspectionType,
                result,
                grade,
                dateFrom,
                dateTo,
                page,
                size,
                limit
        );
    }

    public InspectionHistoryDetailResponse getHistoryDetail(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long inspectionId
    ) {
        PcsPrincipal checkedPrincipal = validatePrincipal(principal, pathCompanyCode);
        return inspectionService.getHistoryDetail(checkedPrincipal.companyId(), inspectionId);
    }

    private PcsPrincipal validatePrincipal(PcsPrincipal principal, String pathCompanyCode) {
        return workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
    }
}
