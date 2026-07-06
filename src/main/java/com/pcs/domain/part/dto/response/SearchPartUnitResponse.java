package com.pcs.domain.part.dto.response;

import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.type.MovementType;
import java.time.LocalDateTime;

public record SearchPartUnitResponse(
        Long unitId,
        String internalSerialNo,
        String manufacturerSerialNo,
        Long partId,
        Long categoryId,
        String categoryName,
        String partName,
        String modelName,
        String manufacturer,
        String partCode,
        UnitStatus unitStatus,
        InspectionStatus inspectionStatus,
        PartGrade grade,
        SalesStatus salesStatus,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        String lastStockDocumentNo,
        MovementType lastStockMovementType,
        LocalDateTime lastStockProcessedAt,
        Long lastInspectionId,
        InspectionType lastInspectionType,
        LocalDateTime lastInspectedAt,
        String recentEventLabel,
        LocalDateTime recentEventAt
) {
}
