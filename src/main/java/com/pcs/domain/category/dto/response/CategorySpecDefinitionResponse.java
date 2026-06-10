package com.pcs.domain.category.dto.response;

import java.util.List;

public record CategorySpecDefinitionResponse(
        Long specDefinitionId,
        Long categoryId,
        String specKey,
        String specName,
        String inputType,
        String unit,
        Boolean required,
        Boolean searchable,
        Integer sortOrder,
        Boolean active,
        List<CategorySpecOptionResponse> options
) {
    public static CategorySpecDefinitionResponse of(
            CategorySpecDefinitionRow row,
            List<CategorySpecOptionResponse> options
    ) {
        return new CategorySpecDefinitionResponse(
                row.specDefinitionId(),
                row.categoryId(),
                row.specKey(),
                row.specName(),
                row.inputType(),
                row.unit(),
                row.required(),
                row.searchable(),
                row.sortOrder(),
                row.active(),
                options == null ? List.of() : options
        );
    }
}
