package com.pcs.domain.auth.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.entity.AuthRefreshTokenSession;
import com.pcs.domain.auth.mapper.AuthMapper;
import com.pcs.domain.auth.type.RefreshTokenRevokedReason;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDateTime;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AuthMapper authMapper;
    @Mock
    private StaffPermissionService staffPermissionService;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private AuthRefreshTokenSession session;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(authMapper, staffPermissionService, passwordEncoder, 30);
    }

    @Test
    void authenticateWorkspace_masksMissingAccountAndRunsDummyPasswordCheck() {
        when(authMapper.countRecentLoginFailures(
                org.mockito.ArgumentMatchers.eq("acme"),
                org.mockito.ArgumentMatchers.eq("127.0.0.1"),
                org.mockito.ArgumentMatchers.any(LocalDateTime.class)
        )).thenReturn(0L);
        when(authMapper.findLoginMember("acme", "missing")).thenReturn(null);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.authenticateWorkspace("acme", "missing", "password", "127.0.0.1", "test")
        );

        assertEquals(ErrorCode.AUTH_LOGIN_FAILED, exception.getErrorCode());
        verify(passwordEncoder).matches(org.mockito.ArgumentMatchers.eq("password"), org.mockito.ArgumentMatchers.any());
    }

    @Test
    void authenticateWorkspace_masksLockedAccount() {
        AuthMember member = org.mockito.Mockito.mock(AuthMember.class);
        when(authMapper.findLoginMember("acme", "admin")).thenReturn(member);
        when(member.getPasswordHash()).thenReturn("hash");
        when(member.isCompanyActive()).thenReturn(true);
        when(member.isActive()).thenReturn(true);
        when(member.isLocked(org.mockito.ArgumentMatchers.any(LocalDateTime.class))).thenReturn(true);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.authenticateWorkspace("acme", "admin", "password", null, "test")
        );

        assertEquals(ErrorCode.AUTH_LOGIN_FAILED, exception.getErrorCode());
    }

    @Test
    void authenticateWorkspace_fifthPasswordFailureLocksAccountForTenMinutes() {
        AuthMember member = org.mockito.Mockito.mock(AuthMember.class);
        when(authMapper.findLoginMember("acme", "admin")).thenReturn(member);
        when(member.getPasswordHash()).thenReturn("hash");
        when(member.isCompanyActive()).thenReturn(true);
        when(member.isActive()).thenReturn(true);
        when(member.isLocked(org.mockito.ArgumentMatchers.any(LocalDateTime.class))).thenReturn(false);
        when(member.getLoginFailedCount()).thenReturn(4);
        when(member.getCompanyId()).thenReturn(10L);
        when(member.getMemberId()).thenReturn(20L);
        when(member.getCompanyCode()).thenReturn("acme");
        when(member.getLoginId()).thenReturn("admin");
        when(passwordEncoder.matches("wrong-password", "hash")).thenReturn(false);
        LocalDateTime beforeAttempt = LocalDateTime.now();

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.authenticateWorkspace("acme", "admin", "wrong-password", null, "test")
        );

        ArgumentCaptor<LocalDateTime> lockedUntilCaptor = ArgumentCaptor.forClass(LocalDateTime.class);
        verify(authMapper).recordLoginFailure(
                org.mockito.ArgumentMatchers.eq(10L),
                org.mockito.ArgumentMatchers.eq(20L),
                lockedUntilCaptor.capture()
        );
        assertEquals(ErrorCode.AUTH_LOGIN_FAILED, exception.getErrorCode());
        org.assertj.core.api.Assertions.assertThat(lockedUntilCaptor.getValue())
                .isAfterOrEqualTo(beforeAttempt.plusMinutes(10))
                .isBeforeOrEqualTo(LocalDateTime.now().plusMinutes(10));
    }

    @Test
    void authenticateWorkspace_rejectsIpRateLimitBeforeAccountLookup() {
        when(authMapper.countRecentLoginFailures(
                org.mockito.ArgumentMatchers.eq("acme"),
                org.mockito.ArgumentMatchers.eq("127.0.0.1"),
                org.mockito.ArgumentMatchers.any(LocalDateTime.class)
        )).thenReturn(30L);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.authenticateWorkspace("acme", "admin", "password", "127.0.0.1", "test")
        );

        assertEquals(ErrorCode.AUTH_LOGIN_FAILED, exception.getErrorCode());
        verify(authMapper, never()).findLoginMember("acme", "admin");
    }

    @Test
    void revokeRefreshTokenFamilyByRawValue_revokesFamilyEvenWhenPresentedTokenWasRotated() {
        when(authMapper.findRefreshTokenSession(org.mockito.ArgumentMatchers.anyString())).thenReturn(session);
        when(session.getCompanyId()).thenReturn(10L);
        when(session.getMemberId()).thenReturn(20L);
        when(session.getTokenFamilyId()).thenReturn("family-1");

        authService.revokeRefreshTokenFamilyByRawValue("rotated-refresh-token", RefreshTokenRevokedReason.LOGOUT);

        verify(authMapper).revokeRefreshTokenFamily(
                10L,
                20L,
                "family-1",
                RefreshTokenRevokedReason.LOGOUT
        );
        verify(session, never()).isRevoked();
    }

    @Test
    void validateRefreshToken_reuseOfRotatedTokenRevokesActiveFamily() {
        when(authMapper.findRefreshTokenSession(org.mockito.ArgumentMatchers.anyString())).thenReturn(session);
        when(session.isRevoked()).thenReturn(true);
        when(session.isRotated()).thenReturn(true);
        when(session.getCompanyId()).thenReturn(10L);
        when(session.getMemberId()).thenReturn(20L);
        when(session.getTokenFamilyId()).thenReturn("family-1");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.validateRefreshToken("rotated-refresh-token")
        );

        assertEquals(ErrorCode.AUTH_TOKEN_INVALID, exception.getErrorCode());
        verify(authMapper).revokeRefreshTokenFamily(
                10L,
                20L,
                "family-1",
                RefreshTokenRevokedReason.REUSE_DETECTED
        );
    }
}
