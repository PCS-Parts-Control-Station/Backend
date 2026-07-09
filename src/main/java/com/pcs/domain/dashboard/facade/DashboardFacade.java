package com.pcs.domain.dashboard.facade;

import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.service.DashboardService;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.stereotype.Component;

@Component
public class DashboardFacade {

    private final DashboardService dashboardService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public DashboardFacade(DashboardService dashboardService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.dashboardService = dashboardService;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public DashboardResponse getDashboard(PcsPrincipal principal, String pathCompanyCode) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(
                principal,
                pathCompanyCode
        );
        return dashboardService.getDashboard(checkedPrincipal.companyId());
    }
}
