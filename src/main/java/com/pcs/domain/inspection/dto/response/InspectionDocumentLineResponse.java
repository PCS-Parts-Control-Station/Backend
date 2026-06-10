package com.pcs.domain.inspection.dto.response;

import java.util.List;

public record InspectionDocumentLineResponse(
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
        long defectiveCount,
        List<InspectionDocumentUnitResponse> units
) {
}
