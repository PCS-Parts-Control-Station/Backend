package com.pcs.domain.inspection.dto.response;

public record SearchInspectionHistorySummaryResponse(
        long totalCount,
        long initialCount,
        long correctionCount,
        long reinspectionCount,
        long failCount,
        long defectiveCount
) {
}
