package com.pcs.global.jwt;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtValidationException;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.stereotype.Component;

@Component
public class JwtTokenProvider {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final String ACCESS_TOKEN_TYPE = "ACCESS";
    private static final String DEFAULT_LOCAL_SECRET = "pcs-local-development-jwt-secret-change-before-production-2026";
    private static final int MIN_SECRET_BYTE_LENGTH = 32;

    private final JwtEncoder jwtEncoder;
    private final JwtDecoder jwtDecoder;
    private final Duration accessTokenDuration;
    private final String issuer;
    private final String audience;

    public JwtTokenProvider(
            @Value("${pcs.jwt.secret}") String secret,
            @Value("${pcs.jwt.access-token-expiration-minutes}") long accessTokenExpirationMinutes,
            @Value("${pcs.jwt.allow-default-secret:false}") boolean allowDefaultSecret,
            @Value("${pcs.jwt.issuer:pcs}") String issuer,
            @Value("${pcs.jwt.audience:pcs-api}") String audience,
            Environment environment
    ) {
        validateSecret(secret, allowDefaultSecret, environment);
        this.issuer = requireConfiguration(issuer, "pcs.jwt.issuer");
        this.audience = requireConfiguration(audience, "pcs.jwt.audience");
        this.accessTokenDuration = Duration.ofMinutes(accessTokenExpirationMinutes);

        SecretKey secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM);
        this.jwtEncoder = new NimbusJwtEncoder(new ImmutableSecret<>(secretKey));
        NimbusJwtDecoder decoder = NimbusJwtDecoder.withSecretKey(secretKey)
                .macAlgorithm(MacAlgorithm.HS256)
                .build();
        decoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(this.issuer));
        this.jwtDecoder = decoder;
    }

    public String createAccessToken(
            Long memberId,
            Long companyId,
            String companyCode,
            String loginId,
            MemberRole role,
            String sessionId
    ) {
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plus(accessTokenDuration);
        String tokenId = UUID.randomUUID().toString();

        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256)
                .type("JWT")
                .build();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(issuer)
                .audience(List.of(audience))
                .subject(memberId.toString())
                .id(tokenId)
                .issuedAt(issuedAt)
                .expiresAt(expiresAt)
                .claim("memberId", memberId)
                .claim("companyId", companyId)
                .claim("companyCode", companyCode)
                .claim("loginId", loginId)
                .claim("role", role.name())
                .claim("tokenType", ACCESS_TOKEN_TYPE)
                .claim("sid", requireConfiguration(sessionId, "sessionId"))
                .build();
        return jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }

    public JwtClaims parseAccessToken(String token) {
        if (token == null || token.isBlank()) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }

        try {
            Jwt jwt = jwtDecoder.decode(token);
            String tokenType = requiredClaim(jwt, "tokenType");
            if (!ACCESS_TOKEN_TYPE.equals(tokenType) || !jwt.getAudience().contains(audience)) {
                throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
            }

            return new JwtClaims(
                    requiredLongClaim(jwt, "memberId"),
                    requiredLongClaim(jwt, "companyId"),
                    requiredClaim(jwt, "companyCode"),
                    requiredClaim(jwt, "loginId"),
                    MemberRole.valueOf(requiredClaim(jwt, "role")),
                    tokenType,
                    requiredClaim(jwt, "jti"),
                    requiredClaim(jwt, "sid"),
                    jwt.getIssuedAt(),
                    jwt.getExpiresAt()
            );
        } catch (JwtValidationException exception) {
            if (exception.getErrors().stream()
                    .map(error -> error.getDescription().toLowerCase())
                    .anyMatch(description -> description.contains("expired"))) {
                throw new BusinessException(ErrorCode.AUTH_TOKEN_EXPIRED);
            }
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        } catch (JwtException | IllegalArgumentException exception) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
    }

    public long getAccessTokenExpiresInSeconds() {
        return accessTokenDuration.toSeconds();
    }

    private String requiredClaim(Jwt jwt, String name) {
        String value = jwt.getClaimAsString(name);
        if (value == null || value.isBlank()) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
        return value;
    }

    private Long requiredLongClaim(Jwt jwt, String name) {
        Object value = jwt.getClaim(name);
        if (value instanceof Number number) {
            return number.longValue();
        }
        try {
            return Long.valueOf(requiredClaim(jwt, name));
        } catch (NumberFormatException exception) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
    }

    private void validateSecret(String secret, boolean allowDefaultSecret, Environment environment) {
        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException("pcs.jwt.secret must not be blank.");
        }
        if (secret.getBytes(StandardCharsets.UTF_8).length < MIN_SECRET_BYTE_LENGTH) {
            throw new IllegalStateException("pcs.jwt.secret must be at least 32 bytes for HS256.");
        }
        if (!allowDefaultSecret && DEFAULT_LOCAL_SECRET.equals(secret) && isProductionProfile(environment)) {
            throw new IllegalStateException("Default local JWT secret cannot be used with production profile.");
        }
    }

    private String requireConfiguration(String value, String name) {
        if (value == null || value.isBlank()) {
            throw new IllegalStateException(name + " must not be blank.");
        }
        return value.trim();
    }

    private boolean isProductionProfile(Environment environment) {
        for (String profile : environment.getActiveProfiles()) {
            if ("prod".equalsIgnoreCase(profile) || "production".equalsIgnoreCase(profile)) {
                return true;
            }
        }
        return false;
    }
}
