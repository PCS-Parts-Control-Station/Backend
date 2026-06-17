package com.pcs.domain.auth.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import com.pcs.domain.auth.entity.AuthRefreshTokenSession;
import com.pcs.domain.auth.mapper.AuthMapper;
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
}
