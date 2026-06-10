package com.pcs.domain.inspection.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record UpdateInspectionTemplateRequest(
        @NotNull Long categoryId,
        @NotBlank String templateName,
        @Positive Integer version,
        Boolean active
) {
}
