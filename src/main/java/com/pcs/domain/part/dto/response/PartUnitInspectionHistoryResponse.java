package com.pcs.domain.part.dto.response;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import java.time.LocalDateTime;

public record PartUnitInspectionHistoryResponse(
        Long inspectionId,
        InspectionType inspectionType,
        InspectionResult result,
        PartGrade grade,
        SalesStatus salesStatus,
        String inspectedByName,
        LocalDateTime inspectedAt,
        String memo
) {
}
