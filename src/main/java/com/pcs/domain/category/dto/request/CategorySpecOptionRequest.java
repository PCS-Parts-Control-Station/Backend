package com.pcs.domain.category.dto.request;

import jakarta.validation.constraints.Size;

public record CategorySpecOptionRequest(
        @Size(max = 100, message = "스펙 선택지명은 100자 이하로 입력해 주세요.")
        String optionLabel,

        @Size(max = 100, message = "스펙 선택지 값은 100자 이하로 입력해 주세요.")
        String optionValue,

        Integer sortOrder
) {
}
