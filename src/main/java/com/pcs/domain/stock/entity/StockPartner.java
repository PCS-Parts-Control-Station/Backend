package com.pcs.domain.stock.entity;

import com.pcs.domain.partner.type.PartnerRole;

public class StockPartner {

    private Long partnerId;
    private PartnerRole partnerRole;
    private boolean active;

    public Long getPartnerId() {
        return partnerId;
    }

    public void setPartnerId(Long partnerId) {
        this.partnerId = partnerId;
    }

    public PartnerRole getPartnerRole() {
        return partnerRole;
    }

    public void setPartnerRole(PartnerRole partnerRole) {
        this.partnerRole = partnerRole;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
