package com.pcs.domain.stock.facade;

import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
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
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class StockFacade {

    private final StockService stockService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public StockFacade(StockService stockService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.stockService = stockService;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> searchDocuments(
            PcsPrincipal principal,
            String pathCompanyCode,
            StockDocumentType documentType,
            String keyword,
            Long partnerId,
            StockDocumentStatus documentStatus,
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
        return stockService.cancelInboundDocument(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                documentId
        );
    }

    @Transactional
    public CreateInboundDocumentResponse createInboundDocument(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateInboundDocumentRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);

        try {
            return stockService.createInboundDocument(
                    checkedPrincipal.companyId(),
                    checkedPrincipal.memberId(),
                    request
            );
        } catch (DuplicateKeyException exception) {
            throw mapDuplicateKeyException(exception);
        }
    }

    private BusinessException mapDuplicateKeyException(DuplicateKeyException exception) {
        String message = exception.getMostSpecificCause().getMessage();
        if (message != null && (
                message.contains("uk_stock_document_document_no")
                        || message.contains("uk_stock_document_company_document_no")
        )) {
            return new BusinessException(ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED);
        }
        if (message != null && (
                message.contains("uk_pc_part_unit_internal_serial")
                        || message.contains("uk_pc_part_unit_manufacturer_serial")
        )) {
            return new BusinessException(ErrorCode.PART_UNIT_SERIAL_DUPLICATED);
        }
        return new BusinessException(ErrorCode.INTERNAL_SERVER_ERROR);
    }

}
