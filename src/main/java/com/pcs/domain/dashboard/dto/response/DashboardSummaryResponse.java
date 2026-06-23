package com.pcs.domain.dashboard.dto.response;

public record DashboardSummaryResponse(
        Long todayInboundQuantity,
        Long todayOutboundQuantity,
        Long waitingInspectionQuantity,
        Long availableQuantity,
        Long holdQuantity,
        Long unavailableQuantity,
        Long todayDefectiveInspectionCount
) {
}
