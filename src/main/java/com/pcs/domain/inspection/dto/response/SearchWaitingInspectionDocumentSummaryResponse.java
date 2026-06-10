package com.pcs.domain.inspection.dto.response;

public record SearchWaitingInspectionDocumentSummaryResponse(
        long documentCount,
        long totalUnitCount,
        long completedCount,
        long waitingCount,
        long defectiveCount
) {
}
