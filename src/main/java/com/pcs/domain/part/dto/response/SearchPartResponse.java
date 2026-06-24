package com.pcs.domain.part.dto.response;

public record SearchPartResponse(
        Long partId,
        Long categoryId,
        String categoryName,
        String partName,
        String modelName,
        String manufacturer,
        String partCode,
        Integer safeQuantity,
        Integer currentStockQuantity,
        boolean active
) {
}
