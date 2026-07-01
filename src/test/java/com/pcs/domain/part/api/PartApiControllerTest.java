package com.pcs.domain.part.api;

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
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.dto.request.CreatePartRequest;
import com.pcs.domain.part.dto.request.PartSpecValueRequest;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.dto.response.PartDetailResponse;
import com.pcs.domain.part.dto.response.PartSpecValueResponse;
import com.pcs.domain.part.dto.response.PartUnitDetailResponse;
import com.pcs.domain.part.dto.response.PartUnitInspectionHistoryResponse;
import com.pcs.domain.part.dto.response.PartUnitStockHistoryResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.dto.response.SearchPartSummaryResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitSummaryResponse;
import com.pcs.domain.part.facade.PartFacade;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.type.MovementType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.math.BigDecimal;
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
class PartApiControllerTest {

    @Mock
    private PartFacade partFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        mockMvc = MockMvcBuilders
                .standaloneSetup(new PartApiController(partFacade))
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
    void searchParts_returnsPagedPartsWithSummary() throws Exception {
        SearchPartResponse part = partResponse(20L, "RTX 3060", "GPU-MSI-001", true, 4);
        SearchPartSummaryResponse summary = new SearchPartSummaryResponse(1, 4, 0);
        when(partFacade.searchParts(principal, "acme", "RTX", 10L, true, 0, 20, null))
                .thenReturn(PageResultDto.of(List.of(part), 0, 20, 1, summary));

        mockMvc.perform(get("/api/workspaces/acme/parts")
                        .param("keyword", "RTX")
                        .param("categoryId", "10")
                        .param("active", "true")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content[0].partName").value("RTX 3060"))
                .andExpect(jsonPath("$.data.content[0].currentStockQuantity").value(4))
                .andExpect(jsonPath("$.data.summary.totalCount").value(1))
                .andExpect(jsonPath("$.data.summary.totalStock").value(4));

        verify(partFacade).searchParts(principal, "acme", "RTX", 10L, true, 0, 20, null);
    }

    @Test
    void searchPartUnits_returnsPagedUnitsWithSummaryAndIgnoresSalesStatusFilter() throws Exception {
        SearchPartUnitResponse unit = partUnitResponse(101L, "PCS-GPU-0001", PartGrade.A, SalesStatus.AVAILABLE);
        SearchPartUnitSummaryResponse summary = new SearchPartUnitSummaryResponse(1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
        when(partFacade.searchPartUnits(principal, "acme", "RTX", 10L, "A", 0, 20, null))
                .thenReturn(PageResultDto.of(List.of(unit), 0, 20, 1, summary));

        mockMvc.perform(get("/api/workspaces/acme/part-units")
                        .param("keyword", "RTX")
                        .param("categoryId", "10")
                        .param("partState", "A")
                        .param("salesStatus", "UNAVAILABLE")
                        .param("page", "0")
                        .param("size", "20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content[0].internalSerialNo").value("PCS-GPU-0001"))
                .andExpect(jsonPath("$.data.content[0].grade").value("A"))
                .andExpect(jsonPath("$.data.content[0].salesStatus").value("AVAILABLE"))
                .andExpect(jsonPath("$.data.summary.totalCount").value(1))
                .andExpect(jsonPath("$.data.summary.heldCount").value(1))
                .andExpect(jsonPath("$.data.summary.salesAvailableCount").value(1))
                .andExpect(jsonPath("$.data.summary.gradeACount").value(1))
                .andExpect(jsonPath("$.data.summary.outboundAvailableCount").value(1));

        verify(partFacade).searchPartUnits(principal, "acme", "RTX", 10L, "A", 0, 20, null);
    }

    @Test
    void getPartUnit_returnsDetailWithStockAndInspectionHistories() throws Exception {
        when(partFacade.getPartUnit(principal, "acme", 101L)).thenReturn(partUnitDetail(101L));

        mockMvc.perform(get("/api/workspaces/acme/part-units/101"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.unit.internalSerialNo").value("PCS-GPU-0001"))
                .andExpect(jsonPath("$.data.stockHistories[0].documentNo").value("IN-20260101-0001"))
                .andExpect(jsonPath("$.data.inspectionHistories[0].grade").value("A"));
    }

    @Test
    void getPartUnit_returnsBusinessErrorWhenUnitNotFound() throws Exception {
        doThrow(new BusinessException(ErrorCode.PART_UNIT_NOT_FOUND))
                .when(partFacade).getPartUnit(principal, "acme", 999L);

        mockMvc.perform(get("/api/workspaces/acme/part-units/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("PART-003"));
    }

    @Test
    void createPart_returnsCreatedDetail() throws Exception {
        CreatePartRequest request = new CreatePartRequest(
                10L,
                "RTX 3060",
                "MSI",
                "RTX 3060 Ventus",
                2,
                List.of(new PartSpecValueRequest(101L, null, null, null, 201L))
        );
        when(partFacade.createPart(eq(principal), eq("acme"), any(CreatePartRequest.class)))
                .thenReturn(partDetail(20L, "GPU-MSI-001"));

        mockMvc.perform(post("/api/workspaces/acme/parts")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.partId").value(20))
                .andExpect(jsonPath("$.data.partCode").value("GPU-MSI-001"))
                .andExpect(jsonPath("$.data.specValues[0].selectedOptionValue").value("RTX_3060"));
    }

    @Test
    void getPart_returnsDetail() throws Exception {
        when(partFacade.getPart(principal, "acme", 20L)).thenReturn(partDetail(20L, "GPU-MSI-001"));

        mockMvc.perform(get("/api/workspaces/acme/parts/20"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.partName").value("RTX 3060"))
                .andExpect(jsonPath("$.data.specValues[0].specKey").value("gpu_chip"));
    }

    @Test
    void updatePart_returnsBusinessErrorWhenPartNotFound() throws Exception {
        UpdatePartRequest request = new UpdatePartRequest(
                10L,
                "RTX 3060",
                "MSI",
                "RTX 3060 Ventus",
                2,
                List.of()
        );
        doThrow(new BusinessException(ErrorCode.PART_NOT_FOUND))
                .when(partFacade).updatePart(eq(principal), eq("acme"), eq(99L), any(UpdatePartRequest.class));

        mockMvc.perform(patch("/api/workspaces/acme/parts/99")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("PART-001"));
    }

    private void authenticate(PcsPrincipal principal) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        TestingAuthenticationToken authentication = new TestingAuthenticationToken(principal, null);
        authentication.setAuthenticated(true);
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    private PartDetailResponse partDetail(Long partId, String partCode) {
        return new PartDetailResponse(
                partId,
                10L,
                "GPU",
                "RTX 3060",
                "RTX 3060 Ventus",
                "MSI",
                partCode,
                2,
                4,
                true,
                List.of(new PartSpecValueResponse(
                        1L,
                        101L,
                        "gpu_chip",
                        "GPU chip",
                        "SELECT",
                        null,
                        null,
                        null,
                        null,
                        201L,
                        "RTX 3060",
                        "RTX_3060"
                ))
        );
    }

    private SearchPartResponse partResponse(Long partId, String partName, String partCode, boolean active, int stock) {
        return new SearchPartResponse(
                partId,
                10L,
                "GPU",
                partName,
                "RTX 3060 Ventus",
                "MSI",
                partCode,
                2,
                stock,
                active
        );
    }

    private SearchPartUnitResponse partUnitResponse(
            Long unitId,
            String serialNo,
            PartGrade grade,
            SalesStatus salesStatus
    ) {
        LocalDateTime processedAt = LocalDateTime.of(2026, 1, 3, 9, 30);
        return new SearchPartUnitResponse(
                unitId,
                serialNo,
                "MFR-" + unitId,
                20L,
                10L,
                "GPU",
                "RTX 3060",
                "RTX 3060 Ventus",
                "MSI",
                "GPU-MSI-001",
                UnitStatus.IN_STOCK,
                InspectionStatus.COMPLETED,
                grade,
                salesStatus,
                processedAt.minusDays(2),
                processedAt,
                "IN-20260101-0001",
                MovementType.INBOUND,
                processedAt.minusDays(1),
                301L,
                InspectionType.INITIAL,
                processedAt,
                "검수",
                processedAt
        );
    }

    private PartUnitDetailResponse partUnitDetail(Long unitId) {
        return new PartUnitDetailResponse(
                partUnitResponse(unitId, "PCS-GPU-0001", PartGrade.A, SalesStatus.AVAILABLE),
                List.of(new PartUnitStockHistoryResponse(
                        201L,
                        301L,
                        "IN-20260101-0001",
                        MovementType.INBOUND,
                        null,
                        UnitStatus.IN_STOCK,
                        "Admin",
                        LocalDateTime.of(2026, 1, 2, 10, 0)
                )),
                List.of(new PartUnitInspectionHistoryResponse(
                        301L,
                        InspectionType.INITIAL,
                        InspectionResult.PASS,
                        PartGrade.A,
                        SalesStatus.AVAILABLE,
                        "Admin",
                        LocalDateTime.of(2026, 1, 3, 9, 30),
                        "정상"
                ))
        );
    }
}
