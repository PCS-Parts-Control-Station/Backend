package com.pcs.domain.member.facade;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.auth.service.AuthService;
import com.pcs.domain.member.dto.request.ChangeMypagePasswordRequest;
import com.pcs.domain.member.dto.response.MypageResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.entity.MemberAccount;
import com.pcs.domain.member.service.MemberService;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class MemberFacadeTest {

    @Mock
    private MemberService memberService;
    @Mock
    private AuthService authService;
    @Mock
    private StaffPermissionService staffPermissionService;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private MemberFacade memberFacade;

    @BeforeEach
    void setUp() {
        memberFacade = new MemberFacade(
                memberService,
                authService,
                staffPermissionService,
                workspaceAccessValidator
        );
    }

    @Test
    void issueTemporaryPassword_revokesExistingRefreshTokens() {
        PcsPrincipal principal = new PcsPrincipal(
                1L,
                10L,
                "bupc",
                "owner",
                MemberRole.OWNER,
                Instant.now().plusSeconds(600)
        );
        TemporaryPasswordResponse expected = new TemporaryPasswordResponse(
                "PCS-Ab3de5Fg7H",
                LocalDateTime.now().plusDays(7)
        );
        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "bupc"))
                .thenReturn(principal);
        when(memberService.issueTemporaryPassword(10L, MemberRole.OWNER, 20L)).thenReturn(expected);

        TemporaryPasswordResponse actual = memberFacade.issueTemporaryPassword(principal, "bupc", 20L);

        assertSame(expected, actual);
        verify(authService).revokeMemberRefreshTokens(10L, 20L);
    }

    @Test
    void issueTemporaryPassword_failsWhenRefreshTokenRevocationFails() {
        PcsPrincipal principal = new PcsPrincipal(
                1L,
                10L,
                "bupc",
                "owner",
                MemberRole.OWNER,
                Instant.now().plusSeconds(600)
        );
        TemporaryPasswordResponse expected = new TemporaryPasswordResponse(
                "PCS-Ab3de5Fg7H",
                LocalDateTime.now().plusDays(7)
        );
        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "bupc"))
                .thenReturn(principal);
        when(memberService.issueTemporaryPassword(10L, MemberRole.OWNER, 20L)).thenReturn(expected);
        doThrow(new IllegalStateException("token revoke failed"))
                .when(authService)
                .revokeMemberRefreshTokens(10L, 20L);

        assertThrows(
                IllegalStateException.class,
                () -> memberFacade.issueTemporaryPassword(principal, "bupc", 20L)
        );

        verify(authService).revokeMemberRefreshTokens(10L, 20L);
    }

    @Test
    void changeMypagePassword_revokesCurrentMemberRefreshTokens() {
        PcsPrincipal principal = new PcsPrincipal(
                1L,
                10L,
                "bupc",
                "staff01",
                MemberRole.STAFF,
                Instant.now().plusSeconds(600)
        );
        ChangeMypagePasswordRequest request = new ChangeMypagePasswordRequest(
                "temporary-password",
                "new-password",
                "new-password"
        );
        MemberAccount account = new MemberAccount();
        account.setCompanyId(10L);
        account.setCompanyCode("bupc");
        account.setMemberId(1L);
        account.setLoginId("staff01");
        account.setName("작업자");
        account.setRole(MemberRole.STAFF);
        account.setPasswordStatus(com.pcs.domain.member.type.PasswordStatus.ACTIVE);
        account.setActive(true);

        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "bupc"))
                .thenReturn(principal);
        when(memberService.changeMyPassword(10L, 1L, request)).thenReturn(account);
        when(staffPermissionService.findEnabledPermissions(10L, MemberRole.STAFF)).thenReturn(List.of());

        MypageResponse response = memberFacade.changeMypagePassword(principal, "bupc", request);

        assertSame(MemberRole.STAFF, response.role());
        verify(authService).revokeMemberRefreshTokens(10L, 1L);
    }

    @Test
    void changeMypagePassword_failsWhenRefreshTokenRevocationFails() {
        PcsPrincipal principal = new PcsPrincipal(
                1L,
                10L,
                "bupc",
                "staff01",
                MemberRole.STAFF,
                Instant.now().plusSeconds(600)
        );
        ChangeMypagePasswordRequest request = new ChangeMypagePasswordRequest(
                "temporary-password",
                "new-password",
                "new-password"
        );
        MemberAccount account = new MemberAccount();
        account.setCompanyId(10L);
        account.setCompanyCode("bupc");
        account.setMemberId(1L);
        account.setLoginId("staff01");
        account.setName("작업자");
        account.setRole(MemberRole.STAFF);
        account.setPasswordStatus(com.pcs.domain.member.type.PasswordStatus.ACTIVE);
        account.setActive(true);

        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "bupc"))
                .thenReturn(principal);
        when(memberService.changeMyPassword(10L, 1L, request)).thenReturn(account);
        doThrow(new IllegalStateException("token revoke failed"))
                .when(authService)
                .revokeMemberRefreshTokens(10L, 1L);

        assertThrows(
                IllegalStateException.class,
                () -> memberFacade.changeMypagePassword(principal, "bupc", request)
        );

        verify(authService).revokeMemberRefreshTokens(10L, 1L);
    }
}
