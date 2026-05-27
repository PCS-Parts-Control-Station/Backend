package com.pcs.domain.partner.dto.response;

import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import java.time.LocalDateTime;

public record SearchPartnerResponse(
        Long partnerId,
        String partnerName,
        PartnerType partnerType,
        PartnerRole partnerRole,
        String phone,
        String email,
        String address,
        String memo,
        Boolean active,
        LocalDateTime updatedAt
) {
}
