package com.pcs.domain.dashboard.dto.response;

public record DashboardTodoResponse(
        String type,
        String label,
        String title,
        Long count,
        String route
) {
}
