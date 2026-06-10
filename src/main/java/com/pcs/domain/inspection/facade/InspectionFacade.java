package com.pcs.domain.inspection.facade;

import com.pcs.domain.inspection.dto.request.CreateBulkInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.dto.response.CreateInspectionResponse;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailResponse;
import com.pcs.domain.inspection.dto.response.InspectionWaitingDocumentDetailResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.service.InspectionService;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import java.time.LocalDate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class InspectionFacade {

    private static final String TOKEN_TYPE = "Bearer";

    private final InspectionService inspectionService;
    private final JwtTokenProvider jwtTokenProvider;

    public InspectionFacade(InspectionService inspectionService, JwtTokenProvider jwtTokenProvider) {
        this.inspectionService = inspectionService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public PageResultDto<SearchWaitingInspectionDocumentResponse, SearchWaitingInspectionDocumentSummaryResponse> searchWaitingDocuments(
            String authorizationHeader,
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
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.searchWaitingDocuments(
                claims.companyId(),
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
            String authorizationHeader,
            String pathCompanyCode,
            Long documentId
    ) {
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.getWaitingDocumentUnits(claims.companyId(), documentId);
    }

    @Transactional
    public CreateInspectionResponse createInitialInspection(
            String authorizationHeader,
            String pathCompanyCode,
            CreateInspectionRequest request
    ) {
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.createInitialInspection(claims.companyId(), claims.memberId(), request);
    }

    @Transactional
    public CreateInspectionResponse createBulkInitialInspection(
            String authorizationHeader,
            String pathCompanyCode,
            CreateBulkInspectionRequest request
    ) {
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.createBulkInitialInspection(claims.companyId(), claims.memberId(), request);
    }

    @Transactional
    public CreateInspectionResponse createCorrection(
            String authorizationHeader,
            String pathCompanyCode,
            Long inspectionId,
            CreateInspectionRevisionRequest request
    ) {
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.createCorrection(claims.companyId(), claims.memberId(), inspectionId, request);
    }

    @Transactional
    public CreateInspectionResponse createReinspection(
            String authorizationHeader,
            String pathCompanyCode,
            Long inspectionId,
            CreateInspectionRevisionRequest request
    ) {
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.createReinspection(claims.companyId(), claims.memberId(), inspectionId, request);
    }

    public PageResultDto<SearchInspectionHistoryResponse, SearchInspectionHistorySummaryResponse> searchHistories(
            String authorizationHeader,
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
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.searchHistories(
                claims.companyId(),
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

    public InspectionHistoryDetailResponse getHistoryDetail(
            String authorizationHeader,
            String pathCompanyCode,
            Long inspectionId
    ) {
        JwtClaims claims = parseAndValidateWorkspace(authorizationHeader, pathCompanyCode);
        return inspectionService.getHistoryDetail(claims.companyId(), inspectionId);
    }

    private JwtClaims parseAndValidateWorkspace(String authorizationHeader, String pathCompanyCode) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return claims;
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
