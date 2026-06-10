package com.pcs.domain.inspection.dto.response;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import java.time.LocalDateTime;
import java.util.List;

public record CreateInspectionResponse(
        List<Long> inspectionIds,
        int savedCount,
        InspectionType inspectionType,
        InspectionResult result,
        PartGrade grade,
        SalesStatus salesStatus,
        LocalDateTime inspectedAt
) {
}
