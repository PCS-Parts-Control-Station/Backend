package com.pcs.domain.inspection.dto.response;

import java.time.LocalDateTime;
import java.util.List;

public record InspectionTemplateDetailResponse(
        Long templateId,
        Long categoryId,
        String categoryName,
        String templateName,
        int version,
        boolean active,
        String createdByName,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        long basicItemCount,
        long detailItemCount,
        long optionCount,
        List<InspectionTemplateItemResponse> items
) {
}
