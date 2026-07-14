package com.pcs.global.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.ApiErrorResponseWriter;
import java.time.Instant;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

@ExtendWith(MockitoExtension.class)
class StaffPermissionAuthorizationFilterTest {

    @Mock
    private StaffPermissionService staffPermissionService;

    private StaffPermissionAuthorizationFilter filter;

    @BeforeEach
    void setUp() {
        filter = new StaffPermissionAuthorizationFilter(
                staffPermissionService,
                new ApiErrorResponseWriter(new ObjectMapper())
        );
        PcsPrincipal staff = new PcsPrincipal(
                7L,
                1L,
                "acme",
                "staff",
                MemberRole.STAFF,
                Instant.now().plusSeconds(600)
        );
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(staff, null, staff.authorities())
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void disabledPermission_returnsCommonForbiddenResponse() throws Exception {
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_PARTNER_MANAGE)).thenReturn(false);

        MockHttpServletResponse response = execute("POST", "/api/workspaces/acme/partners");

        assertThat(response.getStatus()).isEqualTo(403);
        assertThat(response.getContentAsString())
                .contains("\"success\":false")
                .contains("\"code\":\"AUTH-008\"")
                .contains("\"data\":null");
    }

    @ParameterizedTest
    @CsvSource({
            "POST, /api/workspaces/acme/parts, STAFF_PART_CREATE",
            "PATCH, /api/workspaces/acme/parts/10, STAFF_PART_CREATE",
            "POST, /api/workspaces/acme/categories, STAFF_CATEGORY_MANAGE",
            "DELETE, /api/workspaces/acme/categories/10, STAFF_CATEGORY_MANAGE"
    })
    void blocksPartAndCategoryWritesWithoutRequiredPermission(
            String method,
            String path,
            StaffPermission permission
    ) throws Exception {
        when(staffPermissionService.isEnabled(1L, permission)).thenReturn(false);

        MockHttpServletResponse response = execute(method, path);

        assertThat(response.getStatus()).isEqualTo(403);
        assertThat(response.getContentAsString()).contains("AUTH-008");
        verify(staffPermissionService).isEnabled(1L, permission);
    }

    @ParameterizedTest
    @CsvSource({
            "GET, /api/workspaces/acme/parts",
            "GET, /api/workspaces/acme/categories"
    })
    void allowsPartAndCategoryReadsWithoutManagementPermission(String method, String path) throws Exception {
        MockHttpServletResponse response = execute(method, path);

        assertThat(response.getStatus()).isEqualTo(200);
        verifyNoInteractions(staffPermissionService);
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
