package com.pcs.domain.inspection.dto.request;

import com.pcs.domain.inspection.type.InspectionItemResultStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record CreateInspectionItemResultRequest(
        @NotNull(message = "itemId는 필수입니다.")
        Long itemId,

        @NotNull(message = "항목 결과는 필수입니다.")
        InspectionItemResultStatus result,

        @Size(max = 1000, message = "텍스트 값은 최대 1000자까지 입력할 수 있습니다.")
        String valueText,

        BigDecimal valueNumber,

        Long selectedOptionId,

        @Size(max = 1000, message = "항목 메모는 최대 1000자까지 입력할 수 있습니다.")
        String memo
) {
}
