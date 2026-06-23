package com.pcs.global.security;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import com.pcs.domain.auth.mapper.AuthMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import java.time.Instant;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class AccessTokenSessionValidatorTest {

    @Mock
    private AuthMapper authMapper;

    private AccessTokenSessionValidator validator;

    @BeforeEach
    void setUp() {
        validator = new AccessTokenSessionValidator(authMapper);
    }

    @Test
    void acceptsAccessTokenBackedByActiveSessionFamily() {
        JwtClaims claims = claims();
        when(authMapper.existsActiveRefreshTokenFamily(10L, 20L, "family-1")).thenReturn(true);

        assertDoesNotThrow(() -> validator.validate(claims));
    }

    @Test
    void rejectsAccessTokenWhenSessionFamilyWasRevoked() {
        JwtClaims claims = claims();
        when(authMapper.existsActiveRefreshTokenFamily(10L, 20L, "family-1")).thenReturn(false);

        BusinessException exception = assertThrows(BusinessException.class, () -> validator.validate(claims));

        assertEquals(ErrorCode.AUTH_TOKEN_INVALID, exception.getErrorCode());
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
