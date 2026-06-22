package com.pcs.global.jwt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

class JwtTokenProviderTest {

    private static final String SECRET = "pcs-test-jwt-secret-that-is-longer-than-thirty-two-bytes";

    @Test
    void createsAndParsesStandardAccessTokenClaims() {
        JwtTokenProvider provider = provider("pcs-api");

        String token = provider.createAccessToken(10L, 1L, "acme", "admin", MemberRole.ADMIN, "session-1");
        JwtClaims claims = provider.parseAccessToken(token);

        assertEquals(10L, claims.memberId());
        assertEquals(1L, claims.companyId());
        assertEquals("acme", claims.companyCode());
        assertEquals("session-1", claims.sessionId());
        assertFalse(claims.tokenId().isBlank());
        assertTrue(claims.expiresAt().isAfter(claims.issuedAt()));
    }

    @Test
    void rejectsTamperedSignature() {
        JwtTokenProvider provider = provider("pcs-api");
        String token = provider.createAccessToken(10L, 1L, "acme", "admin", MemberRole.ADMIN, "session-1");
        String tampered = token.substring(0, token.length() - 1) + (token.endsWith("a") ? "b" : "a");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> provider.parseAccessToken(tampered)
        );

        assertEquals(ErrorCode.AUTH_TOKEN_INVALID, exception.getErrorCode());
    }

    @Test
    void rejectsTokenForDifferentAudience() {
        String token = provider("other-api").createAccessToken(
                10L,
                1L,
                "acme",
                "admin",
                MemberRole.ADMIN,
                "session-1"
        );

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> provider("pcs-api").parseAccessToken(token)
        );

        assertEquals(ErrorCode.AUTH_TOKEN_INVALID, exception.getErrorCode());
    }

    @Test
    void preservesExpiredTokenErrorCode() {
        Instant expiredAt = Instant.now().minus(Duration.ofMinutes(1));
        NimbusJwtEncoder encoder = new NimbusJwtEncoder(new ImmutableSecret<>(
                new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256")
        ));
        String token = encoder.encode(JwtEncoderParameters.from(
                JwsHeader.with(MacAlgorithm.HS256).type("JWT").build(),
                JwtClaimsSet.builder()
                        .issuer("pcs")
                        .audience(List.of("pcs-api"))
                        .subject("10")
                        .id("token-id")
                        .issuedAt(expiredAt.minus(Duration.ofMinutes(10)))
                        .expiresAt(expiredAt)
                        .claim("memberId", 10L)
                        .claim("companyId", 1L)
                        .claim("companyCode", "acme")
                        .claim("loginId", "admin")
                        .claim("role", "ADMIN")
                        .claim("tokenType", "ACCESS")
                        .claim("sid", "session-1")
                        .build()
        )).getTokenValue();

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> provider("pcs-api").parseAccessToken(token)
        );

        assertEquals(ErrorCode.AUTH_TOKEN_EXPIRED, exception.getErrorCode());
    }

    @Test
    void rejectsDefaultSecretInProduction() {
        MockEnvironment environment = new MockEnvironment();
        environment.setActiveProfiles("prod");

        assertThrows(
                IllegalStateException.class,
                () -> new JwtTokenProvider(
                        "pcs-local-development-jwt-secret-change-before-production-2026",
                        10,
                        false,
                        "pcs",
                        "pcs-api",
                        environment
                )
        );
    }

    private JwtTokenProvider provider(String audience) {
        return new JwtTokenProvider(SECRET, 10, true, "pcs", audience, new MockEnvironment());
    }
}
