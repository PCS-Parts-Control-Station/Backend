package com.pcs.domain.stock.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailRow;
import com.pcs.domain.stock.dto.response.StockDocumentLineRow;
import com.pcs.domain.stock.dto.response.StockDocumentUnitResponse;
import com.pcs.domain.stock.entity.StockDocument;
import com.pcs.domain.stock.entity.StockMovement;
import com.pcs.domain.stock.entity.StockPart;
import com.pcs.domain.stock.entity.StockPartUnit;
import com.pcs.domain.stock.entity.StockPartner;
import com.pcs.domain.stock.mapper.StockMapper;
import com.pcs.domain.stock.type.MovementStatus;
import com.pcs.domain.stock.type.MovementType;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DuplicateKeyException;

@ExtendWith(MockitoExtension.class)
class StockServiceTest {

    @Mock
    private StockMapper stockMapper;

    private StockService stockService;

    @BeforeEach
    void setUp() {
        stockService = new StockService(stockMapper);
    }

    @Test
    void searchDocuments_success() {
        Long companyId = 1L;
        SearchStockDocumentResponse row = new SearchStockDocumentResponse(
                500L,
                "IN-20260529-23456789ABCDEFGH",
                StockDocumentType.INBOUND,
                StockDocumentStatus.COMPLETED,
                100L,
                "서울 부품사",
                "RTX 4060",
                2,
                5,
                "관리자",
                LocalDateTime.of(2026, 5, 29, 10, 0)
        );
        SearchStockDocumentSummaryResponse summary = new SearchStockDocumentSummaryResponse(
                1L,
                5L,
                5L,
                0L
        );

        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.countDocuments(
                companyId,
                StockDocumentType.INBOUND,
                "RTX",
                100L,
                StockDocumentStatus.COMPLETED
        )).thenReturn(1L);
        when(stockMapper.searchDocuments(
                companyId,
                StockDocumentType.INBOUND,
                "RTX",
                100L,
                StockDocumentStatus.COMPLETED,
                20,
                0
        )).thenReturn(List.of(row));
        when(stockMapper.summarizeDocuments(
                companyId,
                StockDocumentType.INBOUND,
                "RTX",
                100L,
                StockDocumentStatus.COMPLETED
        )).thenReturn(summary);

        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> response =
                stockService.searchDocuments(
                        companyId,
                        StockDocumentType.INBOUND,
                        " RTX ",
                        100L,
                        StockDocumentStatus.COMPLETED,
                        null,
                        null,
                        null
                );

