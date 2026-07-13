package com.pcs.global.security;

import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.mapper.AuthMapper;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.global.error.ApiErrorResponseWriter;
import com.pcs.global.error.ErrorCode;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.regex.Pattern;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class TemporaryPasswordAuthorizationFilter extends OncePerRequestFilter {

    private static final Pattern WORKSPACE_ME_PATTERN =
            Pattern.compile("^/api/workspaces/[^/]+/me$");
    private static final Pattern MYPAGE_PATTERN =
            Pattern.compile("^/api/workspaces/[^/]+/mypage$");
    private static final Pattern PASSWORD_CHANGE_PATTERN =
            Pattern.compile("^/api/workspaces/[^/]+/mypage/password$");

    private final AuthMapper authMapper;
    private final ApiErrorResponseWriter errorResponseWriter;

    public TemporaryPasswordAuthorizationFilter(AuthMapper authMapper, ApiErrorResponseWriter errorResponseWriter) {
        this.authMapper = authMapper;
        this.errorResponseWriter = errorResponseWriter;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith("/api/");
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        if (!(principal instanceof PcsPrincipal pcsPrincipal)) {
            filterChain.doFilter(request, response);
            return;
        }

        AuthMember member = authMapper.findSessionMember(pcsPrincipal.companyId(), pcsPrincipal.memberId());
        if (member == null || member.getPasswordStatus() != PasswordStatus.TEMPORARY || isAllowedRequest(request)) {
            filterChain.doFilter(request, response);
            return;
        }

        ErrorCode errorCode = ErrorCode.MEMBER_PASSWORD_CHANGE_REQUIRED;
        errorResponseWriter.write(response, errorCode);
    }

    private boolean isAllowedRequest(HttpServletRequest request) {
        String method = request.getMethod();
        String path = request.getRequestURI();
        return (HttpMethod.POST.matches(method) && "/api/auth/logout".equals(path))
                || (HttpMethod.GET.matches(method) && WORKSPACE_ME_PATTERN.matcher(path).matches())
                || (HttpMethod.GET.matches(method) && MYPAGE_PATTERN.matcher(path).matches())
                || (HttpMethod.PATCH.matches(method) && PASSWORD_CHANGE_PATTERN.matcher(path).matches());
    }
}
