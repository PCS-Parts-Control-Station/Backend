package com.pcs.domain.inspection.dto.response;

import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import java.util.List;

public record InspectionTemplateItemResponse(
        Long itemId,
        InspectionItemGroup itemGroup,
        String itemName,
        InspectionInputType inputType,
        boolean required,
        int sortOrder,
        GradeImpact gradeImpact,
        InspectionFailPolicy failPolicy,
        boolean active,
        List<InspectionTemplateOptionResponse> options
) {
}
