package com.pcs.domain.company.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pcs.domain.company.dto.request.OwnerSignupRequest;
import com.pcs.domain.company.dto.request.UpdateOwnerCompanyRequest;
import com.pcs.domain.company.dto.response.OwnerCompanyResponse;
import com.pcs.domain.company.dto.response.OwnerSignupResponse;
import com.pcs.domain.company.facade.CompanyFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class OwnerSignupApiControllerTest {

    @Mock
    private CompanyFacade companyFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        mockMvc = MockMvcBuilders
                .standaloneSetup(new OwnerSignupApiController(companyFacade))
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
    void signup_returnsCreatedWorkspaceAddress() throws Exception {
        OwnerSignupRequest request = signupRequest();
        when(companyFacade.signupOwner(any(OwnerSignupRequest.class)))
                .thenReturn(new OwnerSignupResponse(1L, "acme", "/w/acme", 7L, "owner01"));

        mockMvc.perform(post("/api/owners/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.companyCode").value("acme"))
                .andExpect(jsonPath("$.data.workspaceLoginUrl").value("/w/acme"))
                .andExpect(jsonPath("$.data.ownerLoginId").value("owner01"));
    }

    @Test
    void signup_returnsBusinessErrorWhenCompanyCodeDuplicated() throws Exception {
        doThrow(new BusinessException(ErrorCode.COMPANY_CODE_DUPLICATED))
                .when(companyFacade).signupOwner(any(OwnerSignupRequest.class));

        mockMvc.perform(post("/api/owners/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signupRequest())))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("COMPANY-002"));
    }

    @Test
    void getOwnerCompany_returnsOwnerCompany() throws Exception {
        when(companyFacade.getOwnerCompany(principal)).thenReturn(ownerCompany());

        mockMvc.perform(get("/api/owners/company"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.companyCode").value("acme"))
                .andExpect(jsonPath("$.data.companyName").value("ACME Parts"));
    }

    @Test
    void updateOwnerCompany_returnsUpdatedOwnerCompany() throws Exception {
        UpdateOwnerCompanyRequest request = new UpdateOwnerCompanyRequest(
                "ACME Updated",
                "owner@example.com",
                "02-1111-2222",
                "123-45-67890"
        );
        when(companyFacade.updateOwnerCompany(eq(principal), any(UpdateOwnerCompanyRequest.class)))
                .thenReturn(new OwnerCompanyResponse(
                        1L,
                        "acme",
                        "ACME Updated",
                        "owner@example.com",
                        "02-1111-2222",
                        "123-45-67890",
                        true
                ));

        mockMvc.perform(patch("/api/owners/company")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.companyCode").value("acme"))
                .andExpect(jsonPath("$.data.companyName").value("ACME Updated"));
    }

    private void authenticate(PcsPrincipal principal) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        TestingAuthenticationToken authentication = new TestingAuthenticationToken(principal, null);
        authentication.setAuthenticated(true);
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    private OwnerSignupRequest signupRequest() {
        return new OwnerSignupRequest(
                "ACME Parts",
                "acme",
                "123-45-67890",
                "owner@example.com",
                "02-1111-2222",
                "Owner User",
                "owner01",
                "password123"
        );
    }

    private OwnerCompanyResponse ownerCompany() {
        return new OwnerCompanyResponse(
                1L,
                "acme",
                "ACME Parts",
                "owner@example.com",
                "02-1111-2222",
                "123-45-67890",
                true
        );
    }
}
