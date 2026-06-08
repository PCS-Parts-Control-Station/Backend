package com.pcs.domain.category.dto.response;

public record CategorySpecOptionResponse(
        Long optionId,
        Long specDefinitionId,
        String optionLabel,
        String optionValue,
        Integer sortOrder,
        Boolean active
) {
}
