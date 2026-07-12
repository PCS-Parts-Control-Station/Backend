package com.pcs.domain.stock.api;

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
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateOutboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchOutboundCandidateResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailResponse;
import com.pcs.domain.stock.facade.StockFacade;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
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
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class StockApiControllerTest {

    @Mock
    private StockFacade stockFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        mockMvc = MockMvcBuilders.standaloneSetup(new StockApiController(stockFacade))
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
    void searchDocuments_forwardsUnifiedDocumentFilters() throws Exception {
        var row = new SearchStockDocumentResponse(
                10L, "IN-001", StockDocumentType.INBOUND, StockDocumentStatus.COMPLETED,
                20L, "공급처", "RAM", 1, 3, "관리자", LocalDateTime.of(2026, 7, 1, 10, 0)
        );
        var summary = new SearchStockDocumentSummaryResponse(1L, 3L, 3L, 0L);
        when(stockFacade.searchDocuments(
                principal, "acme", StockDocumentType.INBOUND, "RAM", 20L,
                StockDocumentStatus.COMPLETED, LocalDate.of(2026, 7, 1), LocalDate.of(2026, 7, 31), 0, 10, null
        )).thenReturn(PageResultDto.of(List.of(row), 0, 10, 1, summary));

        mockMvc.perform(get("/api/workspaces/acme/stock/documents")
                        .param("documentType", "INBOUND")
                        .param("keyword", "RAM")
                        .param("partnerId", "20")
                        .param("documentStatus", "COMPLETED")
                        .param("dateFrom", "2026-07-01")
                        .param("dateTo", "2026-07-31")
                        .param("page", "0")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content[0].documentNo").value("IN-001"))
                .andExpect(jsonPath("$.data.summary.totalQuantity").value(3));
    }

    @Test
    void createInboundDocument_returnsCreatedResponse() throws Exception {
        var request = new CreateInboundDocumentRequest(
                20L, "입고", List.of(new CreateInboundDocumentLineRequest(30L, 2, null))
        );
        when(stockFacade.createInboundDocument(eq(principal), eq("acme"), any(CreateInboundDocumentRequest.class)))
                .thenReturn(new CreateInboundDocumentResponse(10L, "IN-001", 20L, 1, 2, 2));

        mockMvc.perform(post("/api/workspaces/acme/stock/documents/inbounds")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.documentNo").value("IN-001"))
                .andExpect(jsonPath("$.data.createdUnitCount").value(2));
    }

    @Test
    void createInboundDocument_rejectsEmptyLines() throws Exception {
        var request = new CreateInboundDocumentRequest(20L, null, List.of());

        mockMvc.perform(post("/api/workspaces/acme/stock/documents/inbounds")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("COMMON-001"));
    }

    @Test
    void createOutboundDocument_returnsCreatedResponse() throws Exception {
        var request = new CreateOutboundDocumentRequest(
                21L, "출고", List.of(new CreateOutboundDocumentLineRequest(30L, List.of(100L), null))
        );
        when(stockFacade.createOutboundDocument(eq(principal), eq("acme"), any(CreateOutboundDocumentRequest.class)))
                .thenReturn(new CreateOutboundDocumentResponse(11L, "OUT-001", 21L, 1, 1, 1));

        mockMvc.perform(post("/api/workspaces/acme/stock/documents/outbounds")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.documentNo").value("OUT-001"))
                .andExpect(jsonPath("$.data.outboundUnitCount").value(1));
    }

    @Test
    void searchOutboundCandidates_returnsEligibleUnits() throws Exception {
        var candidate = new SearchOutboundCandidateResponse(
                100L, "PCS-GPU-001", "MFR-001", 30L, 40L, "GPU",
                "RTX 4060", "Dual", "ASUS", "GPU-4060",
                UnitStatus.IN_STOCK, InspectionStatus.COMPLETED, PartGrade.A, SalesStatus.AVAILABLE
        );
        when(stockFacade.searchOutboundCandidates(
                principal, "acme", "RTX", 40L, 30L, PartGrade.A, 0, 20, null
        )).thenReturn(PageResultDto.of(List.of(candidate), 0, 20, 1, null));

        mockMvc.perform(get("/api/workspaces/acme/stock/outbound-candidates")
                        .param("keyword", "RTX")
                        .param("categoryId", "40")
                        .param("partId", "30")
                        .param("grade", "A")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content[0].internalSerialNo").value("PCS-GPU-001"))
                .andExpect(jsonPath("$.data.content[0].salesStatus").value("AVAILABLE"));
    }

    @Test
    void getDocument_returnsDetailUsedByHistoryAndUnifiedSearch() throws Exception {
        when(stockFacade.getDocument(principal, "acme", 10L)).thenReturn(new StockDocumentDetailResponse(
                10L, "IN-001", StockDocumentType.INBOUND, StockDocumentStatus.COMPLETED,
                20L, "공급처", "입고", "관리자", LocalDateTime.of(2026, 7, 1, 10, 0),
                1, 2, true, null, List.of()
        ));

        mockMvc.perform(get("/api/workspaces/acme/stock/documents/10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.documentNo").value("IN-001"))
                .andExpect(jsonPath("$.data.cancelable").value(true));
    }

    @Test
    void cancelDocument_returnsBusinessError() throws Exception {
        doThrow(new BusinessException(ErrorCode.STOCK_DOCUMENT_ALREADY_CANCELED))
                .when(stockFacade).cancelDocument(principal, "acme", 10L);

        mockMvc.perform(post("/api/workspaces/acme/stock/documents/10/cancel"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success").value(false));

        verify(stockFacade).cancelDocument(principal, "acme", 10L);
    }
}
