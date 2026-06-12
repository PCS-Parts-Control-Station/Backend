package com.pcs.domain.member.facade;

import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateMemberRequest;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import org.springframework.stereotype.Component;

@Component
public class MemberFacade {

    private final MemberService memberService;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public MemberFacade(MemberService memberService, WorkspaceAccessValidator workspaceAccessValidator) {
        this.memberService = memberService;
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

    public TemporaryPasswordResponse issueTemporaryPassword(
            PcsPrincipal principal,
            String pathCompanyCode,
            Long memberId
    ) {
        PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(principal, pathCompanyCode);
        return memberService.issueTemporaryPassword(checkedPrincipal.companyId(), checkedPrincipal.role(), memberId);
    }
}
