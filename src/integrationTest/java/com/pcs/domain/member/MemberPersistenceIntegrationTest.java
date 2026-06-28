package com.pcs.domain.member;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.member.dto.request.ChangeMypagePasswordRequest;
import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateStaffPermissionRequest;
import com.pcs.domain.member.dto.response.CreateMemberResponse;
import com.pcs.domain.member.dto.response.MypageResponse;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.StaffPermissionSettingsResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.facade.MemberFacade;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.jdbc.Sql;

@Sql("/pcs-account-test-schema.sql")
class MemberPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private MemberService memberService;
    @Autowired
    private MemberFacade memberFacade;
    @Autowired
    private StaffPermissionService staffPermissionService;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void createMember_persistsTemporaryPasswordAccount() {
        long ownerId = insertMember(1L, "owner01", "Owner User", MemberRole.OWNER, PasswordStatus.ACTIVE, 1, 1L);

        CreateMemberResponse response = memberService.createMember(
                1L,
                ownerId,
                MemberRole.OWNER,
                new CreateMemberRequest("Staff User", "staff01", MemberRole.STAFF)
        );

        assertThat(response.temporaryPassword()).startsWith("PCS-");
        String passwordHash = jdbcTemplate.queryForObject(
                "SELECT password_hash FROM tb_member WHERE member_id = ?",
                String.class,
                response.member().memberId()
        );
        String passwordStatus = jdbcTemplate.queryForObject(
                "SELECT password_status FROM tb_member WHERE member_id = ?",
                String.class,
                response.member().memberId()
        );
        assertThat(passwordHash).isNotEqualTo(response.temporaryPassword());
        assertThat(passwordEncoder.matches(response.temporaryPassword(), passwordHash)).isTrue();
        assertThat(passwordStatus).isEqualTo("TEMPORARY");
    }

    @Test
    void searchMembers_adminSeesOnlyStaffAndCannotSearchAdmin() {
        insertMember(1L, "owner01", "Owner User", MemberRole.OWNER, PasswordStatus.ACTIVE, 1, 1L);
        insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null, 2L);
        insertMember(1L, "staff01", "Staff User", MemberRole.STAFF, PasswordStatus.ACTIVE, null, 3L);

        PageResultDto<SearchMemberResponse, SearchMemberSummaryResponse> result =
                memberService.searchMembers(1L, MemberRole.ADMIN, null, null, 0, 20, null);

        assertThat(result.content()).extracting(SearchMemberResponse::role)
                .containsExactly(MemberRole.STAFF);
        assertThatThrownBy(() -> memberService.searchMembers(1L, MemberRole.ADMIN, null, MemberRole.ADMIN, 0, 20, null))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
                );
    }

    @Test
    void updateStaffPermissions_persistsOnlyDisabledPermissions() {
        long adminId = insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null, 2L);

        StaffPermissionSettingsResponse response = staffPermissionService.updateSettings(
                1L,
                adminId,
                MemberRole.ADMIN,
                new UpdateStaffPermissionRequest(List.of(
                        StaffPermission.STAFF_INBOUND,
                        StaffPermission.STAFF_OUTBOUND
                ))
        );

        Integer disabledCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_company_staff_permission_disabled WHERE company_id = ?",
                Integer.class,
                1L
        );
        assertThat(disabledCount).isEqualTo(4);
        assertThat(response.permissions())
                .filteredOn(permission -> permission.code() == StaffPermission.STAFF_INBOUND)
                .singleElement()
                .satisfies(permission -> assertThat(permission.enabled()).isTrue());
        assertThat(staffPermissionService.findEnabledPermissions(1L, MemberRole.STAFF))
                .containsExactly(StaffPermission.STAFF_INBOUND, StaffPermission.STAFF_OUTBOUND);
    }

    @Test
    void issueTemporaryPassword_revokesTargetMemberRefreshTokens() {
        long ownerId = insertMember(1L, "owner01", "Owner User", MemberRole.OWNER, PasswordStatus.ACTIVE, 1, 1L);
        long staffId = insertMember(1L, "staff01", "Staff User", MemberRole.STAFF, PasswordStatus.ACTIVE, null, 2L);
        insertRefreshToken(1L, staffId, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "family-1");

        TemporaryPasswordResponse response = memberFacade.issueTemporaryPassword(
                principal(ownerId, MemberRole.OWNER),
                "acme",
                staffId
        );

        Integer revokedCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE member_id = ? AND revoked_reason = 'ADMIN_REVOKED'",
                Integer.class,
                staffId
        );
        String passwordStatus = jdbcTemplate.queryForObject(
                "SELECT password_status FROM tb_member WHERE member_id = ?",
                String.class,
                staffId
        );
        assertThat(response.temporaryPassword()).startsWith("PCS-");
        assertThat(revokedCount).isEqualTo(1);
        assertThat(passwordStatus).isEqualTo("TEMPORARY");
    }

    @Test
    void changeMypagePassword_activatesPasswordAndRevokesCurrentMemberRefreshTokens() {
        long staffId = insertMember(1L, "staff01", "Staff User", MemberRole.STAFF, PasswordStatus.TEMPORARY, null, 2L);
        insertRefreshToken(1L, staffId, "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", "family-2");

        MypageResponse response = memberFacade.changeMypagePassword(
                principal(staffId, MemberRole.STAFF),
                "acme",
                new ChangeMypagePasswordRequest("raw-password", "new-password", "new-password")
        );

        String passwordStatus = jdbcTemplate.queryForObject(
                "SELECT password_status FROM tb_member WHERE member_id = ?",
                String.class,
                staffId
        );
        Integer activeTokenCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE member_id = ? AND revoked_at IS NULL",
                Integer.class,
                staffId
        );
        assertThat(response.passwordStatus()).isEqualTo(PasswordStatus.ACTIVE);
        assertThat(passwordStatus).isEqualTo("ACTIVE");
        assertThat(activeTokenCount).isZero();
    }

    private long insertMember(
            long companyId,
            String loginId,
            String name,
            MemberRole role,
            PasswordStatus passwordStatus,
            Integer ownerSlot,
            long sequence
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_member (
                    company_id,
                    login_id,
                    password_hash,
                    name,
                    role,
                    owner_slot,
                    password_status,
                    temp_password_expires_at,
                    active,
                    created_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, NULL)
                """,
                companyId,
                loginId,
                passwordEncoder.encode("raw-password"),
                name,
                role.name(),
                ownerSlot,
                passwordStatus.name(),
                passwordStatus == PasswordStatus.TEMPORARY ? LocalDateTime.now().plusDays(7) : null
        );
        return jdbcTemplate.queryForObject(
                "SELECT member_id FROM tb_member WHERE company_id = ? AND login_id = ?",
                Long.class,
                companyId,
                loginId
        );
    }

    private void insertRefreshToken(long companyId, long memberId, String hash, String familyId) {
        jdbcTemplate.update(
                """
                INSERT INTO tb_auth_refresh_token (
                    company_id,
                    member_id,
                    refresh_token_hash,
                    token_family_id,
                    expires_at,
                    created_ip,
                    created_user_agent
                ) VALUES (?, ?, ?, ?, DATE_ADD(CURRENT_TIMESTAMP(6), INTERVAL 14 DAY), '127.0.0.1', 'test')
                """,
                companyId,
                memberId,
                hash,
                familyId
        );
    }

    private PcsPrincipal principal(long memberId, MemberRole role) {
        return new PcsPrincipal(memberId, 1L, "acme", "user" + memberId, role, Instant.now().plusSeconds(600));
    }
}
