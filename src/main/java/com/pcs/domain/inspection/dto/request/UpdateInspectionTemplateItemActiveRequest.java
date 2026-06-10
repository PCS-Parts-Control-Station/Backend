package com.pcs.domain.inspection.dto.request;

import jakarta.validation.constraints.NotNull;

public record UpdateInspectionTemplateItemActiveRequest(
        @NotNull Boolean active
) {
}
