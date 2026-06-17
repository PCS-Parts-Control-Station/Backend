package com.pcs.domain.member.dto.response;

import java.time.LocalDateTime;

public record TemporaryPasswordResponse(
        String temporaryPassword,
        LocalDateTime expiresAt
) {
}
