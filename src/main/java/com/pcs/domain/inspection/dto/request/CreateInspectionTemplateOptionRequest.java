package com.pcs.domain.inspection.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record CreateInspectionTemplateOptionRequest(
        @NotBlank String optionLabel,
        String optionValue,
        @Min(0) Integer sortOrder
) {
}
