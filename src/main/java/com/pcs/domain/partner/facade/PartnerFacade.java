package com.pcs.domain.partner.facade;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.service.PartnerService;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PartnerFacade {

    private static final String TOKEN_TYPE = "Bearer";

    private final PartnerService partnerService;
    private final JwtTokenProvider jwtTokenProvider;

    public PartnerFacade(PartnerService partnerService, JwtTokenProvider jwtTokenProvider) {
        this.partnerService = partnerService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public List<SearchPartnerResponse> searchPartners(
            String authorizationHeader,
            String pathCompanyCode,
            String keyword,
            PartnerRole partnerRole,
            Boolean active,
            Integer limit
    ) {
        JwtClaims claims = jwtTokenProvider.parseAccessToken(extractBearerToken(authorizationHeader));
        validateWorkspace(pathCompanyCode, claims.companyCode());
        return partnerService.searchPartners(claims.companyId(), keyword, partnerRole, active, limit);
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
