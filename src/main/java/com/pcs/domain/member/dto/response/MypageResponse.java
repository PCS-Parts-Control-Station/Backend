package com.pcs.domain.member.dto.response;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.member.type.StaffPermission;
import java.util.List;

public record MypageResponse(
        Long companyId,
        String companyCode,
        Long memberId,
        String loginId,
        String name,
        MemberRole role,
        PasswordStatus passwordStatus,
        List<StaffPermission> staffPermissions
) {
}
