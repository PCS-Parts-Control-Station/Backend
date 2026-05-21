package com.pcs.domain.company.dto.response;

public record OwnerSignupResponse(
        Long companyId,
        String companyCode,
        String workspaceLoginUrl,
        Long ownerMemberId,
        String ownerLoginId
) {
}
