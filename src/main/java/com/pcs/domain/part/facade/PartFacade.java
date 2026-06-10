package com.pcs.domain.part.facade;

import com.pcs.domain.part.dto.request.CreatePartRequest;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.dto.response.PartDetailResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.service.PartService;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.stereotype.Component;

@Component
public class PartFacade {

    private final PartService partService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public PartFacade(PartService partService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.partService = partService;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchPartResponse, Void> searchParts(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            Long categoryId,
            Boolean active,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partService.searchParts(checkedPrincipal.companyId(), keyword, categoryId, active, page, size, limit);
    }

    public PartDetailResponse getPart(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partService.getPart(checkedPrincipal.companyId(), partId);
    }

    public PartDetailResponse createPart(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreatePartRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partService.createPart(checkedPrincipal.companyId(), request, checkedPrincipal.memberId());
    }

    public PartDetailResponse updatePart(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long partId,
            UpdatePartRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return partService.updatePart(checkedPrincipal.companyId(), partId, request);
    }
}
