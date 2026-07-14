package com.pcs.domain.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.facade.AuthFacade;
import com.pcs.domain.auth.service.AuthService;
import com.pcs.domain.auth.service.RefreshTokenIssueResult;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.security.AccessTokenSessionValidator;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.support.MariaDbIntegrationTest;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.jdbc.Sql;

@Sql("/pcs-account-test-schema.sql")
class AuthPersistenceIntegrationTest extends MariaDbIntegrationTest {

    @Autowired
    private AuthService authService;
    @Autowired
    private AuthFacade authFacade;
    @Autowired
    private AccessTokenSessionValidator accessTokenSessionValidator;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void authenticateWorkspace_recordsSuccessHistoryAndUpdatesMemberLoginState() {
        long memberId = insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null);

        AuthMember member = authService.authenticateWorkspace(
                "acme",
                "admin01",
                "raw-password",
                "127.0.0.1",
                "test-agent"
        );

        Integer successHistoryCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_auth_login_history WHERE member_id = ? AND login_result = 'SUCCESS'",
                Integer.class,
                memberId
        );
        Integer failedCount = jdbcTemplate.queryForObject(
                "SELECT login_failed_count FROM tb_member WHERE member_id = ?",
                Integer.class,
                memberId
        );
        assertThat(member.getMemberId()).isEqualTo(memberId);
        assertThat(successHistoryCount).isEqualTo(1);
        assertThat(failedCount).isZero();
    }

    @Test
    void authenticateWorkspace_recordsPasswordFailureAndMasksExternalError() {
        long memberId = insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null);

        assertThatThrownBy(() -> authService.authenticateWorkspace(
                "acme",
                "admin01",
                "wrong-password",
                "127.0.0.1",
                "test-agent"
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_LOGIN_FAILED)
        );

        Integer failedHistoryCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_auth_login_history WHERE member_id = ? AND failure_reason = 'PASSWORD_MISMATCH'",
                Integer.class,
                memberId
        );
        Integer failedCount = jdbcTemplate.queryForObject(
                "SELECT login_failed_count FROM tb_member WHERE member_id = ?",
                Integer.class,
                memberId
        );
        assertThat(failedHistoryCount).isEqualTo(1);
        assertThat(failedCount).isEqualTo(1);
    }

    @Test
    void issueRefreshToken_savesHashAndKeepsRawTokenOutOfDatabase() {
        long memberId = insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null);

        RefreshTokenIssueResult result = authService.issueRefreshToken(
                1L,
                memberId,
                null,
                "127.0.0.1",
                "test-agent"
        );

        String storedHash = jdbcTemplate.queryForObject(
                "SELECT refresh_token_hash FROM tb_auth_refresh_token WHERE token_id = ?",
                String.class,
                result.tokenId()
        );
        assertThat(storedHash).isEqualTo(result.tokenHash());
        assertThat(storedHash).isNotEqualTo(result.rawToken());
    }

    @Test
    void validateRefreshToken_marksExpiredTokenAsExpired() {
        long memberId = insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null);
        insertRefreshToken(1L, memberId, hash("expired-token"), "family-expired", LocalDateTime.now().minusDays(1));

        assertThatThrownBy(() -> authService.validateRefreshToken("expired-token"))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_TOKEN_EXPIRED)
                );

        String revokedReason = jdbcTemplate.queryForObject(
                "SELECT revoked_reason FROM tb_auth_refresh_token WHERE refresh_token_hash = ?",
                String.class,
                hash("expired-token")
        );
        assertThat(revokedReason).isEqualTo("EXPIRED");
    }

    @Test
    void refreshRotationAndReuseDetectionRevokeTheWholeSessionFamily() {
        long memberId = insertMember(1L, "admin01", "Admin User", MemberRole.ADMIN, PasswordStatus.ACTIVE, null);
        RefreshTokenIssueResult original = authService.issueRefreshToken(
                1L,
                memberId,
                null,
                "127.0.0.1",
                "test-agent"
        );

        AuthFacade.RefreshIssueResult rotated = authFacade.refresh(
                original.rawToken(),
                "127.0.0.1",
                "test-agent"
        );

        var originalRow = jdbcTemplate.queryForMap(
                "SELECT revoked_reason, replaced_by_token_id FROM tb_auth_refresh_token WHERE token_id = ?",
                original.tokenId()
        );
        Long replacementTokenId = ((Number) originalRow.get("replaced_by_token_id")).longValue();
        String replacementFamilyId = jdbcTemplate.queryForObject(
                "SELECT token_family_id FROM tb_auth_refresh_token WHERE token_id = ?",
                String.class,
                replacementTokenId
        );
        assertThat(originalRow.get("revoked_reason")).isEqualTo("ROTATED");
        assertThat(replacementFamilyId).isEqualTo(original.tokenFamilyId());

        assertThatThrownBy(() -> authService.validateRefreshToken(original.rawToken()))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_TOKEN_INVALID)
                );

        String replacementRevokedReason = jdbcTemplate.queryForObject(
                "SELECT revoked_reason FROM tb_auth_refresh_token WHERE refresh_token_hash = ?",
                String.class,
                hash(rotated.refreshToken())
        );
        Integer activeFamilyCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE token_family_id = ? AND revoked_at IS NULL",
                Integer.class,
                original.tokenFamilyId()
        );
        assertThat(replacementRevokedReason).isEqualTo("REUSE_DETECTED");
        assertThat(activeFamilyCount).isZero();

        Instant now = Instant.now();
        JwtClaims claims = new JwtClaims(
                memberId,
                1L,
                "acme",
                "admin01",
                MemberRole.ADMIN,
                "ACCESS",
                "jti-reused-family",
                original.tokenFamilyId(),
                now,
                now.plusSeconds(600)
        );
        assertThatThrownBy(() -> accessTokenSessionValidator.validate(claims))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_TOKEN_INVALID)
                );
    }

    @Test
    void findCurrentSession_returnsStaffEnabledPermissionsAndRejectsWorkspaceMismatch() {
        long staffId = insertMember(1L, "staff01", "Staff User", MemberRole.STAFF, PasswordStatus.ACTIVE, null);
        jdbcTemplate.update(
                "INSERT INTO tb_company_staff_permission_disabled (company_id, permission_code, disabled_by) VALUES (1, 'STAFF_OUTBOUND', NULL)"
        );

        var response = authService.findCurrentSession(
                new PcsPrincipal(staffId, 1L, "acme", "staff01", MemberRole.STAFF, Instant.now().plusSeconds(600)),
                "acme"
        );

        assertThat(response.staffPermissions()).contains(StaffPermission.STAFF_INBOUND);
        assertThat(response.staffPermissions()).doesNotContain(StaffPermission.STAFF_OUTBOUND);
        assertThatThrownBy(() -> authService.findCurrentSession(
                new PcsPrincipal(staffId, 1L, "acme", "staff01", MemberRole.STAFF, Instant.now().plusSeconds(600)),
                "other"
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_WORKSPACE_MISMATCH)
        );
    }

    private long insertMember(
            long companyId,
            String loginId,
            String name,
            MemberRole role,
            PasswordStatus passwordStatus,
            Integer ownerSlot
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

    private void insertRefreshToken(long companyId, long memberId, String hash, String familyId, LocalDateTime expiresAt) {
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
                ) VALUES (?, ?, ?, ?, ?, '127.0.0.1', 'test')
                """,
                companyId,
                memberId,
                hash,
                familyId,
                expiresAt
        );
    }

    private String hash(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder(bytes.length * 2);
            for (byte value : bytes) {
                builder.append(String.format("%02x", value));
            }
            return builder.toString();
        } catch (Exception exception) {
            throw new IllegalStateException(exception);
        }
    }
}
