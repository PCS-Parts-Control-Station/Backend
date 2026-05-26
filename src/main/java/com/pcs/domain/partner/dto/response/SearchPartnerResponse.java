package com.pcs.domain.partner.dto.response;

import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;

public record SearchPartnerResponse(
        Long partnerId,
        String partnerName,
        PartnerType partnerType,
        PartnerRole partnerRole,
        String phone,
        Boolean active
) {
}
