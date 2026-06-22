package com.pcs.global.jwt;

import com.pcs.domain.member.type.MemberRole;
import java.time.Instant;

public record JwtClaims(
        Long memberId,
        Long companyId,
        String companyCode,
        String loginId,
        MemberRole role,
        String tokenType,
        String tokenId,
        String sessionId,
        Instant issuedAt,
        Instant expiresAt
) {

    public JwtClaims(
            Long memberId,
            Long companyId,
            String companyCode,
            String loginId,
            MemberRole role,
            String tokenType,
            Instant expiresAt
    ) {
        this(
                memberId,
                companyId,
                companyCode,
                loginId,
                role,
                tokenType,
                null,
                null,
                null,
                expiresAt
        );
    }
}
