package com.pcs.domain.dashboard.dto.response;

public record DashboardStockStatusResponse(
        Long availableQuantity,
        Long holdQuantity,
        Long unavailableQuantity,
        Integer availableRatio,
        Integer holdRatio,
        Integer unavailableRatio
) {
}
