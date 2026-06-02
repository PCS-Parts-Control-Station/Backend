package com.pcs.domain.stock.dto.response;

import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import java.time.LocalDateTime;

public record StockDocumentDetailRow(
        Long documentId,
        String documentNo,
        StockDocumentType documentType,
        StockDocumentStatus documentStatus,
        Long partnerId,
        String partnerName,
        String reason,
        String processedByName,
        LocalDateTime createdAt,
        Integer lineCount,
        Integer totalQuantity
) {
}
