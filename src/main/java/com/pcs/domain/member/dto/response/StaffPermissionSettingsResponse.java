package com.pcs.domain.member.dto.response;

import java.util.List;

public record StaffPermissionSettingsResponse(
        List<StaffPermissionItemResponse> permissions
) {
}
