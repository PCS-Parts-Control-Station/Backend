package com.pcs.domain.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record WorkspaceLoginRequest(
        @Size(max = 50, message = "업체 코드는 50자 이하여야 합니다.")
        @Pattern(
                regexp = "^[a-z0-9-]*$",
                message = "업체 코드는 영문 소문자, 숫자, 하이픈만 사용할 수 있습니다."
        )
        String companyCode,

        @NotBlank(message = "아이디를 입력해 주세요.")
        @Size(max = 50, message = "아이디는 50자 이하여야 합니다.")
        String loginId,

        @NotBlank(message = "비밀번호를 입력해 주세요.")
        @Size(max = 100, message = "비밀번호는 100자 이하여야 합니다.")
        String password
) {
}
