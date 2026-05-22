package com.pcs.domain.auth.entity;

import java.time.LocalDateTime;

public class AuthRefreshToken {

    private Long tokenId;
    private final Long companyId;
    private final Long memberId;
    private final String refreshTokenHash;
    private final String tokenFamilyId;
    private final LocalDateTime expiresAt;
    private final String createdIp;
    private final String createdUserAgent;

    public AuthRefreshToken(
            Long companyId,
            Long memberId,
            String refreshTokenHash,
            String tokenFamilyId,
            LocalDateTime expiresAt,
            String createdIp,
            String createdUserAgent
    ) {
        this.companyId = companyId;
        this.memberId = memberId;
        this.refreshTokenHash = refreshTokenHash;
        this.tokenFamilyId = tokenFamilyId;
        this.expiresAt = expiresAt;
        this.createdIp = createdIp;
        this.createdUserAgent = createdUserAgent;
    }

    public Long getTokenId() {
        return tokenId;
    }

    public void setTokenId(Long tokenId) {
        this.tokenId = tokenId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public Long getMemberId() {
        return memberId;
    }

    public String getRefreshTokenHash() {
        return refreshTokenHash;
    }

    public String getTokenFamilyId() {
        return tokenFamilyId;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public String getCreatedIp() {
        return createdIp;
    }

    public String getCreatedUserAgent() {
        return createdUserAgent;
    }
}
