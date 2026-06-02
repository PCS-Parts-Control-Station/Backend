package com.pcs.domain.stock.dto.response;

public record SearchStockDocumentSummaryResponse(
        Long totalCount,
        Long totalQuantity,
        Long waitingQuantity,
        Long canceledCount
) {
}
