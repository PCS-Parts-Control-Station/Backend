package com.pcs.domain.stock.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
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
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import java.time.Instant;
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
    private JwtTokenProvider jwtTokenProvider;

    private StockFacade stockFacade;

    @BeforeEach
    void setUp() {
        stockFacade = new StockFacade(stockService, jwtTokenProvider);
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

        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(stockService.searchDocuments(
                1L,
                StockDocumentType.INBOUND,
                "RTX",
                100L,
                StockDocumentStatus.COMPLETED,
                0,
                20,
                null
        )).thenReturn(expected);

        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> response =
                stockFacade.searchDocuments(
                        "Bearer token",
                        "acme",
                        StockDocumentType.INBOUND,
                        "RTX",
                        100L,
                        StockDocumentStatus.COMPLETED,
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
                0,
                20,
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

        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(stockService.getDocument(1L, 500L)).thenReturn(expected);

        StockDocumentDetailResponse response = stockFacade.getDocument("Bearer token", "acme", 500L);

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

        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(stockService.cancelDocument(1L, 10L, 500L)).thenReturn(expected);

        CancelStockDocumentResponse response = stockFacade.cancelDocument("Bearer token", "acme", 500L);

        assertSame(expected, response);
        verify(stockService).cancelDocument(1L, 10L, 500L);
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

        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(stockService.createInboundDocument(1L, 10L, request)).thenReturn(expected);

        CreateInboundDocumentResponse response = stockFacade.createInboundDocument(
                "Bearer token",
                "acme",
                request
        );

        assertSame(expected, response);
        verify(stockService).createInboundDocument(1L, 10L, request);
    }

    @Test
    void createInboundDocument_fail_whenAuthorizationMissing() {
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
        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockFacade.createInboundDocument("Bearer token", "other", request)
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    @Test
    void createInboundDocument_mapsDuplicateDocumentNoException() {
        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                100L,
                null,
                List.of(new CreateInboundDocumentLineRequest(1000L, 1, null))
        );
        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(stockService.createInboundDocument(any(), any(), any())).thenThrow(
                new DuplicateKeyException("duplicate", new RuntimeException("uk_stock_document_document_no"))
        );

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockFacade.createInboundDocument("Bearer token", "acme", request)
        );

        assertEquals(ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED, exception.getErrorCode());
    }

    private JwtClaims claims(Long companyId, Long memberId, String companyCode) {
        return new JwtClaims(
                memberId,
                companyId,
                companyCode,
                "admin",
                MemberRole.ADMIN,
                "ACCESS",
                Instant.now().plusSeconds(1800)
        );
    }
}
