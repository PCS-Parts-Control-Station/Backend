package com.pcs.domain.inspection.dto.request;

import jakarta.validation.constraints.NotNull;

public record UpdateInspectionTemplateActiveRequest(
        @NotNull Boolean active
) {
}
