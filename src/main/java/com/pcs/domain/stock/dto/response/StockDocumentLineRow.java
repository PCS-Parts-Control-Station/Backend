package com.pcs.domain.stock.dto.response;

import com.pcs.domain.stock.type.MovementStatus;
import com.pcs.domain.stock.type.MovementType;

public record StockDocumentLineRow(
        Long movementId,
        Long partId,
        String partName,
        String modelName,
        String partCode,
        MovementType movementType,
        MovementStatus movementStatus,
        Integer quantity,
        Integer beforeQuantity,
        Integer afterQuantity,
        String reason
) {
}
