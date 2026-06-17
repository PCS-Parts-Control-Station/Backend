package com.pcs.domain.member.dto.response;

import com.pcs.domain.member.type.StaffPermission;

public record StaffPermissionItemResponse(
        StaffPermission code,
        String label,
        boolean enabled
) {
}
