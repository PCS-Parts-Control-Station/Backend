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
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.entity.StockDocument;
import com.pcs.domain.stock.entity.StockMovement;
import com.pcs.domain.stock.entity.StockPart;
import com.pcs.domain.stock.entity.StockPartUnit;
import com.pcs.domain.stock.entity.StockPartner;
import com.pcs.domain.stock.mapper.StockMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

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
