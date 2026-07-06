package com.pcs.domain.company.facade;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.sql.SQLIntegrityConstraintViolationException;
import java.time.Instant;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DuplicateKeyException;

@ExtendWith(MockitoExtension.class)
class CompanyFacadeTest {

    @Mock
    private CompanyService companyService;
    @Mock
    private MemberService memberService;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private CompanyFacade companyFacade;

    @BeforeEach
    void setUp() {
        companyFacade = new CompanyFacade(companyService, memberService, workspaceAccessValidator);
    }

    @Test
    void signupOwner_createsCompanyAndOwnerInOneFlow() {
        OwnerSignupRequest request = signupRequest(" ACME Parts ", "Acme-Parts", "1234567890");
        when(companyService.existsByCompanyCode("acme-parts")).thenReturn(false);
        doAnswer(invocation -> {
            Company company = invocation.getArgument(0);
            company.setCompanyId(10L);
            return null;
        }).when(companyService).create(any(Company.class));
        when(memberService.createOwner(10L, "owner01", "Owner User", "password123"))
                .thenReturn(new OwnerMemberCreationResult(20L, "owner01"));

        OwnerSignupResponse response = companyFacade.signupOwner(request);

        assertThat(response.companyId()).isEqualTo(10L);
        assertThat(response.companyCode()).isEqualTo("acme-parts");
        assertThat(response.workspaceLoginUrl()).isEqualTo("/w/acme-parts");
        assertThat(response.ownerMemberId()).isEqualTo(20L);

        ArgumentCaptor<Company> captor = ArgumentCaptor.forClass(Company.class);
        verify(companyService).create(captor.capture());
        assertThat(captor.getValue().getCompanyName()).isEqualTo("ACME Parts");
        assertThat(captor.getValue().getBusinessRegistrationNo()).isEqualTo("123-45-67890");
    }

    @Test
    void signupOwner_failsWhenCompanyCodeAlreadyExists() {
        OwnerSignupRequest request = signupRequest("ACME Parts", "acme", null);
        when(companyService.existsByCompanyCode("acme")).thenReturn(true);

        assertThatThrownBy(() -> companyFacade.signupOwner(request))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.COMPANY_CODE_DUPLICATED)
                );
    }

    @Test
    void signupOwner_mapsBusinessRegistrationDuplicate() {
        OwnerSignupRequest request = signupRequest("ACME Parts", "acme", "123-45-67890");
        when(companyService.existsByCompanyCode("acme")).thenReturn(false);
        DuplicateKeyException duplicate = duplicate("uk_company_business_registration_no");
        org.mockito.Mockito.doThrow(duplicate).when(companyService).create(any(Company.class));

        assertThatThrownBy(() -> companyFacade.signupOwner(request))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode())
                                .isEqualTo(ErrorCode.COMPANY_BUSINESS_REGISTRATION_NO_DUPLICATED)
                );
    }

    @Test
    void findWorkspacePublicInfo_requiresExistingActiveCompany() {
        when(companyService.findPublicInfoByCompanyCode("acme"))
                .thenReturn(new WorkspacePublicInfoResponse("acme", "ACME Parts", true));

        WorkspacePublicInfoResponse response = companyFacade.findWorkspacePublicInfo(" ACME ");

        assertThat(response.companyCode()).isEqualTo("acme");
    }

    @Test
    void findWorkspacePublicInfo_rejectsInactiveCompany() {
        when(companyService.findPublicInfoByCompanyCode("inactive"))
                .thenReturn(new WorkspacePublicInfoResponse("inactive", "Inactive Parts", false));

        assertThatThrownBy(() -> companyFacade.findWorkspacePublicInfo("inactive"))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.COMPANY_INACTIVE)
                );
    }

    @Test
    void getOwnerCompany_allowsOwnerOnly() {
        PcsPrincipal owner = principal(MemberRole.OWNER);
        when(companyService.findOwnerCompanyById(1L)).thenReturn(ownerCompany("ACME Parts"));

        OwnerCompanyResponse response = companyFacade.getOwnerCompany(owner);

        assertThat(response.companyName()).isEqualTo("ACME Parts");
        verify(workspaceAccessValidator).validateCompanyActive(1L);
    }

    @Test
    void getOwnerCompany_rejectsAdmin() {
        assertThatThrownBy(() -> companyFacade.getOwnerCompany(principal(MemberRole.ADMIN)))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
                );
    }

    @Test
    void updateOwnerCompany_keepsCompanyCodeAndNormalizesBusinessNumber() {
        PcsPrincipal owner = principal(MemberRole.OWNER);
        UpdateOwnerCompanyRequest request = new UpdateOwnerCompanyRequest(
                " Updated ACME ",
                " owner@example.com ",
                " 02-1111-2222 ",
                "1234567890"
        );
        when(companyService.updateOwnerCompany(1L, "Updated ACME", "owner@example.com", "02-1111-2222", "123-45-67890"))
                .thenReturn(1);
        when(companyService.findOwnerCompanyById(1L)).thenReturn(ownerCompany("Updated ACME"));

        OwnerCompanyResponse response = companyFacade.updateOwnerCompany(owner, request);

        assertThat(response.companyCode()).isEqualTo("acme");
        assertThat(response.companyName()).isEqualTo("Updated ACME");
    }

    private OwnerSignupRequest signupRequest(String companyName, String companyCode, String businessNo) {
        return new OwnerSignupRequest(
                companyName,
                companyCode,
                businessNo,
                " owner@example.com ",
                " 02-0000-0000 ",
                " Owner User ",
                "owner01",
                "password123"
        );
    }

    private PcsPrincipal principal(MemberRole role) {
        return new PcsPrincipal(7L, 1L, "acme", "owner01", role, Instant.now().plusSeconds(600));
    }

    private OwnerCompanyResponse ownerCompany(String companyName) {
        return new OwnerCompanyResponse(
                1L,
                "acme",
                companyName,
                "owner@example.com",
                "02-1111-2222",
                "123-45-67890",
                true
        );
    }

    private DuplicateKeyException duplicate(String constraintName) {
        return new DuplicateKeyException(
                constraintName,
                new SQLIntegrityConstraintViolationException("Duplicate entry for key '" + constraintName + "'")
        );
    }
}
