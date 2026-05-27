package com.pcs.global.dto;

import java.util.List;

public record PageResultDto<T, S>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean hasPrevious,
        boolean hasNext,
        S summary
) {

    public static <T, S> PageResultDto<T, S> of(
            List<T> items,
            int page,
            int size,
            long totalElements,
            S summary
    ) {
        int safeSize = Math.max(size, 1);
        int totalPages = (int) Math.ceil((double) totalElements / safeSize);
        return new PageResultDto<>(
                List.copyOf(items),
                page,
                safeSize,
                totalElements,
                totalPages,
                page > 0,
                totalPages > 0 && page < totalPages - 1,
                summary
        );
    }
}
