package com.pcs.domain.member.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.pcs.domain.member.dto.request.ChangeMypagePasswordRequest;
import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateMypageRequest;
import com.pcs.domain.member.dto.request.UpdateStaffPermissionRequest;
import com.pcs.domain.member.dto.response.CreateMemberResponse;
import com.pcs.domain.member.dto.response.MypageResponse;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.StaffPermissionItemResponse;
import com.pcs.domain.member.dto.response.StaffPermissionSettingsResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.facade.MemberFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class MemberApiControllerTest {

    @Mock
    private MemberFacade memberFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        mockMvc = MockMvcBuilders
                .standaloneSetup(new MemberApiController(memberFacade))
                .setControllerAdvice(new GlobalExceptionHandler())
                .setCustomArgumentResolvers(new AuthenticationPrincipalArgumentResolver())
                .setMessageConverters(new MappingJackson2HttpMessageConverter(objectMapper))
                .build();
        principal = new PcsPrincipal(7L, 1L, "acme", "owner01", MemberRole.OWNER, Instant.now().plusSeconds(600));
        authenticate(principal);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void searchMembers_returnsPagedMemberList() throws Exception {
        SearchMemberResponse member = member(2L, "staff01", MemberRole.STAFF);
        SearchMemberSummaryResponse summary = new SearchMemberSummaryResponse(1, 0, 1);
        when(memberFacade.searchMembers(
                principal,
                "acme",
                "staff",
                MemberRole.STAFF,
                PasswordStatus.TEMPORARY,
                LocalDate.of(2026, 5, 1),
                LocalDate.of(2026, 5, 31),
                0,
                10,
                null
        ))
                .thenReturn(PageResultDto.of(List.of(member), 0, 10, 1, summary));

        mockMvc.perform(get("/api/workspaces/acme/users")
                        .param("keyword", "staff")
                        .param("role", "STAFF")
                        .param("passwordStatus", "TEMPORARY")
                        .param("createdFrom", "2026-05-01")
                        .param("createdTo", "2026-05-31")
                        .param("page", "0")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content[0].loginId").value("staff01"))
                .andExpect(jsonPath("$.data.summary.staffCount").value(1));
    }

    @Test
    void createMember_returnsOneTimeTemporaryPasswordWithNoStore() throws Exception {
        CreateMemberRequest request = new CreateMemberRequest("Staff User", "staff01", MemberRole.STAFF);
        CreateMemberResponse response = new CreateMemberResponse(
                member(2L, "staff01", MemberRole.STAFF),
                "PCS-AbCd123456",
                LocalDateTime.of(2026, 6, 1, 10, 0)
        );
        when(memberFacade.createMember(eq(principal), eq("acme"), any(CreateMemberRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/workspaces/acme/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(header().string(HttpHeaders.CACHE_CONTROL, "no-store"))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.member.loginId").value("staff01"))
                .andExpect(jsonPath("$.data.temporaryPassword").value("PCS-AbCd123456"));
    }

    @Test
    void getMember_returnsMemberDetail() throws Exception {
        when(memberFacade.getMember(principal, "acme", 2L)).thenReturn(member(2L, "staff01", MemberRole.STAFF));

        mockMvc.perform(get("/api/workspaces/acme/users/2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.loginId").value("staff01"));
    }

    @Test
    void updateMember_returnsForbiddenWhenTargetRoleIsNotManageable() throws Exception {
        UpdateMemberRequest request = new UpdateMemberRequest("Admin User", MemberRole.ADMIN);
        doThrow(new BusinessException(ErrorCode.AUTH_FORBIDDEN))
                .when(memberFacade).updateMember(eq(principal), eq("acme"), eq(2L), any(UpdateMemberRequest.class));

        mockMvc.perform(patch("/api/workspaces/acme/users/2")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("AUTH-005"));
    }

    @Test
    void issueTemporaryPassword_returnsNoStoreOneTimePassword() throws Exception {
        when(memberFacade.issueTemporaryPassword(principal, "acme", 2L))
                .thenReturn(new TemporaryPasswordResponse("PCS-ZyXw987654", LocalDateTime.of(2026, 6, 1, 10, 0)));

        mockMvc.perform(post("/api/workspaces/acme/users/2/temporary-password"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CACHE_CONTROL, "no-store"))
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.temporaryPassword").value("PCS-ZyXw987654"));
    }

    @Test
    void staffPermissions_returnsSettings() throws Exception {
        when(memberFacade.getStaffPermissions(principal, "acme")).thenReturn(new StaffPermissionSettingsResponse(List.of(
                new StaffPermissionItemResponse(StaffPermission.STAFF_INBOUND, "Inbound", true),
                new StaffPermissionItemResponse(StaffPermission.STAFF_OUTBOUND, "Outbound", false)
        )));

        mockMvc.perform(get("/api/workspaces/acme/users/staff-permissions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.permissions[0].code").value("STAFF_INBOUND"))
                .andExpect(jsonPath("$.data.permissions[1].enabled").value(false));
    }

    @Test
    void updateStaffPermissions_returnsSettings() throws Exception {
        UpdateStaffPermissionRequest request = new UpdateStaffPermissionRequest(List.of(StaffPermission.STAFF_INBOUND));
        when(memberFacade.updateStaffPermissions(eq(principal), eq("acme"), any(UpdateStaffPermissionRequest.class)))
                .thenReturn(new StaffPermissionSettingsResponse(List.of(
                        new StaffPermissionItemResponse(StaffPermission.STAFF_INBOUND, "Inbound", true)
                )));

        mockMvc.perform(patch("/api/workspaces/acme/users/staff-permissions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.permissions[0].code").value("STAFF_INBOUND"));
    }

    @Test
    void getMypage_returnsCurrentAccount() throws Exception {
        when(memberFacade.getMypage(principal, "acme")).thenReturn(mypage());

        mockMvc.perform(get("/api/workspaces/acme/mypage"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.loginId").value("owner01"))
                .andExpect(jsonPath("$.data.role").value("OWNER"));
    }

    @Test
    void updateMypage_returnsUpdatedCurrentAccount() throws Exception {
        when(memberFacade.updateMypage(eq(principal), eq("acme"), any(UpdateMypageRequest.class))).thenReturn(mypage());

        mockMvc.perform(patch("/api/workspaces/acme/mypage")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new UpdateMypageRequest("Owner User"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.name").value("Owner User"));
    }

    @Test
    void changeMypagePassword_returnsUpdatedCurrentAccount() throws Exception {
        ChangeMypagePasswordRequest request = new ChangeMypagePasswordRequest(
                "old-password",
                "new-password",
                "new-password"
        );
        when(memberFacade.changeMypagePassword(eq(principal), eq("acme"), any(ChangeMypagePasswordRequest.class)))
                .thenReturn(mypage());

        mockMvc.perform(patch("/api/workspaces/acme/mypage/password")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(memberFacade).changeMypagePassword(eq(principal), eq("acme"), any(ChangeMypagePasswordRequest.class));
    }

    private void authenticate(PcsPrincipal principal) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        TestingAuthenticationToken authentication = new TestingAuthenticationToken(principal, null);
        authentication.setAuthenticated(true);
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
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

    private MypageResponse mypage() {
        return new MypageResponse(
                1L,
                "acme",
                7L,
                "owner01",
                "Owner User",
                MemberRole.OWNER,
                PasswordStatus.ACTIVE,
                StaffPermission.all()
        );
    }
}
