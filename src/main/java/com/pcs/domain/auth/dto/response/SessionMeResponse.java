package com.pcs.domain.auth.dto.response;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;

public record SessionMeResponse(
        Long companyId,
        String companyCode,
        Long memberId,
        String loginId,
        String name,
        MemberRole role,
        PasswordStatus passwordStatus
) {
}
