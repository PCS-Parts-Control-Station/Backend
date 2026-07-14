package com.pcs.domain.stock.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.StaffPermission;
import com.pcs.domain.member.service.StaffPermissionService;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateOutboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailResponse;
import com.pcs.domain.stock.dto.response.StockDocumentLineResponse;
import com.pcs.domain.stock.service.StockService;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import com.pcs.global.workspace.WorkspaceMapper;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DuplicateKeyException;

@ExtendWith(MockitoExtension.class)
class StockFacadeTest {

    @Mock
    private StockService stockService;

    @Mock
    private WorkspaceMapper workspaceMapper;

    @Mock
    private StaffPermissionService staffPermissionService;

    private StockFacade stockFacade;

    @BeforeEach
    void setUp() {
        stockFacade = new StockFacade(stockService, new WorkspaceAccessValidator(workspaceMapper), staffPermissionService);
    }

    @Test
    void searchDocuments_success() {
        SearchStockDocumentResponse row = new SearchStockDocumentResponse(
                500L,
                "IN-20260529-23456789ABCDEFGH",
                StockDocumentType.INBOUND,
                StockDocumentStatus.COMPLETED,
                100L,
                "서울 부품사",
                "RTX 4060",
                1,
                3,
                "관리자",
                LocalDateTime.of(2026, 5, 29, 10, 0)
        );
        SearchStockDocumentSummaryResponse summary = new SearchStockDocumentSummaryResponse(
                1L,
                3L,
                3L,
                0L
        );
        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> expected =
                PageResultDto.of(List.of(row), 0, 20, 1, summary);

        when(stockService.searchDocuments(
                1L,
                StockDocumentType.INBOUND,
                "RTX",
                100L,
                StockDocumentStatus.COMPLETED,
                null,
                null,
                0,
                20,
                null
        )).thenReturn(expected);

        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> response =
                stockFacade.searchDocuments(
                        principal(1L, 10L, "acme"),
                        "acme",
                        StockDocumentType.INBOUND,
                        "RTX",
                        100L,
                        StockDocumentStatus.COMPLETED,
                        null,
                        null,
                        0,
                        20,
                        null
                );

        assertSame(expected, response);
        verify(stockService).searchDocuments(
                1L,
                StockDocumentType.INBOUND,
                "RTX",
                100L,
                StockDocumentStatus.COMPLETED,
                null,
                null,
                0,
                20,
                null
        );
    }

    @Test
    void searchDocuments_success_whenOutboundManagementFilter() {
        SearchStockDocumentResponse row = new SearchStockDocumentResponse(
                600L,
                "OUT-20260619-23456789ABCDEFGH",
                StockDocumentType.OUTBOUND,
                StockDocumentStatus.COMPLETED,
                200L,
                "서울 고객사",
                "RAM DDR4 16GB",
                1,
                2,
                "관리자",
                LocalDateTime.of(2026, 6, 19, 10, 0)
        );
        SearchStockDocumentSummaryResponse summary = new SearchStockDocumentSummaryResponse(
                1L,
                2L,
                0L,
                2L
        );
        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> expected =
                PageResultDto.of(List.of(row), 0, 10, 1, summary);
        LocalDate dateFrom = LocalDate.of(2026, 6, 1);
        LocalDate dateTo = LocalDate.of(2026, 6, 30);

        when(stockService.searchDocuments(
                1L,
                StockDocumentType.OUTBOUND,
                "RAM",
                200L,
                StockDocumentStatus.COMPLETED,
                dateFrom,
                dateTo,
                0,
                10,
                null
        )).thenReturn(expected);

        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> response =
                stockFacade.searchDocuments(
                        principal(1L, 10L, "acme"),
                        "acme",
                        StockDocumentType.OUTBOUND,
                        "RAM",
                        200L,
                        StockDocumentStatus.COMPLETED,
                        dateFrom,
                        dateTo,
                        0,
                        10,
                        null
                );

        assertSame(expected, response);
        verify(stockService).searchDocuments(
                1L,
                StockDocumentType.OUTBOUND,
                "RAM",
                200L,
                StockDocumentStatus.COMPLETED,
                dateFrom,
                dateTo,
                0,
                10,
                null
        );
    }

    @Test
    void getDocument_success() {
        StockDocumentDetailResponse expected = new StockDocumentDetailResponse(
                500L,
                "IN-20260529-23456789ABCDEFGH",
                StockDocumentType.INBOUND,
                StockDocumentStatus.COMPLETED,
                100L,
                "서울 부품사",
                "입고",
                "관리자",
                LocalDateTime.of(2026, 5, 29, 10, 0),
                1,
                2,
                true,
                null,
                List.<StockDocumentLineResponse>of()
        );

        when(stockService.getDocument(1L, 500L)).thenReturn(expected);

        StockDocumentDetailResponse response = stockFacade.getDocument(principal(1L, 10L, "acme"), "acme", 500L);

        assertSame(expected, response);
        verify(stockService).getDocument(1L, 500L);
    }

    @Test
    void cancelDocument_success() {
        CancelStockDocumentResponse expected = new CancelStockDocumentResponse(
                500L,
                "IN-20260529-23456789ABCDEFGH",
                StockDocumentStatus.CANCELED,
                1,
                2
        );

        when(stockService.cancelDocument(1L, 10L, 500L)).thenReturn(expected);

        CancelStockDocumentResponse response = stockFacade.cancelDocument(principal(1L, 10L, "acme"), "acme", 500L);

        assertSame(expected, response);
        verify(stockService).cancelDocument(1L, 10L, 500L);
    }

