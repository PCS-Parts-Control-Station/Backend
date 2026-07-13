package com.pcs.domain.inspection.api;

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
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateActiveRequest;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateSummaryResponse;
import com.pcs.domain.inspection.facade.InspectionTemplateFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
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
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class InspectionTemplateApiControllerTest {

    @Mock
    private InspectionTemplateFacade inspectionTemplateFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        mockMvc = MockMvcBuilders.standaloneSetup(new InspectionTemplateApiController(inspectionTemplateFacade))
                .setControllerAdvice(new GlobalExceptionHandler())
                .setCustomArgumentResolvers(new AuthenticationPrincipalArgumentResolver())
                .setMessageConverters(new MappingJackson2HttpMessageConverter(objectMapper))
                .build();
        principal = new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.ADMIN, Instant.now().plusSeconds(600));
        SecurityContextHolder.getContext().setAuthentication(new TestingAuthenticationToken(principal, null));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void searchTemplates_returnsSummary() throws Exception {
        var summary = new SearchInspectionTemplateSummaryResponse(2, 1, 3, 4);
        when(inspectionTemplateFacade.searchTemplates(principal, "acme", "GPU", 10L, true, 0, 20, null))
                .thenReturn(PageResultDto.of(List.of(), 0, 20, 0, summary));

        mockMvc.perform(get("/api/workspaces/acme/inspection-templates")
                        .param("keyword", "GPU")
                        .param("categoryId", "10")
                        .param("active", "true")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.summary.itemCount").value(3))
                .andExpect(jsonPath("$.data.summary.optionCount").value(4));
    }

    @Test
    void createTemplate_rejectsMissingName() throws Exception {
        var request = new CreateInspectionTemplateRequest(10L, "", 1, true);

        mockMvc.perform(post("/api/workspaces/acme/inspection-templates")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-001"));
    }

    @Test
    void updateTemplateActive_forwardsState() throws Exception {
        var request = new UpdateInspectionTemplateActiveRequest(false);

        mockMvc.perform(patch("/api/workspaces/acme/inspection-templates/10/active")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(inspectionTemplateFacade).updateTemplateActive(principal, "acme", 10L, false);
    }

    @Test
    void getTemplate_returnsNotFoundError() throws Exception {
        doThrow(new BusinessException(ErrorCode.INSPECTION_TEMPLATE_NOT_FOUND))
                .when(inspectionTemplateFacade).getTemplate(principal, "acme", 999L);

        mockMvc.perform(get("/api/workspaces/acme/inspection-templates/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false));
    }
}
