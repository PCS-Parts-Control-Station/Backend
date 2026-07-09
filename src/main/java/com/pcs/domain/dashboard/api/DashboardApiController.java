package com.pcs.domain.dashboard.api;

import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.facade.DashboardFacade;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.security.PcsPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class DashboardApiController {

    private final DashboardFacade dashboardFacade;

    public DashboardApiController(DashboardFacade dashboardFacade) {
        this.dashboardFacade = dashboardFacade;
    }

    @GetMapping("/workspaces/{companyCode}/dashboard")
    public ResponseEntity<ApiResultDto<DashboardResponse>> getDashboard(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        DashboardResponse response = dashboardFacade.getDashboard(principal, companyCode);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }
}
