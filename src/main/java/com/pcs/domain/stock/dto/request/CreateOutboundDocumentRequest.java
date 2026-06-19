package com.pcs.domain.stock.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateOutboundDocumentRequest(
        @NotNull(message = "거래처 ID는 필수입니다.")
        Long partnerId,

        @Size(max = 500, message = "전표 사유는 500자 이하로 입력해 주세요.")
        String reason,

        @NotEmpty(message = "출고 라인은 최소 1개 이상 필요합니다.")
        List<@Valid CreateOutboundDocumentLineRequest> lines
) {
}
