package com.pcs.domain.auth.dto.response;

import com.pcs.domain.member.type.MemberRole;

public record LoginResponse(
        String accessToken,
        String tokenType,
        long expiresInSeconds,
        Long companyId,
        String companyCode,
        Long memberId,
        String loginId,
        String name,
        MemberRole role,
        boolean passwordChangeRequired
) {
}
