package com.pcs.domain.inspection.dto.response;

import java.time.LocalDateTime;
import java.util.List;

public record InspectionWaitingDocumentDetailResponse(
        Long documentId,
        String documentNo,
        Long partnerId,
        String partnerName,
        String summary,
        long totalUnitCount,
        long completedCount,
        long waitingCount,
        long defectiveCount,
        int progressRate,
        String inspectionStatus,
        LocalDateTime createdAt,
        List<InspectionDocumentLineResponse> lines
) {
}
