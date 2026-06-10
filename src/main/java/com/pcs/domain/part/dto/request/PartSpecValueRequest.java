package com.pcs.domain.part.dto.request;

import java.math.BigDecimal;

public record PartSpecValueRequest(
        Long specDefinitionId,
        String valueText,
        BigDecimal valueNumber,
        Boolean valueBoolean,
        Long selectedOptionId
) {
}
