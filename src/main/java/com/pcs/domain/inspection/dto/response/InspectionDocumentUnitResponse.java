package com.pcs.domain.inspection.dto.response;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import java.time.LocalDateTime;

public record InspectionDocumentUnitResponse(
        Long movementId,
        Long partId,
        Long unitId,
        String internalSerialNo,
        String manufacturerSerialNo,
        UnitStatus unitStatus,
        InspectionStatus inspectionStatus,
        PartGrade grade,
        SalesStatus salesStatus,
        Long latestInspectionId,
        InspectionType latestInspectionType,
        InspectionResult latestInspectionResult,
        LocalDateTime latestInspectedAt
) {
}
