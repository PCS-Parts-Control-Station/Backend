package com.pcs.domain.partner.dto.request;

import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreatePartnerRequest(
        @NotBlank(message = "거래처명을 입력해 주세요.")
        @Size(max = 150, message = "거래처명은 150자 이하로 입력해 주세요.")
        String partnerName,

        @NotNull(message = "거래처 유형을 선택해 주세요.")
        PartnerType partnerType,

        @NotNull(message = "거래처 역할을 선택해 주세요.")
        PartnerRole partnerRole,

        @Size(max = 50, message = "연락처는 50자 이하로 입력해 주세요.")
        String phone,

        @Email(message = "이메일 형식이 올바르지 않습니다.")
        @Size(max = 150, message = "이메일은 150자 이하로 입력해 주세요.")
        String email,

        @Size(max = 500, message = "주소는 500자 이하로 입력해 주세요.")
        String address,

        @Size(max = 1000, message = "메모는 1000자 이하로 입력해 주세요.")
        String memo
) {
}
