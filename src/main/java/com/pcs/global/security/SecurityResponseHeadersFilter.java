package com.pcs.global.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class SecurityResponseHeadersFilter extends OncePerRequestFilter {

    static final String CONTENT_SECURITY_POLICY = String.join("; ",
            "default-src 'self'",
            "script-src 'self'",
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
            "font-src 'self' https://fonts.gstatic.com",
            "img-src 'self' data:",
            "connect-src 'self'",
            "object-src 'none'",
            "base-uri 'self'",
            "frame-ancestors 'none'",
            "form-action 'self'"
    );

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        setHeaderIfAbsent(response, "Content-Security-Policy", CONTENT_SECURITY_POLICY);
        setHeaderIfAbsent(response, "X-Content-Type-Options", "nosniff");
        setHeaderIfAbsent(response, "X-Frame-Options", "DENY");
        setHeaderIfAbsent(response, "Referrer-Policy", "strict-origin-when-cross-origin");
        setHeaderIfAbsent(response, "Permissions-Policy", "camera=(), microphone=(), geolocation=(), payment=()");

        filterChain.doFilter(request, response);
    }

    private void setHeaderIfAbsent(HttpServletResponse response, String name, String value) {
        if (!response.containsHeader(name)) {
            response.setHeader(name, value);
        }
    }
}
