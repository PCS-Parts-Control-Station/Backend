package com.pcs.domain.part.dto.response;

public record SearchPartUnitSummaryResponse(
        long totalCount,
        long heldCount,
        long waitingCount,
        long salesAvailableCount,
        long salesHoldCount,
        long salesUnavailableCount,
        long gradeACount,
        long gradeBCount,
        long gradeCCount,
        long defectiveCount,
        long outboundCount,
        long outboundAvailableCount
) {
}
