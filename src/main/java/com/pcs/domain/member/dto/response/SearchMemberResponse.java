package com.pcs.domain.member.dto.response;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import java.time.LocalDateTime;

public record SearchMemberResponse(
        Long memberId,
        String memberName,
        String loginId,
        MemberRole role,
        PasswordStatus passwordStatus,
        Boolean active,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
