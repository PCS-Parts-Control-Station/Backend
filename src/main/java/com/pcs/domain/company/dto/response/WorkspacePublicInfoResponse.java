package com.pcs.domain.company.dto.response;

public record WorkspacePublicInfoResponse(
        String companyCode,
        String companyName,
        Boolean active
) {
}
