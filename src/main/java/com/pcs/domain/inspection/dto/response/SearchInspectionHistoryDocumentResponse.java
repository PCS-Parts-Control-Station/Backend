package com.pcs.domain.inspection.dto.response;

import java.time.LocalDateTime;

public record SearchInspectionHistoryDocumentResponse(
        Long documentId,
        String documentNo,
        String partSummary,
        long unitCount,
        long inspectionCount,
        long failCount,
        LocalDateTime latestInspectedAt
) {
}
