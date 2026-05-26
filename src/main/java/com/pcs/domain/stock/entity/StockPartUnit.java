package com.pcs.domain.stock.entity;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;

public class StockPartUnit {

    private Long unitId;
    private final Long companyId;
    private final Long partId;
    private final String internalSerialNo;
    private final String manufacturerSerialNo;
    private final UnitStatus unitStatus;
    private final PartGrade grade;
    private final InspectionStatus inspectionStatus;
    private final SalesStatus salesStatus;
    private final boolean active;
    private final Long createdBy;

    public StockPartUnit(
            Long companyId,
            Long partId,
            String internalSerialNo,
            String manufacturerSerialNo,
            UnitStatus unitStatus,
            PartGrade grade,
            InspectionStatus inspectionStatus,
            SalesStatus salesStatus,
            Long createdBy
    ) {
        this.companyId = companyId;
        this.partId = partId;
        this.internalSerialNo = internalSerialNo;
        this.manufacturerSerialNo = manufacturerSerialNo;
        this.unitStatus = unitStatus;
        this.grade = grade;
        this.inspectionStatus = inspectionStatus;
        this.salesStatus = salesStatus;
        this.active = true;
        this.createdBy = createdBy;
    }

    public Long getUnitId() {
        return unitId;
    }

    public void setUnitId(Long unitId) {
        this.unitId = unitId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public Long getPartId() {
        return partId;
    }

    public String getInternalSerialNo() {
        return internalSerialNo;
    }

    public String getManufacturerSerialNo() {
        return manufacturerSerialNo;
    }

    public UnitStatus getUnitStatus() {
        return unitStatus;
    }

    public PartGrade getGrade() {
        return grade;
    }

    public InspectionStatus getInspectionStatus() {
        return inspectionStatus;
    }

    public SalesStatus getSalesStatus() {
        return salesStatus;
    }

    public boolean isActive() {
        return active;
    }

    public Long getCreatedBy() {
        return createdBy;
    }
}
