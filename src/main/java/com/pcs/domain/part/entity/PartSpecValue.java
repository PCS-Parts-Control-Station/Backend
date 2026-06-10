package com.pcs.domain.part.entity;

import java.math.BigDecimal;

public class PartSpecValue {

    private Long specValueId;
    private Long companyId;
    private Long partId;
    private Long specDefinitionId;
    private String valueText;
    private BigDecimal valueNumber;
    private Boolean valueBoolean;
    private Long selectedOptionId;
    private String selectedOptionLabelSnapshot;
    private String selectedOptionValueSnapshot;

    public PartSpecValue() {
    }

    public PartSpecValue(
            Long companyId,
            Long partId,
            Long specDefinitionId,
            String valueText,
            BigDecimal valueNumber,
            Boolean valueBoolean,
            Long selectedOptionId,
            String selectedOptionLabelSnapshot,
            String selectedOptionValueSnapshot
    ) {
        this.companyId = companyId;
        this.partId = partId;
        this.specDefinitionId = specDefinitionId;
        this.valueText = valueText;
        this.valueNumber = valueNumber;
        this.valueBoolean = valueBoolean;
        this.selectedOptionId = selectedOptionId;
        this.selectedOptionLabelSnapshot = selectedOptionLabelSnapshot;
        this.selectedOptionValueSnapshot = selectedOptionValueSnapshot;
    }

    public Long getSpecValueId() {
        return specValueId;
    }

    public void setSpecValueId(Long specValueId) {
        this.specValueId = specValueId;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public Long getPartId() {
        return partId;
    }

    public void setPartId(Long partId) {
        this.partId = partId;
    }

    public Long getSpecDefinitionId() {
        return specDefinitionId;
    }

    public void setSpecDefinitionId(Long specDefinitionId) {
        this.specDefinitionId = specDefinitionId;
    }

    public String getValueText() {
        return valueText;
    }

    public void setValueText(String valueText) {
        this.valueText = valueText;
    }

    public BigDecimal getValueNumber() {
        return valueNumber;
    }

    public void setValueNumber(BigDecimal valueNumber) {
        this.valueNumber = valueNumber;
    }

    public Boolean getValueBoolean() {
        return valueBoolean;
    }

    public void setValueBoolean(Boolean valueBoolean) {
        this.valueBoolean = valueBoolean;
    }

    public Long getSelectedOptionId() {
        return selectedOptionId;
    }

    public void setSelectedOptionId(Long selectedOptionId) {
        this.selectedOptionId = selectedOptionId;
    }

    public String getSelectedOptionLabelSnapshot() {
        return selectedOptionLabelSnapshot;
    }

    public void setSelectedOptionLabelSnapshot(String selectedOptionLabelSnapshot) {
        this.selectedOptionLabelSnapshot = selectedOptionLabelSnapshot;
    }

    public String getSelectedOptionValueSnapshot() {
        return selectedOptionValueSnapshot;
    }

    public void setSelectedOptionValueSnapshot(String selectedOptionValueSnapshot) {
        this.selectedOptionValueSnapshot = selectedOptionValueSnapshot;
    }
}
