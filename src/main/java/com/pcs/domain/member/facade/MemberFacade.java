package com.pcs.domain.member.facade;

import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.auth.service.AuthService;
import com.pcs.domain.member.dto.request.ChangeMypagePasswordRequest;
import com.pcs.domain.member.dto.request.UpdateMypageRequest;
import com.pcs.domain.member.dto.request.UpdateStaffPermissionRequest;
import com.pcs.domain.member.dto.request.UpdateMemberRequest;
import com.pcs.domain.member.dto.response.MypageResponse;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.StaffPermissionSettingsResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.entity.MemberAccount;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class MemberFacade {

    private final MemberService memberService;
    private final AuthService authService;
    private final StaffPermissionService staffPermissionService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public MemberFacade(
            MemberService memberService,
            AuthService authService,
            StaffPermissionService staffPermissionService,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.memberService = memberService;
        this.authService = authService;
        this.staffPermissionService = staffPermissionService;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchMemberResponse, SearchMemberSummaryResponse> searchMembers(
            PcsPrincipal principal,
            String pathCompanyCode,
            String keyword,
            MemberRole role,
            Integer page,
            Integer size,
            Integer limit
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return memberService.searchMembers(
                checkedPrincipal.companyId(),
                checkedPrincipal.role(),
                keyword,
                role,
                page,
                size,
                limit
        );
    }

    public SearchMemberResponse createMember(
            PcsPrincipal principal,
            String pathCompanyCode,
            CreateMemberRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return memberService.createMember(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                checkedPrincipal.role(),
                request
        );
    }

    public SearchMemberResponse getMember(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long memberId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return memberService.getMember(checkedPrincipal.companyId(), checkedPrincipal.role(), memberId);
    }

    public SearchMemberResponse updateMember(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long memberId,
            UpdateMemberRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return memberService.updateMember(checkedPrincipal.companyId(), checkedPrincipal.role(), memberId, request);
    }

    @Transactional
    public TemporaryPasswordResponse issueTemporaryPassword(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long memberId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        TemporaryPasswordResponse response = memberService.issueTemporaryPassword(
                checkedPrincipal.companyId(),
                checkedPrincipal.role(),
                memberId
        );
        authService.revokeMemberRefreshTokens(checkedPrincipal.companyId(), memberId);
        return response;
    }

    public StaffPermissionSettingsResponse getStaffPermissions(PcsPrincipal principal, String pathCompanyCode) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return staffPermissionService.getSettings(checkedPrincipal.companyId(), checkedPrincipal.role());
    }

    public StaffPermissionSettingsResponse updateStaffPermissions(
            PcsPrincipal principal,
            String pathCompanyCode,
            UpdateStaffPermissionRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return staffPermissionService.updateSettings(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                checkedPrincipal.role(),
                request
        );
    }

    public MypageResponse getMypage(PcsPrincipal principal, String pathCompanyCode) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        MemberAccount account = memberService.getMyAccount(checkedPrincipal.companyId(), checkedPrincipal.memberId());
        return toMypageResponse(account);
    }

    public MypageResponse updateMypage(
            PcsPrincipal principal,
            String pathCompanyCode,
            UpdateMypageRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        MemberAccount account = memberService.updateMyAccount(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                request
        );
        return toMypageResponse(account);
    }

    @Transactional
    public MypageResponse changeMypagePassword(
            PcsPrincipal principal,
            String pathCompanyCode,
            ChangeMypagePasswordRequest request
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        MemberAccount account = memberService.changeMyPassword(
                checkedPrincipal.companyId(),
                checkedPrincipal.memberId(),
                request
        );
        authService.revokeMemberRefreshTokens(checkedPrincipal.companyId(), checkedPrincipal.memberId());
        return toMypageResponse(account);
    }

    private MypageResponse toMypageResponse(MemberAccount account) {
        List<StaffPermission> permissions = staffPermissionService.findEnabledPermissions(
                account.getCompanyId(),
                account.getRole()
        );
        return new MypageResponse(
                account.getCompanyId(),
                account.getCompanyCode(),
                account.getMemberId(),
                account.getLoginId(),
                account.getName(),
                account.getRole(),
                account.getPasswordStatus(),
                permissions
        );
    }
}
