package com.pcs.domain.company.dto.response;

public record OwnerCompanyResponse(
        Long companyId,
        String companyCode,
        String companyName,
        String representativeEmail,
        String representativePhone,
        String businessRegistrationNo,
        Boolean active
) {
}
