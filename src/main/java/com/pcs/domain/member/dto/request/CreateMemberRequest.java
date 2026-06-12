package com.pcs.domain.member.dto.request;

import com.pcs.domain.member.type.MemberRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CreateMemberRequest(
        @NotBlank(message = "이름을 입력해 주세요.")
        @Size(max = 100, message = "이름은 100자 이하로 입력해 주세요.")
        String memberName,

        @NotBlank(message = "로그인 아이디를 입력해 주세요.")
        @Size(max = 50, message = "로그인 아이디는 50자 이하로 입력해 주세요.")
        @Pattern(regexp = "^[a-zA-Z0-9._-]+$", message = "로그인 아이디는 영문, 숫자, 점, 하이픈, 언더바만 사용할 수 있습니다.")
        String loginId,

        @NotNull(message = "권한을 선택해 주세요.")
        MemberRole role
) {
}
