package com.pcs.domain.category.entity;

public class PartSpecDefinition {

    private Long specDefinitionId;
    private Long companyId;
    private Long categoryId;
    private String specKey;
    private String specName;
    private String inputType;
    private String unit;
    private Boolean required;
    private Boolean searchable;
    private Integer sortOrder;
    private Boolean active;
    private Long createdBy;

    public PartSpecDefinition() {
    }

    public PartSpecDefinition(
            Long companyId,
            Long categoryId,
            String specKey,
            String specName,
            String inputType,
            String unit,
            Boolean required,
            Boolean searchable,
            Integer sortOrder,
            Long createdBy
    ) {
        this.companyId = companyId;
        this.categoryId = categoryId;
        this.specKey = specKey;
        this.specName = specName;
        this.inputType = inputType;
        this.unit = unit;
        this.required = required;
        this.searchable = searchable;
        this.sortOrder = sortOrder;
        this.active = true;
        this.createdBy = createdBy;
    }

    public Long getSpecDefinitionId() {
        return specDefinitionId;
    }

    public void setSpecDefinitionId(Long specDefinitionId) {
        this.specDefinitionId = specDefinitionId;
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

    public String getSpecKey() {
        return specKey;
    }

    public void setSpecKey(String specKey) {
        this.specKey = specKey;
    }

    public String getSpecName() {
        return specName;
    }

    public void setSpecName(String specName) {
        this.specName = specName;
    }

    public String getInputType() {
        return inputType;
    }

    public void setInputType(String inputType) {
        this.inputType = inputType;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Boolean getRequired() {
        return required;
    }

    public void setRequired(Boolean required) {
        this.required = required;
    }

    public Boolean getSearchable() {
        return searchable;
    }

    public void setSearchable(Boolean searchable) {
        this.searchable = searchable;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }
}
