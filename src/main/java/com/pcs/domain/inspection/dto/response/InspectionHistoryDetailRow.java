package com.pcs.domain.inspection.dto.response;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import java.time.LocalDateTime;

public record InspectionHistoryDetailRow(
        Long inspectionId,
        InspectionType inspectionType,
        Long originalInspectionId,
        Long documentId,
        String documentNo,
        Long unitId,
        String internalSerialNo,
        Long partId,
        Long categoryId,
        String categoryName,
        String partName,
        String modelName,
        Long templateId,
        String templateName,
        InspectionResult result,
        PartGrade grade,
        SalesStatus salesStatus,
        String memo,
        String inspectedByName,
        LocalDateTime inspectedAt
) {
}
