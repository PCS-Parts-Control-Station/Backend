package com.pcs.domain.inspection.dto.request;

import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record SaveInspectionTemplateItemRequest(
        Long itemId,
        @NotBlank String itemName,
        @NotNull InspectionItemGroup itemGroup,
        @NotNull InspectionInputType inputType,
        Boolean required,
        @Min(0) Integer sortOrder,
        GradeImpact gradeImpact,
        InspectionFailPolicy failPolicy,
        Boolean active,
        @Valid List<SaveInspectionTemplateOptionRequest> options
) {
}
