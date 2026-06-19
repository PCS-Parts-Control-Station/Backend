package com.pcs.domain.stock.dto.response;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;

public record SearchOutboundCandidateResponse(
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
        SalesStatus salesStatus
) {
}
