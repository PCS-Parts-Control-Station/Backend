package com.pcs.domain.auth.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.auth.dto.request.WorkspaceLoginRequest;
import com.pcs.domain.auth.dto.response.LoginResponse;
import com.pcs.domain.auth.dto.response.RefreshTokenResponse;
import com.pcs.domain.auth.dto.response.SessionMeResponse;
import com.pcs.domain.auth.facade.AuthFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class AuthApiControllerTest {

    @Mock
    private AuthFacade authFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        mockMvc = MockMvcBuilders
                .standaloneSetup(new AuthApiController(authFacade, false))
                .setControllerAdvice(new GlobalExceptionHandler())
                .setCustomArgumentResolvers(new AuthenticationPrincipalArgumentResolver())
                .setMessageConverters(new MappingJackson2HttpMessageConverter(objectMapper))
                .build();
        principal = new PcsPrincipal(7L, 1L, "acme", "admin01", MemberRole.ADMIN, Instant.now().plusSeconds(600));
        authenticate(principal);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void loginWorkspace_setsHttpOnlyRefreshCookie() throws Exception {
        WorkspaceLoginRequest request = new WorkspaceLoginRequest("acme", "admin01", "password");
        when(authFacade.loginWorkspace(any(WorkspaceLoginRequest.class), eq(null), eq("127.0.0.1"), eq("test-agent")))
                .thenReturn(new AuthFacade.LoginIssueResult(loginResponse(false), "refresh-token", 1209600L));

        mockMvc.perform(post("/api/workspaces/login")
                        .with(servletRequest -> {
                            servletRequest.setRemoteAddr("127.0.0.1");
                            servletRequest.addHeader(HttpHeaders.USER_AGENT, "test-agent");
                            return servletRequest;
                        })
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.SET_COOKIE, org.hamcrest.Matchers.containsString("pcsRefreshToken=refresh-token")))
                .andExpect(header().string(HttpHeaders.SET_COOKIE, org.hamcrest.Matchers.containsString("HttpOnly")))
                .andExpect(header().string(HttpHeaders.SET_COOKIE, org.hamcrest.Matchers.containsString("Path=/api/auth")))
                .andExpect(jsonPath("$.data.accessToken").value("access-token"))
                .andExpect(jsonPath("$.data.passwordChangeRequired").value(false));
    }

    @Test
    void loginWorkspaceByPath_usesPathCompanyCode() throws Exception {
        WorkspaceLoginRequest request = new WorkspaceLoginRequest(null, "admin01", "password");
        when(authFacade.loginWorkspace(any(WorkspaceLoginRequest.class), eq("acme"), eq("127.0.0.1"), eq("test-agent")))
                .thenReturn(new AuthFacade.LoginIssueResult(loginResponse(false), "refresh-token", 1209600L));

        mockMvc.perform(post("/api/workspaces/acme/login")
                        .with(servletRequest -> {
                            servletRequest.setRemoteAddr("127.0.0.1");
                            servletRequest.addHeader(HttpHeaders.USER_AGENT, "test-agent");
                            return servletRequest;
                        })
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.companyCode").value("acme"));
    }

    @Test
    void refresh_rotatesRefreshCookie() throws Exception {
        when(authFacade.refresh("old-refresh", "127.0.0.1", "test-agent"))
                .thenReturn(new AuthFacade.RefreshIssueResult(
                        new RefreshTokenResponse("new-access", "Bearer", 600),
                        "new-refresh",
                        1209600L
                ));

        mockMvc.perform(post("/api/auth/refresh")
                        .cookie(new jakarta.servlet.http.Cookie("pcsRefreshToken", "old-refresh"))
                        .with(servletRequest -> {
                            servletRequest.setRemoteAddr("127.0.0.1");
                            servletRequest.addHeader(HttpHeaders.USER_AGENT, "test-agent");
                            return servletRequest;
                        }))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.SET_COOKIE, org.hamcrest.Matchers.containsString("pcsRefreshToken=new-refresh")))
                .andExpect(jsonPath("$.data.accessToken").value("new-access"));
    }

    @Test
    void logout_expiresRefreshCookie() throws Exception {
        mockMvc.perform(post("/api/auth/logout")
                        .cookie(new jakarta.servlet.http.Cookie("pcsRefreshToken", "refresh-token")))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.SET_COOKIE, org.hamcrest.Matchers.containsString("pcsRefreshToken=")))
                .andExpect(header().string(HttpHeaders.SET_COOKIE, org.hamcrest.Matchers.containsString("Max-Age=0")));
    }

    @Test
    void me_returnsCurrentSession() throws Exception {
        when(authFacade.findMe(principal, "acme")).thenReturn(new SessionMeResponse(
                1L,
                "acme",
                7L,
                "admin01",
                "Admin User",
                MemberRole.ADMIN,
                PasswordStatus.ACTIVE,
                StaffPermission.all()
        ));

        mockMvc.perform(get("/api/workspaces/acme/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.loginId").value("admin01"))
                .andExpect(jsonPath("$.data.role").value("ADMIN"));
    }

    private void authenticate(PcsPrincipal principal) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        TestingAuthenticationToken authentication = new TestingAuthenticationToken(principal, null);
        authentication.setAuthenticated(true);
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    private LoginResponse loginResponse(boolean passwordChangeRequired) {
        return new LoginResponse(
                "access-token",
                "Bearer",
                600,
                1L,
                "acme",
                7L,
                "admin01",
                "Admin User",
                MemberRole.ADMIN,
                passwordChangeRequired
        );
    }
}
