package com.pcs.domain.inspection.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.inspection.dto.request.CreateBulkInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionItemResultRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailRow;
import com.pcs.domain.inspection.dto.response.InspectionItemResultResponse;
import com.pcs.domain.inspection.dto.response.InspectionPartUnitRow;
import com.pcs.domain.inspection.dto.response.InspectionTemplateOptionRow;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentSummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.entity.Inspection;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
import com.pcs.domain.inspection.entity.PartStatusHistory;
import com.pcs.domain.inspection.mapper.InspectionMapper;
import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import com.pcs.domain.inspection.type.InspectionItemResultStatus;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class InspectionServiceTest {

    @Mock
    private InspectionMapper inspectionMapper;

    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private InspectionService inspectionService;

    @BeforeEach
    void setUp() {
        inspectionService = new InspectionService(inspectionMapper, workspaceAccessValidator);
        lenient().when(inspectionMapper.updatePartUnitInspectionStatus(
                any(),
                any(),
                any(),
                any(),
                any(),
                any()
        )).thenReturn(1);
    }

    @Test
    void createInitialInspection_savesInspectionItemResultsAndUnitStatusHistory() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long unitId = 100L;
        Long templateId = 200L;
        Long itemId = 300L;
        Long optionId = 400L;
        CreateInspectionRequest request = new CreateInspectionRequest(
                unitId,
                templateId,
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                "정상",
                List.of(new CreateInspectionItemResultRequest(
                        itemId,
                        InspectionItemResultStatus.PASS,
                        null,
                        null,
                        optionId,
                        null
                ))
        );
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(waitingUnit(companyId, unitId));
        when(inspectionMapper.findActiveTemplate(companyId, templateId)).thenReturn(template(companyId, templateId));
        when(inspectionMapper.findActiveTemplateItems(companyId, templateId)).thenReturn(List.of(selectItem(templateId, itemId)));
        when(inspectionMapper.findActiveTemplateOptions(companyId, templateId)).thenReturn(List.of(
                new InspectionTemplateOptionRow(optionId, itemId, "정상", "NORMAL", true)
        ));
        doAnswer(invocation -> {
            Inspection inspection = invocation.getArgument(0);
            inspection.setInspectionId(500L);
            return null;
        }).when(inspectionMapper).insertInspection(any(Inspection.class));

        var response = inspectionService.createInitialInspection(companyId, memberId, request);

        assertEquals(List.of(500L), response.inspectionIds());
        assertEquals(InspectionType.INITIAL, response.inspectionType());
        verify(inspectionMapper).insertInspection(any(Inspection.class));
        verify(inspectionMapper).insertItemResult(any());
        verify(inspectionMapper).updatePartUnitInspectionStatus(
                companyId,
                unitId,
                InspectionStatus.WAITING,
                InspectionStatus.COMPLETED,
                PartGrade.A,
                SalesStatus.AVAILABLE
        );
        verify(inspectionMapper).insertPartStatusHistory(any());
    }

    @Test
    void createBulkInitialInspection_loadsTemplateOnceAndUpdatesUnitsInBatch() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long templateId = 200L;
        List<Long> unitIds = List.of(100L, 101L);
        CreateBulkInspectionRequest request = new CreateBulkInspectionRequest(
                unitIds,
                templateId,
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                null,
                List.of()
        );
        when(inspectionMapper.findPartUnitsForUpdate(companyId, unitIds)).thenReturn(List.of(
                waitingUnit(companyId, 100L),
                waitingUnit(companyId, 101L)
        ));
        when(inspectionMapper.findActiveTemplate(companyId, templateId)).thenReturn(template(companyId, templateId));
        when(inspectionMapper.findActiveTemplateItems(companyId, templateId)).thenReturn(List.of());
        when(inspectionMapper.findActiveTemplateOptions(companyId, templateId)).thenReturn(List.of());
        AtomicLong sequence = new AtomicLong(500L);
        doAnswer(invocation -> {
            Inspection inspection = invocation.getArgument(0);
            inspection.setInspectionId(sequence.getAndIncrement());
            return null;
        }).when(inspectionMapper).insertInspection(any(Inspection.class));
        when(inspectionMapper.updatePartUnitInspectionStatuses(
                companyId,
                unitIds,
                InspectionStatus.WAITING,
                InspectionStatus.COMPLETED,
                PartGrade.A,
                SalesStatus.AVAILABLE
        )).thenReturn(2);

        var response = inspectionService.createBulkInitialInspection(companyId, memberId, request);

        assertEquals(List.of(500L, 501L), response.inspectionIds());
        verify(inspectionMapper, times(1)).findActiveTemplate(companyId, templateId);
        verify(inspectionMapper, times(2)).insertInspection(any(Inspection.class));
        verify(inspectionMapper).updatePartUnitInspectionStatuses(
                companyId,
                unitIds,
                InspectionStatus.WAITING,
                InspectionStatus.COMPLETED,
                PartGrade.A,
                SalesStatus.AVAILABLE
        );
        verify(inspectionMapper).insertPartStatusHistories(any());
    }

    @Test
    void createInitialInspection_failsWhenUnitStatusUpdateDoesNotMatchExpectedStatus() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long unitId = 100L;
        CreateInspectionRequest request = new CreateInspectionRequest(
                unitId,
                null,
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                null,
                List.of()
        );
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(waitingUnit(companyId, unitId));
        when(inspectionMapper.updatePartUnitInspectionStatus(
                companyId,
                unitId,
                InspectionStatus.WAITING,
                InspectionStatus.COMPLETED,
                PartGrade.A,
                SalesStatus.AVAILABLE
        )).thenReturn(0);
        doAnswer(invocation -> {
            Inspection inspection = invocation.getArgument(0);
            inspection.setInspectionId(500L);
            return null;
        }).when(inspectionMapper).insertInspection(any(Inspection.class));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionService.createInitialInspection(companyId, memberId, request)
        );

        assertEquals(ErrorCode.PART_INVALID_STATUS_CHANGE, exception.getErrorCode());
        verify(inspectionMapper, never()).insertPartStatusHistory(any());
    }

    @Test
    void createInitialInspection_failsWhenUnitAlreadyCompleted() {
        Long companyId = 1L;
        Long unitId = 100L;
        CreateInspectionRequest request = new CreateInspectionRequest(
                unitId,
                null,
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                null,
                List.of()
        );
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(new InspectionPartUnitRow(
                unitId,
                companyId,
                11L,
                12L,
                "PCS-RAM-20260609-0001",
                UnitStatus.IN_STOCK,
                PartGrade.A,
                InspectionStatus.COMPLETED,
                SalesStatus.AVAILABLE,
                true
        ));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionService.createInitialInspection(companyId, 10L, request)
        );

        assertEquals(ErrorCode.INSPECTION_ALREADY_COMPLETED, exception.getErrorCode());
    }

    @Test
    void createInitialInspection_failsWhenSelectOptionDoesNotBelongToItem() {
        Long companyId = 1L;
        Long unitId = 100L;
        Long templateId = 200L;
        Long itemId = 300L;
        CreateInspectionRequest request = new CreateInspectionRequest(
                unitId,
                templateId,
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                null,
                List.of(new CreateInspectionItemResultRequest(
                        itemId,
                        InspectionItemResultStatus.PASS,
                        null,
                        null,
                        999L,
                        null
                ))
        );
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(waitingUnit(companyId, unitId));
        when(inspectionMapper.findActiveTemplate(companyId, templateId)).thenReturn(template(companyId, templateId));
        when(inspectionMapper.findActiveTemplateItems(companyId, templateId)).thenReturn(List.of(selectItem(templateId, itemId)));
        when(inspectionMapper.findActiveTemplateOptions(companyId, templateId)).thenReturn(List.of());

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionService.createInitialInspection(companyId, 10L, request)
        );

        assertEquals(ErrorCode.INSPECTION_TEMPLATE_OPTION_NOT_FOUND, exception.getErrorCode());
    }

    @Test
    void createCorrection_savesRevisionFromOriginalInspection() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long baseInspectionId = 500L;
        Long unitId = 100L;
        Long templateId = 200L;
        Inspection baseInspection = inspection(
                baseInspectionId,
                companyId,
                unitId,
                templateId,
                InspectionType.INITIAL,
                null
        );
        CreateInspectionRevisionRequest request = new CreateInspectionRevisionRequest(
                null,
                InspectionResult.FAIL,
                PartGrade.DEFECTIVE,
                SalesStatus.UNAVAILABLE,
                " 정정 사유 ",
                List.of()
        );
        when(inspectionMapper.findInspection(companyId, baseInspectionId)).thenReturn(baseInspection);
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(completedUnit(companyId, unitId));
        when(inspectionMapper.findTemplate(companyId, templateId)).thenReturn(template(companyId, templateId));
        when(inspectionMapper.findTemplateItems(companyId, templateId)).thenReturn(List.of());
        when(inspectionMapper.findTemplateOptions(companyId, templateId)).thenReturn(List.of());
        doAnswer(invocation -> {
            Inspection inspection = invocation.getArgument(0);
            inspection.setInspectionId(900L);
            return null;
        }).when(inspectionMapper).insertInspection(any(Inspection.class));

        var response = inspectionService.createCorrection(companyId, memberId, baseInspectionId, request);

        ArgumentCaptor<Inspection> inspectionCaptor = ArgumentCaptor.forClass(Inspection.class);
        ArgumentCaptor<PartStatusHistory> historyCaptor = ArgumentCaptor.forClass(PartStatusHistory.class);
        verify(inspectionMapper).insertInspection(inspectionCaptor.capture());
        verify(inspectionMapper).insertPartStatusHistory(historyCaptor.capture());

        Inspection savedInspection = inspectionCaptor.getValue();
        assertEquals(List.of(900L), response.inspectionIds());
        assertEquals(InspectionType.CORRECTION, response.inspectionType());
        assertEquals(InspectionType.CORRECTION, savedInspection.getInspectionType());
        assertEquals(baseInspectionId, savedInspection.getOriginalInspectionId());
        assertEquals(unitId, savedInspection.getUnitId());
        assertEquals(templateId, savedInspection.getTemplateId());
        assertEquals("정정 사유", savedInspection.getMemo());
        assertEquals("CORRECTION", historyCaptor.getValue().getReason());
    }

    @Test
    void createCorrection_failsWhenCurrentUnitIsNotCompleted() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long baseInspectionId = 500L;
        Long unitId = 100L;
        Inspection baseInspection = inspection(
                baseInspectionId,
                companyId,
                unitId,
                null,
                InspectionType.INITIAL,
                null
        );
        CreateInspectionRevisionRequest request = new CreateInspectionRevisionRequest(
                null,
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                null,
                List.of()
        );
        when(inspectionMapper.findInspection(companyId, baseInspectionId)).thenReturn(baseInspection);
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(waitingUnit(companyId, unitId));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionService.createCorrection(companyId, memberId, baseInspectionId, request)
        );

        assertEquals(ErrorCode.PART_INVALID_STATUS_CHANGE, exception.getErrorCode());
        verify(inspectionMapper, never()).insertInspection(any(Inspection.class));
    }

    @Test
    void createReinspection_preservesOriginalInspectionIdWhenBaseIsRevision() {
        Long companyId = 1L;
        Long memberId = 10L;
        Long originalInspectionId = 500L;
        Long baseInspectionId = 700L;
        Long unitId = 100L;
        Long baseTemplateId = 200L;
        Long revisionTemplateId = 201L;
        Inspection baseInspection = inspection(
                baseInspectionId,
                companyId,
                unitId,
                baseTemplateId,
                InspectionType.CORRECTION,
                originalInspectionId
        );
        CreateInspectionRevisionRequest request = new CreateInspectionRevisionRequest(
                revisionTemplateId,
                InspectionResult.PASS,
                PartGrade.B,
                SalesStatus.AVAILABLE,
                "재검수 완료",
                List.of()
        );
        when(inspectionMapper.findInspection(companyId, baseInspectionId)).thenReturn(baseInspection);
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(completedUnit(companyId, unitId));
        when(inspectionMapper.findTemplate(companyId, revisionTemplateId)).thenReturn(template(companyId, revisionTemplateId));
        when(inspectionMapper.findTemplateItems(companyId, revisionTemplateId)).thenReturn(List.of());
        when(inspectionMapper.findTemplateOptions(companyId, revisionTemplateId)).thenReturn(List.of());
        doAnswer(invocation -> {
            Inspection inspection = invocation.getArgument(0);
            inspection.setInspectionId(901L);
            return null;
        }).when(inspectionMapper).insertInspection(any(Inspection.class));

        var response = inspectionService.createReinspection(companyId, memberId, baseInspectionId, request);

        ArgumentCaptor<Inspection> inspectionCaptor = ArgumentCaptor.forClass(Inspection.class);
        verify(inspectionMapper).insertInspection(inspectionCaptor.capture());

        Inspection savedInspection = inspectionCaptor.getValue();
        assertEquals(List.of(901L), response.inspectionIds());
        assertEquals(InspectionType.REINSPECTION, response.inspectionType());
        assertEquals(InspectionType.REINSPECTION, savedInspection.getInspectionType());
        assertEquals(originalInspectionId, savedInspection.getOriginalInspectionId());
        assertEquals(revisionTemplateId, savedInspection.getTemplateId());
    }

    @Test
    void searchWaitingDocuments_passesDashboardWaitingFilter() {
        Long companyId = 1L;
        Long partId = 11L;
        Long partnerId = 20L;
        LocalDate dateFrom = LocalDate.of(2026, 6, 1);
        LocalDate dateTo = LocalDate.of(2026, 6, 8);
        SearchWaitingInspectionDocumentSummaryResponse summary =
                new SearchWaitingInspectionDocumentSummaryResponse(1, 3, 1, 2, 0);
        SearchWaitingInspectionDocumentResponse row = new SearchWaitingInspectionDocumentResponse(
                100L,
                "IN-20260608-001",
                partnerId,
                "서울 부품",
                "RAM DDR4 8GB",
                1,
                3,
                1,
                2,
                0,
                33,
                "IN_PROGRESS",
                LocalDateTime.of(2026, 6, 8, 10, 0)
        );
        when(inspectionMapper.searchWaitingDocuments(
                companyId,
                "RAM",
                partId,
                true,
                partnerId,
                null,
                dateFrom.atStartOfDay(),
                dateTo.plusDays(1).atStartOfDay(),
                10,
                10
        )).thenReturn(List.of(row));
        when(inspectionMapper.summarizeWaitingDocuments(
                companyId,
                "RAM",
                partId,
                true,
                partnerId,
                null,
                dateFrom.atStartOfDay(),
                dateTo.plusDays(1).atStartOfDay()
        )).thenReturn(summary);

        var result = inspectionService.searchWaitingDocuments(
                companyId,
                " RAM ",
                partId,
                true,
                partnerId,
                null,
                dateFrom,
                dateTo,
                1,
                10,
                null
        );

        assertEquals(1, result.page());
        assertEquals(10, result.size());
        assertEquals(1, result.totalElements());
        assertEquals(List.of(row), result.content());
        assertEquals(summary, result.summary());
    }

    @Test
    void searchHistories_normalizesFiltersAndPaging() {
        Long companyId = 1L;
        LocalDate dateFrom = LocalDate.of(2026, 6, 1);
        LocalDate dateTo = LocalDate.of(2026, 6, 8);
        SearchInspectionHistorySummaryResponse summary = new SearchInspectionHistorySummaryResponse(1, 1, 0, 0, 0, 0);
        SearchInspectionHistoryResponse row = new SearchInspectionHistoryResponse(
                500L,
                InspectionType.INITIAL,
                null,
                20L,
                "IN-20260608-001",
                100L,
                "PCS-RAM-20260608-0001",
                UnitStatus.IN_STOCK,
                11L,
                12L,
                "RAM",
                "DDR4 8GB",
                "MTA8ATF1G64AZ",
                200L,
                "기본 검수",
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                null,
                "홍길동",
                LocalDateTime.of(2026, 6, 8, 10, 0)
        );
        when(inspectionMapper.searchHistories(
                companyId,
                "RTX",
                20L,
                100L,
                11L,
                InspectionType.INITIAL,
                InspectionResult.PASS,
                PartGrade.A,
                dateFrom.atStartOfDay(),
                dateTo.plusDays(1).atStartOfDay(),
                100,
                200
        )).thenReturn(List.of(row));
        when(inspectionMapper.summarizeHistories(
                companyId,
                "RTX",
                20L,
                100L,
                11L,
                InspectionType.INITIAL,
                InspectionResult.PASS,
                PartGrade.A,
                dateFrom.atStartOfDay(),
                dateTo.plusDays(1).atStartOfDay()
        )).thenReturn(summary);

        var result = inspectionService.searchHistories(
                companyId,
                " RTX ",
                20L,
                100L,
                11L,
                InspectionType.INITIAL,
                InspectionResult.PASS,
                PartGrade.A,
                dateFrom,
                dateTo,
                2,
                150,
                null
        );

        assertEquals(2, result.page());
        assertEquals(100, result.size());
        assertEquals(1, result.totalElements());
        assertEquals(List.of(row), result.content());
        assertEquals(summary, result.summary());
        assertFalse(result.hasNext());
    }

    @Test
    void searchHistoryDocuments_returnsDocumentSummaries() {
        Long companyId = 1L;
        LocalDate dateFrom = LocalDate.of(2026, 6, 1);
        LocalDate dateTo = LocalDate.of(2026, 6, 8);
        SearchInspectionHistoryDocumentSummaryResponse summary =
                new SearchInspectionHistoryDocumentSummaryResponse(1, 3, 1);
        SearchInspectionHistoryDocumentResponse row = new SearchInspectionHistoryDocumentResponse(
                20L,
                "IN-20260608-001",
                "DDR4 8GB MTA8ATF1G64AZ",
                2,
                3,
                1,
                LocalDateTime.of(2026, 6, 8, 10, 0)
        );
        when(inspectionMapper.searchHistoryDocuments(
                companyId,
                "RAM",
                null,
                11L,
                InspectionType.INITIAL,
                InspectionResult.PASS,
                PartGrade.A,
                dateFrom.atStartOfDay(),
                dateTo.plusDays(1).atStartOfDay(),
                10,
                10
        )).thenReturn(List.of(row));
        when(inspectionMapper.summarizeHistoryDocuments(
                companyId,
                "RAM",
                null,
                11L,
                InspectionType.INITIAL,
                InspectionResult.PASS,
                PartGrade.A,
                dateFrom.atStartOfDay(),
                dateTo.plusDays(1).atStartOfDay()
        )).thenReturn(summary);

        var result = inspectionService.searchHistoryDocuments(
                companyId,
                " RAM ",
                null,
                11L,
                InspectionType.INITIAL,
                InspectionResult.PASS,
                PartGrade.A,
                dateFrom,
                dateTo,
                1,
                10,
                null
        );

        assertEquals(1, result.page());
        assertEquals(10, result.size());
        assertEquals(1, result.totalElements());
        assertEquals(List.of(row), result.content());
        assertEquals(summary, result.summary());
    }

    @Test
    void getHistoryDetail_returnsDetailWithItemResults() {
        Long companyId = 1L;
        Long inspectionId = 500L;
        InspectionHistoryDetailRow row = new InspectionHistoryDetailRow(
                inspectionId,
                InspectionType.INITIAL,
                null,
                20L,
                "IN-20260608-001",
                100L,
                "PCS-RAM-20260608-0001",
                UnitStatus.IN_STOCK,
                11L,
                12L,
                "RAM",
                "DDR4 8GB",
                "MTA8ATF1G64AZ",
                200L,
                "기본 검수",
                InspectionResult.PASS,
                PartGrade.A,
                SalesStatus.AVAILABLE,
                "정상",
                "홍길동",
                LocalDateTime.of(2026, 6, 8, 10, 0)
        );
        InspectionItemResultResponse itemResult = new InspectionItemResultResponse(
                1L,
                inspectionId,
                300L,
                "외관 상태",
                InspectionItemResultStatus.PASS,
                null,
                null,
                400L,
                "정상",
                "NORMAL",
                null
        );
        when(inspectionMapper.findHistoryDetail(companyId, inspectionId)).thenReturn(row);
        when(inspectionMapper.findItemResults(companyId, inspectionId)).thenReturn(List.of(itemResult));

        var response = inspectionService.getHistoryDetail(companyId, inspectionId);

        assertEquals(inspectionId, response.inspectionId());
        assertEquals("PCS-RAM-20260608-0001", response.internalSerialNo());
        assertEquals("RAM", response.categoryName());
        assertEquals(List.of(itemResult), response.itemResults());
    }

    private InspectionPartUnitRow waitingUnit(Long companyId, Long unitId) {
        return new InspectionPartUnitRow(
                unitId,
                companyId,
                11L,
                12L,
                "PCS-RAM-20260609-0001",
                UnitStatus.IN_STOCK,
                PartGrade.NONE,
                InspectionStatus.WAITING,
                SalesStatus.HOLD,
                true
        );
    }

    private InspectionPartUnitRow completedUnit(Long companyId, Long unitId) {
        return new InspectionPartUnitRow(
                unitId,
                companyId,
                11L,
                12L,
                "PCS-RAM-20260609-0001",
                UnitStatus.IN_STOCK,
                PartGrade.B,
                InspectionStatus.COMPLETED,
                SalesStatus.HOLD,
                true
        );
    }

    private Inspection inspection(
            Long inspectionId,
            Long companyId,
            Long unitId,
            Long templateId,
            InspectionType inspectionType,
            Long originalInspectionId
    ) {
        Inspection inspection = new Inspection(
                companyId,
                unitId,
                templateId,
                10L,
                inspectionType,
                originalInspectionId,
                SalesStatus.AVAILABLE,
                InspectionResult.PASS,
                PartGrade.A,
                "기존 검수",
                LocalDateTime.of(2026, 6, 8, 10, 0)
        );
        inspection.setInspectionId(inspectionId);
        return inspection;
    }

    private InspectionTemplate template(Long companyId, Long templateId) {
        InspectionTemplate template = new InspectionTemplate(
                companyId,
                12L,
                "기본 검수",
                1,
                true,
                10L
        );
        template.setTemplateId(templateId);
        return template;
    }

    private InspectionTemplateItem selectItem(Long templateId, Long itemId) {
        InspectionTemplateItem item = new InspectionTemplateItem(
                templateId,
                InspectionItemGroup.BASIC,
                "외관 상태",
                InspectionInputType.SELECT,
                true,
                10,
                GradeImpact.LOW,
                InspectionFailPolicy.NONE
        );
        item.setItemId(itemId);
        return item;
    }
}
