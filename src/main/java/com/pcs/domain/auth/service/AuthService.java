package com.pcs.domain.auth.service;

import com.pcs.domain.auth.dto.response.SessionMeResponse;
import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.entity.AuthRefreshToken;
import com.pcs.domain.auth.entity.AuthRefreshTokenSession;
import com.pcs.domain.auth.mapper.AuthMapper;
import com.pcs.domain.auth.type.LoginResult;
import com.pcs.domain.auth.type.RefreshTokenRevokedReason;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private static final int MAX_LOGIN_FAILED_COUNT = 5;
    private static final Duration LOGIN_LOCK_DURATION = Duration.ofMinutes(10);

    private final AuthMapper authMapper;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom secureRandom = new SecureRandom();
    private final Duration refreshTokenDuration;

    public AuthService(
            AuthMapper authMapper,
            PasswordEncoder passwordEncoder,
            @Value("${pcs.jwt.refresh-token-expiration-days}") long refreshTokenExpirationDays
    ) {
        this.authMapper = authMapper;
        this.passwordEncoder = passwordEncoder;
        this.refreshTokenDuration = Duration.ofDays(refreshTokenExpirationDays);
    }

    public AuthMember authenticateWorkspace(
            String companyCode,
            String loginId,
            String rawPassword,
            String loginIp,
            String userAgent
    ) {
        String normalizedCompanyCode = normalizeRequired(companyCode).toLowerCase();
        String normalizedLoginId = normalizeRequired(loginId);
        AuthMember member = authMapper.findLoginMember(normalizedCompanyCode, normalizedLoginId);
        LocalDateTime now = LocalDateTime.now();

        if (member == null) {
            authMapper.insertLoginHistory(
                    null,
                    null,
                    normalizedCompanyCode,
                    normalizedLoginId,
                    LoginResult.FAIL,
                    "LOGIN_MEMBER_NOT_FOUND",
                    loginIp,
                    userAgent
            );
            throw new BusinessException(ErrorCode.AUTH_LOGIN_FAILED);
        }

        if (!member.isCompanyActive()) {
            insertHistory(member, LoginResult.INACTIVE, "COMPANY_INACTIVE", loginIp, userAgent);
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        if (!member.isActive()) {
            insertHistory(member, LoginResult.INACTIVE, "MEMBER_INACTIVE", loginIp, userAgent);
            throw new BusinessException(ErrorCode.MEMBER_INACTIVE);
        }

        if (member.isLocked(now)) {
            insertHistory(member, LoginResult.LOCKED, "LOGIN_LOCKED", loginIp, userAgent);
            throw new BusinessException(ErrorCode.AUTH_ACCOUNT_LOCKED);
        }

        if (!passwordEncoder.matches(rawPassword, member.getPasswordHash())) {
            recordPasswordFailure(member, loginIp, userAgent, now);
            throw new BusinessException(ErrorCode.AUTH_LOGIN_FAILED);
        }

        if (member.isTemporaryPasswordExpired(now)) {
            insertHistory(member, LoginResult.TEMP_PASSWORD_EXPIRED, "TEMP_PASSWORD_EXPIRED", loginIp, userAgent);
            throw new BusinessException(ErrorCode.MEMBER_TEMP_PASSWORD_EXPIRED);
        }

        authMapper.recordLoginSuccess(
                member.getCompanyId(),
                member.getMemberId(),
                loginIp,
                truncate(userAgent, 500)
        );
        insertHistory(member, LoginResult.SUCCESS, null, loginIp, userAgent);
        return member;
    }

    public AuthMember authenticateOwner(
            String companyCode,
            String loginId,
            String rawPassword,
            String loginIp,
            String userAgent
    ) {
        AuthMember member = authenticateWorkspace(companyCode, loginId, rawPassword, loginIp, userAgent);
        if (member.getRole() != MemberRole.OWNER) {
            throw new BusinessException(ErrorCode.AUTH_FORBIDDEN);
        }
        return member;
    }

    public RefreshTokenIssueResult issueRefreshToken(
            Long companyId,
            Long memberId,
            String tokenFamilyId,
            String loginIp,
            String userAgent
    ) {
        String rawToken = createRawRefreshToken();
        String tokenHash = hashRefreshToken(rawToken);
        LocalDateTime expiresAt = LocalDateTime.now().plus(refreshTokenDuration);

        AuthRefreshToken refreshToken = new AuthRefreshToken(
                companyId,
                memberId,
                tokenHash,
                tokenFamilyId == null ? UUID.randomUUID().toString() : tokenFamilyId,
                expiresAt,
                loginIp,
                truncate(userAgent, 500)
        );
        authMapper.insertRefreshToken(refreshToken);
        return new RefreshTokenIssueResult(
                refreshToken.getTokenId(),
                rawToken,
                tokenHash,
                expiresAt,
                refreshTokenDuration.toSeconds()
        );
    }

    public AuthRefreshTokenSession validateRefreshToken(String rawRefreshToken) {
        if (rawRefreshToken == null || rawRefreshToken.isBlank()) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }

        AuthRefreshTokenSession session = authMapper.findRefreshTokenSession(hashRefreshToken(rawRefreshToken));
        LocalDateTime now = LocalDateTime.now();
        if (session == null) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
        if (session.isRevoked()) {
            if (session.isRotated()) {
                revokeRefreshTokenFamily(
                        session.getCompanyId(),
                        session.getMemberId(),
                        session.getTokenFamilyId(),
                        RefreshTokenRevokedReason.REUSE_DETECTED
                );
            }
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
        if (session.isExpired(now)) {
            revokeRefreshToken(session.getTokenId(), RefreshTokenRevokedReason.EXPIRED, null);
            throw new BusinessException(ErrorCode.AUTH_TOKEN_EXPIRED);
        }
        if (!session.isCompanyActive()) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        if (!session.isMemberActive()) {
            throw new BusinessException(ErrorCode.MEMBER_INACTIVE);
        }
        return session;
    }

    public void revokeRefreshToken(
            Long tokenId,
            RefreshTokenRevokedReason revokedReason,
            Long replacedByTokenId
    ) {
        authMapper.revokeRefreshToken(tokenId, revokedReason, replacedByTokenId);
    }

    public void revokeRefreshTokenFamily(
            Long companyId,
            Long memberId,
            String tokenFamilyId,
            RefreshTokenRevokedReason revokedReason
    ) {
        authMapper.revokeRefreshTokenFamily(companyId, memberId, tokenFamilyId, revokedReason);
    }

    public void revokeRefreshTokenByRawValue(String rawRefreshToken, RefreshTokenRevokedReason revokedReason) {
        if (rawRefreshToken == null || rawRefreshToken.isBlank()) {
            return;
        }
        AuthRefreshTokenSession session = authMapper.findRefreshTokenSession(hashRefreshToken(rawRefreshToken));
        if (session != null && !session.isRevoked()) {
            revokeRefreshToken(session.getTokenId(), revokedReason, null);
        }
    }

    public SessionMeResponse findCurrentSession(PcsPrincipal principal, String pathCompanyCode) {
        String normalizedPathCompanyCode = normalizeRequired(pathCompanyCode).toLowerCase();
        if (!principal.companyCode().equals(normalizedPathCompanyCode)) {
            throw new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH);
        }

        AuthMember member = authMapper.findSessionMember(principal.companyId(), principal.memberId());
        if (member == null) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
        if (!member.isCompanyActive()) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        if (!member.isActive()) {
            throw new BusinessException(ErrorCode.MEMBER_INACTIVE);
        }
        if (!member.getCompanyCode().equals(normalizedPathCompanyCode)) {
            throw new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH);
        }

        return new SessionMeResponse(
                member.getCompanyId(),
                member.getCompanyCode(),
                member.getMemberId(),
                member.getLoginId(),
                member.getName(),
                member.getRole(),
                member.getPasswordStatus()
        );
    }

    private void recordPasswordFailure(AuthMember member, String loginIp, String userAgent, LocalDateTime now) {
        int failedCountAfter = member.getLoginFailedCount() + 1;
        LocalDateTime lockedUntilAt = failedCountAfter >= MAX_LOGIN_FAILED_COUNT
                ? now.plus(LOGIN_LOCK_DURATION)
                : null;
        authMapper.recordLoginFailure(member.getCompanyId(), member.getMemberId(), lockedUntilAt);
        insertHistory(member, LoginResult.FAIL, "PASSWORD_MISMATCH", loginIp, userAgent);
    }

    private void insertHistory(
            AuthMember member,
            LoginResult result,
            String failureReason,
            String loginIp,
            String userAgent
    ) {
        authMapper.insertLoginHistory(
                member.getCompanyId(),
                member.getMemberId(),
                member.getCompanyCode(),
                member.getLoginId(),
                result,
                failureReason,
                loginIp,
                truncate(userAgent, 500)
        );
    }

    private String createRawRefreshToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashRefreshToken(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder(hash.length * 2);
            for (byte value : hash) {
                builder.append(String.format("%02x", value));
            }
            return builder.toString();
        } catch (Exception exception) {
            throw new IllegalStateException("Failed to hash refresh token.", exception);
        }
    }

    private String normalizeRequired(String value) {
        return value == null ? "" : value.trim();
    }

    private String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }
}
