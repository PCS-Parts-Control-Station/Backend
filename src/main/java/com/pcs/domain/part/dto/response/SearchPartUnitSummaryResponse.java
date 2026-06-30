package com.pcs.domain.part.dto.response;

public record SearchPartUnitSummaryResponse(
        long totalCount,
        long waitingCount,
        long outboundAvailableCount
) {
}
