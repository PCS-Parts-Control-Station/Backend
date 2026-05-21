package com.pcs.domain.member.entity;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import java.time.LocalDateTime;

public class Member {

    private Long memberId;
    private final Long companyId;
    private final String loginId;
    private final String passwordHash;
    private final String name;
    private final MemberRole role;
    private final Integer ownerSlot;
    private final PasswordStatus passwordStatus;
    private final LocalDateTime tempPasswordExpiresAt;
    private final boolean active;
    private final Long createdBy;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Member(
            Long companyId,
            String loginId,
            String passwordHash,
            String name,
            MemberRole role,
            Integer ownerSlot,
            PasswordStatus passwordStatus,
            LocalDateTime tempPasswordExpiresAt,
            Long createdBy
    ) {
        this.companyId = companyId;
        this.loginId = loginId;
        this.passwordHash = passwordHash;
        this.name = name;
        this.role = role;
        this.ownerSlot = ownerSlot;
        this.passwordStatus = passwordStatus;
        this.tempPasswordExpiresAt = tempPasswordExpiresAt;
        this.active = true;
        this.createdBy = createdBy;
    }

    public Long getMemberId() {
        return memberId;
    }

    public void setMemberId(Long memberId) {
        this.memberId = memberId;
    }

    public Long getCompanyId() {
        return companyId;
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

    public Integer getOwnerSlot() {
        return ownerSlot;
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

    public Long getCreatedBy() {
        return createdBy;
    }

    public LocalDateTime getLastLoginAt() {
        return lastLoginAt;
    }

    public void setLastLoginAt(LocalDateTime lastLoginAt) {
        this.lastLoginAt = lastLoginAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
