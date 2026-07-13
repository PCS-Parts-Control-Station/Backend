package com.pcs.domain.stock.facade;

import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateOutboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchOutboundCandidateResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailResponse;
import com.pcs.domain.stock.service.StockService;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class StockFacade {

    private final StockService stockService;
    private final WorkspaceAccessValidator workspaceAccessValidator;
    private final StaffPermissionService staffPermissionService;

    public StockFacade(
            StockService stockService,
            WorkspaceAccessValidator workspaceAccessValidator,
            StaffPermissionService staffPermissionService
    ) {
        this.stockService = stockService;
        this.workspaceAccessValidator = workspaceAccessValidator;
        this.staffPermissionService = staffPermissionService;
    }

    public PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> searchDocuments(
            PcsPrincipal principal,
            String pathCompanyCode,
            StockDocumentType documentType,
            String keyword,
            Long partnerId,
            StockDocumentStatus documentStatus,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return stockService.searchDocuments(
                checkedPrincipal.companyId(),
                documentType,
                keyword,
                partnerId,
                documentStatus,
                dateFrom,
                dateTo,
                page,
                size,
                limit
        );
    }

    public PageResultDto<SearchOutboundCandidateResponse, Void> searchOutboundCandidates(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long categoryId,
            Long partId,
            PartGrade grade,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return stockService.searchOutboundCandidates(
                checkedPrincipal.companyId(),
                keyword,
                categoryId,
                partId,
                grade,
                page,
                size,
                limit
        );
    }

    public StockDocumentDetailResponse getDocument(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long documentId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return stockService.getDocument(checkedPrincipal.companyId(), documentId);
    }

    @Transactional
    public CancelStockDocumentResponse cancelDocument(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long documentId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        validateCancelPermission(checkedPrincipal, stockService.getDocument(checkedPrincipal.companyId(), documentId));
        return stockService.cancelDocument(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                documentId
        );
    }

    private void validateCancelPermission(PcsPrincipal principal, StockDocumentDetailResponse document) {
        if (principal.role() != MemberRole.STAFF) {
            return;
        }
        StaffPermission required = document.documentType() == StockDocumentType.OUTBOUND
                ? StaffPermission.STAFF_OUTBOUND
                : StaffPermission.STAFF_INBOUND;
        if (!staffPermissionService.isEnabled(principal.companyId(), required)) {
            throw new BusinessException(ErrorCode.AUTH_STAFF_PERMISSION_DENIED);
        }
    }

    @Transactional
    public CreateInboundDocumentResponse createInboundDocument(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateInboundDocumentRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);

        return stockService.createInboundDocument(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                request
        );
    }

    @Transactional
    public CreateOutboundDocumentResponse createOutboundDocument(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateOutboundDocumentRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);

        return stockService.createOutboundDocument(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                request
        );
    }

}
