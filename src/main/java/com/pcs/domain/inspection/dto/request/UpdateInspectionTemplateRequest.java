package com.pcs.domain.inspection.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.util.List;

public record UpdateInspectionTemplateRequest(
        @NotNull Long categoryId,
        @NotBlank String templateName,
        @Positive Integer version,
        Boolean active,
        @Valid List<SaveInspectionTemplateItemRequest> items
) {
    public UpdateInspectionTemplateRequest(
            Long categoryId,
            String templateName,
            Integer version,
            Boolean active
    ) {
        this(categoryId, templateName, version, active, List.of());
    }
}
