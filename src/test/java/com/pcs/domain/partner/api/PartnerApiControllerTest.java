package com.pcs.domain.partner.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.partner.dto.request.CreatePartnerRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerActiveRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.facade.PartnerFacade;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
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
class PartnerApiControllerTest {

    @Mock
    private PartnerFacade partnerFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        mockMvc = MockMvcBuilders
                .standaloneSetup(new PartnerApiController(partnerFacade))
                .setControllerAdvice(new GlobalExceptionHandler())
                .setCustomArgumentResolvers(new AuthenticationPrincipalArgumentResolver())
                .setMessageConverters(new MappingJackson2HttpMessageConverter(objectMapper))
                .build();
        principal = new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.ADMIN, Instant.now().plusSeconds(600));
        authenticate(principal);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void searchPartners_returnsPagedPartnersWithSummary() throws Exception {
        SearchPartnerResponse partner = partnerResponse(10L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, true);
        SearchPartnerSummaryResponse summary = new SearchPartnerSummaryResponse(1, 1, 0, 1);
        when(partnerFacade.searchPartners(
                principal,
                "acme",
                "Yongsan",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                true,
                0,
                20,
                null
        )).thenReturn(PageResultDto.of(List.of(partner), 0, 20, 1, summary));

        mockMvc.perform(get("/api/workspaces/acme/partners")
                        .param("keyword", "Yongsan")
                        .param("partnerType", "COMPANY")
                        .param("partnerRole", "SUPPLIER")
                        .param("active", "true")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content[0].partnerName").value("Yongsan Parts"))
                .andExpect(jsonPath("$.data.content[0].partnerRole").value("SUPPLIER"))
                .andExpect(jsonPath("$.data.summary.totalCount").value(1))
                .andExpect(jsonPath("$.data.summary.activeCount").value(1));
    }

    @Test
    void createPartner_returnsCreatedPartner() throws Exception {
        CreatePartnerRequest request = new CreatePartnerRequest(
                "Yongsan Parts",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                "010-1234-5678",
                null,
                null,
                null,
                null
        );
        when(partnerFacade.createPartner(eq(principal), eq("acme"), any(CreatePartnerRequest.class)))
                .thenReturn(partnerResponse(10L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, true));

        mockMvc.perform(post("/api/workspaces/acme/partners")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.partnerId").value(10))
                .andExpect(jsonPath("$.data.active").value(true));
    }

    @Test
    void getPartner_returnsPartnerDetail() throws Exception {
        when(partnerFacade.getPartner(principal, "acme", 10L))
                .thenReturn(partnerResponse(10L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.BOTH, true));

        mockMvc.perform(get("/api/workspaces/acme/partners/10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.partnerName").value("Yongsan Parts"))
                .andExpect(jsonPath("$.data.partnerRole").value("BOTH"));
    }

    @Test
    void updatePartner_returnsBusinessErrorWhenNameDuplicated() throws Exception {
        UpdatePartnerRequest request = new UpdatePartnerRequest(
                "Yongsan Parts",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                null,
                null,
                null,
                null,
                true
        );
        doThrow(new BusinessException(ErrorCode.PARTNER_NAME_DUPLICATED))
                .when(partnerFacade).updatePartner(eq(principal), eq("acme"), eq(10L), any(UpdatePartnerRequest.class));

        mockMvc.perform(patch("/api/workspaces/acme/partners/10")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("PARTNER-002"));
    }

    @Test
    void updatePartnerActive_returnsOk() throws Exception {
        UpdatePartnerActiveRequest request = new UpdatePartnerActiveRequest(false);

        mockMvc.perform(patch("/api/workspaces/acme/partners/10/active")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(partnerFacade).updatePartnerActive(principal, "acme", 10L, request);
    }

    private void authenticate(PcsPrincipal principal) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        TestingAuthenticationToken authentication = new TestingAuthenticationToken(principal, null);
        authentication.setAuthenticated(true);
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    private SearchPartnerResponse partnerResponse(
            Long partnerId,
            String partnerName,
            PartnerType partnerType,
            PartnerRole partnerRole,
            boolean active
    ) {
        return new SearchPartnerResponse(
                partnerId,
                partnerName,
                partnerType,
                partnerRole,
                "010-1234-5678",
                "partner@example.com",
                "Seoul",
                null,
                active,
                LocalDateTime.of(2026, 6, 1, 10, 0)
        );
    }
}
