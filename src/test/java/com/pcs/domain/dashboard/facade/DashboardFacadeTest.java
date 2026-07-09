package com.pcs.domain.dashboard.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.dto.response.DashboardStockStatusResponse;
import com.pcs.domain.dashboard.dto.response.DashboardSummaryResponse;
import com.pcs.domain.dashboard.service.DashboardService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class DashboardFacadeTest {

    @Mock
    private DashboardService dashboardService;

    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private DashboardFacade dashboardFacade;

    @BeforeEach
    void setUp() {
        dashboardFacade = new DashboardFacade(dashboardService, workspaceAccessValidator);
    }

    @Test
    void getDashboard_success() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        DashboardResponse expected = new DashboardResponse(
                new DashboardSummaryResponse(0L, 0L, 0L, 0L, 0L, 0L, 0L),
                List.of(),
                new DashboardStockStatusResponse(0L, 0L, 0L, 0, 0, 0),
                List.of()
        );

        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "acme")).thenReturn(principal);
        when(dashboardService.getDashboard(1L)).thenReturn(expected);

        DashboardResponse response = dashboardFacade.getDashboard(principal, "acme");

        assertSame(expected, response);
        verify(dashboardService).getDashboard(1L);
    }

    @Test
    void getDashboard_fail_whenAuthPrincipalMissing() {
        doThrow(new BusinessException(ErrorCode.AUTH_REQUIRED))
                .when(workspaceAccessValidator)
                .validateAuthenticatedWorkspace(null, "acme");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> dashboardFacade.getDashboard(null, "acme")
        );

        assertEquals(ErrorCode.AUTH_REQUIRED, exception.getErrorCode());
    }

    @Test
    void getDashboard_fail_whenWorkspaceMismatch() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        doThrow(new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH))
                .when(workspaceAccessValidator)
                .validateAuthenticatedWorkspace(principal, "other");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> dashboardFacade.getDashboard(principal, "other")
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    private PcsPrincipal principal(Long companyId, Long memberId, String companyCode) {
        return new PcsPrincipal(
                memberId,
                companyId,
                companyCode,
                "admin",
                MemberRole.ADMIN,
                Instant.now().plusSeconds(1800)
        );
    }
}
