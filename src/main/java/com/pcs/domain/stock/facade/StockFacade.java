package com.pcs.domain.stock.facade;

import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.service.StockService;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
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
