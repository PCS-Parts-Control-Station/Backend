package com.pcs.domain.inspection.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record UpdateInspectionTemplateOptionSortOrderRequest(
        @NotEmpty List<@NotNull Long> orderedOptionIds
) {
}
