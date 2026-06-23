package com.pcs.domain.dashboard.dto.response;

import java.util.List;

public record DashboardResponse(
        DashboardSummaryResponse summary,
        List<DashboardTodoResponse> todos,
        DashboardStockStatusResponse stockStatus,
        List<DashboardRecentActivityResponse> recentActivities
) {
}
