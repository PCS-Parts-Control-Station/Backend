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
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.stereotype.Component;

@Component
public class PartnerFacade {

    private final PartnerService partnerService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public PartnerFacade(PartnerService partnerService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.partnerService = partnerService;
        this.workspaceAccessValidator = workspaceAccessValidator;
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
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partnerService.searchPartners(
                checkedPrincipal.companyId(),
                keyword,
                partnerType,
                partnerRole,
                active,
                page,
                size,
                limit
        );
    }

    public SearchPartnerResponse createPartner(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreatePartnerRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partnerService.createPartner(checkedPrincipal.companyId(), request, checkedPrincipal.memberId());
    }

    public SearchPartnerResponse getPartner(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partnerId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partnerService.getPartner(checkedPrincipal.companyId(), partnerId);
    }

    public SearchPartnerResponse updatePartner(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partnerId,
            UpdatePartnerRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partnerService.updatePartner(checkedPrincipal.companyId(), partnerId, request);
    }

    public void updatePartnerActive(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partnerId,
            UpdatePartnerActiveRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        partnerService.updatePartnerActive(checkedPrincipal.companyId(), partnerId, request.active());
    }
}
