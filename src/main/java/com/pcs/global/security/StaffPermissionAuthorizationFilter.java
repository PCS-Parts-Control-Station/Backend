package com.pcs.global.security;

import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.error.ApiErrorResponseWriter;
import com.pcs.global.error.ErrorCode;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class StaffPermissionAuthorizationFilter extends OncePerRequestFilter {

    private static final Pattern WORKSPACE_API_PATTERN = Pattern.compile("^/api/workspaces/[^/]+/(.+)$");

    private final StaffPermissionService staffPermissionService;
    private final ApiErrorResponseWriter errorResponseWriter;

    public StaffPermissionAuthorizationFilter(
            StaffPermissionService staffPermissionService,
            ApiErrorResponseWriter errorResponseWriter
    ) {
        this.staffPermissionService = staffPermissionService;
        this.errorResponseWriter = errorResponseWriter;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith("/api/workspaces/");
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Object principal = authentication == null ? null : authentication.getPrincipal();
        if (!(principal instanceof PcsPrincipal pcsPrincipal) || pcsPrincipal.role() != MemberRole.STAFF) {
            filterChain.doFilter(request, response);
            return;
        }

        StaffPermission requiredPermission = findRequiredPermission(request);
        if (requiredPermission == null || staffPermissionService.isEnabled(pcsPrincipal.companyId(), requiredPermission)) {
            filterChain.doFilter(request, response);
            return;
        }

        errorResponseWriter.write(response, ErrorCode.AUTH_STAFF_PERMISSION_DENIED);
    }

    private StaffPermission findRequiredPermission(HttpServletRequest request) {
        Matcher matcher = WORKSPACE_API_PATTERN.matcher(request.getRequestURI());
        if (!matcher.matches()) {
            return null;
        }

        String path = matcher.group(1).toLowerCase(Locale.ROOT);
        String method = request.getMethod().toUpperCase(Locale.ROOT);

        if (path.startsWith("stock/documents/outbounds")) {
            return StaffPermission.STAFF_OUTBOUND;
        }
        if (path.startsWith("stock/documents/inbounds") || path.startsWith("stock/documents")) {
            return StaffPermission.STAFF_INBOUND;
        }
        if (path.startsWith("inspections") || path.startsWith("inspection-templates")) {
            return StaffPermission.STAFF_INSPECTION;
        }
        if (path.startsWith("partners")) {
            return isWriteMethod(method) ? StaffPermission.STAFF_PARTNER_MANAGE : null;
        }
        if (path.startsWith("parts")) {
            return isWriteMethod(method) ? StaffPermission.STAFF_PART_CREATE : null;
        }
        if (path.startsWith("categories")) {
            return isWriteMethod(method) ? StaffPermission.STAFF_CATEGORY_MANAGE : null;
        }

        return null;
    }

    private boolean isWriteMethod(String method) {
        return "POST".equals(method)
                || "PATCH".equals(method)
                || "PUT".equals(method)
                || "DELETE".equals(method);
    }
}
