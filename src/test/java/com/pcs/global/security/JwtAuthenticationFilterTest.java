package com.pcs.global.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ApiErrorResponseWriter;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import jakarta.servlet.FilterChain;
import java.time.Instant;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpHeaders;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;

@ExtendWith(MockitoExtension.class)
class JwtAuthenticationFilterTest {

    @Mock
    private JwtTokenProvider jwtTokenProvider;
    @Mock
    private AccessTokenSessionValidator accessTokenSessionValidator;
    @Mock
    private FilterChain filterChain;

    private JwtAuthenticationFilter filter;

    @BeforeEach
    void setUp() {
        filter = new JwtAuthenticationFilter(
                jwtTokenProvider,
                accessTokenSessionValidator,
                new JwtAuthenticationEntryPoint(new ApiErrorResponseWriter(new ObjectMapper()))
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void authenticatesAccessTokenBackedByActiveSession() throws Exception {
        JwtClaims claims = claims();
        when(jwtTokenProvider.parseAccessToken("access-token")).thenReturn(claims);
        MockHttpServletRequest request = authenticatedRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, filterChain);

        verify(accessTokenSessionValidator).validate(claims);
        verify(filterChain).doFilter(request, response);
        assertInstanceOf(
                PcsPrincipal.class,
                SecurityContextHolder.getContext().getAuthentication().getPrincipal()
        );
    }

    @Test
    void rejectsAccessTokenBackedByRevokedSession() throws Exception {
        JwtClaims claims = claims();
        when(jwtTokenProvider.parseAccessToken("access-token")).thenReturn(claims);
        doThrow(new BusinessException(ErrorCode.AUTH_TOKEN_INVALID))
                .when(accessTokenSessionValidator)
                .validate(claims);
        MockHttpServletRequest request = authenticatedRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, filterChain);

        assertEquals(401, response.getStatus());
        assertTrue(response.getContentAsString().contains("AUTH-003"));
        verify(filterChain, never()).doFilter(request, response);
    }

    @Test
    void failsClosedWithJsonWhenSessionLookupFails() throws Exception {
        JwtClaims claims = claims();
        when(jwtTokenProvider.parseAccessToken("access-token")).thenReturn(claims);
        doThrow(new IllegalStateException("database unavailable"))
                .when(accessTokenSessionValidator)
                .validate(claims);
        MockHttpServletRequest request = authenticatedRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, filterChain);

        assertEquals(500, response.getStatus());
        assertTrue(response.getContentAsString().contains("COMMON-999"));
        assertTrue(!response.getContentAsString().contains("database unavailable"));
        verify(filterChain, never()).doFilter(request, response);
    }

    private MockHttpServletRequest authenticatedRequest() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/workspaces/bupc/parts");
        request.addHeader(HttpHeaders.AUTHORIZATION, "Bearer access-token");
        return request;
    }

    private JwtClaims claims() {
        Instant now = Instant.now();
        return new JwtClaims(
                20L,
                10L,
                "bupc",
                "staff01",
                MemberRole.STAFF,
                "ACCESS",
                "jti-1",
                "family-1",
                now,
                now.plusSeconds(600)
        );
    }
}
