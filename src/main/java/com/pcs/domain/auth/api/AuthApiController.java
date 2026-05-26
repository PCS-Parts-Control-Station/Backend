package com.pcs.domain.auth.api;

import com.pcs.domain.auth.dto.request.WorkspaceLoginRequest;
import com.pcs.domain.auth.dto.response.LoginResponse;
import com.pcs.domain.auth.dto.response.RefreshTokenResponse;
import com.pcs.domain.auth.dto.response.SessionMeResponse;
import com.pcs.domain.auth.facade.AuthFacade;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.security.PcsPrincipal;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class AuthApiController {

    private static final String REFRESH_TOKEN_COOKIE_NAME = "pcsRefreshToken";

    private final AuthFacade authFacade;
    private final boolean refreshCookieSecure;

    public AuthApiController(
            AuthFacade authFacade,
            @Value("${pcs.jwt.refresh-cookie-secure:false}") boolean refreshCookieSecure
    ) {
        this.authFacade = authFacade;
        this.refreshCookieSecure = refreshCookieSecure;
    }

    @PostMapping("/owners/login")
    public ResponseEntity<ApiResultDto<LoginResponse>> loginOwner(
            @Valid @RequestBody WorkspaceLoginRequest request,
            HttpServletRequest httpRequest
    ) {
        AuthFacade.LoginIssueResult result = authFacade.loginOwner(
                request,
                clientIp(httpRequest),
                userAgent(httpRequest)
        );
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, refreshCookie(result.refreshToken(), result.refreshTokenMaxAgeSeconds()))
                .body(ApiResultDto.ok("로그인되었습니다.", result.response()));
    }

    @PostMapping("/workspaces/login")
    public ResponseEntity<ApiResultDto<LoginResponse>> loginWorkspace(
            @Valid @RequestBody WorkspaceLoginRequest request,
            HttpServletRequest httpRequest
    ) {
        AuthFacade.LoginIssueResult result = authFacade.loginWorkspace(
                request,
                null,
                clientIp(httpRequest),
                userAgent(httpRequest)
        );
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, refreshCookie(result.refreshToken(), result.refreshTokenMaxAgeSeconds()))
                .body(ApiResultDto.ok("로그인되었습니다.", result.response()));
    }

    @PostMapping("/workspaces/{companyCode}/login")
    public ResponseEntity<ApiResultDto<LoginResponse>> loginWorkspaceByPath(
            @PathVariable String companyCode,
            @Valid @RequestBody WorkspaceLoginRequest request,
            HttpServletRequest httpRequest
    ) {
        AuthFacade.LoginIssueResult result = authFacade.loginWorkspace(
                request,
                companyCode,
                clientIp(httpRequest),
                userAgent(httpRequest)
        );
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, refreshCookie(result.refreshToken(), result.refreshTokenMaxAgeSeconds()))
                .body(ApiResultDto.ok("로그인되었습니다.", result.response()));
    }

    @PostMapping("/auth/refresh")
    public ResponseEntity<ApiResultDto<RefreshTokenResponse>> refresh(
            @CookieValue(name = REFRESH_TOKEN_COOKIE_NAME, required = false) String refreshToken,
            HttpServletRequest httpRequest
    ) {
        AuthFacade.RefreshIssueResult result = authFacade.refresh(
                refreshToken,
                clientIp(httpRequest),
                userAgent(httpRequest)
        );
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, refreshCookie(result.refreshToken(), result.refreshTokenMaxAgeSeconds()))
                .body(ApiResultDto.ok("토큰이 재발급되었습니다.", result.response()));
    }

    @PostMapping("/auth/logout")
    public ResponseEntity<ApiResultDto<Void>> logout(
            @CookieValue(name = REFRESH_TOKEN_COOKIE_NAME, required = false) String refreshToken
    ) {
        authFacade.logout(refreshToken);
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, expiredRefreshCookie())
                .body(ApiResultDto.ok());
    }

    @GetMapping("/workspaces/{companyCode}/me")
    public ResponseEntity<ApiResultDto<SessionMeResponse>> me(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        return ResponseEntity.ok(ApiResultDto.ok(authFacade.findMe(principal, companyCode)));
    }

    private String refreshCookie(String refreshToken, long maxAgeSeconds) {
        return ResponseCookie.from(REFRESH_TOKEN_COOKIE_NAME, refreshToken)
                .httpOnly(true)
                .secure(refreshCookieSecure)
                .sameSite("Strict")
                .path("/api/auth")
                .maxAge(maxAgeSeconds)
                .build()
                .toString();
    }

    private String expiredRefreshCookie() {
        return ResponseCookie.from(REFRESH_TOKEN_COOKIE_NAME, "")
                .httpOnly(true)
                .secure(refreshCookieSecure)
                .sameSite("Strict")
                .path("/api/auth")
                .maxAge(0)
                .build()
                .toString();
    }

    private String clientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String userAgent(HttpServletRequest request) {
        return request.getHeader("User-Agent");
    }
}
