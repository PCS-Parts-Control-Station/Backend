package com.pcs.domain.category.dto.response;

import java.time.LocalDateTime;
import java.util.List;

public record CategoryDetailResponse(
        Long categoryId,
        String categoryName,
        String description,
        Long partCount,
        LocalDateTime updatedAt,
        List<CategorySpecDefinitionResponse> specDefinitions
) {
    public static CategoryDetailResponse of(
            SearchCategoryResponse category,
            List<CategorySpecDefinitionResponse> specDefinitions
    ) {
        return new CategoryDetailResponse(
                category.categoryId(),
                category.categoryName(),
                category.description(),
                category.partCount(),
                category.updatedAt(),
                specDefinitions == null ? List.of() : specDefinitions
        );
    }
}
