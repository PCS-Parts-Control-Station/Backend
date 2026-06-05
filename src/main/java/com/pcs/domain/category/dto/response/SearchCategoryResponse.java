package com.pcs.domain.category.dto.response;

import java.time.LocalDateTime;

public record SearchCategoryResponse(
        Long categoryId,
        String categoryName,
        String description,
        Long partCount,
        LocalDateTime updatedAt
) {
}
