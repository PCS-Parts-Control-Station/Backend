package com.pcs.domain.member.api;

import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateMemberRequest;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.facade.MemberFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class MemberApiController {

    private final MemberFacade memberFacade;

    public MemberApiController(MemberFacade memberFacade) {
        this.memberFacade = memberFacade;
    }

    @GetMapping("/workspaces/{companyCode}/users")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchMemberResponse, SearchMemberSummaryResponse>>> searchMembers(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) MemberRole role,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchMemberResponse, SearchMemberSummaryResponse> response = memberFacade.searchMembers(
                principal,
                companyCode,
                keyword,
                role,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/users")
    public ResponseEntity<ApiResultDto<SearchMemberResponse>> createMember(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateMemberRequest request
    ) {
        SearchMemberResponse response = memberFacade.createMember(principal, companyCode, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("사용자 등록이 완료되었습니다.", response));
    }

    @GetMapping("/workspaces/{companyCode}/users/{memberId}")
    public ResponseEntity<ApiResultDto<SearchMemberResponse>> getMember(
            @PathVariable String companyCode,
            @PathVariable Long memberId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        SearchMemberResponse response = memberFacade.getMember(principal, companyCode, memberId);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PatchMapping("/workspaces/{companyCode}/users/{memberId}")
    public ResponseEntity<ApiResultDto<SearchMemberResponse>> updateMember(
            @PathVariable String companyCode,
            @PathVariable Long memberId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateMemberRequest request
    ) {
        SearchMemberResponse response = memberFacade.updateMember(principal, companyCode, memberId, request);
        return ResponseEntity.ok(ApiResultDto.ok("사용자 수정이 완료되었습니다.", response));
    }

    @PostMapping("/workspaces/{companyCode}/users/{memberId}/temporary-password")
    public ResponseEntity<ApiResultDto<TemporaryPasswordResponse>> issueTemporaryPassword(
            @PathVariable String companyCode,
            @PathVariable Long memberId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        TemporaryPasswordResponse response = memberFacade.issueTemporaryPassword(principal, companyCode, memberId);
        return ResponseEntity.ok(ApiResultDto.ok("임시 비밀번호가 발급되었습니다.", response));
    }
}
