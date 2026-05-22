package com.pcs.domain.auth.entity;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import java.time.LocalDateTime;

public class AuthMember {

    private Long companyId;
    private String companyCode;
    private boolean companyActive;
    private Long memberId;
    private String loginId;
    private String passwordHash;
    private String name;
    private MemberRole role;
    private PasswordStatus passwordStatus;
    private LocalDateTime tempPasswordExpiresAt;
    private boolean active;
    private Integer loginFailedCount;
    private LocalDateTime lockedUntilAt;

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

    public String getPasswordHash() {
        return passwordHash;
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

    public LocalDateTime getTempPasswordExpiresAt() {
        return tempPasswordExpiresAt;
    }

    public boolean isActive() {
        return active;
    }

    public int getLoginFailedCount() {
        return loginFailedCount == null ? 0 : loginFailedCount;
    }

    public LocalDateTime getLockedUntilAt() {
        return lockedUntilAt;
    }

    public boolean isLocked(LocalDateTime now) {
        return lockedUntilAt != null && lockedUntilAt.isAfter(now);
    }

    public boolean isTemporaryPasswordExpired(LocalDateTime now) {
        return passwordStatus == PasswordStatus.TEMPORARY
                && tempPasswordExpiresAt != null
                && tempPasswordExpiresAt.isBefore(now);
    }

    public boolean isPasswordChangeRequired() {
        return passwordStatus == PasswordStatus.TEMPORARY;
    }
}
