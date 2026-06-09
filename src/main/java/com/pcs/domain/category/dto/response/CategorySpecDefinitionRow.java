package com.pcs.domain.category.dto.response;

public record CategorySpecDefinitionRow(
        Long specDefinitionId,
        Long categoryId,
        String specKey,
        String specName,
        String inputType,
        String unit,
        Boolean required,
        Boolean searchable,
        Integer sortOrder,
        Boolean active
) {
}
