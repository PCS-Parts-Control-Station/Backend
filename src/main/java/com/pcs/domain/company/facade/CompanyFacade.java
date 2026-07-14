package com.pcs.domain.company.facade;

import com.pcs.domain.company.dto.request.OwnerSignupRequest;
import com.pcs.domain.company.dto.request.UpdateOwnerCompanyRequest;
import com.pcs.domain.company.dto.response.OwnerCompanyResponse;
import com.pcs.domain.company.dto.response.OwnerSignupResponse;
import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import com.pcs.domain.company.entity.Company;
import com.pcs.domain.company.service.CompanyService;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.service.OwnerMemberCreationResult;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.DuplicateKeyErrorResolver;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class CompanyFacade {

    private final CompanyService companyService;
    private final MemberService memberService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public CompanyFacade(
            CompanyService companyService,
            MemberService memberService,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.companyService = companyService;
        this.memberService = memberService;
        this.workspaceAccessValidator = workspaceAccessValidator;
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

    public OwnerCompanyResponse getOwnerCompany(PcsPrincipal principal) {
        validateOwner(principal);
        OwnerCompanyResponse response = companyService.findOwnerCompanyById(principal.companyId());
        if (response == null) {
            throw new BusinessException(ErrorCode.COMPANY_NOT_FOUND);
        }
        if (Boolean.FALSE.equals(response.active())) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        return response;
    }

    @Transactional
    public OwnerCompanyResponse updateOwnerCompany(PcsPrincipal principal, UpdateOwnerCompanyRequest request) {
        validateOwner(principal);
        try {
            int updatedCount = companyService.updateOwnerCompany(
                    principal.companyId(),
                    normalizeRequired(request.companyName()),
                    normalizeOptional(request.representativeEmail()),
                    normalizeOptional(request.representativePhone()),
                    normalizeBusinessRegistrationNo(request.businessRegistrationNo())
            );
            if (updatedCount == 0) {
                throw new BusinessException(ErrorCode.COMPANY_NOT_FOUND);
            }
            return getOwnerCompany(principal);
        } catch (DuplicateKeyException exception) {
            throw mapDuplicateKeyException(exception);
        }
    }

    private BusinessException mapDuplicateKeyException(DuplicateKeyException exception) {
        ErrorCode errorCode = DuplicateKeyErrorResolver.resolve(exception);
        if (errorCode == ErrorCode.INTERNAL_SERVER_ERROR) {
            throw exception;
        }
        return new BusinessException(errorCode);
    }

    private void validateOwner(PcsPrincipal principal) {
        if (principal == null) {
            throw new BusinessException(ErrorCode.AUTH_REQUIRED);
        }
        if (principal.role() != MemberRole.OWNER) {
            throw new BusinessException(ErrorCode.AUTH_FORBIDDEN);
        }
        workspaceAccessValidator.validateCompanyActive(principal.companyId());
    }

    private String normalizeRequired(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeOptional(String value) {
        return TextNormalizer.optional(value);
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
