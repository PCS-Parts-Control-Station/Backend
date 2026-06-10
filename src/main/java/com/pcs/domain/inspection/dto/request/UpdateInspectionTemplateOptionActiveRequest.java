package com.pcs.domain.inspection.dto.request;

import jakarta.validation.constraints.NotNull;

public record UpdateInspectionTemplateOptionActiveRequest(
        @NotNull Boolean active
) {
}
