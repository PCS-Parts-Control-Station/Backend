package com.pcs.domain.member.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.mapper.MemberMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDateTime;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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
    void issueTemporaryPassword_returnsOneTimePasswordWhenMemberIsUpdated() {
        SearchMemberResponse target = targetMember();
        when(memberMapper.findResponseById(1L, 2L)).thenReturn(target);
        when(passwordEncoder.encode(anyString())).thenReturn("encoded-password");
        when(memberMapper.updateTemporaryPassword(
                org.mockito.ArgumentMatchers.eq(1L),
                org.mockito.ArgumentMatchers.eq(2L),
                org.mockito.ArgumentMatchers.eq("encoded-password"),
                org.mockito.ArgumentMatchers.any(LocalDateTime.class)
        )).thenReturn(1);

        TemporaryPasswordResponse response = memberService.issueTemporaryPassword(1L, MemberRole.OWNER, 2L);

        assertTrue(response.temporaryPassword().startsWith("PCS-"));
        assertEquals(14, response.temporaryPassword().length());
        verify(memberMapper).updateTemporaryPassword(
                org.mockito.ArgumentMatchers.eq(1L),
                org.mockito.ArgumentMatchers.eq(2L),
                org.mockito.ArgumentMatchers.eq("encoded-password"),
                org.mockito.ArgumentMatchers.any(LocalDateTime.class)
        );
    }

    @Test
    void issueTemporaryPassword_failsWhenUpdateTargetDisappears() {
        when(memberMapper.findResponseById(1L, 2L)).thenReturn(targetMember());
        when(passwordEncoder.encode(anyString())).thenReturn("encoded-password");
        when(memberMapper.updateTemporaryPassword(
                org.mockito.ArgumentMatchers.eq(1L),
                org.mockito.ArgumentMatchers.eq(2L),
                org.mockito.ArgumentMatchers.eq("encoded-password"),
                org.mockito.ArgumentMatchers.any(LocalDateTime.class)
        )).thenReturn(0);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> memberService.issueTemporaryPassword(1L, MemberRole.OWNER, 2L)
        );

        assertEquals(ErrorCode.MEMBER_NOT_FOUND, exception.getErrorCode());
    }

    private SearchMemberResponse targetMember() {
        return new SearchMemberResponse(
                2L,
                "작업자",
                "staff01",
                MemberRole.STAFF,
                PasswordStatus.ACTIVE,
                true,
                LocalDateTime.now()
        );
    }
}
