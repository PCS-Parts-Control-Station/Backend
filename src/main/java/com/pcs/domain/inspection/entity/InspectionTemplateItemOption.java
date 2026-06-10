package com.pcs.domain.inspection.entity;

public class InspectionTemplateItemOption {

    private Long optionId;
    private Long itemId;
    private String optionLabel;
    private String optionValue;
    private int sortOrder;
    private boolean active;

    public InspectionTemplateItemOption() {
    }

    public InspectionTemplateItemOption(
            Long itemId,
            String optionLabel,
            String optionValue,
            int sortOrder
    ) {
        this.itemId = itemId;
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

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
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

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
