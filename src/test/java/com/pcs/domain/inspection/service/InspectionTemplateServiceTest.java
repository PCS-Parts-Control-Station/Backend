package com.pcs.domain.inspection.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionSortOrderRequest;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateResponse;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
import com.pcs.domain.inspection.mapper.InspectionTemplateMapper;
import com.pcs.domain.inspection.mapper.SortOrderUpdate;
import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class InspectionTemplateServiceTest {

    @Mock
    private InspectionTemplateMapper inspectionTemplateMapper;

    private InspectionTemplateService inspectionTemplateService;

    @BeforeEach
    void setUp() {
        inspectionTemplateService = new InspectionTemplateService(inspectionTemplateMapper);
    }

    @Test
    void createTemplate_failsWhenTemplateVersionDuplicated() {
        Long companyId = 1L;
        CreateInspectionTemplateRequest request = new CreateInspectionTemplateRequest(
                10L,
                "그래픽카드 기본 검수",
                1,
                true
        );

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.existsCategory(companyId, 10L)).thenReturn(true);
        when(inspectionTemplateMapper.existsTemplateVersion(
                companyId,
                10L,
                "그래픽카드 기본 검수",
                1,
                null
        )).thenReturn(true);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionTemplateService.createTemplate(companyId, 20L, request)
        );

        assertEquals(ErrorCode.INSPECTION_TEMPLATE_DUPLICATED, exception.getErrorCode());
        verify(inspectionTemplateMapper, never()).insertTemplate(any());
    }

    @Test
    void createTemplate_insertsAndReturnsDetail() {
        Long companyId = 1L;
        CreateInspectionTemplateRequest request = new CreateInspectionTemplateRequest(
                10L,
                "그래픽카드 기본 검수",
                null,
                null
        );
        InspectionTemplate template = template(100L, companyId, 10L, "그래픽카드 기본 검수", 1, true);
        SearchInspectionTemplateResponse summary = summary(100L, 10L, "그래픽카드", "그래픽카드 기본 검수");

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.existsCategory(companyId, 10L)).thenReturn(true);
        when(inspectionTemplateMapper.existsTemplateVersion(companyId, 10L, "그래픽카드 기본 검수", 1, null))
                .thenReturn(false);
        doAnswer((invocation) -> {
            InspectionTemplate inserted = invocation.getArgument(0);
            inserted.setTemplateId(100L);
            return null;
        }).when(inspectionTemplateMapper).insertTemplate(any(InspectionTemplate.class));
        when(inspectionTemplateMapper.findTemplateSummaryById(companyId, 100L)).thenReturn(summary);
        when(inspectionTemplateMapper.findItemsByTemplateId(100L)).thenReturn(List.of());
        when(inspectionTemplateMapper.findOptionsByTemplateId(100L)).thenReturn(List.of());
        when(inspectionTemplateMapper.findTemplateById(companyId, 100L)).thenReturn(template);

        var response = inspectionTemplateService.createTemplate(companyId, 20L, request);

        assertEquals(100L, response.templateId());
        assertEquals(1, response.version());
        assertTrue(response.active());
        verify(inspectionTemplateMapper).insertTemplate(any(InspectionTemplate.class));
    }

    @Test
    void createOption_failsWhenItemIsNotSelectType() {
        Long companyId = 1L;
        Long templateId = 100L;
        Long itemId = 200L;
        InspectionTemplateItem item = item(templateId, itemId, InspectionInputType.CHECK);

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.findItemById(companyId, templateId, itemId)).thenReturn(item);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionTemplateService.createOption(
                        companyId,
                        templateId,
                        itemId,
                        new CreateInspectionTemplateOptionRequest("정상", null, null)
                )
        );

        assertEquals(ErrorCode.INVALID_INPUT_VALUE, exception.getErrorCode());
        verify(inspectionTemplateMapper, never()).insertOption(any());
    }

    @Test
    void updateItem_deactivatesOptionsWhenInputTypeChangesFromSelect() {
        Long companyId = 1L;
        Long templateId = 100L;
        Long itemId = 200L;
        InspectionTemplateItem item = item(templateId, itemId, InspectionInputType.SELECT);
        SearchInspectionTemplateResponse summary = summary(templateId, 10L, "그래픽카드", "그래픽카드 기본 검수");
        InspectionTemplate template = template(templateId, companyId, 10L, "그래픽카드 기본 검수", 1, true);
        UpdateInspectionTemplateItemRequest request = new UpdateInspectionTemplateItemRequest(
                "소음 메모",
                InspectionItemGroup.DETAIL,
                InspectionInputType.TEXT,
                false,
                20,
                GradeImpact.LOW,
                InspectionFailPolicy.NONE
        );

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.findItemById(companyId, templateId, itemId)).thenReturn(item);
        when(inspectionTemplateMapper.existsItemName(templateId, "소음 메모", itemId)).thenReturn(false);
        when(inspectionTemplateMapper.findTemplateSummaryById(companyId, templateId)).thenReturn(summary);
        when(inspectionTemplateMapper.findItemsByTemplateId(templateId)).thenReturn(List.of(item));
        when(inspectionTemplateMapper.findOptionsByTemplateId(templateId)).thenReturn(List.of());
        when(inspectionTemplateMapper.findTemplateById(companyId, templateId)).thenReturn(template);

        inspectionTemplateService.updateItem(companyId, templateId, itemId, request);

        verify(inspectionTemplateMapper).updateItem(item);
        verify(inspectionTemplateMapper).deactivateOptionsByItemId(itemId);
        verify(inspectionTemplateMapper).touchTemplate(templateId);
    }

    @Test
    void updateItemSortOrder_updatesSortOrdersAndReturnsDetail() {
        Long companyId = 1L;
        Long templateId = 100L;
        InspectionTemplate template = template(templateId, companyId, 10L, "그래픽카드 기본 검수", 1, true);
        SearchInspectionTemplateResponse summary = summary(templateId, 10L, "그래픽카드", "그래픽카드 기본 검수");
        UpdateInspectionTemplateItemSortOrderRequest request = new UpdateInspectionTemplateItemSortOrderRequest(
                InspectionItemGroup.BASIC,
                List.of(201L, 202L, 203L)
        );

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.findTemplateById(companyId, templateId)).thenReturn(template);
        when(inspectionTemplateMapper.countItemsByTemplateGroup(templateId, InspectionItemGroup.BASIC)).thenReturn(3);
        when(inspectionTemplateMapper.countItemsByTemplateGroupAndIds(
                templateId,
                InspectionItemGroup.BASIC,
                List.of(201L, 202L, 203L)
        )).thenReturn(3);
        when(inspectionTemplateMapper.findTemplateSummaryById(companyId, templateId)).thenReturn(summary);
        when(inspectionTemplateMapper.findItemsByTemplateId(templateId)).thenReturn(List.of());
        when(inspectionTemplateMapper.findOptionsByTemplateId(templateId)).thenReturn(List.of());

        inspectionTemplateService.updateItemSortOrder(companyId, templateId, request);

        verify(inspectionTemplateMapper).updateItemSortOrders(
                templateId,
                InspectionItemGroup.BASIC,
                List.of(
                        new SortOrderUpdate(201L, 10),
                        new SortOrderUpdate(202L, 20),
                        new SortOrderUpdate(203L, 30)
                )
        );
        verify(inspectionTemplateMapper).touchTemplate(templateId);
    }

    @Test
    void updateItemSortOrder_failsWhenRequestDoesNotContainAllGroupItems() {
        Long companyId = 1L;
        Long templateId = 100L;
        InspectionTemplate template = template(templateId, companyId, 10L, "그래픽카드 기본 검수", 1, true);
        UpdateInspectionTemplateItemSortOrderRequest request = new UpdateInspectionTemplateItemSortOrderRequest(
                InspectionItemGroup.BASIC,
                List.of(201L, 202L)
        );

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.findTemplateById(companyId, templateId)).thenReturn(template);
        when(inspectionTemplateMapper.countItemsByTemplateGroup(templateId, InspectionItemGroup.BASIC)).thenReturn(3);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionTemplateService.updateItemSortOrder(companyId, templateId, request)
        );

        assertEquals(ErrorCode.INVALID_INPUT_VALUE, exception.getErrorCode());
        verify(inspectionTemplateMapper, never()).updateItemSortOrders(any(), any(), any());
    }

    @Test
    void updateItemSortOrder_failsWhenIdsDuplicated() {
        Long companyId = 1L;
        Long templateId = 100L;
        InspectionTemplate template = template(templateId, companyId, 10L, "그래픽카드 기본 검수", 1, true);
        UpdateInspectionTemplateItemSortOrderRequest request = new UpdateInspectionTemplateItemSortOrderRequest(
                InspectionItemGroup.BASIC,
                List.of(201L, 201L)
        );

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.findTemplateById(companyId, templateId)).thenReturn(template);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> inspectionTemplateService.updateItemSortOrder(companyId, templateId, request)
        );

        assertEquals(ErrorCode.INVALID_INPUT_VALUE, exception.getErrorCode());
        verify(inspectionTemplateMapper, never()).updateItemSortOrders(any(), any(), any());
    }

    @Test
    void updateOptionSortOrder_updatesSortOrdersAndReturnsDetail() {
        Long companyId = 1L;
        Long templateId = 100L;
        Long itemId = 200L;
        InspectionTemplateItem item = item(templateId, itemId, InspectionInputType.SELECT);
        InspectionTemplate template = template(templateId, companyId, 10L, "그래픽카드 기본 검수", 1, true);
        SearchInspectionTemplateResponse summary = summary(templateId, 10L, "그래픽카드", "그래픽카드 기본 검수");
        UpdateInspectionTemplateOptionSortOrderRequest request = new UpdateInspectionTemplateOptionSortOrderRequest(
                List.of(301L, 302L)
        );

        when(inspectionTemplateMapper.isCompanyActive(companyId)).thenReturn(true);
        when(inspectionTemplateMapper.findItemById(companyId, templateId, itemId)).thenReturn(item);
        when(inspectionTemplateMapper.countOptionsByItemId(itemId)).thenReturn(2);
        when(inspectionTemplateMapper.countOptionsByItemIdAndIds(itemId, List.of(301L, 302L))).thenReturn(2);
        when(inspectionTemplateMapper.findTemplateSummaryById(companyId, templateId)).thenReturn(summary);
        when(inspectionTemplateMapper.findItemsByTemplateId(templateId)).thenReturn(List.of(item));
        when(inspectionTemplateMapper.findOptionsByTemplateId(templateId)).thenReturn(List.of());
        when(inspectionTemplateMapper.findTemplateById(companyId, templateId)).thenReturn(template);

        inspectionTemplateService.updateOptionSortOrder(companyId, templateId, itemId, request);

        verify(inspectionTemplateMapper).updateOptionSortOrders(
                itemId,
                List.of(
                        new SortOrderUpdate(301L, 10),
                        new SortOrderUpdate(302L, 20)
                )
        );
        verify(inspectionTemplateMapper).touchTemplate(templateId);
    }

    private InspectionTemplate template(
            Long templateId,
            Long companyId,
            Long categoryId,
            String templateName,
            int version,
            boolean active
    ) {
        InspectionTemplate template = new InspectionTemplate(companyId, categoryId, templateName, version, active, 20L);
        template.setTemplateId(templateId);
        template.setCreatedAt(LocalDateTime.of(2026, 6, 7, 10, 0));
        template.setUpdatedAt(LocalDateTime.of(2026, 6, 7, 10, 0));
        return template;
    }

    private SearchInspectionTemplateResponse summary(
            Long templateId,
            Long categoryId,
            String categoryName,
            String templateName
    ) {
        return new SearchInspectionTemplateResponse(
                templateId,
                categoryId,
                categoryName,
                templateName,
                1,
                true,
                0,
                0,
                "관리자",
                LocalDateTime.of(2026, 6, 7, 10, 0)
        );
    }

    private InspectionTemplateItem item(Long templateId, Long itemId, InspectionInputType inputType) {
        InspectionTemplateItem item = new InspectionTemplateItem(
                templateId,
                InspectionItemGroup.DETAIL,
                "소음 상태",
                inputType,
                false,
                10,
                GradeImpact.LOW,
                InspectionFailPolicy.NONE
        );
        item.setItemId(itemId);
        return item;
    }
}
