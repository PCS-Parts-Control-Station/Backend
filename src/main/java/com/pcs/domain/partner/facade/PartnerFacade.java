package com.pcs.domain.partner.facade;

import com.pcs.domain.partner.dto.request.CreatePartnerRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerActiveRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.service.PartnerService;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import org.springframework.stereotype.Component;

@Component
public class PartnerFacade {

    private final PartnerService partnerService;

    public PartnerFacade(PartnerService partnerService) {
        this.partnerService = partnerService;
    }

    public PageResultDto<SearchPartnerResponse, SearchPartnerSummaryResponse> searchPartners(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            PartnerType partnerType,
            PartnerRole partnerRole,
            Boolean active,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partnerService.searchPartners(
                principal.companyId(),
                keyword,
                partnerType,
                partnerRole,
                active,
                page,
                size,
                limit
        );
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

    public SearchPartnerResponse createPartner(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreatePartnerRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partnerService.createPartner(principal.companyId(), request, principal.memberId());
    }

    public SearchPartnerResponse getPartner(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partnerId
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partnerService.getPartner(principal.companyId(), partnerId);
    }

    public SearchPartnerResponse updatePartner(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partnerId,
            UpdatePartnerRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        return partnerService.updatePartner(principal.companyId(), partnerId, request);
    }

    public void updatePartnerActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partnerId,
            UpdatePartnerActiveRequest request
    ) {
        validateAuthenticated(principal);
        validateWorkspace(pathCompanyCode, principal.companyCode());
        partnerService.updatePartnerActive(principal.companyId(), partnerId, request.active());
    }
}
