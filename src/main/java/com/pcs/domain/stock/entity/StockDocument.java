package com.pcs.domain.stock.entity;

import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;

public class StockDocument {

    private Long documentId;
    private final Long companyId;
    private final Long partnerId;
    private final String documentNo;
    private final StockDocumentType documentType;
    private final StockDocumentStatus documentStatus;
    private final String reason;
    private final Long processedBy;

    public StockDocument(
            Long companyId,
            Long partnerId,
            String documentNo,
            StockDocumentType documentType,
            StockDocumentStatus documentStatus,
            String reason,
            Long processedBy
    ) {
        this.companyId = companyId;
        this.partnerId = partnerId;
        this.documentNo = documentNo;
        this.documentType = documentType;
        this.documentStatus = documentStatus;
        this.reason = reason;
        this.processedBy = processedBy;
    }

    public Long getDocumentId() {
        return documentId;
    }

    public void setDocumentId(Long documentId) {
        this.documentId = documentId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public Long getPartnerId() {
        return partnerId;
    }

    public String getDocumentNo() {
        return documentNo;
    }

    public StockDocumentType getDocumentType() {
        return documentType;
    }

    public StockDocumentStatus getDocumentStatus() {
        return documentStatus;
    }

    public String getReason() {
        return reason;
    }

    public Long getProcessedBy() {
        return processedBy;
    }
}
