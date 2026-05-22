package com.pcs.domain.auth.dto.response;

public record RefreshTokenResponse(
        String accessToken,
        String tokenType,
        long expiresInSeconds
) {
}
