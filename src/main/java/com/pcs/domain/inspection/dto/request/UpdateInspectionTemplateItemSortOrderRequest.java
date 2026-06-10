package com.pcs.domain.inspection.dto.request;

import com.pcs.domain.inspection.type.InspectionItemGroup;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record UpdateInspectionTemplateItemSortOrderRequest(
        @NotNull InspectionItemGroup itemGroup,
        @NotEmpty List<@NotNull Long> orderedItemIds
) {
}
