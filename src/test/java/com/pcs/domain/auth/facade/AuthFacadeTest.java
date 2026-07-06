package com.pcs.domain.auth.facade;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.auth.dto.request.WorkspaceLoginRequest;
import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.entity.AuthRefreshTokenSession;
import com.pcs.domain.auth.service.AuthService;
import com.pcs.domain.auth.service.RefreshTokenIssueResult;
import com.pcs.domain.auth.type.RefreshTokenRevokedReason;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtTokenProvider;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import java.time.LocalDateTime;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class AuthFacadeTest {

    @Mock
    private AuthService authService;
    @Mock
    private JwtTokenProvider jwtTokenProvider;
    @Mock
    private AuthMember authMember;
    @Mock
    private AuthRefreshTokenSession refreshSession;

    private AuthFacade authFacade;

    @BeforeEach
    void setUp() {
        authFacade = new AuthFacade(authService, jwtTokenProvider);
    }

    @Test
    void loginWorkspace_usesBodyCompanyCodeWhenPathIsMissing() {
        WorkspaceLoginRequest request = new WorkspaceLoginRequest(" ACME ", "admin01", "password");
        givenMember(MemberRole.ADMIN, false);
        givenRefreshToken(100L, "refresh-token", "family-1", 1209600L);
        when(authService.authenticateWorkspace("acme", "admin01", "password", "127.0.0.1", "agent"))
                .thenReturn(authMember);
        when(jwtTokenProvider.createAccessToken(7L, 1L, "acme", "admin01", MemberRole.ADMIN, "family-1"))
                .thenReturn("access-token");
        when(jwtTokenProvider.getAccessTokenExpiresInSeconds()).thenReturn(600L);

        AuthFacade.LoginIssueResult result = authFacade.loginWorkspace(request, null, "127.0.0.1", "agent");

        assertThat(result.response().accessToken()).isEqualTo("access-token");
        assertThat(result.response().companyCode()).isEqualTo("acme");
        assertThat(result.refreshToken()).isEqualTo("refresh-token");
    }

    @Test
    void loginWorkspace_usesPathCompanyCodeBeforeBodyCompanyCode() {
        WorkspaceLoginRequest request = new WorkspaceLoginRequest("wrong", "admin01", "password");
        givenMember(MemberRole.ADMIN, false);
        givenRefreshToken(100L, "refresh-token", "family-1", 1209600L);
        when(authService.authenticateWorkspace("acme", "admin01", "password", "127.0.0.1", "agent"))
                .thenReturn(authMember);
        when(jwtTokenProvider.createAccessToken(7L, 1L, "acme", "admin01", MemberRole.ADMIN, "family-1"))
                .thenReturn("access-token");
        when(jwtTokenProvider.getAccessTokenExpiresInSeconds()).thenReturn(600L);

        authFacade.loginWorkspace(request, " ACME ", "127.0.0.1", "agent");

        verify(authService).authenticateWorkspace("acme", "admin01", "password", "127.0.0.1", "agent");
    }

    @Test
    void loginOwner_rejectsMissingCompanyCode() {
        WorkspaceLoginRequest request = new WorkspaceLoginRequest(null, "owner01", "password");

        assertThatThrownBy(() -> authFacade.loginOwner(request, "127.0.0.1", "agent"))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE)
                );
    }

    @Test
    void refresh_rotatesRefreshTokenAndIssuesNewAccessToken() {
        when(authService.validateRefreshToken("old-refresh")).thenReturn(refreshSession);
        when(refreshSession.getCompanyId()).thenReturn(1L);
        when(refreshSession.getCompanyCode()).thenReturn("acme");
        when(refreshSession.getMemberId()).thenReturn(7L);
        when(refreshSession.getLoginId()).thenReturn("admin01");
        when(refreshSession.getRole()).thenReturn(MemberRole.ADMIN);
        when(refreshSession.getTokenFamilyId()).thenReturn("family-1");
        when(refreshSession.getTokenId()).thenReturn(10L);
        when(authService.issueRefreshToken(1L, 7L, "family-1", "127.0.0.1", "agent"))
                .thenReturn(new RefreshTokenIssueResult(
                        11L,
                        "new-refresh",
                        "new-hash",
                        "family-1",
                        LocalDateTime.now().plusDays(14),
                        1209600L
                ));
        when(jwtTokenProvider.createAccessToken(7L, 1L, "acme", "admin01", MemberRole.ADMIN, "family-1"))
                .thenReturn("new-access");
        when(jwtTokenProvider.getAccessTokenExpiresInSeconds()).thenReturn(600L);

        AuthFacade.RefreshIssueResult result = authFacade.refresh("old-refresh", "127.0.0.1", "agent");

        assertThat(result.response().accessToken()).isEqualTo("new-access");
        assertThat(result.refreshToken()).isEqualTo("new-refresh");
        verify(authService).revokeRefreshToken(10L, RefreshTokenRevokedReason.ROTATED, 11L);
    }

    @Test
    void findMe_requiresPrincipal() {
        assertThatThrownBy(() -> authFacade.findMe(null, "acme"))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_REQUIRED)
                );
    }

    @Test
    void logout_revokesRefreshTokenFamilyByRawValue() {
        authFacade.logout("refresh-token");

        verify(authService).revokeRefreshTokenFamilyByRawValue("refresh-token", RefreshTokenRevokedReason.LOGOUT);
    }

    private void givenMember(MemberRole role, boolean passwordChangeRequired) {
        when(authMember.getCompanyId()).thenReturn(1L);
        when(authMember.getCompanyCode()).thenReturn("acme");
        when(authMember.getMemberId()).thenReturn(7L);
        when(authMember.getLoginId()).thenReturn("admin01");
        when(authMember.getName()).thenReturn("Admin User");
        when(authMember.getRole()).thenReturn(role);
        when(authMember.isPasswordChangeRequired()).thenReturn(passwordChangeRequired);
    }

    private void givenRefreshToken(Long tokenId, String rawToken, String familyId, long expiresInSeconds) {
        when(authService.issueRefreshToken(1L, 7L, null, "127.0.0.1", "agent"))
                .thenReturn(new RefreshTokenIssueResult(
                        tokenId,
                        rawToken,
                        "hash",
                        familyId,
                        LocalDateTime.now().plusDays(14),
                        expiresInSeconds
                ));
    }

    @SuppressWarnings("unused")
    private PcsPrincipal principal() {
        return new PcsPrincipal(7L, 1L, "acme", "admin01", MemberRole.ADMIN, Instant.now().plusSeconds(600));
    }
}
