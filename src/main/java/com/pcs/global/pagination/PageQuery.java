package com.pcs.global.pagination;

public record PageQuery(
        int page,
        int size,
        int offset
) {

    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 100;

    public static PageQuery of(Integer page, Integer size, Integer limit) {
        return of(page, size, limit, DEFAULT_SIZE);
    }

    public static PageQuery of(Integer page, Integer size, Integer limit, int defaultSize) {
        int normalizedPage = page == null || page < 0 ? 0 : page;
        Integer requestedSize = size == null ? limit : size;
        int normalizedSize = requestedSize == null || requestedSize < 1
                ? defaultSize
                : Math.min(requestedSize, MAX_SIZE);

        return new PageQuery(
                normalizedPage,
                normalizedSize,
                normalizedPage * normalizedSize
        );
    }
}
