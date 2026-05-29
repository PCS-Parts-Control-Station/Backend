package com.pcs.domain.partner.entity;

import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import java.time.LocalDateTime;

public class Partner {

    private Long partnerId;
    private Long companyId;
    private String partnerName;
    private PartnerType partnerType;
    private PartnerRole partnerRole;
    private String phone;
    private String email;
    private String address;
    private String memo;
    private boolean active;
    private Long createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Partner() {
    }

    public Partner(
            Long companyId,
            String partnerName,
            PartnerType partnerType,
            PartnerRole partnerRole,
            String phone,
            String email,
            String address,
            String memo,
            Long createdBy
    ) {
        this.companyId = companyId;
        this.partnerName = partnerName;
        this.partnerType = partnerType;
        this.partnerRole = partnerRole;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.memo = memo;
        this.active = true;
        this.createdBy = createdBy;
    }

    public Long getPartnerId() {
        return partnerId;
    }

    public void setPartnerId(Long partnerId) {
        this.partnerId = partnerId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public String getPartnerName() {
        return partnerName;
    }

    public void setPartnerName(String partnerName) {
        this.partnerName = partnerName;
    }

    public PartnerType getPartnerType() {
        return partnerType;
    }

    public void setPartnerType(PartnerType partnerType) {
        this.partnerType = partnerType;
    }

    public PartnerRole getPartnerRole() {
        return partnerRole;
    }

    public void setPartnerRole(PartnerRole partnerRole) {
        this.partnerRole = partnerRole;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
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
