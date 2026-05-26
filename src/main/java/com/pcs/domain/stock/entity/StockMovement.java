package com.pcs.domain.stock.entity;

import com.pcs.domain.stock.type.MovementStatus;
import com.pcs.domain.stock.type.MovementType;

public class StockMovement {

    private Long movementId;
    private final Long companyId;
    private final Long documentId;
    private final Long partId;
    private final MovementType movementType;
    private final MovementStatus movementStatus;
    private final Integer quantity;
    private final Integer beforeQuantity;
    private final Integer afterQuantity;
    private final String reason;
    private final Long processedBy;

    public StockMovement(
            Long companyId,
            Long documentId,
            Long partId,
            MovementType movementType,
            MovementStatus movementStatus,
            Integer quantity,
            Integer beforeQuantity,
            Integer afterQuantity,
            String reason,
            Long processedBy
    ) {
        this.companyId = companyId;
        this.documentId = documentId;
        this.partId = partId;
        this.movementType = movementType;
        this.movementStatus = movementStatus;
        this.quantity = quantity;
        this.beforeQuantity = beforeQuantity;
        this.afterQuantity = afterQuantity;
        this.reason = reason;
        this.processedBy = processedBy;
    }

    public Long getMovementId() {
        return movementId;
    }

    public void setMovementId(Long movementId) {
        this.movementId = movementId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public Long getDocumentId() {
        return documentId;
    }

    public Long getPartId() {
        return partId;
    }

    public MovementType getMovementType() {
        return movementType;
    }

    public MovementStatus getMovementStatus() {
        return movementStatus;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public Integer getBeforeQuantity() {
        return beforeQuantity;
    }

    public Integer getAfterQuantity() {
        return afterQuantity;
    }

    public String getReason() {
        return reason;
    }

    public Long getProcessedBy() {
        return processedBy;
    }
}
