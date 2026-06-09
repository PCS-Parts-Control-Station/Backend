package com.pcs.domain.category.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CategorySpecDefinitionRequest(
        @Size(max = 80, message = "스펙 키는 80자 이하로 입력해 주세요.")
        String specKey,

        @Size(max = 100, message = "스펙 항목명은 100자 이하로 입력해 주세요.")
        String specName,

        @Pattern(regexp = "TEXT|NUMBER|SELECT|BOOLEAN", message = "스펙 입력 방식이 올바르지 않습니다.")
        String inputType,

        @Size(max = 30, message = "스펙 단위는 30자 이하로 입력해 주세요.")
        String unit,

        Boolean required,

        Boolean searchable,

        Integer sortOrder,

        @Size(max = 30, message = "스펙 선택지는 30개 이하로 입력해 주세요.")
        List<@Valid CategorySpecOptionRequest> options
) {
}
