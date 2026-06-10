package com.pcs.domain.inspection.dto.response;

public record InspectionTemplateOptionRow(
        Long optionId,
        Long itemId,
        String optionLabel,
        String optionValue,
        boolean active
) {
}
