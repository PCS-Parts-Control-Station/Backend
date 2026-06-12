package com.pcs.domain.member.dto.request;

import com.pcs.domain.member.type.StaffPermission;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record UpdateStaffPermissionRequest(
        @NotNull List<StaffPermission> enabledPermissions
) {
}
