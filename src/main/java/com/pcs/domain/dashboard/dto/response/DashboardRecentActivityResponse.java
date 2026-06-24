package com.pcs.domain.dashboard.dto.response;

import java.time.LocalDateTime;

public record DashboardRecentActivityResponse(
        String type,
        String label,
        String documentNo,
        String title,
        Long quantity,
        LocalDateTime processedAt,
        String route
) {
}
