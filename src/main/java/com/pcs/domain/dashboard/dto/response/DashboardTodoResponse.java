package com.pcs.domain.dashboard.dto.response;

public record DashboardTodoResponse(
        String type,
        String label,
        String title,
        Long count,
        Long partId,
        String categoryName,
        String route,
        String partState
) {
}
