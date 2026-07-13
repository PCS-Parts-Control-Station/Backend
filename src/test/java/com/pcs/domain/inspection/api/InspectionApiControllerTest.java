package com.pcs.domain.inspection.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.response.CreateInspectionResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.facade.InspectionFacade;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
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
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class InspectionApiControllerTest {

    @Mock
    private InspectionFacade inspectionFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        mockMvc = MockMvcBuilders.standaloneSetup(new InspectionApiController(inspectionFacade))
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
    void searchWaitingDocuments_forwardsDashboardPartFilter() throws Exception {
        var summary = new SearchWaitingInspectionDocumentSummaryResponse(1, 4, 0, 4, 0);
        when(inspectionFacade.searchWaitingDocuments(
                principal, "acme", null, 30L, true, null, null,
                null, null, 0, 20, null
        )).thenReturn(PageResultDto.of(List.of(), 0, 20, 0, summary));

        mockMvc.perform(get("/api/workspaces/acme/inspections/waiting-documents")
                        .param("partId", "30")
                        .param("hasWaiting", "true")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.summary.waitingCount").value(4));

        verify(inspectionFacade).searchWaitingDocuments(
                principal, "acme", null, 30L, true, null, null,
                null, null, 0, 20, null
        );
    }

    @Test
    void createInitialInspection_returnsCreatedResponse() throws Exception {
        var request = new CreateInspectionRequest(
                100L, null, InspectionResult.PASS, PartGrade.A, SalesStatus.AVAILABLE, "정상", List.of()
        );
        when(inspectionFacade.createInitialInspection(eq(principal), eq("acme"), any(CreateInspectionRequest.class)))
                .thenReturn(new CreateInspectionResponse(
                        List.of(200L), 1, InspectionType.INITIAL, InspectionResult.PASS,
                        PartGrade.A, SalesStatus.AVAILABLE, LocalDateTime.of(2026, 7, 1, 10, 0)
                ));

        mockMvc.perform(post("/api/workspaces/acme/inspections")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.inspectionIds[0]").value(200))
                .andExpect(jsonPath("$.data.inspectionType").value("INITIAL"));
    }

    @Test
    void createInitialInspection_rejectsInvalidPassDecision() throws Exception {
        var request = new CreateInspectionRequest(
                100L, null, InspectionResult.PASS, PartGrade.DEFECTIVE,
                SalesStatus.AVAILABLE, null, List.of()
        );

        mockMvc.perform(post("/api/workspaces/acme/inspections")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-001"));
    }

    @Test
    void searchHistories_returnsInspectionSummary() throws Exception {
        var summary = new SearchInspectionHistorySummaryResponse(3, 1, 1, 1, 1, 0);
        when(inspectionFacade.searchHistories(
                principal, "acme", null, 10L, null, null, null, null, null,
                null, null, 0, 20, null
        )).thenReturn(PageResultDto.of(List.of(), 0, 20, 0, summary));

        mockMvc.perform(get("/api/workspaces/acme/inspections")
                        .param("documentId", "10")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.summary.correctionCount").value(1))
                .andExpect(jsonPath("$.data.summary.reinspectionCount").value(1));
    }

    @Test
    void getHistoryDetail_returnsNotFoundError() throws Exception {
        doThrow(new BusinessException(ErrorCode.INSPECTION_NOT_FOUND))
                .when(inspectionFacade).getHistoryDetail(principal, "acme", 999L);

        mockMvc.perform(get("/api/workspaces/acme/inspections/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false));
    }
}
