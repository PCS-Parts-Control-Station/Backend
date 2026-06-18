package com.pcs.domain.inspection.dto.response;

public record SearchInspectionHistoryDocumentSummaryResponse(
        long documentCount,
        long inspectionCount,
        long failCount
) {
}
