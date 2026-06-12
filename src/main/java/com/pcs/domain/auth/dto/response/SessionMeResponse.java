package com.pcs.domain.auth.dto.response;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.member.type.StaffPermission;
import java.util.List;

public record SessionMeResponse(
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
