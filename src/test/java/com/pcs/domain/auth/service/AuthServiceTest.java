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
    void validateRefreshToken_rejectsTemporaryPasswordSession() {
        when(authMapper.findRefreshTokenSession(org.mockito.ArgumentMatchers.anyString())).thenReturn(session);
        when(session.isRevoked()).thenReturn(false);
        when(session.isExpired(org.mockito.ArgumentMatchers.any(LocalDateTime.class))).thenReturn(false);
        when(session.isCompanyActive()).thenReturn(true);
        when(session.isMemberActive()).thenReturn(true);
        when(session.getPasswordStatus()).thenReturn(PasswordStatus.TEMPORARY);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> authService.validateRefreshToken("refresh-token")
        );

        assertEquals(ErrorCode.MEMBER_PASSWORD_CHANGE_REQUIRED, exception.getErrorCode());
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
}
