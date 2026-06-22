package com.pcs.global.security;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.jwt.JwtClaims;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

public record PcsPrincipal(
        Long memberId,
        Long companyId,
        String companyCode,
        String loginId,
        MemberRole role,
        String tokenId,
        String sessionId,
        Instant tokenExpiresAt
) {

    public PcsPrincipal(
            Long memberId,
            Long companyId,
            String companyCode,
            String loginId,
            MemberRole role,
            Instant tokenExpiresAt
    ) {
        this(memberId, companyId, companyCode, loginId, role, null, null, tokenExpiresAt);
    }

    public static PcsPrincipal from(JwtClaims claims) {
        return new PcsPrincipal(
                claims.memberId(),
                claims.companyId(),
                claims.companyCode(),
                claims.loginId(),
                claims.role(),
                claims.tokenId(),
                claims.sessionId(),
                claims.expiresAt()
        );
    }

    public Collection<? extends GrantedAuthority> authorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
}
