package com.pcs.domain.company.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record OwnerSignupRequest(
        @NotBlank(message = "회사명을 입력해 주세요.")
        @Size(max = 100, message = "회사명은 100자 이하로 입력해 주세요.")
        String companyName,

        @NotBlank(message = "업체 코드를 입력해 주세요.")
        @Size(min = 2, max = 50, message = "업체 코드는 2자 이상 50자 이하로 입력해 주세요.")
        @Pattern(
                regexp = "^[a-z0-9]+(?:-[a-z0-9]+)*$",
                message = "업체 코드는 영문 소문자, 숫자, 하이픈만 사용할 수 있습니다."
        )
        String companyCode,

        @Pattern(
                regexp = "^$|^\\d{3}-?\\d{2}-?\\d{5}$",
                message = "사업자등록번호 형식이 올바르지 않습니다."
        )
        String businessRegistrationNo,

        @Email(message = "대표 이메일 형식이 올바르지 않습니다.")
        @Size(max = 255, message = "대표 이메일은 255자 이하로 입력해 주세요.")
        String representativeEmail,

        @Size(max = 30, message = "대표 연락처는 30자 이하로 입력해 주세요.")
        String representativePhone,

        @NotBlank(message = "Owner 이름을 입력해 주세요.")
        @Size(max = 100, message = "Owner 이름은 100자 이하로 입력해 주세요.")
        String ownerName,

        @NotBlank(message = "Owner 로그인 ID를 입력해 주세요.")
        @Size(min = 4, max = 50, message = "Owner 로그인 ID는 4자 이상 50자 이하로 입력해 주세요.")
        @Pattern(
                regexp = "^[a-zA-Z0-9._-]+$",
                message = "Owner 로그인 ID는 영문, 숫자, 점, 밑줄, 하이픈만 사용할 수 있습니다."
        )
        String ownerLoginId,

        @NotBlank(message = "Owner 비밀번호를 입력해 주세요.")
        @Size(min = 8, max = 72, message = "Owner 비밀번호는 8자 이상 72자 이하로 입력해 주세요.")
        String ownerPassword
) {
}
