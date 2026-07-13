package com.pcs.global.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import java.time.Instant;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

@ExtendWith(MockitoExtension.class)
class StaffPermissionAuthorizationFilterTest {

    @Mock
    private StaffPermissionService staffPermissionService;

    private StaffPermissionAuthorizationFilter filter;
    private PcsPrincipal staff;

    @BeforeEach
    void setUp() {
        filter = new StaffPermissionAuthorizationFilter(staffPermissionService, new ObjectMapper());
        staff = new PcsPrincipal(7L, 1L, "acme", "staff", MemberRole.STAFF, Instant.now().plusSeconds(600));
        SecurityContextHolder.getContext().setAuthentication(new TestingAuthenticationToken(staff, null));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void blocksInboundApiWithoutInboundPermission() throws Exception {
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_INBOUND)).thenReturn(false);

        MockHttpServletResponse response = execute("POST", "/api/workspaces/acme/stock/documents/inbounds");

        assertThat(response.getStatus()).isEqualTo(403);
        assertThat(response.getContentAsString()).contains("AUTH-008");
    }

    @Test
    void blocksOutboundApiWithoutOutboundPermission() throws Exception {
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_OUTBOUND)).thenReturn(false);

        MockHttpServletResponse response = execute("POST", "/api/workspaces/acme/stock/documents/outbounds");

        assertThat(response.getStatus()).isEqualTo(403);
        verify(staffPermissionService).isEnabled(1L, StaffPermission.STAFF_OUTBOUND);
    }

    @Test
    void blocksOutboundCandidatesWithoutOutboundPermission() throws Exception {
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_OUTBOUND)).thenReturn(false);

        MockHttpServletResponse response = execute("GET", "/api/workspaces/acme/stock/outbound-candidates");

        assertThat(response.getStatus()).isEqualTo(403);
        verify(staffPermissionService).isEnabled(1L, StaffPermission.STAFF_OUTBOUND);
    }

    @Test
    void allowsDocumentReadAndDefersCancelPermissionToFacade() throws Exception {
        MockHttpServletResponse list = execute("GET", "/api/workspaces/acme/stock/documents");
        MockHttpServletResponse cancel = execute("POST", "/api/workspaces/acme/stock/documents/10/cancel");

        assertThat(list.getStatus()).isEqualTo(200);
        assertThat(cancel.getStatus()).isEqualTo(200);
        verify(staffPermissionService, never()).isEnabled(1L, StaffPermission.STAFF_INBOUND);
    }

    @Test
    void blocksInspectionAndTemplateApisWithoutInspectionPermission() throws Exception {
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_INSPECTION)).thenReturn(false);

        MockHttpServletResponse inspection = execute("GET", "/api/workspaces/acme/inspections");
        MockHttpServletResponse template = execute("GET", "/api/workspaces/acme/inspection-templates");

        assertThat(inspection.getStatus()).isEqualTo(403);
        assertThat(template.getStatus()).isEqualTo(403);
    }

    @Test
    void allowsDashboardBecauseItHasNoStaffPermissionGate() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/workspaces/acme/dashboard");
        MockHttpServletResponse response = new MockHttpServletResponse();
        MockFilterChain chain = new MockFilterChain();

        filter.doFilter(request, response, chain);

        assertThat(chain.getRequest()).isSameAs(request);
        verify(staffPermissionService, never()).isEnabled(1L, StaffPermission.STAFF_INBOUND);
    }

    private MockHttpServletResponse execute(String method, String uri) throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest(method, uri);
        MockHttpServletResponse response = new MockHttpServletResponse();
        filter.doFilter(request, response, new MockFilterChain());
        return response;
    }
}
