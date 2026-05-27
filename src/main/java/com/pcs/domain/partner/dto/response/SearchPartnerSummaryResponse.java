package com.pcs.domain.partner.dto.response;

public record SearchPartnerSummaryResponse(
        long totalCount,
        long supplierCount,
        long customerCount,
        long activeCount
) {
}
