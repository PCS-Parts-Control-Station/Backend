package com.pcs.global.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.ApiErrorResponseWriter;
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
class StaffPermissionAuthorizationFilterTest {

    @Mock
    private StaffPermissionService staffPermissionService;
    @Mock
    private FilterChain filterChain;

    private StaffPermissionAuthorizationFilter filter;

    @BeforeEach
    void setUp() {
        filter = new StaffPermissionAuthorizationFilter(
                staffPermissionService,
                new ApiErrorResponseWriter(new ObjectMapper())
        );
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
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void disabledPermission_returnsCommonForbiddenResponse() throws Exception {
        when(staffPermissionService.isEnabled(10L, StaffPermission.STAFF_PARTNER_MANAGE)).thenReturn(false);
        MockHttpServletRequest request = new MockHttpServletRequest(
                "POST",
                "/api/workspaces/bupc/partners"
        );
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, filterChain);

        assertEquals(403, response.getStatus());
        assertTrue(response.getContentAsString().contains("\"success\":false"));
        assertTrue(response.getContentAsString().contains("\"code\":\"AUTH-008\""));
        assertTrue(response.getContentAsString().contains("\"data\":null"));
        verify(filterChain, never()).doFilter(request, response);
    }
}
