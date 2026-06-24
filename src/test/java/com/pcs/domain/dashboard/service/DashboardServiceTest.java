package com.pcs.domain.dashboard.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.dashboard.dto.response.DashboardRecentActivityResponse;
import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.dto.response.DashboardStockStatusResponse;
import com.pcs.domain.dashboard.dto.response.DashboardSummaryResponse;
import com.pcs.domain.dashboard.dto.response.DashboardTodoResponse;
import com.pcs.domain.dashboard.mapper.DashboardMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private DashboardMapper dashboardMapper;

    private DashboardService dashboardService;

    @BeforeEach
    void setUp() {
        dashboardService = new DashboardService(dashboardMapper);
    }

    @Test
    void getDashboard_success() {
        Long companyId = 1L;
        DashboardSummaryResponse summary = new DashboardSummaryResponse(
                12L,
                3L,
                7L,
                50L,
                8L,
                2L,
                1L
        );
        DashboardStockStatusResponse stockStatus = new DashboardStockStatusResponse(
                50L,
                8L,
                2L,
                83,
                13,
                3
        );
        DashboardTodoResponse todo = new DashboardTodoResponse(
                "INSPECTION_WAITING",
                "검수 대기",
                "RAM DDR4 16GB",
                7L,
                "inspection"
        );
        DashboardRecentActivityResponse activity = new DashboardRecentActivityResponse(
                "INBOUND",
                "입고",
                "IN-20260622-0001",
                "RAM DDR4 16GB",
                12L,
                LocalDateTime.of(2026, 6, 22, 10, 0),
                "inbound"
        );

        when(dashboardMapper.isCompanyActive(companyId)).thenReturn(true);
        when(dashboardMapper.summarize(eq(companyId), any(), any())).thenReturn(summary);
        when(dashboardMapper.summarizeStockStatus(companyId)).thenReturn(stockStatus);
        when(dashboardMapper.findTodos(companyId, 20)).thenReturn(List.of(todo));
        when(dashboardMapper.findRecentActivities(companyId, 20)).thenReturn(List.of(activity));

        DashboardResponse response = dashboardService.getDashboard(companyId);

        assertSame(summary, response.summary());
        assertEquals(List.of(todo), response.todos());
        assertSame(stockStatus, response.stockStatus());
        assertEquals(List.of(activity), response.recentActivities());
        verify(dashboardMapper).summarize(eq(companyId), any(), any());
    }

    @Test
    void getDashboard_fail_whenCompanyInactive() {
        Long companyId = 1L;
        when(dashboardMapper.isCompanyActive(companyId)).thenReturn(false);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> dashboardService.getDashboard(companyId)
        );

        assertEquals(ErrorCode.COMPANY_INACTIVE, exception.getErrorCode());
    }
}
