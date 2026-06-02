package com.pcs.domain.stock.dto.response;

import com.pcs.domain.stock.type.StockDocumentStatus;

public record CancelStockDocumentResponse(
        Long documentId,
        String documentNo,
        StockDocumentStatus documentStatus,
        Integer canceledMovementCount,
        Integer canceledUnitCount
) {
}
