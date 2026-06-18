package com.pcs.domain.stock.dto.response;

public record CreateOutboundDocumentResponse(
        Long documentId,
        String documentNo,
        Long partnerId,
        int lineCount,
        int totalQuantity,
        int outboundUnitCount
) {
}
