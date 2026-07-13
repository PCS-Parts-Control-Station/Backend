package com.pcs.domain.stock.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateOutboundDocumentLineRequest(
        @NotNull(message = "부품 ID는 필수입니다.")
        Long partId,

        @NotEmpty(message = "출고할 관리번호는 최소 1개 이상 필요합니다.")
        @Size(max = 1000, message = "한 라인에서 최대 1000개까지 출고할 수 있습니다.")
        List<@NotNull(message = "관리번호 ID는 필수입니다.") Long> unitIds,

        @Size(max = 500, message = "라인 사유는 500자 이하로 입력해 주세요.")
        String reason
) {
}
