package com.pcs.domain.part.dto.response;

public record SearchPartSummaryResponse(
        long totalCount,
        long totalStock,
        long lowStockCount
) {
}
