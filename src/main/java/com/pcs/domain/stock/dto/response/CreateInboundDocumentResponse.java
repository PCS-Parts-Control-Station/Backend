package com.pcs.domain.stock.dto.response;

public record CreateInboundDocumentResponse(
        Long documentId,
        String documentNo,
        Long partnerId,
        int lineCount,
        int totalQuantity,
        int createdUnitCount
) {
}
