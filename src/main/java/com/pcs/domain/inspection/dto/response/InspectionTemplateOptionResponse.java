package com.pcs.domain.inspection.dto.response;

public record InspectionTemplateOptionResponse(
        Long optionId,
        Long itemId,
        String optionLabel,
        String optionValue,
        int sortOrder,
        boolean active
) {
}
