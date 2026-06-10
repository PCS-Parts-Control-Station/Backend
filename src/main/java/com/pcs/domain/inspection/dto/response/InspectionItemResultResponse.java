package com.pcs.domain.inspection.dto.response;

import com.pcs.domain.inspection.type.InspectionItemResultStatus;
import java.math.BigDecimal;

public record InspectionItemResultResponse(
        Long itemResultId,
        Long inspectionId,
        Long itemId,
        String itemNameSnapshot,
        InspectionItemResultStatus result,
        String valueText,
        BigDecimal valueNumber,
        Long selectedOptionId,
        String selectedOptionLabelSnapshot,
        String selectedOptionValueSnapshot,
        String memo
) {
}
