package com.pcs.domain.stock.dto.response;

import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import java.time.LocalDateTime;

public record SearchStockDocumentResponse(
        Long documentId,
        String documentNo,
        StockDocumentType documentType,
        StockDocumentStatus documentStatus,
        Long partnerId,
        String partnerName,
        String firstPartName,
        Integer lineCount,
        Integer totalQuantity,
        String processedByName,
        LocalDateTime createdAt
) {
}
