package com.pcs.domain.auth.service;

import java.time.LocalDateTime;

public record RefreshTokenIssueResult(
        Long tokenId,
        String rawToken,
        String tokenHash,
        LocalDateTime expiresAt,
        long expiresInSeconds
) {
}
