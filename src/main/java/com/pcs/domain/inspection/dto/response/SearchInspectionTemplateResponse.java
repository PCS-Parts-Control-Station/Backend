package com.pcs.domain.inspection.dto.response;

import java.time.LocalDateTime;

public record SearchInspectionTemplateResponse(
        Long templateId,
        Long categoryId,
        String categoryName,
        String templateName,
        int version,
        boolean active,
        long itemCount,
        long optionCount,
        String createdByName,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
