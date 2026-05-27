package com.pcs.domain.part.dto.response;

import java.math.BigDecimal;

public record SearchPartResponse(
        Long partId,
        Long categoryId,
        String categoryName,
        String partName,
        String modelName,
        String manufacturer,
        String partCode,
        BigDecimal estimatedPrice,
        Integer safeQuantity,
        Integer currentStockQuantity,
        boolean active
) {
}
