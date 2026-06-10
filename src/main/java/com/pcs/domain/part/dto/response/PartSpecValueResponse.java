package com.pcs.domain.part.dto.response;

import java.math.BigDecimal;

public record PartSpecValueResponse(
        Long specValueId,
        Long specDefinitionId,
        String specKey,
        String specName,
        String inputType,
        String unit,
        BigDecimal valueNumber,
        String valueText,
        Boolean valueBoolean,
        Long selectedOptionId,
        String selectedOptionLabel,
        String selectedOptionValue
) {
}
