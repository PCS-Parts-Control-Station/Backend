package com.pcs.domain.stock.dto.response;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;

public record StockDocumentUnitResponse(
        Long movementId,
        Long unitId,
        String internalSerialNo,
        String manufacturerSerialNo,
        UnitStatus unitStatus,
        PartGrade grade,
        InspectionStatus inspectionStatus,
        SalesStatus salesStatus,
        Boolean active
) {
}
