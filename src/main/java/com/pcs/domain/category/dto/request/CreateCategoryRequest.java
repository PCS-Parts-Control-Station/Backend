package com.pcs.domain.category.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateCategoryRequest(
        @NotBlank(message = "카테고리명을 입력해 주세요.")
        @Size(max = 100, message = "카테고리명은 100자 이하로 입력해 주세요.")
        String categoryName,

        @Size(max = 500, message = "설명은 500자 이하로 입력해 주세요.")
        String description,

        @Size(max = 20, message = "스펙 항목은 20개 이하로 입력해 주세요.")
        List<@Valid CategorySpecDefinitionRequest> specDefinitions
) {
}
