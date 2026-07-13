package com.pcs.domain.dashboard.api;

import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.dto.response.DashboardStockStatusResponse;
import com.pcs.domain.dashboard.dto.response.DashboardSummaryResponse;
import com.pcs.domain.dashboard.facade.DashboardFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class DashboardApiControllerTest {

    @Mock
    private DashboardFacade dashboardFacade;

    private MockMvc mockMvc;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(new DashboardApiController(dashboardFacade))
                .setControllerAdvice(new GlobalExceptionHandler())
                .setCustomArgumentResolvers(new AuthenticationPrincipalArgumentResolver())
                .build();
        principal = new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.ADMIN, Instant.now().plusSeconds(600));
        SecurityContextHolder.getContext().setAuthentication(new TestingAuthenticationToken(principal, null));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void getDashboard_returnsOperationalSummary() throws Exception {
        DashboardResponse response = new DashboardResponse(
                new DashboardSummaryResponse(3L, 2L, 4L, 5L, 1L, 1L, 1L),
                List.of(),
                new DashboardStockStatusResponse(5L, 1L, 1L, 71, 14, 14),
                List.of()
        );
        when(dashboardFacade.getDashboard(principal, "acme")).thenReturn(response);

        mockMvc.perform(get("/api/workspaces/acme/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.summary.todayInboundQuantity").value(3))
                .andExpect(jsonPath("$.data.summary.waitingInspectionQuantity").value(4))
                .andExpect(jsonPath("$.data.stockStatus.availableRatio").value(71));

        verify(dashboardFacade).getDashboard(principal, "acme");
    }

    @Test
    void getDashboard_returnsWorkspaceMismatchError() throws Exception {
        doThrow(new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH))
                .when(dashboardFacade).getDashboard(principal, "other");

        mockMvc.perform(get("/api/workspaces/other/dashboard"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("AUTH-006"));
    }
}
