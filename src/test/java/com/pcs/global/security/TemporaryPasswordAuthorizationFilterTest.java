package com.pcs.global.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.mapper.AuthMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import jakarta.servlet.FilterChain;
import java.time.Instant;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

@ExtendWith(MockitoExtension.class)
class TemporaryPasswordAuthorizationFilterTest {

    @Mock
    private AuthMapper authMapper;
    @Mock
    private AuthMember member;
    @Mock
    private FilterChain filterChain;

    private TemporaryPasswordAuthorizationFilter filter;

    @BeforeEach
    void setUp() {
        filter = new TemporaryPasswordAuthorizationFilter(authMapper, new ObjectMapper());
        PcsPrincipal principal = new PcsPrincipal(
                1L,
                10L,
                "bupc",
                "staff01",
                MemberRole.STAFF,
                Instant.now().plusSeconds(600)
        );
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, principal.authorities())
        );
        when(authMapper.findSessionMember(10L, 1L)).thenReturn(member);
        when(member.getPasswordStatus()).thenReturn(PasswordStatus.TEMPORARY);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void blocksBusinessApiForTemporaryPassword() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/workspaces/bupc/parts");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, filterChain);

        assertEquals(403, response.getStatus());
        verify(filterChain, never()).doFilter(request, response);
    }

    @Test
    void allowsPasswordChangeForTemporaryPassword() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest(
                "PATCH",
                "/api/workspaces/bupc/mypage/password"
        );
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
    }
}
