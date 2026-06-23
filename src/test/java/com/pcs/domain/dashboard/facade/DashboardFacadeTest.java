package com.pcs.domain.dashboard.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.dto.response.DashboardStockStatusResponse;
import com.pcs.domain.dashboard.dto.response.DashboardSummaryResponse;
import com.pcs.domain.dashboard.service.DashboardService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
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
    private JwtTokenProvider jwtTokenProvider;

    private DashboardFacade dashboardFacade;

    @BeforeEach
    void setUp() {
        dashboardFacade = new DashboardFacade(dashboardService, jwtTokenProvider);
    }

    @Test
    void getDashboard_success() {
        DashboardResponse expected = new DashboardResponse(
                new DashboardSummaryResponse(0L, 0L, 0L, 0L, 0L, 0L, 0L),
                List.of(),
                new DashboardStockStatusResponse(0L, 0L, 0L, 0, 0, 0),
                List.of()
        );

        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(dashboardService.getDashboard(1L)).thenReturn(expected);

        DashboardResponse response = dashboardFacade.getDashboard("Bearer token", "acme");

        assertSame(expected, response);
        verify(dashboardService).getDashboard(1L);
    }

    @Test
    void getDashboard_fail_whenAuthHeaderMissing() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> dashboardFacade.getDashboard(null, "acme")
        );

        assertEquals(ErrorCode.AUTH_REQUIRED, exception.getErrorCode());
    }

    @Test
    void getDashboard_fail_whenWorkspaceMismatch() {
        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> dashboardFacade.getDashboard("Bearer token", "other")
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    private JwtClaims claims(Long companyId, Long memberId, String companyCode) {
        return new JwtClaims(
                memberId,
                companyId,
                companyCode,
                "admin",
                MemberRole.ADMIN,
                "ACCESS",
                Instant.now().plusSeconds(1800)
        );
    }
}
