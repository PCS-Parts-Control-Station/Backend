package com.pcs.domain.member.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.dto.request.UpdateStaffPermissionRequest;
import com.pcs.domain.member.dto.response.StaffPermissionSettingsResponse;
import com.pcs.domain.member.mapper.StaffPermissionMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class StaffPermissionServiceTest {

    @Mock
    private StaffPermissionMapper staffPermissionMapper;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private StaffPermissionService staffPermissionService;

    @BeforeEach
    void setUp() {
        staffPermissionService = new StaffPermissionService(staffPermissionMapper, workspaceAccessValidator);
    }

    @Test
    void getSettings_marksDisabledPermissions() {
        when(staffPermissionMapper.findDisabledPermissions(1L))
                .thenReturn(List.of(StaffPermission.STAFF_PARTNER_MANAGE));

        StaffPermissionSettingsResponse response = staffPermissionService.getSettings(1L, MemberRole.ADMIN);

        assertThat(response.permissions())
                .filteredOn(permission -> permission.code() == StaffPermission.STAFF_PARTNER_MANAGE)
                .singleElement()
                .satisfies(permission -> assertThat(permission.enabled()).isFalse());
        verify(workspaceAccessValidator).validateCompanyActive(1L);
    }

    @Test
    void updateSettings_storesOnlyDisabledPermissions() {
        UpdateStaffPermissionRequest request = new UpdateStaffPermissionRequest(List.of(
                StaffPermission.STAFF_PART_CREATE,
                StaffPermission.STAFF_INBOUND,
                StaffPermission.STAFF_INSPECTION,
                StaffPermission.STAFF_OUTBOUND
        ));

        staffPermissionService.updateSettings(1L, 7L, MemberRole.OWNER, request);

        verify(staffPermissionMapper).deleteDisabledPermissions(1L);
        verify(staffPermissionMapper).insertDisabledPermissions(
                1L,
                List.of(StaffPermission.STAFF_PARTNER_MANAGE, StaffPermission.STAFF_CATEGORY_MANAGE),
                7L
        );
    }

    @Test
    void updateSettings_rejectsStaffActor() {
        assertThatThrownBy(() -> staffPermissionService.updateSettings(
                1L,
                7L,
                MemberRole.STAFF,
                new UpdateStaffPermissionRequest(List.of())
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
        );
    }

    @Test
    void findEnabledPermissions_returnsAllPermissionsForAdminAndOwner() {
        assertThat(staffPermissionService.findEnabledPermissions(1L, MemberRole.ADMIN))
                .containsExactlyElementsOf(StaffPermission.all());
    }

    @Test
    void findEnabledPermissions_excludesDisabledPermissionsForStaff() {
        when(staffPermissionMapper.findDisabledPermissions(1L))
                .thenReturn(List.of(StaffPermission.STAFF_OUTBOUND));

        List<StaffPermission> permissions = staffPermissionService.findEnabledPermissions(1L, MemberRole.STAFF);

        assertThat(permissions).doesNotContain(StaffPermission.STAFF_OUTBOUND);
        assertThat(permissions).contains(StaffPermission.STAFF_INBOUND);
    }

    @Test
    void isEnabled_returnsFalseWhenPermissionIsDisabled() {
        when(staffPermissionMapper.existsDisabledPermission(1L, StaffPermission.STAFF_CATEGORY_MANAGE))
                .thenReturn(true);

        assertThat(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_CATEGORY_MANAGE)).isFalse();
    }
}
