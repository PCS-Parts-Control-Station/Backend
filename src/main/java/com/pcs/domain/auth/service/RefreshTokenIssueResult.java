package com.pcs.domain.auth.service;

import java.time.LocalDateTime;

public record RefreshTokenIssueResult(
        Long tokenId,
        String rawToken,
        String tokenHash,
        String tokenFamilyId,
        LocalDateTime expiresAt,
        long expiresInSeconds
) {
}
