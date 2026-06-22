package com.pcs.domain.member.dto.response;

import java.time.LocalDateTime;

public record CreateMemberResponse(
        SearchMemberResponse member,
        String temporaryPassword,
        LocalDateTime expiresAt
) {
}
