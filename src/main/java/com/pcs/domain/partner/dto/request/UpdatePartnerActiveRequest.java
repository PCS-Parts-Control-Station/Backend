package com.pcs.domain.partner.dto.request;

import jakarta.validation.constraints.NotNull;

public record UpdatePartnerActiveRequest(
        @NotNull(message = "활성화 여부를 선택해 주세요.")
        Boolean active
) {
}