        assertEquals(1, response.totalElements());
        assertEquals(1, response.content().size());
        assertEquals(row, response.content().get(0));
        assertEquals(summary, response.summary());
        assertEquals(20, response.size());
    }

    @Test
    void getDocument_success() {
        Long companyId = 1L;
        Long documentId = 500L;
        StockDocumentDetailRow document = new StockDocumentDetailRow(
                documentId,
                "IN-20260529-23456789ABCDEFGH",
                StockDocumentType.INBOUND,
                StockDocumentStatus.COMPLETED,
                100L,
                "서울 부품사",
                "입고",
                "관리자",
                LocalDateTime.of(2026, 5, 29, 10, 0),
                1,
                2
        );
        StockDocumentLineRow line = new StockDocumentLineRow(
                900L,
                1000L,
                "RTX 4060",
                "RTX 4060 8GB",
                "GPU-4060",
                MovementType.INBOUND,
                MovementStatus.COMPLETED,
                2,
                0,
                2,
                "라인"
        );
        StockDocumentUnitResponse unit = new StockDocumentUnitResponse(
                900L,
                10000L,
                "GPU-4060-20260529-0001",
                null,
                UnitStatus.IN_STOCK,
                PartGrade.NONE,
                InspectionStatus.WAITING,
                SalesStatus.HOLD,
                true
        );

        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findDocumentDetail(companyId, documentId)).thenReturn(document);
        when(stockMapper.findDocumentLines(companyId, documentId)).thenReturn(List.of(line));
        when(stockMapper.findDocumentUnits(companyId, documentId)).thenReturn(List.of(unit));
        when(stockMapper.countInvalidInboundCancelUnits(companyId, documentId)).thenReturn(0);

        StockDocumentDetailResponse response = stockService.getDocument(companyId, documentId);

        assertEquals(documentId, response.documentId());
        assertEquals("IN-20260529-23456789ABCDEFGH", response.documentNo());
        assertEquals(1, response.lines().size());
        assertEquals(1, response.lines().get(0).units().size());
        assertTrue(response.cancelable());
        assertEquals("GPU-4060-20260529-0001", response.lines().get(0).units().get(0).internalSerialNo());
    }

    @Test
    void cancelInboundDocument_success() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long documentId = 500L;
        StockDocumentDetailRow document = new StockDocumentDetailRow(
                documentId,
                "IN-20260529-23456789ABCDEFGH",
                StockDocumentType.INBOUND,
                StockDocumentStatus.COMPLETED,
                100L,
                "서울 부품사",
                "입고",
                "관리자",
                LocalDateTime.of(2026, 5, 29, 10, 0),
                0,
                0
        );
        StockDocumentLineRow movement = new StockDocumentLineRow(
                900L,
                1000L,
                "RTX 4060",
                "RTX 4060 8GB",
                "GPU-4060",
                MovementType.INBOUND,
                MovementStatus.COMPLETED,
                2,
                0,
                2,
                "라인"
        );

        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findDocumentForUpdate(companyId, documentId)).thenReturn(document);
        when(stockMapper.findOriginalInboundMovementsForUpdate(companyId, documentId)).thenReturn(List.of(movement));
        when(stockMapper.countInvalidInboundCancelUnits(companyId, documentId)).thenReturn(0);
        when(stockMapper.findPartStockQuantityForUpdate(companyId, 1000L)).thenReturn(5);
        when(stockMapper.findMovementUnitIds(900L)).thenReturn(List.of(10000L, 10001L));
        doAnswer(invocation -> {
            StockMovement cancelMovement = invocation.getArgument(0);
            cancelMovement.setMovementId(901L);
            return null;
        }).when(stockMapper).insertMovement(any(StockMovement.class));

        CancelStockDocumentResponse response = stockService.cancelInboundDocument(companyId, memberId, documentId);

        assertEquals(documentId, response.documentId());
        assertEquals(StockDocumentStatus.CANCELED, response.documentStatus());
        assertEquals(1, response.canceledMovementCount());
        assertEquals(2, response.canceledUnitCount());
        verify(stockMapper).updatePartStockQuantity(companyId, 1000L, 3);
        verify(stockMapper).insertMovementUnitStatusChange(901L, 10000L, UnitStatus.IN_STOCK, UnitStatus.CANCELED);
        verify(stockMapper).insertMovementUnitStatusChange(901L, 10001L, UnitStatus.IN_STOCK, UnitStatus.CANCELED);
        verify(stockMapper).updatePartUnitStatusForInboundCancel(companyId, 10000L);
        verify(stockMapper).updatePartUnitStatusForInboundCancel(companyId, 10001L);
        verify(stockMapper).updateDocumentMovementStatus(companyId, documentId, MovementStatus.CANCELED);
        verify(stockMapper).updateDocumentStatus(companyId, documentId, StockDocumentStatus.CANCELED);
    }

    @Test
    void createInboundDocument_success_withAutoDocumentNo() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long partnerId = 100L;
        Long partId = 1000L;

        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                partnerId,
                "입고 테스트",
                List.of(new CreateInboundDocumentLineRequest(partId, 2, "CPU 입고"))
        );

        StockPartner partner = new StockPartner();
        partner.setPartnerId(partnerId);
        partner.setPartnerRole(PartnerRole.SUPPLIER);
        partner.setActive(true);

        StockPart part = new StockPart();
        part.setPartId(partId);
        part.setPartCode("CPU-5600");

        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findPartner(companyId, partnerId)).thenReturn(partner);
        when(stockMapper.existsDocumentNo(anyString())).thenReturn(false);
        when(stockMapper.findPart(companyId, partId)).thenReturn(part);
        when(stockMapper.findPartStockQuantityForUpdate(companyId, partId)).thenReturn(10);
        when(stockMapper.findSerialSequence(companyId, "CPU-5600", LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE)))
                .thenReturn(20);

        doAnswer(invocation -> {
            StockDocument document = invocation.getArgument(0);
            document.setDocumentId(500L);
            return null;
        }).when(stockMapper).insertDocument(any(StockDocument.class));

        doAnswer(invocation -> {
            StockMovement movement = invocation.getArgument(0);
            movement.setMovementId(900L);
            return null;
        }).when(stockMapper).insertMovement(any(StockMovement.class));

        AtomicLong unitIdSequence = new AtomicLong(10000L);
        doAnswer(invocation -> {
            StockPartUnit unit = invocation.getArgument(0);
            unit.setUnitId(unitIdSequence.incrementAndGet());
            return null;
        }).when(stockMapper).insertPartUnit(any(StockPartUnit.class));

        CreateInboundDocumentResponse response = stockService.createInboundDocument(companyId, memberId, request);

        String expectedDateToken = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        assertEquals(500L, response.documentId());
        assertTrue(response.documentNo().matches("IN-" + expectedDateToken + "-[23456789ABCDEFGHJKLMNPQRSTUVWXYZ]{16}"));
        assertEquals(partnerId, response.partnerId());
        assertEquals(1, response.lineCount());
        assertEquals(2, response.totalQuantity());
        assertEquals(2, response.createdUnitCount());

        verify(stockMapper).updatePartStockQuantity(companyId, partId, 12);
        verify(stockMapper, never()).insertPartStock(anyLong(), anyLong(), anyInt());
        verify(stockMapper, times(2)).insertPartUnit(any(StockPartUnit.class));
        verify(stockMapper, times(2)).insertMovementUnit(anyLong(), anyLong(), any());

        ArgumentCaptor<StockPartUnit> unitCaptor = ArgumentCaptor.forClass(StockPartUnit.class);
        verify(stockMapper, times(2)).insertPartUnit(unitCaptor.capture());
        List<StockPartUnit> units = unitCaptor.getAllValues();
        assertEquals(2, units.size());
        assertTrue(units.get(0).getInternalSerialNo().startsWith("CPU-5600-" + expectedDateToken + "-"));
        assertNotNull(units.get(0).getUnitStatus());
    }

    @Test
    void createInboundDocument_success_whenPartStockDoesNotExist() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long partnerId = 100L;
        Long partId = 1000L;

        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                partnerId,
                "최초 입고",
                List.of(new CreateInboundDocumentLineRequest(partId, 3, null))
        );

        StockPartner partner = new StockPartner();
        partner.setPartnerId(partnerId);
        partner.setPartnerRole(PartnerRole.SUPPLIER);
        partner.setActive(true);

        StockPart part = new StockPart();
        part.setPartId(partId);
        part.setPartCode("GPU-RTX");

        String dateToken = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findPartner(companyId, partnerId)).thenReturn(partner);
        when(stockMapper.existsDocumentNo(anyString())).thenReturn(false);
        when(stockMapper.findPart(companyId, partId)).thenReturn(part);
        when(stockMapper.findPartStockQuantityForUpdate(companyId, partId)).thenReturn(null);
        when(stockMapper.findSerialSequence(companyId, "GPU-RTX", dateToken)).thenReturn(0);

        doAnswer(invocation -> {
            StockDocument document = invocation.getArgument(0);
            document.setDocumentId(501L);
            return null;
        }).when(stockMapper).insertDocument(any(StockDocument.class));

        doAnswer(invocation -> {
            StockMovement movement = invocation.getArgument(0);
            movement.setMovementId(901L);
            return null;
        }).when(stockMapper).insertMovement(any(StockMovement.class));

        AtomicLong unitIdSequence = new AtomicLong(11000L);
        doAnswer(invocation -> {
            StockPartUnit unit = invocation.getArgument(0);
            unit.setUnitId(unitIdSequence.incrementAndGet());
            return null;
        }).when(stockMapper).insertPartUnit(any(StockPartUnit.class));

        CreateInboundDocumentResponse response = stockService.createInboundDocument(companyId, memberId, request);

        assertEquals(501L, response.documentId());
        assertEquals(1, response.lineCount());
        assertEquals(3, response.totalQuantity());
        assertEquals(3, response.createdUnitCount());

        verify(stockMapper).insertPartStock(companyId, partId, 3);
        verify(stockMapper, never()).updatePartStockQuantity(anyLong(), anyLong(), anyInt());
        verify(stockMapper, times(3)).insertPartUnit(any(StockPartUnit.class));
        verify(stockMapper, times(3)).insertMovementUnit(anyLong(), anyLong(), any());
    }

    @Test
    void createInboundDocument_success_whenPartStockInsertedByAnotherTransaction() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long partnerId = 100L;
        Long partId = 1000L;

        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                partnerId,
                "동시 입고",
                List.of(new CreateInboundDocumentLineRequest(partId, 2, null))
        );

        StockPartner partner = new StockPartner();
        partner.setPartnerId(partnerId);
        partner.setPartnerRole(PartnerRole.SUPPLIER);
        partner.setActive(true);

        StockPart part = new StockPart();
        part.setPartId(partId);
        part.setPartCode("RAM-16G");

        String dateToken = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findPartner(companyId, partnerId)).thenReturn(partner);
        when(stockMapper.existsDocumentNo(anyString())).thenReturn(false);
        when(stockMapper.findPart(companyId, partId)).thenReturn(part);
        when(stockMapper.findPartStockQuantityForUpdate(companyId, partId))
                .thenReturn(null)
                .thenReturn(7);
        when(stockMapper.findSerialSequence(companyId, "RAM-16G", dateToken)).thenReturn(5);

        doAnswer(invocation -> {
            StockDocument document = invocation.getArgument(0);
            document.setDocumentId(502L);
            return null;
        }).when(stockMapper).insertDocument(any(StockDocument.class));

        doAnswer(invocation -> {
            StockMovement movement = invocation.getArgument(0);
            movement.setMovementId(902L);
            return null;
        }).when(stockMapper).insertMovement(any(StockMovement.class));

        doAnswer(invocation -> {
            throw new DuplicateKeyException("duplicate part stock");
        }).when(stockMapper).insertPartStock(companyId, partId, 2);

        AtomicLong unitIdSequence = new AtomicLong(12000L);
        doAnswer(invocation -> {
            StockPartUnit unit = invocation.getArgument(0);
            unit.setUnitId(unitIdSequence.incrementAndGet());
            return null;
        }).when(stockMapper).insertPartUnit(any(StockPartUnit.class));

        CreateInboundDocumentResponse response = stockService.createInboundDocument(companyId, memberId, request);

        assertEquals(502L, response.documentId());
        assertEquals(1, response.lineCount());
        assertEquals(2, response.totalQuantity());
        assertEquals(2, response.createdUnitCount());

        verify(stockMapper).insertPartStock(companyId, partId, 2);
        verify(stockMapper).updatePartStockQuantity(companyId, partId, 9);
        verify(stockMapper, times(2)).insertPartUnit(any(StockPartUnit.class));
        verify(stockMapper, times(2)).insertMovementUnit(anyLong(), anyLong(), any());
    }

    @Test
    void createInboundDocument_fail_whenPartnerRoleIsCustomer() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long partnerId = 100L;

        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                partnerId,
                null,
                List.of(new CreateInboundDocumentLineRequest(2000L, 1, null))
        );

        StockPartner partner = new StockPartner();
        partner.setPartnerId(partnerId);
        partner.setPartnerRole(PartnerRole.CUSTOMER);
        partner.setActive(true);

        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findPartner(companyId, partnerId)).thenReturn(partner);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockService.createInboundDocument(companyId, memberId, request)
        );

        assertEquals(ErrorCode.PARTNER_INACTIVE, exception.getErrorCode());
        verify(stockMapper, never()).insertDocument(any(StockDocument.class));
    }

    @Test
    void createInboundDocument_fail_whenDocumentNoRandomRetryExhausted() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long partnerId = 100L;

        CreateInboundDocumentRequest request = new CreateInboundDocumentRequest(
                partnerId,
                null,
                List.of(new CreateInboundDocumentLineRequest(2000L, 1, null))
        );

        StockPartner partner = new StockPartner();
        partner.setPartnerId(partnerId);
        partner.setPartnerRole(PartnerRole.BOTH);
        partner.setActive(true);

        when(stockMapper.isCompanyActive(companyId)).thenReturn(true);
        when(stockMapper.findPartner(companyId, partnerId)).thenReturn(partner);
        when(stockMapper.existsDocumentNo(anyString())).thenReturn(true);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> stockService.createInboundDocument(companyId, memberId, request)
        );

        assertEquals(ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED, exception.getErrorCode());
        verify(stockMapper, never()).insertDocument(any(StockDocument.class));
    }
}
