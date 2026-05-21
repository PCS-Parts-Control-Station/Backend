package com.pcs.domain.company.entity;

import java.time.LocalDateTime;

public class Company {

    private Long companyId;
    private final String companyName;
    private final String companyCode;
    private final String representativeEmail;
    private final String representativePhone;
    private final String businessRegistrationNo;
    private final boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Company(
            String companyName,
            String companyCode,
            String representativeEmail,
            String representativePhone,
            String businessRegistrationNo
    ) {
        this.companyName = companyName;
        this.companyCode = companyCode;
        this.representativeEmail = representativeEmail;
        this.representativePhone = representativePhone;
        this.businessRegistrationNo = businessRegistrationNo;
        this.active = true;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public String getCompanyCode() {
        return companyCode;
    }

    public String getRepresentativeEmail() {
        return representativeEmail;
    }

    public String getRepresentativePhone() {
        return representativePhone;
    }

    public String getBusinessRegistrationNo() {
        return businessRegistrationNo;
    }

    public boolean isActive() {
        return active;
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
