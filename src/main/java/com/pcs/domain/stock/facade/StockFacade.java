package com.pcs.domain.stock.facade;

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
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import java.time.LocalDate;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class StockFacade {

    private static final String TOKEN_TYPE = "Bearer";

    private final StockService stockService;
    private final JwtTokenProvider jwtTokenProvider;

    public StockFacade(StockService stockService, JwtTokenProvider jwtTokenProvider) {
        this.stockService = stockService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> searchDocuments(
            String authorizationHeader,
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
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return stockService.searchDocuments(
                claims.companyId(),
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
            String authorizationHeader,
            String pathCompanyCode,
            String keyword,
            Long categoryId,
            Long partId,
            PartGrade grade,
            Integer page,
            Integer size,
            Integer limit
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return stockService.searchOutboundCandidates(
                claims.companyId(),
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
            String authorizationHeader,
            String pathCompanyCode,
            Long documentId
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return stockService.getDocument(claims.companyId(), documentId);
    }

    @Transactional
    public CancelStockDocumentResponse cancelDocument(
            String authorizationHeader,
            String pathCompanyCode,
            Long documentId
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return stockService.cancelDocument(claims.companyId(), claims.memberId(), documentId);
    }

    @Transactional
    public CreateInboundDocumentResponse createInboundDocument(
            String authorizationHeader,
            String pathCompanyCode,
            CreateInboundDocumentRequest request
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());

        try {
            return stockService.createInboundDocument(claims.companyId(), claims.memberId(), request);
        } catch (DuplicateKeyException exception) {
            throw mapDuplicateKeyException(exception);
        }
    }

    @Transactional
    public CreateOutboundDocumentResponse createOutboundDocument(
            String authorizationHeader,
            String pathCompanyCode,
            CreateOutboundDocumentRequest request
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());

        try {
            return stockService.createOutboundDocument(claims.companyId(), claims.memberId(), request);
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

    private void validateWorkspace(String pathCompanyCode, String tokenCompanyCode) {
        if (pathCompanyCode == null || pathCompanyCode.isBlank()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "업체 코드가 필요합니다.");
        }
        if (!tokenCompanyCode.equals(pathCompanyCode.trim().toLowerCase())) {
            throw new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH);
        }
    }

    private String extractBearerToken(String authorizationHeader) {
        if (authorizationHeader == null || authorizationHeader.isBlank()) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }
        String prefix = TOKEN_TYPE + " ";
        if (!authorizationHeader.startsWith(prefix)) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
        return authorizationHeader.substring(prefix.length()).trim();
    }
}
