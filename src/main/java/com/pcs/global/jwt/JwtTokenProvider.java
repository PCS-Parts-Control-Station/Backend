package com.pcs.global.jwt;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class JwtTokenProvider {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final String ACCESS_TOKEN_TYPE = "ACCESS";
    private static final TypeReference<Map<String, Object>> MAP_TYPE = new TypeReference<>() {
    };

    private final ObjectMapper objectMapper;
    private final byte[] secretBytes;
    private final Duration accessTokenDuration;

    public JwtTokenProvider(
            ObjectMapper objectMapper,
            @Value("${pcs.jwt.secret}") String secret,
            @Value("${pcs.jwt.access-token-expiration-minutes}") long accessTokenExpirationMinutes
    ) {
        this.objectMapper = objectMapper;
        this.secretBytes = secret.getBytes(StandardCharsets.UTF_8);
        this.accessTokenDuration = Duration.ofMinutes(accessTokenExpirationMinutes);
    }

    public String createAccessToken(
            Long memberId,
            Long companyId,
            String companyCode,
            String loginId,
            MemberRole role
    ) {
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plus(accessTokenDuration);

        Map<String, Object> header = new LinkedHashMap<>();
        header.put("alg", "HS256");
        header.put("typ", "JWT");

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("sub", memberId.toString());
        payload.put("memberId", memberId);
        payload.put("companyId", companyId);
        payload.put("companyCode", companyCode);
        payload.put("loginId", loginId);
        payload.put("role", role.name());
        payload.put("tokenType", ACCESS_TOKEN_TYPE);
        payload.put("iat", issuedAt.getEpochSecond());
        payload.put("exp", expiresAt.getEpochSecond());

        String encodedHeader = encodeJson(header);
        String encodedPayload = encodeJson(payload);
        String signingInput = encodedHeader + "." + encodedPayload;
        return signingInput + "." + sign(signingInput);
    }

    public JwtClaims parseAccessToken(String token) {
        Map<String, Object> payload = parseAndVerify(token);
        String tokenType = readString(payload, "tokenType");
        if (!ACCESS_TOKEN_TYPE.equals(tokenType)) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }

        Instant expiresAt = Instant.ofEpochSecond(readLong(payload, "exp"));
        if (expiresAt.isBefore(Instant.now())) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_EXPIRED);
        }

        return new JwtClaims(
                readLong(payload, "memberId"),
                readLong(payload, "companyId"),
                readString(payload, "companyCode"),
                readString(payload, "loginId"),
                MemberRole.valueOf(readString(payload, "role")),
                tokenType,
                expiresAt
        );
    }

    public long getAccessTokenExpiresInSeconds() {
        return accessTokenDuration.toSeconds();
    }

    private Map<String, Object> parseAndVerify(String token) {
        if (token == null || token.isBlank()) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }

        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }

        String signingInput = parts[0] + "." + parts[1];
        String expectedSignature = sign(signingInput);
        if (!constantTimeEquals(expectedSignature, parts[2])) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }

        try {
            byte[] payloadBytes = Base64.getUrlDecoder().decode(parts[1]);
            return objectMapper.readValue(payloadBytes, MAP_TYPE);
        } catch (Exception exception) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
    }

    private String encodeJson(Map<String, Object> value) {
        try {
            return Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(objectMapper.writeValueAsBytes(value));
        } catch (Exception exception) {
            throw new IllegalStateException("Failed to encode JWT JSON.", exception);
        }
    }

    private String sign(String value) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(secretBytes, HMAC_ALGORITHM));
            return Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) {
            throw new IllegalStateException("Failed to sign JWT.", exception);
        }
    }

    private boolean constantTimeEquals(String left, String right) {
        byte[] leftBytes = left.getBytes(StandardCharsets.UTF_8);
        byte[] rightBytes = right.getBytes(StandardCharsets.UTF_8);
        if (leftBytes.length != rightBytes.length) {
            return false;
        }

        int result = 0;
        for (int index = 0; index < leftBytes.length; index++) {
            result |= leftBytes[index] ^ rightBytes[index];
        }
        return result == 0;
    }

    private String readString(Map<String, Object> payload, String key) {
        Object value = payload.get(key);
        if (value == null) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
        return value.toString();
    }

    private Long readLong(Map<String, Object> payload, String key) {
        Object value = payload.get(key);
        if (value instanceof Number number) {
            return number.longValue();
        }
        try {
            return Long.parseLong(readString(payload, key));
        } catch (NumberFormatException exception) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
    }
}
