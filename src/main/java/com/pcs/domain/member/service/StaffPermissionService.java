package com.pcs.domain.member.service;

import com.pcs.domain.member.dto.request.UpdateStaffPermissionRequest;
import com.pcs.domain.member.dto.response.StaffPermissionItemResponse;
import com.pcs.domain.member.dto.response.StaffPermissionSettingsResponse;
import com.pcs.domain.member.mapper.StaffPermissionMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class StaffPermissionService {

    private final StaffPermissionMapper staffPermissionMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public StaffPermissionService(
            StaffPermissionMapper staffPermissionMapper,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.staffPermissionMapper = staffPermissionMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public StaffPermissionSettingsResponse getSettings(Long companyId, MemberRole actorRole) {
        validateManager(actorRole);
        workspaceAccessValidator.validateCompanyActive(companyId);
        return buildResponse(companyId);
    }

    @Transactional
    public StaffPermissionSettingsResponse updateSettings(
            Long companyId,
            Long updatedBy,
            MemberRole actorRole,
            UpdateStaffPermissionRequest request
    ) {
        validateManager(actorRole);
        workspaceAccessValidator.validateCompanyActive(companyId);
        Set<StaffPermission> enabledPermissions = normalizeEnabledPermissions(request.enabledPermissions());
        List<StaffPermission> disabledPermissions = StaffPermission.all()
                .stream()
                .filter(permission -> !enabledPermissions.contains(permission))
                .toList();

        staffPermissionMapper.deleteDisabledPermissions(companyId);
        if (!disabledPermissions.isEmpty()) {
            staffPermissionMapper.insertDisabledPermissions(companyId, disabledPermissions, updatedBy);
        }
        return buildResponse(companyId);
    }

    public boolean isEnabled(Long companyId, StaffPermission permission) {
        if (permission == null) {
            return true;
        }
        return !staffPermissionMapper.existsDisabledPermission(companyId, permission);
    }

    public List<StaffPermission> findEnabledPermissions(Long companyId, MemberRole role) {
        if (role != MemberRole.STAFF) {
            return StaffPermission.all();
        }
        Set<StaffPermission> disabledPermissions = EnumSet.noneOf(StaffPermission.class);
        disabledPermissions.addAll(staffPermissionMapper.findDisabledPermissions(companyId));
        return StaffPermission.all()
                .stream()
                .filter(permission -> !disabledPermissions.contains(permission))
                .toList();
    }

    private StaffPermissionSettingsResponse buildResponse(Long companyId) {
        Set<StaffPermission> disabledPermissions = EnumSet.noneOf(StaffPermission.class);
        disabledPermissions.addAll(staffPermissionMapper.findDisabledPermissions(companyId));
        List<StaffPermissionItemResponse> permissions = StaffPermission.all()
                .stream()
                .map(permission -> new StaffPermissionItemResponse(
                        permission,
                        permission.getLabel(),
                        !disabledPermissions.contains(permission)
                ))
                .toList();
        return new StaffPermissionSettingsResponse(permissions);
    }

    private Set<StaffPermission> normalizeEnabledPermissions(List<StaffPermission> permissions) {
        if (permissions == null) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }

        Set<StaffPermission> normalized = EnumSet.noneOf(StaffPermission.class);
        for (StaffPermission permission : permissions) {
            if (permission == null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
            }
            normalized.add(permission);
        }
        return normalized;
    }

    private void validateManager(MemberRole actorRole) {
        if (actorRole != MemberRole.OWNER && actorRole != MemberRole.ADMIN) {
            throw new BusinessException(ErrorCode.AUTH_FORBIDDEN);
        }
    }
}
