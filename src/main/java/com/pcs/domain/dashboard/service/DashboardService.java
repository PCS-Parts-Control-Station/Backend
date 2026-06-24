package com.pcs.domain.dashboard.service;

import com.pcs.domain.dashboard.dto.response.DashboardRecentActivityResponse;
import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.dto.response.DashboardStockStatusResponse;
import com.pcs.domain.dashboard.dto.response.DashboardSummaryResponse;
import com.pcs.domain.dashboard.dto.response.DashboardTodoResponse;
import com.pcs.domain.dashboard.mapper.DashboardMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class DashboardService {

    private static final int TODO_SIZE = 20;
    private static final int RECENT_ACTIVITY_SIZE = 20;

    private final DashboardMapper dashboardMapper;

    public DashboardService(DashboardMapper dashboardMapper) {
        this.dashboardMapper = dashboardMapper;
    }

    public DashboardResponse getDashboard(Long companyId) {
        validateCompanyActive(companyId);

        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime tomorrowStart = today.plusDays(1).atStartOfDay();

        DashboardSummaryResponse summary = dashboardMapper.summarize(companyId, todayStart, tomorrowStart);
        DashboardStockStatusResponse stockStatus = dashboardMapper.summarizeStockStatus(companyId);
        List<DashboardTodoResponse> todos = dashboardMapper.findTodos(companyId, TODO_SIZE);
        List<DashboardRecentActivityResponse> recentActivities =
                dashboardMapper.findRecentActivities(companyId, RECENT_ACTIVITY_SIZE);

        return new DashboardResponse(
                requireSummary(summary),
                List.copyOf(todos),
                requireStockStatus(stockStatus),
                List.copyOf(recentActivities)
        );
    }

    private void validateCompanyActive(Long companyId) {
        if (!dashboardMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
    }

    private DashboardSummaryResponse requireSummary(DashboardSummaryResponse summary) {
        if (summary == null) {
            return new DashboardSummaryResponse(0L, 0L, 0L, 0L, 0L, 0L, 0L);
        }
        return summary;
    }

    private DashboardStockStatusResponse requireStockStatus(DashboardStockStatusResponse stockStatus) {
        if (stockStatus == null) {
            return new DashboardStockStatusResponse(0L, 0L, 0L, 0, 0, 0);
        }
        return stockStatus;
    }
}
