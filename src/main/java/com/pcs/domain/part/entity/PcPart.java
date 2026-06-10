package com.pcs.domain.part.entity;

import java.math.BigDecimal;

public class PcPart {

    private Long partId;
    private Long companyId;
    private Long categoryId;
    private Long createdBy;
    private String partName;
    private String modelName;
    private String manufacturer;
    private String partCode;
    private BigDecimal estimatedPrice;
    private Integer safeQuantity;
    private Boolean active;

    public PcPart() {
    }

    public PcPart(
            Long companyId,
            Long categoryId,
            Long createdBy,
            String partName,
            String modelName,
            String manufacturer,
            String partCode,
            BigDecimal estimatedPrice,
            Integer safeQuantity
    ) {
        this.companyId = companyId;
        this.categoryId = categoryId;
        this.createdBy = createdBy;
        this.partName = partName;
        this.modelName = modelName;
        this.manufacturer = manufacturer;
        this.partCode = partCode;
        this.estimatedPrice = estimatedPrice;
        this.safeQuantity = safeQuantity;
        this.active = true;
    }

    public Long getPartId() {
        return partId;
    }

    public void setPartId(Long partId) {
        this.partId = partId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public String getPartName() {
        return partName;
    }

    public void setPartName(String partName) {
        this.partName = partName;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public String getManufacturer() {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer) {
        this.manufacturer = manufacturer;
    }

    public String getPartCode() {
        return partCode;
    }

    public void setPartCode(String partCode) {
        this.partCode = partCode;
    }

    public BigDecimal getEstimatedPrice() {
        return estimatedPrice;
    }

    public void setEstimatedPrice(BigDecimal estimatedPrice) {
        this.estimatedPrice = estimatedPrice;
    }

    public Integer getSafeQuantity() {
        return safeQuantity;
    }

    public void setSafeQuantity(Integer safeQuantity) {
        this.safeQuantity = safeQuantity;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}
