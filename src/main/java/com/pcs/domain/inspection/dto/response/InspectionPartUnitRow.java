package com.pcs.domain.inspection.dto.response;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;

public record InspectionPartUnitRow(
        Long unitId,
        Long companyId,
        Long partId,
        Long categoryId,
        String internalSerialNo,
        UnitStatus unitStatus,
        PartGrade grade,
        InspectionStatus inspectionStatus,
        SalesStatus salesStatus,
        boolean active
) {
}
