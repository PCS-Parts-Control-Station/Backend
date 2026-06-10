package com.pcs.domain.inspection.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.inspection.dto.request.CreateInspectionItemResultRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.response.InspectionPartUnitRow;
import com.pcs.domain.inspection.dto.response.InspectionTemplateOptionRow;
import com.pcs.domain.inspection.entity.Inspection;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
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
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class InspectionServiceTest {

    @Mock
    private InspectionMapper inspectionMapper;

    private InspectionService inspectionService;

    @BeforeEach
    void setUp() {
        inspectionService = new InspectionService(inspectionMapper);
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

        when(inspectionMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(waitingUnit(companyId, unitId));
        when(inspectionMapper.findActiveTemplate(companyId, templateId)).thenReturn(template(companyId, templateId));
        when(inspectionMapper.findActiveTemplateItems(templateId)).thenReturn(List.of(selectItem(templateId, itemId)));
        when(inspectionMapper.findActiveTemplateOptions(templateId)).thenReturn(List.of(
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
                InspectionStatus.COMPLETED,
                PartGrade.A,
                SalesStatus.AVAILABLE
        );
        verify(inspectionMapper).insertPartStatusHistory(any());
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

        when(inspectionMapper.isCompanyActive(companyId)).thenReturn(true);
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

        when(inspectionMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionMapper.findPartUnitForUpdate(companyId, unitId)).thenReturn(waitingUnit(companyId, unitId));
        when(inspectionMapper.findActiveTemplate(companyId, templateId)).thenReturn(template(companyId, templateId));
        when(inspectionMapper.findActiveTemplateItems(templateId)).thenReturn(List.of(selectItem(templateId, itemId)));
        when(inspectionMapper.findActiveTemplateOptions(templateId)).thenReturn(List.of());

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionService.createInitialInspection(companyId, 10L, request)
        );

        assertEquals(ErrorCode.INSPECTION_TEMPLATE_OPTION_NOT_FOUND, exception.getErrorCode());
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
