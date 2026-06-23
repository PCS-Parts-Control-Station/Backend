package com.pcs.domain.part.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreatePartRequest(
        @NotNull(message = "분류를 선택해 주세요.")
        Long categoryId,

        @NotBlank(message = "품목명을 입력해 주세요.")
        @Size(max = 150, message = "품목명은 150자 이하로 입력해 주세요.")
        String partName,

        @NotBlank(message = "제조사를 입력해 주세요.")
        @Size(max = 100, message = "제조사는 100자 이하로 입력해 주세요.")
        String manufacturer,

        @NotBlank(message = "제조사 모델명을 입력해 주세요.")
        @Size(max = 150, message = "제조사 모델명은 150자 이하로 입력해 주세요.")
        String modelName,

        @PositiveOrZero(message = "안전 재고는 0 이상이어야 합니다.")
        Integer safeQuantity,

        @Valid
        List<PartSpecValueRequest> specValues
) {
}
