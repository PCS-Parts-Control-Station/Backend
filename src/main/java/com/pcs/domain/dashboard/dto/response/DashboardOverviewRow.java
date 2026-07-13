package com.pcs.domain.dashboard.dto.response;

public record DashboardOverviewRow(
        long todayInboundQuantity,
        long todayOutboundQuantity,
        long waitingInspectionQuantity,
        long availableQuantity,
        long holdQuantity,
        long unavailableQuantity,
        long totalStockQuantity,
        long todayDefectiveInspectionCount
) {
}
