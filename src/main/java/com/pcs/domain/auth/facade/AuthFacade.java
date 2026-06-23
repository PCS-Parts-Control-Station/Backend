package com.pcs.domain.auth.facade;

import com.pcs.domain.auth.dto.request.WorkspaceLoginRequest;
import com.pcs.domain.auth.dto.response.LoginResponse;
import com.pcs.domain.auth.dto.response.RefreshTokenResponse;
import com.pcs.domain.auth.dto.response.SessionMeResponse;
import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.entity.AuthRefreshTokenSession;
import com.pcs.domain.auth.service.AuthService;
import com.pcs.domain.auth.service.RefreshTokenIssueResult;
import com.pcs.domain.auth.type.RefreshTokenRevokedReason;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtTokenProvider;
import com.pcs.global.security.PcsPrincipal;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class AuthFacade {

    private static final String TOKEN_TYPE = "Bearer";

    private final AuthService authService;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthFacade(AuthService authService, JwtTokenProvider jwtTokenProvider) {
        this.authService = authService;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Transactional
    public LoginIssueResult loginWorkspace(
            WorkspaceLoginRequest request,
            String pathCompanyCode,
            String loginIp,
            String userAgent
    ) {
        String companyCode = resolveCompanyCode(request.companyCode(), pathCompanyCode);
        AuthMember member = authService.authenticateWorkspace(
                companyCode,
                request.loginId(),
                request.password(),
                loginIp,
                userAgent
        );
        return issueLoginResult(member, loginIp, userAgent);
    }

    @Transactional
    public LoginIssueResult loginOwner(WorkspaceLoginRequest request, String loginIp, String userAgent) {
        String companyCode = resolveCompanyCode(request.companyCode(), null);
        AuthMember member = authService.authenticateOwner(
                companyCode,
                request.loginId(),
                request.password(),
                loginIp,
                userAgent
        );
        return issueLoginResult(member, loginIp, userAgent);
    }

    @Transactional
    public RefreshIssueResult refresh(String rawRefreshToken, String loginIp, String userAgent) {
        AuthRefreshTokenSession session = authService.validateRefreshToken(rawRefreshToken);
        RefreshTokenIssueResult refreshToken = authService.issueRefreshToken(
                session.getCompanyId(),
                session.getMemberId(),
                session.getTokenFamilyId(),
                loginIp,
                userAgent
        );
        authService.revokeRefreshToken(
                session.getTokenId(),
                RefreshTokenRevokedReason.ROTATED,
                refreshToken.tokenId()
        );

        String accessToken = jwtTokenProvider.createAccessToken(
                session.getMemberId(),
                session.getCompanyId(),
                session.getCompanyCode(),
                session.getLoginId(),
                session.getRole(),
                session.getTokenFamilyId()
        );
        RefreshTokenResponse response = new RefreshTokenResponse(
                accessToken,
                TOKEN_TYPE,
                jwtTokenProvider.getAccessTokenExpiresInSeconds()
        );
        return new RefreshIssueResult(response, refreshToken.rawToken(), refreshToken.expiresInSeconds());
    }

    @Transactional
    public void logout(String rawRefreshToken) {
        authService.revokeRefreshTokenFamilyByRawValue(rawRefreshToken, RefreshTokenRevokedReason.LOGOUT);
    }

    public SessionMeResponse findMe(PcsPrincipal principal, String companyCode) {
        if (principal == null) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }
        return authService.findCurrentSession(principal, companyCode);
    }

    private LoginIssueResult issueLoginResult(AuthMember member, String loginIp, String userAgent) {
        RefreshTokenIssueResult refreshToken = authService.issueRefreshToken(
                member.getCompanyId(),
                member.getMemberId(),
                null,
                loginIp,
                userAgent
        );
        String accessToken = jwtTokenProvider.createAccessToken(
                member.getMemberId(),
                member.getCompanyId(),
                member.getCompanyCode(),
                member.getLoginId(),
                member.getRole(),
                refreshToken.tokenFamilyId()
        );

        LoginResponse response = new LoginResponse(
                accessToken,
                TOKEN_TYPE,
                jwtTokenProvider.getAccessTokenExpiresInSeconds(),
                member.getCompanyId(),
                member.getCompanyCode(),
                member.getMemberId(),
                member.getLoginId(),
                member.getName(),
                member.getRole(),
                member.isPasswordChangeRequired()
        );
        return new LoginIssueResult(response, refreshToken.rawToken(), refreshToken.expiresInSeconds());
    }

    private String resolveCompanyCode(String bodyCompanyCode, String pathCompanyCode) {
        if (pathCompanyCode != null && !pathCompanyCode.isBlank()) {
            return pathCompanyCode.trim().toLowerCase();
        }
        if (bodyCompanyCode == null || bodyCompanyCode.isBlank()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "업체 코드를 입력해 주세요.");
        }
        return bodyCompanyCode.trim().toLowerCase();
    }

    public record LoginIssueResult(
            LoginResponse response,
            String refreshToken,
            long refreshTokenMaxAgeSeconds
    ) {
    }

    public record RefreshIssueResult(
            RefreshTokenResponse response,
            String refreshToken,
            long refreshTokenMaxAgeSeconds
    ) {
    }
}
