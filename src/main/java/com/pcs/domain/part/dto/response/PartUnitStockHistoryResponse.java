package com.pcs.domain.part.dto.response;

import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.type.MovementType;
import java.time.LocalDateTime;

public record PartUnitStockHistoryResponse(
        Long movementId,
        Long documentId,
        String documentNo,
        MovementType movementType,
        UnitStatus beforeUnitStatus,
        UnitStatus afterUnitStatus,
        String processedByName,
        LocalDateTime createdAt
) {
}
