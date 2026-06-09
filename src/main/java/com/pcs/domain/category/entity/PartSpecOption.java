package com.pcs.domain.category.entity;

public class PartSpecOption {

    private Long optionId;
    private Long specDefinitionId;
    private String optionLabel;
    private String optionValue;
    private Integer sortOrder;
    private Boolean active;

    public PartSpecOption() {
    }

    public PartSpecOption(
            Long specDefinitionId,
            String optionLabel,
            String optionValue,
            Integer sortOrder
    ) {
        this.specDefinitionId = specDefinitionId;
        this.optionLabel = optionLabel;
        this.optionValue = optionValue;
        this.sortOrder = sortOrder;
        this.active = true;
    }

    public Long getOptionId() {
        return optionId;
    }

    public void setOptionId(Long optionId) {
        this.optionId = optionId;
    }

    public Long getSpecDefinitionId() {
        return specDefinitionId;
    }

    public void setSpecDefinitionId(Long specDefinitionId) {
        this.specDefinitionId = specDefinitionId;
    }

    public String getOptionLabel() {
        return optionLabel;
    }

    public void setOptionLabel(String optionLabel) {
        this.optionLabel = optionLabel;
    }

    public String getOptionValue() {
        return optionValue;
    }

    public void setOptionValue(String optionValue) {
        this.optionValue = optionValue;
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
}
