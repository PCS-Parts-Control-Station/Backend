package com.pcs.domain.dashboard.service;

import com.pcs.domain.dashboard.dto.response.DashboardRecentActivityResponse;
import com.pcs.domain.dashboard.dto.response.DashboardOverviewRow;
import com.pcs.domain.dashboard.dto.response.DashboardResponse;
import com.pcs.domain.dashboard.dto.response.DashboardStockStatusResponse;
import com.pcs.domain.dashboard.dto.response.DashboardSummaryResponse;
import com.pcs.domain.dashboard.dto.response.DashboardTodoResponse;
import com.pcs.domain.dashboard.mapper.DashboardMapper;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class DashboardService {

    private static final int TODO_SIZE = 20;
    private static final int RECENT_ACTIVITY_SIZE = 20;

    private final DashboardMapper dashboardMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public DashboardService(DashboardMapper dashboardMapper, WorkspaceAccessValidator workspaceAccessValidator) {
        this.dashboardMapper = dashboardMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public DashboardResponse getDashboard(Long companyId) {
        workspaceAccessValidator.validateCompanyActive(companyId);

        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime tomorrowStart = today.plusDays(1).atStartOfDay();

        DashboardOverviewRow overview = dashboardMapper.summarizeOverview(companyId, todayStart, tomorrowStart);
        if (overview == null) {
            overview = new DashboardOverviewRow(0, 0, 0, 0, 0, 0, 0, 0);
        }
        DashboardSummaryResponse summary = toSummary(overview);
        DashboardStockStatusResponse stockStatus = toStockStatus(overview);
        List<DashboardTodoResponse> todos = dashboardMapper.findTodos(companyId, TODO_SIZE);
        List<DashboardRecentActivityResponse> recentActivities =
                dashboardMapper.findRecentActivities(companyId, RECENT_ACTIVITY_SIZE);

        return new DashboardResponse(
                summary,
                List.copyOf(todos),
                stockStatus,
                List.copyOf(recentActivities)
        );
    }

    private DashboardSummaryResponse toSummary(DashboardOverviewRow overview) {
        return new DashboardSummaryResponse(
                overview.todayInboundQuantity(),
                overview.todayOutboundQuantity(),
                overview.waitingInspectionQuantity(),
                overview.availableQuantity(),
                overview.holdQuantity(),
                overview.unavailableQuantity(),
                overview.todayDefectiveInspectionCount()
        );
    }

    private DashboardStockStatusResponse toStockStatus(DashboardOverviewRow overview) {
        return new DashboardStockStatusResponse(
                overview.availableQuantity(),
                overview.holdQuantity(),
                overview.unavailableQuantity(),
                ratio(overview.availableQuantity(), overview.totalStockQuantity()),
                ratio(overview.holdQuantity(), overview.totalStockQuantity()),
                ratio(overview.unavailableQuantity(), overview.totalStockQuantity())
        );
    }

    private int ratio(long quantity, long totalQuantity) {
        return totalQuantity == 0 ? 0 : (int) (quantity * 100 / totalQuantity);
    }
}
