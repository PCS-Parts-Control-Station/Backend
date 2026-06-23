package com.pcs.domain.dashboard.api;

import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.facade.DashboardFacade;
import com.pcs.global.dto.ApiResultDto;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
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
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader
    ) {
        DashboardResponse response = dashboardFacade.getDashboard(authorizationHeader, companyCode);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }
}
