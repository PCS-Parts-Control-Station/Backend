package com.pcs.domain.stock.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateInboundDocumentLineRequest(
        @NotNull(message = "부품 ID는 필수입니다.")
        Long partId,

        @NotNull(message = "수량은 필수입니다.")
        @Min(value = 1, message = "수량은 1 이상이어야 합니다.")
        @Max(value = 1000, message = "한 라인의 수량은 1000개 이하여야 합니다.")
        Integer quantity,

        @Size(max = 500, message = "라인 사유는 500자 이하로 입력해 주세요.")
        String reason
) {
}
