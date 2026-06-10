package com.pcs.domain.inspection.entity;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;

public class PartStatusHistory {

    private Long historyId;
    private final Long companyId;
    private final Long unitId;
    private final Long changedBy;
    private final InspectionStatus fromInspectionStatus;
    private final InspectionStatus toInspectionStatus;
    private final PartGrade fromGrade;
    private final PartGrade toGrade;
    private final SalesStatus fromSalesStatus;
    private final SalesStatus toSalesStatus;
    private final String reason;

    public PartStatusHistory(
            Long companyId,
            Long unitId,
            Long changedBy,
            InspectionStatus fromInspectionStatus,
            InspectionStatus toInspectionStatus,
            PartGrade fromGrade,
            PartGrade toGrade,
            SalesStatus fromSalesStatus,
            SalesStatus toSalesStatus,
            String reason
    ) {
        this.companyId = companyId;
        this.unitId = unitId;
        this.changedBy = changedBy;
        this.fromInspectionStatus = fromInspectionStatus;
        this.toInspectionStatus = toInspectionStatus;
        this.fromGrade = fromGrade;
        this.toGrade = toGrade;
        this.fromSalesStatus = fromSalesStatus;
        this.toSalesStatus = toSalesStatus;
        this.reason = reason;
    }

    public Long getHistoryId() {
        return historyId;
    }

    public void setHistoryId(Long historyId) {
        this.historyId = historyId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public Long getUnitId() {
        return unitId;
    }

    public Long getChangedBy() {
        return changedBy;
    }

    public InspectionStatus getFromInspectionStatus() {
        return fromInspectionStatus;
    }

    public InspectionStatus getToInspectionStatus() {
        return toInspectionStatus;
    }

    public PartGrade getFromGrade() {
        return fromGrade;
    }

    public PartGrade getToGrade() {
        return toGrade;
    }

    public SalesStatus getFromSalesStatus() {
        return fromSalesStatus;
    }

    public SalesStatus getToSalesStatus() {
        return toSalesStatus;
    }

    public String getReason() {
        return reason;
    }
}
