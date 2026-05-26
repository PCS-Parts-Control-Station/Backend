package com.pcs.domain.part.facade;

import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.service.PartService;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PartFacade {

    private static final String TOKEN_TYPE = "Bearer";

    private final PartService partService;
    private final JwtTokenProvider jwtTokenProvider;

    public PartFacade(PartService partService, JwtTokenProvider jwtTokenProvider) {
        this.partService = partService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public List<SearchPartResponse> searchParts(
            String authorizationHeader,
            String pathCompanyCode,
            String keyword,
            Long categoryId,
            Boolean active,
            Integer limit
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return partService.searchParts(claims.companyId(), keyword, categoryId, active, limit);
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
