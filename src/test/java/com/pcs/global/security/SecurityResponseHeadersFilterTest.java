package com.pcs.global.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

class SecurityResponseHeadersFilterTest {

    private final SecurityResponseHeadersFilter filter = new SecurityResponseHeadersFilter();

    @Test
    void addsBrowserSecurityHeaders() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/w/pcs/dashboard");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, new MockFilterChain());

        assertEquals(SecurityResponseHeadersFilter.CONTENT_SECURITY_POLICY,
                response.getHeader("Content-Security-Policy"));
        assertEquals("nosniff", response.getHeader("X-Content-Type-Options"));
        assertEquals("DENY", response.getHeader("X-Frame-Options"));
        assertEquals("strict-origin-when-cross-origin", response.getHeader("Referrer-Policy"));
        assertTrue(response.getHeader("Permissions-Policy").contains("camera=()"));
    }

    @Test
    void doesNotOverwriteExistingHeaders() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/workspaces/pcs/me");
        MockHttpServletResponse response = new MockHttpServletResponse();
        response.setHeader("Content-Security-Policy", "default-src 'none'");

        filter.doFilter(request, response, new MockFilterChain());

        assertEquals("default-src 'none'", response.getHeader("Content-Security-Policy"));
        assertEquals("nosniff", response.getHeader("X-Content-Type-Options"));
    }
}
