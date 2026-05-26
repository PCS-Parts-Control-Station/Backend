package com.pcs.domain.auth.entity;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.auth.type.RefreshTokenRevokedReason;
import java.time.LocalDateTime;

public class AuthRefreshTokenSession {

    private Long tokenId;
    private Long companyId;
    private String companyCode;
    private boolean companyActive;
    private Long memberId;
    private String loginId;
    private String name;
    private MemberRole role;
    private PasswordStatus passwordStatus;
    private boolean memberActive;
    private String tokenFamilyId;
    private LocalDateTime expiresAt;
    private LocalDateTime revokedAt;
    private RefreshTokenRevokedReason revokedReason;

    public Long getTokenId() {
        return tokenId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public String getCompanyCode() {
        return companyCode;
    }

    public boolean isCompanyActive() {
        return companyActive;
    }

    public Long getMemberId() {
        return memberId;
    }

    public String getLoginId() {
        return loginId;
    }

    public String getName() {
        return name;
    }

    public MemberRole getRole() {
        return role;
    }

    public PasswordStatus getPasswordStatus() {
        return passwordStatus;
    }

    public boolean isMemberActive() {
        return memberActive;
    }

    public String getTokenFamilyId() {
        return tokenFamilyId;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public LocalDateTime getRevokedAt() {
        return revokedAt;
    }

    public RefreshTokenRevokedReason getRevokedReason() {
        return revokedReason;
    }

    public boolean isExpired(LocalDateTime now) {
        return expiresAt == null || expiresAt.isBefore(now);
    }

    public boolean isRevoked() {
        return revokedAt != null;
    }

    public boolean isRotated() {
        return revokedReason == RefreshTokenRevokedReason.ROTATED;
    }
}
