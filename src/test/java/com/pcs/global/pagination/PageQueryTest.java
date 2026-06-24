package com.pcs.global.pagination;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class PageQueryTest {

    @Test
    void normalizesPageSizeAndOffset() {
        PageQuery query = PageQuery.of(2, 25, null);

        assertEquals(2, query.page());
        assertEquals(25, query.size());
        assertEquals(50, query.offset());
    }

    @Test
    void usesLimitAsSizeAliasAndCapsSize() {
        PageQuery query = PageQuery.of(null, null, 500);

        assertEquals(0, query.page());
        assertEquals(100, query.size());
        assertEquals(0, query.offset());
    }

    @Test
    void preventsOffsetOverflow() {
        PageQuery query = PageQuery.of(Integer.MAX_VALUE, 100, null);

        assertEquals(Integer.MAX_VALUE, query.page());
        assertEquals(100, query.size());
        assertEquals(Integer.MAX_VALUE, query.offset());
    }
}