    @Test
    void cancelDocument_blocksStaffWithoutPermissionForDocumentType() {
        StockDocumentDetailResponse outbound = documentDetail(500L, StockDocumentType.OUTBOUND);
        when(stockService.getDocument(1L, 500L)).thenReturn(outbound);
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_OUTBOUND)).thenReturn(false);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockFacade.cancelDocument(staffPrincipal(), "acme", 500L)
        );

        assertEquals(ErrorCode.AUTH_STAFF_PERMISSION_DENIED, exception.getErrorCode());
        verify(stockService, never()).cancelDocument(1L, 10L, 500L);
    }

    @Test
    void cancelDocument_usesInboundPermissionForInboundDocument() {
        StockDocumentDetailResponse inbound = documentDetail(500L, StockDocumentType.INBOUND);
        CancelStockDocumentResponse expected = new CancelStockDocumentResponse(
                500L, "IN-20260529-23456789ABCDEFGH", StockDocumentStatus.CANCELED, 1, 2
        );
        when(stockService.getDocument(1L, 500L)).thenReturn(inbound);
        when(staffPermissionService.isEnabled(1L, StaffPermission.STAFF_INBOUND)).thenReturn(true);
        when(stockService.cancelDocument(1L, 10L, 500L)).thenReturn(expected);

        assertSame(expected, stockFacade.cancelDocument(staffPrincipal(), "acme", 500L));
        verify(staffPermissionService).isEnabled(1L, StaffPermission.STAFF_INBOUND);
    }

    @Test
    void createInboundDocument_success() {
        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                100L,
                "입고",
                List.of(new CreateInboundDocumentLineRequest(1000L, 2, "라인"))
        );
        CreateInboundDocumentResponse expected = new CreateInboundDocumentResponse(
                1L,
                "IN-20260526-0001",
                100L,
                1,
                2,
                2
        );

        when(stockService.createInboundDocument(1L, 10L, request)).thenReturn(expected);

        CreateInboundDocumentResponse response = stockFacade.createInboundDocument(
                principal(1L, 10L, "acme"),
                "acme",
                request
        );

        assertSame(expected, response);
        verify(stockService).createInboundDocument(1L, 10L, request);
    }

    @Test
    void createOutboundDocument_success() {
        CreateOutboundDocumentRequest request = new CreateOutboundDocumentRequest(
                200L,
                "판매 출고",
                List.of(new CreateOutboundDocumentLineRequest(1000L, List.of(10000L, 10001L), "라인"))
        );
        CreateOutboundDocumentResponse expected = new CreateOutboundDocumentResponse(
                2L,
                "OUT-20260619-23456789ABCDEFGH",
                200L,
                1,
                2,
                2
        );

        when(stockService.createOutboundDocument(1L, 10L, request)).thenReturn(expected);

        CreateOutboundDocumentResponse response = stockFacade.createOutboundDocument(
                principal(1L, 10L, "acme"),
                "acme",
                request
        );

        assertSame(expected, response);
        verify(stockService).createOutboundDocument(1L, 10L, request);
    }

    @Test
    void createInboundDocument_fail_whenPrincipalMissing() {
        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                100L,
                null,
                List.of(new CreateInboundDocumentLineRequest(1000L, 1, null))
        );

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockFacade.createInboundDocument(null, "acme", request)
        );

        assertEquals(ErrorCode.AUTH_REQUIRED, exception.getErrorCode());
    }

    @Test
    void createInboundDocument_fail_whenWorkspaceMismatch() {
        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                100L,
                null,
                List.of(new CreateInboundDocumentLineRequest(1000L, 1, null))
        );
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockFacade.createInboundDocument(principal(1L, 10L, "acme"), "other", request)
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    @Test
    void createInboundDocument_propagatesDuplicateKeyForGlobalHandling() {
        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                100L,
                null,
                List.of(new CreateInboundDocumentLineRequest(1000L, 1, null))
        );
        when(stockService.createInboundDocument(any(), any(), any())).thenThrow(
                new DuplicateKeyException("duplicate", new RuntimeException("uk_stock_document_document_no"))
        );

        assertThrows(
                DuplicateKeyException.class,
                () -> stockFacade.createInboundDocument(principal(1L, 10L, "acme"), "acme", request)
        );
    }

    @Test
    void createOutboundDocument_propagatesDuplicateKeyForGlobalHandling() {
        CreateOutboundDocumentRequest request = new CreateOutboundDocumentRequest(
                200L,
                null,
                List.of(new CreateOutboundDocumentLineRequest(1000L, List.of(10000L), null))
        );
        when(stockService.createOutboundDocument(any(), any(), any())).thenThrow(
                new DuplicateKeyException("duplicate", new RuntimeException("uk_stock_document_company_document_no"))
        );

        assertThrows(
                DuplicateKeyException.class,
                () -> stockFacade.createOutboundDocument(principal(1L, 10L, "acme"), "acme", request)
        );
    }

    private PcsPrincipal principal(Long companyId, Long memberId, String companyCode) {
        return new PcsPrincipal(
                memberId,
                companyId,
                companyCode,
                "admin",
                MemberRole.ADMIN,
                Instant.now().plusSeconds(1800)
        );
    }

    private PcsPrincipal staffPrincipal() {
        return new PcsPrincipal(10L, 1L, "acme", "staff", MemberRole.STAFF, Instant.now().plusSeconds(1800));
    }

    private StockDocumentDetailResponse documentDetail(Long documentId, StockDocumentType documentType) {
        String prefix = documentType == StockDocumentType.INBOUND ? "IN" : "OUT";
        return new StockDocumentDetailResponse(
                documentId,
                prefix + "-20260529-23456789ABCDEFGH",
                documentType,
                StockDocumentStatus.COMPLETED,
                100L,
                "서울 부품사",
                null,
                "관리자",
                LocalDateTime.of(2026, 5, 29, 10, 0),
                1,
                2,
                true,
                null,
                List.of()
        );
    }
}
