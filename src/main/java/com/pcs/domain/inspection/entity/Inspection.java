package com.pcs.domain.inspection.entity;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import java.time.LocalDateTime;

public class Inspection {

    private Long inspectionId;
    private Long companyId;
    private Long unitId;
    private Long templateId;
    private Long inspectedBy;
    private InspectionType inspectionType;
    private Long originalInspectionId;
    private SalesStatus salesStatus;
    private InspectionResult result;
    private PartGrade grade;
    private String memo;
    private LocalDateTime inspectedAt;

    public Inspection() {
    }

    public Inspection(
            Long companyId,
            Long unitId,
            Long templateId,
            Long inspectedBy,
            InspectionType inspectionType,
            Long originalInspectionId,
            SalesStatus salesStatus,
            InspectionResult result,
            PartGrade grade,
            String memo,
            LocalDateTime inspectedAt
    ) {
        this.companyId = companyId;
        this.unitId = unitId;
        this.templateId = templateId;
        this.inspectedBy = inspectedBy;
        this.inspectionType = inspectionType;
        this.originalInspectionId = originalInspectionId;
        this.salesStatus = salesStatus;
        this.result = result;
        this.grade = grade;
        this.memo = memo;
        this.inspectedAt = inspectedAt;
    }

    public Long getInspectionId() {
        return inspectionId;
    }

    public void setInspectionId(Long inspectionId) {
        this.inspectionId = inspectionId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public Long getUnitId() {
        return unitId;
    }

    public void setUnitId(Long unitId) {
        this.unitId = unitId;
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }

    public Long getInspectedBy() {
        return inspectedBy;
    }

    public void setInspectedBy(Long inspectedBy) {
        this.inspectedBy = inspectedBy;
    }

    public InspectionType getInspectionType() {
        return inspectionType;
    }

    public void setInspectionType(InspectionType inspectionType) {
        this.inspectionType = inspectionType;
    }

    public Long getOriginalInspectionId() {
        return originalInspectionId;
    }

    public void setOriginalInspectionId(Long originalInspectionId) {
        this.originalInspectionId = originalInspectionId;
    }

    public SalesStatus getSalesStatus() {
        return salesStatus;
    }

    public void setSalesStatus(SalesStatus salesStatus) {
        this.salesStatus = salesStatus;
    }

    public InspectionResult getResult() {
        return result;
    }

    public void setResult(InspectionResult result) {
        this.result = result;
    }

    public PartGrade getGrade() {
        return grade;
    }

    public void setGrade(PartGrade grade) {
        this.grade = grade;
    }

    public String getMemo() {
        return memo;
    }

    public void setMemo(String memo) {
        this.memo = memo;
    }

    public LocalDateTime getInspectedAt() {
        return inspectedAt;
    }

    public void setInspectedAt(LocalDateTime inspectedAt) {
        this.inspectedAt = inspectedAt;
    }
}
