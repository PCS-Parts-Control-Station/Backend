package com.pcs.domain.member.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.dto.request.ChangeMypagePasswordRequest;
import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateMypageRequest;
import com.pcs.domain.member.dto.response.CreateMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.entity.Member;
import com.pcs.domain.member.entity.MemberAccount;
import com.pcs.domain.member.mapper.MemberMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class MemberServiceTest {

    @Mock
    private MemberMapper memberMapper;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private MemberService memberService;

    @BeforeEach
    void setUp() {
        memberService = new MemberService(memberMapper, passwordEncoder, workspaceAccessValidator);
    }

    @Test
    void searchMembers_ownerCanSearchAdminAndStaff() {
        SearchMemberResponse admin = member(2L, "admin01", MemberRole.ADMIN);
        LocalDate createdFrom = LocalDate.of(2026, 5, 1);
        LocalDate createdTo = LocalDate.of(2026, 5, 31);
        LocalDateTime createdFromAt = LocalDateTime.of(2026, 5, 1, 0, 0);
        LocalDateTime createdToBefore = LocalDateTime.of(2026, 6, 1, 0, 0);
        when(memberMapper.countMembers(
                eq(1L),
                eq("adm"),
                eq(MemberRole.ADMIN),
                eq(PasswordStatus.TEMPORARY),
                eq(List.of(MemberRole.ADMIN, MemberRole.STAFF)),
                eq(createdFromAt),
                eq(createdToBefore)
        ))
                .thenReturn(1L);
        when(memberMapper.searchMembers(
                eq(1L),
                eq("adm"),
                eq(MemberRole.ADMIN),
                eq(PasswordStatus.TEMPORARY),
                eq(List.of(MemberRole.ADMIN, MemberRole.STAFF)),
                eq(createdFromAt),
                eq(createdToBefore),
                eq(20),
                eq(0)
        ))
                .thenReturn(List.of(admin));
        when(memberMapper.summarizeMembers(
                eq(1L),
                eq("adm"),
                eq(MemberRole.ADMIN),
                eq(PasswordStatus.TEMPORARY),
                eq(List.of(MemberRole.ADMIN, MemberRole.STAFF)),
                eq(createdFromAt),
                eq(createdToBefore)
        ))
                .thenReturn(new SearchMemberSummaryResponse(1, 1, 0));

        PageResultDto<SearchMemberResponse, SearchMemberSummaryResponse> result =
                memberService.searchMembers(
                        1L,
                        MemberRole.OWNER,
                        " adm ",
                        MemberRole.ADMIN,
                        PasswordStatus.TEMPORARY,
                        createdFrom,
                        createdTo,
                        0,
                        20,
                        null
                );

        assertThat(result.content()).containsExactly(admin);
        assertThat(result.summary().adminCount()).isEqualTo(1);
        verify(workspaceAccessValidator).validateCompanyActive(1L);
    }

    @Test
    void searchMembers_adminCannotSearchAdminRole() {
        assertThatThrownBy(() ->
                memberService.searchMembers(1L, MemberRole.ADMIN, null, MemberRole.ADMIN, null, null, null, 0, 10, null)
        ).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
        );
    }

    @Test
    void searchMembers_staffCannotUseUserManagement() {
        assertThatThrownBy(() ->
                memberService.searchMembers(1L, MemberRole.STAFF, null, null, null, null, null, 0, 10, null)
        ).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
        );
    }

    @Test
    void createMember_issuesOneTimeTemporaryPassword() {
        CreateMemberRequest request = new CreateMemberRequest("Staff User", "staff01", MemberRole.STAFF);
        when(memberMapper.existsByLoginId(1L, "staff01")).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encoded-temporary-password");
        doAnswer(invocation -> {
            Member member = invocation.getArgument(0);
            member.setMemberId(2L);
            return null;
        }).when(memberMapper).insert(any(Member.class));
        when(memberMapper.findResponseById(1L, 2L)).thenReturn(member(2L, "staff01", MemberRole.STAFF));

        CreateMemberResponse response = memberService.createMember(1L, 10L, MemberRole.OWNER, request);

        assertThat(response.temporaryPassword()).startsWith("PCS-");
        assertThat(response.temporaryPassword()).hasSize(14);
        assertThat(response.member().memberId()).isEqualTo(2L);
        verify(passwordEncoder).encode(response.temporaryPassword());

        ArgumentCaptor<Member> captor = ArgumentCaptor.forClass(Member.class);
        verify(memberMapper).insert(captor.capture());
        assertThat(captor.getValue().getRole()).isEqualTo(MemberRole.STAFF);
        assertThat(captor.getValue().getPasswordStatus()).isEqualTo(PasswordStatus.TEMPORARY);
        assertThat(captor.getValue().getCreatedBy()).isEqualTo(10L);
    }

    @Test
    void createMember_rejectsDuplicateLoginIdInCompany() {
        CreateMemberRequest request = new CreateMemberRequest("Staff User", "staff01", MemberRole.STAFF);
        when(memberMapper.existsByLoginId(1L, "staff01")).thenReturn(true);

        assertThatThrownBy(() -> memberService.createMember(1L, 10L, MemberRole.OWNER, request))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.MEMBER_LOGIN_ID_DUPLICATED)
                );
    }

    @Test
    void createMember_adminCanOnlyCreateStaff() {
        CreateMemberRequest request = new CreateMemberRequest("Admin User", "admin02", MemberRole.ADMIN);

        assertThatThrownBy(() -> memberService.createMember(1L, 10L, MemberRole.ADMIN, request))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.AUTH_FORBIDDEN)
                );
    }

    @Test
    void issueTemporaryPassword_updatesPasswordAndExpiration() {
        when(memberMapper.findResponseById(1L, 2L)).thenReturn(member(2L, "staff01", MemberRole.STAFF));
        when(passwordEncoder.encode(anyString())).thenReturn("encoded-password");
        when(memberMapper.updateTemporaryPassword(eq(1L), eq(2L), eq("encoded-password"), any(LocalDateTime.class)))
                .thenReturn(1);

        TemporaryPasswordResponse response = memberService.issueTemporaryPassword(1L, MemberRole.OWNER, 2L);

        assertThat(response.temporaryPassword()).startsWith("PCS-");
        verify(memberMapper).updateTemporaryPassword(eq(1L), eq(2L), eq("encoded-password"), any(LocalDateTime.class));
    }

    @Test
    void getMyAccount_rejectsInactiveMember() {
        MemberAccount account = account(MemberRole.STAFF, PasswordStatus.ACTIVE);
        account.setActive(false);
        when(memberMapper.findAccount(1L, 2L)).thenReturn(account);

        assertThatThrownBy(() -> memberService.getMyAccount(1L, 2L))
                .isInstanceOfSatisfying(BusinessException.class, exception ->
                        assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.MEMBER_INACTIVE)
                );
    }

    @Test
    void updateMyAccount_updatesOwnName() {
        MemberAccount account = account(MemberRole.STAFF, PasswordStatus.ACTIVE);
        account.setName("Updated Staff");
        when(memberMapper.updateMypageName(1L, 2L, "Updated Staff")).thenReturn(1);
        when(memberMapper.findAccount(1L, 2L)).thenReturn(account);

        MemberAccount updated = memberService.updateMyAccount(1L, 2L, new UpdateMypageRequest(" Updated Staff "));

        assertThat(updated.getName()).isEqualTo("Updated Staff");
    }

    @Test
    void changeMyPassword_updatesPasswordAndActivatesTemporaryAccount() {
        MemberAccount account = account(MemberRole.STAFF, PasswordStatus.TEMPORARY);
        when(memberMapper.findAccount(1L, 2L)).thenReturn(account);
        when(passwordEncoder.matches("old-password", "old-hash")).thenReturn(true);
        when(passwordEncoder.encode("new-password")).thenReturn("new-hash");
        when(memberMapper.updateMypagePassword(1L, 2L, "new-hash")).thenReturn(1);

        MemberAccount response = memberService.changeMyPassword(
                1L,
                2L,
                new ChangeMypagePasswordRequest("old-password", "new-password", "new-password")
        );

        assertThat(response.getMemberId()).isEqualTo(2L);
        verify(memberMapper).updateMypagePassword(1L, 2L, "new-hash");
    }

    @Test
    void changeMyPassword_rejectsWrongCurrentPassword() {
        when(memberMapper.findAccount(1L, 2L)).thenReturn(account(MemberRole.STAFF, PasswordStatus.ACTIVE));
        when(passwordEncoder.matches("wrong-password", "old-hash")).thenReturn(false);

        assertThatThrownBy(() -> memberService.changeMyPassword(
                1L,
                2L,
                new ChangeMypagePasswordRequest("wrong-password", "new-password", "new-password")
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE)
        );
    }

    @Test
    void changeMyPassword_rejectsConfirmMismatch() {
        when(memberMapper.findAccount(1L, 2L)).thenReturn(account(MemberRole.STAFF, PasswordStatus.ACTIVE));
        when(passwordEncoder.matches("old-password", "old-hash")).thenReturn(true);

        assertThatThrownBy(() -> memberService.changeMyPassword(
                1L,
                2L,
                new ChangeMypagePasswordRequest("old-password", "new-password", "mismatch-password")
        )).isInstanceOfSatisfying(BusinessException.class, exception ->
                assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE)
        );
    }

    private SearchMemberResponse member(Long memberId, String loginId, MemberRole role) {
        return new SearchMemberResponse(
                memberId,
                loginId + " name",
                loginId,
                role,
                PasswordStatus.ACTIVE,
                true,
                LocalDateTime.of(2026, 5, 1, 9, 0),
                LocalDateTime.of(2026, 6, 1, 10, 0)
        );
    }

    private MemberAccount account(MemberRole role, PasswordStatus passwordStatus) {
        MemberAccount account = new MemberAccount();
        account.setCompanyId(1L);
        account.setCompanyCode("acme");
        account.setMemberId(2L);
        account.setLoginId("staff01");
        account.setPasswordHash("old-hash");
        account.setName("Staff User");
        account.setRole(role);
        account.setPasswordStatus(passwordStatus);
        account.setActive(true);
        return account;
    }
}
