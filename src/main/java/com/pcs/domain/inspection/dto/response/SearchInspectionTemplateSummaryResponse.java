package com.pcs.domain.inspection.dto.response;

public record SearchInspectionTemplateSummaryResponse(
        long totalCount,
        long activeCount,
        long itemCount,
        long optionCount
) {
}
