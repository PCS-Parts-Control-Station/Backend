package com.pcs.domain.part.dto.response;

import java.math.BigDecimal;
import java.util.List;

public record PartDetailResponse(
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
        boolean active,
        List<PartSpecValueResponse> specValues
) {
    public static PartDetailResponse of(
            SearchPartResponse part,
            List<PartSpecValueResponse> specValues
    ) {
        return new PartDetailResponse(
                part.partId(),
                part.categoryId(),
                part.categoryName(),
                part.partName(),
                part.modelName(),
                part.manufacturer(),
                part.partCode(),
                part.estimatedPrice(),
                part.safeQuantity(),
                part.currentStockQuantity(),
                part.active(),
                specValues == null ? List.of() : specValues
        );
    }
}
