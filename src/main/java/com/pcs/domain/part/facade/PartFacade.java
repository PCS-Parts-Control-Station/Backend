package com.pcs.domain.part.facade;

import com.pcs.domain.part.dto.request.CreatePartRequest;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.dto.response.PartDetailResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.service.PartService;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PartFacade {

    private final PartService partService;

    public PartFacade(PartService partService) {
        this.partService = partService;
    }

    public List<SearchPartResponse> searchParts(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long categoryId,
            Boolean active,
            Integer limit
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partService.searchParts(principal.companyId(), keyword, categoryId, active, limit);
    }

    public PartDetailResponse getPart(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partId
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partService.getPart(principal.companyId(), partId);
    }

    public PartDetailResponse createPart(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreatePartRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partService.createPart(principal.companyId(), request, principal.memberId());
    }

    public PartDetailResponse updatePart(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partId,
            UpdatePartRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partService.updatePart(principal.companyId(), partId, request);
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
