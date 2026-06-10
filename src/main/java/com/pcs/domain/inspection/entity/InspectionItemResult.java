package com.pcs.domain.inspection.entity;

import com.pcs.domain.inspection.type.InspectionItemResultStatus;
import java.math.BigDecimal;

public class InspectionItemResult {

    private Long itemResultId;
    private final Long inspectionId;
    private final Long itemId;
    private final String itemNameSnapshot;
    private final InspectionItemResultStatus result;
    private final String valueText;
    private final BigDecimal valueNumber;
    private final Long selectedOptionId;
    private final String selectedOptionLabelSnapshot;
    private final String selectedOptionValueSnapshot;
    private final String memo;

    public InspectionItemResult(
            Long inspectionId,
            Long itemId,
            String itemNameSnapshot,
            InspectionItemResultStatus result,
            String valueText,
            BigDecimal valueNumber,
            Long selectedOptionId,
            String selectedOptionLabelSnapshot,
            String selectedOptionValueSnapshot,
            String memo
    ) {
        this.inspectionId = inspectionId;
        this.itemId = itemId;
        this.itemNameSnapshot = itemNameSnapshot;
        this.result = result;
        this.valueText = valueText;
        this.valueNumber = valueNumber;
        this.selectedOptionId = selectedOptionId;
        this.selectedOptionLabelSnapshot = selectedOptionLabelSnapshot;
        this.selectedOptionValueSnapshot = selectedOptionValueSnapshot;
        this.memo = memo;
    }

    public Long getItemResultId() {
        return itemResultId;
    }

    public void setItemResultId(Long itemResultId) {
        this.itemResultId = itemResultId;
    }

    public Long getInspectionId() {
        return inspectionId;
    }

    public Long getItemId() {
        return itemId;
    }

    public String getItemNameSnapshot() {
        return itemNameSnapshot;
    }

    public InspectionItemResultStatus getResult() {
        return result;
    }

    public String getValueText() {
        return valueText;
    }

    public BigDecimal getValueNumber() {
        return valueNumber;
    }

    public Long getSelectedOptionId() {
        return selectedOptionId;
    }

    public String getSelectedOptionLabelSnapshot() {
        return selectedOptionLabelSnapshot;
    }

    public String getSelectedOptionValueSnapshot() {
        return selectedOptionValueSnapshot;
    }

    public String getMemo() {
        return memo;
    }
}
