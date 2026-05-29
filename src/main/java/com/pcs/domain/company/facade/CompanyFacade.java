package com.pcs.domain.company.facade;

import com.pcs.domain.company.dto.request.OwnerSignupRequest;
import com.pcs.domain.company.dto.response.OwnerSignupResponse;
import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import com.pcs.domain.company.entity.Company;
import com.pcs.domain.company.service.CompanyService;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.service.OwnerMemberCreationResult;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class CompanyFacade {

    private final CompanyService companyService;
    private final MemberService memberService;

    public CompanyFacade(CompanyService companyService, MemberService memberService) {
        this.companyService = companyService;
        this.memberService = memberService;
    }

    @Transactional
    public OwnerSignupResponse signupOwner(OwnerSignupRequest request) {
        String companyCode = normalizeRequired(request.companyCode()).toLowerCase();
        if (companyService.existsByCompanyCode(companyCode)) {
            throw new BusinessException(ErrorCode.COMPANY_CODE_DUPLICATED);
        }

        Company company = new Company(
                normalizeRequired(request.companyName()),
                companyCode,
                normalizeOptional(request.representativeEmail()),
                normalizeOptional(request.representativePhone()),
                normalizeBusinessRegistrationNo(request.businessRegistrationNo())
        );

        try {
            companyService.create(company);
            OwnerMemberCreationResult owner = memberService.createOwner(
                    company.getCompanyId(),
                    normalizeRequired(request.ownerLoginId()),
                    normalizeRequired(request.ownerName()),
                    request.ownerPassword()
            );

            return new OwnerSignupResponse(
                    company.getCompanyId(),
                    company.getCompanyCode(),
                    "/w/" + company.getCompanyCode(),
                    owner.memberId(),
                    owner.loginId()
            );
        } catch (DuplicateKeyException exception) {
            throw mapDuplicateKeyException(exception);
        }
    }

    public WorkspacePublicInfoResponse findWorkspacePublicInfo(String companyCode) {
        String normalizedCompanyCode = normalizeRequired(companyCode).toLowerCase();
        if (normalizedCompanyCode.isBlank()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "업체 코드가 필요합니다.");
        }

        WorkspacePublicInfoResponse response = companyService.findPublicInfoByCompanyCode(normalizedCompanyCode);
        if (response == null) {
            throw new BusinessException(ErrorCode.COMPANY_NOT_FOUND);
        }
        if (Boolean.FALSE.equals(response.active())) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        return response;
    }

    private BusinessException mapDuplicateKeyException(DuplicateKeyException exception) {
        String message = exception.getMostSpecificCause().getMessage();
        if (message != null && message.contains("uk_company_business_registration_no")) {
            return new BusinessException(ErrorCode.COMPANY_BUSINESS_REGISTRATION_NO_DUPLICATED);
        }
        if (message != null && message.contains("uk_member_company_login")) {
            return new BusinessException(ErrorCode.MEMBER_LOGIN_ID_DUPLICATED);
        }
        return new BusinessException(ErrorCode.COMPANY_CODE_DUPLICATED);
    }

    private String normalizeRequired(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeBusinessRegistrationNo(String value) {
        String normalized = normalizeOptional(value);
        if (normalized == null) {
            return null;
        }
        String digits = normalized.replace("-", "");
        if (digits.length() == 10) {
            return digits.substring(0, 3) + "-" + digits.substring(3, 5) + "-" + digits.substring(5);
        }
        return normalized;
    }
}
