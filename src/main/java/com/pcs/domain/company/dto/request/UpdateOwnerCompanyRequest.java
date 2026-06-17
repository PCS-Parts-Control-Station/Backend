package com.pcs.domain.company.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateOwnerCompanyRequest(
        @NotBlank(message = "회사명을 입력해 주세요.")
        @Size(max = 100, message = "회사명은 100자 이하로 입력해 주세요.")
        String companyName,

        @Email(message = "대표 이메일 형식이 올바르지 않습니다.")
        @Size(max = 255, message = "대표 이메일은 255자 이하로 입력해 주세요.")
        String representativeEmail,

        @Size(max = 30, message = "대표 연락처는 30자 이하로 입력해 주세요.")
        String representativePhone,

        @Size(max = 20, message = "사업자등록번호는 20자 이하로 입력해 주세요.")
        String businessRegistrationNo
) {
}
