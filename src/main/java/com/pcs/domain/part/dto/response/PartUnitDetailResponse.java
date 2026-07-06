package com.pcs.domain.part.dto.response;

import java.util.List;

public record PartUnitDetailResponse(
        SearchPartUnitResponse unit,
        List<PartUnitStockHistoryResponse> stockHistories,
        List<PartUnitInspectionHistoryResponse> inspectionHistories
) {
    public PartUnitDetailResponse {
        stockHistories = stockHistories == null ? List.of() : List.copyOf(stockHistories);
        inspectionHistories = inspectionHistories == null ? List.of() : List.copyOf(inspectionHistories);
    }
}
