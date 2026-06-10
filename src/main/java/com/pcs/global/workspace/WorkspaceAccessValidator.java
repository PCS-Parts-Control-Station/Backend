package com.pcs.global.workspace;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.util.Locale;
import org.springframework.stereotype.Component;

@Component
public class WorkspaceAccessValidator {

    private final WorkspaceMapper workspaceMapper;

    public WorkspaceAccessValidator(WorkspaceMapper workspaceMapper) {
        this.workspaceMapper = workspaceMapper;
    }

    public PcsPrincipal validateAuthenticatedWorkspace(PcsPrincipal principal, String pathCompanyCode) {
        if (principal == null) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }

        if (pathCompanyCode == null || pathCompanyCode.isBlank()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "업체 코드가 필요합니다.");
        }

        String normalizedPathCompanyCode = pathCompanyCode.trim().toLowerCase(Locale.ROOT);
        if (!normalizedPathCompanyCode.equals(principal.companyCode())) {
            throw new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH);
        }

        return principal;
    }

    public void validateCompanyActive(Long companyId) {
        if (!workspaceMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
    }
}
