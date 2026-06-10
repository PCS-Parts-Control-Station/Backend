package com.pcs.domain.inspection.dto.response;

import java.time.LocalDateTime;

public record SearchWaitingInspectionDocumentResponse(
        Long documentId,
        String documentNo,
        Long partnerId,
        String partnerName,
        String summary,
        long lineCount,
        long totalUnitCount,
        long completedCount,
        long waitingCount,
        long defectiveCount,
        int progressRate,
        String inspectionStatus,
        LocalDateTime createdAt
) {
}
