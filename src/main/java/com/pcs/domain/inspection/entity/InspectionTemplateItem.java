package com.pcs.domain.inspection.entity;

import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;

public class InspectionTemplateItem {

    private Long itemId;
    private Long templateId;
    private InspectionItemGroup itemGroup;
    private String itemName;
    private InspectionInputType inputType;
    private boolean required;
    private int sortOrder;
    private GradeImpact gradeImpact;
    private InspectionFailPolicy failPolicy;
    private boolean active;

    public InspectionTemplateItem() {
    }

    public InspectionTemplateItem(
            Long templateId,
            InspectionItemGroup itemGroup,
            String itemName,
            InspectionInputType inputType,
            boolean required,
            int sortOrder,
            GradeImpact gradeImpact,
            InspectionFailPolicy failPolicy
    ) {
        this.templateId = templateId;
        this.itemGroup = itemGroup;
        this.itemName = itemName;
        this.inputType = inputType;
        this.required = required;
        this.sortOrder = sortOrder;
        this.gradeImpact = gradeImpact;
        this.failPolicy = failPolicy;
        this.active = true;
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }

    public InspectionItemGroup getItemGroup() {
        return itemGroup;
    }

    public void setItemGroup(InspectionItemGroup itemGroup) {
        this.itemGroup = itemGroup;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public InspectionInputType getInputType() {
        return inputType;
    }

    public void setInputType(InspectionInputType inputType) {
        this.inputType = inputType;
    }

    public boolean isRequired() {
        return required;
    }

    public void setRequired(boolean required) {
        this.required = required;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public GradeImpact getGradeImpact() {
        return gradeImpact;
    }

    public void setGradeImpact(GradeImpact gradeImpact) {
        this.gradeImpact = gradeImpact;
    }

    public InspectionFailPolicy getFailPolicy() {
        return failPolicy;
    }

    public void setFailPolicy(InspectionFailPolicy failPolicy) {
        this.failPolicy = failPolicy;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
