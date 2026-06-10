package com.pcs.domain.inspection.dto.response;

public record InspectionDocumentLineRow(
        Long movementId,
        Long partId,
        Long categoryId,
        String categoryName,
        String partName,
        String modelName,
        String partCode,
        long quantity,
        long completedCount,
        long waitingCount,
        long defectiveCount
) {
}
