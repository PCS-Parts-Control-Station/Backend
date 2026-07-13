package com.pcs.domain.inspection.service;

import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.request.SaveInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.SaveInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateItemSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateOptionSortOrderRequest;
import com.pcs.domain.inspection.dto.request.UpdateInspectionTemplateRequest;
import com.pcs.domain.inspection.dto.response.InspectionTemplateDetailResponse;
import com.pcs.domain.inspection.dto.response.InspectionTemplateItemResponse;
import com.pcs.domain.inspection.dto.response.InspectionTemplateOptionResponse;
import com.pcs.domain.inspection.dto.response.InspectionTemplateReorderValidationRow;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateSummaryResponse;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
import com.pcs.domain.inspection.entity.InspectionTemplateItemOption;
import com.pcs.domain.inspection.mapper.InspectionTemplateMapper;
import com.pcs.domain.inspection.mapper.SortOrderUpdate;
import com.pcs.domain.inspection.type.GradeImpact;
import com.pcs.domain.inspection.type.InspectionFailPolicy;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.pagination.PageQuery;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.springframework.stereotype.Service;

@Service
public class InspectionTemplateService {

    private static final int DEFAULT_SIZE = 20;
    private static final int SORT_ORDER_STEP = 10;

    private final InspectionTemplateMapper inspectionTemplateMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public InspectionTemplateService(
            InspectionTemplateMapper inspectionTemplateMapper,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.inspectionTemplateMapper = inspectionTemplateMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchInspectionTemplateResponse, SearchInspectionTemplateSummaryResponse> searchTemplates(
            Long companyId,
            String keyword,
            Long categoryId,
            Boolean active,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);
        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);

        SearchInspectionTemplateSummaryResponse summary = inspectionTemplateMapper.summarizeTemplates(
                companyId,
                normalizedKeyword,
                categoryId,
                active
        );
        long totalElements = summary.totalCount();
        List<SearchInspectionTemplateResponse> items = totalElements == 0
                ? List.of()
                : inspectionTemplateMapper.searchTemplates(
                        companyId,
                        normalizedKeyword,
                        categoryId,
                        active,
                        pageQuery.size(),
                        pageQuery.offset()
                );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public InspectionTemplateDetailResponse getTemplate(Long companyId, Long templateId) {
        validateCompanyActive(companyId);
        SearchInspectionTemplateResponse template = findTemplateSummaryOrThrow(companyId, templateId);
        return buildDetail(companyId, template);
    }

    public InspectionTemplateDetailResponse createTemplate(
            Long companyId,
            Long memberId,
            CreateInspectionTemplateRequest request
    ) {
        validateCompanyActive(companyId);
        validateCategory(companyId, request.categoryId());
        String templateName = TextNormalizer.required(request.templateName());
        int version = normalizeVersion(request.version());
        validateTemplateDuplicate(companyId, request.categoryId(), templateName, version, null);

        InspectionTemplate template = new InspectionTemplate(
                companyId,
                request.categoryId(),
                templateName,
                version,
                request.active() == null || request.active(),
                memberId
        );
        inspectionTemplateMapper.insertTemplate(template);
        saveTemplateItems(companyId, template.getTemplateId(), request.items());
        return getTemplate(companyId, template.getTemplateId());
    }

    public InspectionTemplateDetailResponse updateTemplate(
            Long companyId,
            Long templateId,
            UpdateInspectionTemplateRequest request
    ) {
        InspectionTemplate template = validateActiveCompanyAndFindTemplate(companyId, templateId);
        validateCategory(companyId, request.categoryId());
        String templateName = TextNormalizer.required(request.templateName());
        int version = normalizeVersion(request.version());
        validateTemplateDuplicate(companyId, request.categoryId(), templateName, version, templateId);

        template.setCategoryId(request.categoryId());
        template.setTemplateName(templateName);
        template.setVersion(version);
        template.setActive(request.active() == null || request.active());
        inspectionTemplateMapper.updateTemplate(template);
        saveTemplateItems(companyId, templateId, request.items());
        return getTemplate(companyId, templateId);
    }

    public void updateTemplateActive(Long companyId, Long templateId, boolean active) {
        validateActiveCompanyAndFindTemplate(companyId, templateId);
        inspectionTemplateMapper.updateTemplateActive(companyId, templateId, active);
    }

    public InspectionTemplateDetailResponse createItem(
            Long companyId,
            Long templateId,
            CreateInspectionTemplateItemRequest request
    ) {
        InspectionTemplate template = validateActiveCompanyAndFindTemplate(companyId, templateId);
        String itemName = TextNormalizer.required(request.itemName());
        validateItemDuplicate(companyId, templateId, itemName, null);

        InspectionTemplateItem item = new InspectionTemplateItem(
                template.getTemplateId(),
                request.itemGroup(),
                itemName,
                request.inputType(),
                request.required() != null && request.required(),
                normalizeSortOrder(request.sortOrder(), inspectionTemplateMapper.nextItemSortOrder(companyId, templateId)),
                request.gradeImpact() == null ? GradeImpact.LOW : request.gradeImpact(),
                request.failPolicy() == null ? InspectionFailPolicy.NONE : request.failPolicy()
        );
        inspectionTemplateMapper.insertItem(item);
        touchTemplate(companyId, templateId);
        return getTemplate(companyId, templateId);
    }

    public InspectionTemplateDetailResponse updateItem(
            Long companyId,
            Long templateId,
            Long itemId,
            UpdateInspectionTemplateItemRequest request
    ) {
        InspectionTemplateItem item = validateActiveCompanyAndFindItem(companyId, templateId, itemId);
        String itemName = TextNormalizer.required(request.itemName());
        validateItemDuplicate(companyId, templateId, itemName, itemId);

        item.setItemGroup(request.itemGroup());
        item.setItemName(itemName);
        item.setInputType(request.inputType());
        item.setRequired(request.required() != null && request.required());
        item.setSortOrder(normalizeSortOrder(request.sortOrder(), item.getSortOrder()));
        item.setGradeImpact(request.gradeImpact() == null ? GradeImpact.LOW : request.gradeImpact());
        item.setFailPolicy(request.failPolicy() == null ? InspectionFailPolicy.NONE : request.failPolicy());
        inspectionTemplateMapper.updateItem(companyId, item);
        if (item.getInputType() != InspectionInputType.SELECT) {
            inspectionTemplateMapper.deactivateOptionsByItemId(companyId, templateId, itemId);
        }
        touchTemplate(companyId, templateId);
        return getTemplate(companyId, templateId);
    }

    public void updateItemActive(Long companyId, Long templateId, Long itemId, boolean active) {
        validateActiveCompanyAndFindItem(companyId, templateId, itemId);
        inspectionTemplateMapper.updateItemActive(companyId, templateId, itemId, active);
        touchTemplate(companyId, templateId);
    }

    public InspectionTemplateDetailResponse updateItemSortOrder(
            Long companyId,
            Long templateId,
            UpdateInspectionTemplateItemSortOrderRequest request
    ) {
        validateActiveCompanyAndFindTemplate(companyId, templateId);
        validateOrderedIds(request.orderedItemIds(), "검수 항목");
        validateAllItemsBelongToGroup(companyId, templateId, request.itemGroup(), request.orderedItemIds());

        inspectionTemplateMapper.updateItemSortOrders(
                companyId,
                templateId,
                request.itemGroup(),
                toSortOrderUpdates(request.orderedItemIds())
        );
        touchTemplate(companyId, templateId);
        return getTemplate(companyId, templateId);
    }

    public InspectionTemplateDetailResponse createOption(
            Long companyId,
            Long templateId,
            Long itemId,
            CreateInspectionTemplateOptionRequest request
    ) {
        InspectionTemplateItem item = validateActiveCompanyAndFindSelectItem(companyId, templateId, itemId);
        String optionLabel = TextNormalizer.required(request.optionLabel());
        String optionValue = normalizeOptionValue(request.optionValue(), optionLabel);
        validateOptionDuplicate(companyId, templateId, itemId, optionLabel, optionValue, null);

        InspectionTemplateItemOption option = new InspectionTemplateItemOption(
                itemId,
                optionLabel,
                optionValue,
                normalizeSortOrder(request.sortOrder(), inspectionTemplateMapper.nextOptionSortOrder(companyId, templateId, itemId))
        );
        inspectionTemplateMapper.insertOption(option);
        touchTemplate(companyId, templateId);
        return getTemplate(companyId, templateId);
    }

    public InspectionTemplateDetailResponse updateOption(
            Long companyId,
            Long templateId,
            Long itemId,
            Long optionId,
            UpdateInspectionTemplateOptionRequest request
    ) {
        validateActiveCompanyAndFindSelectItem(companyId, templateId, itemId);
        InspectionTemplateItemOption option = findOptionOrThrow(companyId, templateId, itemId, optionId);
        String optionLabel = TextNormalizer.required(request.optionLabel());
        String optionValue = normalizeOptionValue(request.optionValue(), optionLabel);
        validateOptionDuplicate(companyId, templateId, itemId, optionLabel, optionValue, optionId);

        option.setOptionLabel(optionLabel);
        option.setOptionValue(optionValue);
        option.setSortOrder(normalizeSortOrder(request.sortOrder(), option.getSortOrder()));
        inspectionTemplateMapper.updateOption(companyId, templateId, option);
        touchTemplate(companyId, templateId);
        return getTemplate(companyId, templateId);
    }

    public void updateOptionActive(Long companyId, Long templateId, Long itemId, Long optionId, boolean active) {
        validateActiveCompanyAndFindSelectItem(companyId, templateId, itemId);
        findOptionOrThrow(companyId, templateId, itemId, optionId);
        inspectionTemplateMapper.updateOptionActive(companyId, templateId, itemId, optionId, active);
        touchTemplate(companyId, templateId);
    }

    public InspectionTemplateDetailResponse updateOptionSortOrder(
            Long companyId,
            Long templateId,
            Long itemId,
            UpdateInspectionTemplateOptionSortOrderRequest request
    ) {
        validateActiveCompanyAndFindSelectItem(companyId, templateId, itemId);
        validateOrderedIds(request.orderedOptionIds(), "선택지");
        validateAllOptionsBelongToItem(companyId, templateId, itemId, request.orderedOptionIds());

        inspectionTemplateMapper.updateOptionSortOrders(companyId, templateId, itemId, toSortOrderUpdates(request.orderedOptionIds()));
        touchTemplate(companyId, templateId);
        return getTemplate(companyId, templateId);
    }

    private void saveTemplateItems(
            Long companyId,
            Long templateId,
            List<SaveInspectionTemplateItemRequest> itemRequests
    ) {
        if (itemRequests == null || itemRequests.isEmpty()) {
            return;
        }

        Map<Long, InspectionTemplateItem> existingItems = inspectionTemplateMapper.findItemsByTemplateId(companyId, templateId)
                .stream()
                .collect(Collectors.toMap(InspectionTemplateItem::getItemId, (item) -> item));
        Map<Long, Map<Long, InspectionTemplateOptionResponse>> existingOptionsByItem = inspectionTemplateMapper
                .findOptionsByTemplateId(companyId, templateId)
                .stream()
                .collect(Collectors.groupingBy(
                        InspectionTemplateOptionResponse::itemId,
                        Collectors.toMap(InspectionTemplateOptionResponse::optionId, option -> option)
                ));
        validateBatchItemNames(existingItems, itemRequests);

        Map<InspectionItemGroup, Integer> groupIndexes = new EnumMap<>(InspectionItemGroup.class);
        for (SaveInspectionTemplateItemRequest request : itemRequests) {
            InspectionItemGroup itemGroup = request.itemGroup();
            InspectionInputType inputType = request.inputType();
            if (itemGroup == null || inputType == null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "검수 항목 구분과 입력 방식이 필요합니다.");
            }

            int groupIndex = groupIndexes.merge(itemGroup, 1, Integer::sum);
            int fallbackSortOrder = groupIndex * SORT_ORDER_STEP;
            String itemName = TextNormalizer.required(request.itemName());

            InspectionTemplateItem item;
            if (request.itemId() == null) {
                item = new InspectionTemplateItem(
                        templateId,
                        itemGroup,
                        itemName,
                        inputType,
                        request.required() != null && request.required(),
                        normalizeSortOrder(request.sortOrder(), fallbackSortOrder),
                        request.gradeImpact() == null ? GradeImpact.LOW : request.gradeImpact(),
                        request.failPolicy() == null ? InspectionFailPolicy.NONE : request.failPolicy()
                );
                item.setActive(request.active() == null || request.active());
                inspectionTemplateMapper.insertItem(item);
            } else {
                item = existingItems.get(request.itemId());
                if (item == null) {
                    throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_ITEM_NOT_FOUND);
                }
                item.setItemGroup(itemGroup);
                item.setItemName(itemName);
                item.setInputType(inputType);
                item.setRequired(request.required() != null && request.required());
                item.setSortOrder(normalizeSortOrder(request.sortOrder(), fallbackSortOrder));
                item.setGradeImpact(request.gradeImpact() == null ? GradeImpact.LOW : request.gradeImpact());
                item.setFailPolicy(request.failPolicy() == null ? InspectionFailPolicy.NONE : request.failPolicy());
                item.setActive(request.active() == null || request.active());
                inspectionTemplateMapper.updateItem(companyId, item);
            }

            if (inputType == InspectionInputType.SELECT) {
                saveTemplateOptions(
                        companyId,
                        templateId,
                        item.getItemId(),
                        request.options(),
                        existingOptionsByItem.getOrDefault(item.getItemId(), Map.of())
                );
            } else {
                inspectionTemplateMapper.deactivateOptionsByItemId(companyId, templateId, item.getItemId());
            }
        }

        touchTemplate(companyId, templateId);
    }

    private void saveTemplateOptions(
            Long companyId,
            Long templateId,
            Long itemId,
            List<SaveInspectionTemplateOptionRequest> optionRequests,
            Map<Long, InspectionTemplateOptionResponse> existingOptions
    ) {
        if (optionRequests == null) {
            return;
        }

        validateBatchOptionNames(existingOptions, optionRequests);

        for (int index = 0; index < optionRequests.size(); index++) {
            SaveInspectionTemplateOptionRequest request = optionRequests.get(index);
            String optionLabel = TextNormalizer.required(request.optionLabel());
            String optionValue = normalizeOptionValue(request.optionValue(), optionLabel);
            int sortOrder = normalizeSortOrder(request.sortOrder(), (index + 1) * SORT_ORDER_STEP);

            if (request.optionId() == null) {
                InspectionTemplateItemOption option = new InspectionTemplateItemOption(
                        itemId,
                        optionLabel,
                        optionValue,
                        sortOrder
                );
                option.setActive(request.active() == null || request.active());
                inspectionTemplateMapper.insertOption(option);
                continue;
            }

            InspectionTemplateOptionResponse existingOption = existingOptions.get(request.optionId());
            if (existingOption == null) {
                throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_OPTION_NOT_FOUND);
            }
            InspectionTemplateItemOption option = new InspectionTemplateItemOption(
                    itemId,
                    existingOption.optionLabel(),
                    existingOption.optionValue(),
                    existingOption.sortOrder()
            );
            option.setOptionId(existingOption.optionId());
            option.setOptionLabel(optionLabel);
            option.setOptionValue(optionValue);
            option.setSortOrder(sortOrder);
            option.setActive(request.active() == null || request.active());
            inspectionTemplateMapper.updateOption(companyId, templateId, option);
        }
    }

    private void validateBatchItemNames(
            Map<Long, InspectionTemplateItem> existingItems,
            List<SaveInspectionTemplateItemRequest> itemRequests
    ) {
        Set<Long> requestedIds = new HashSet<>();
        Set<String> itemNames = new HashSet<>();

        for (SaveInspectionTemplateItemRequest request : itemRequests) {
            if (request.itemId() != null && !requestedIds.add(request.itemId())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "검수 항목 ID가 중복되었습니다.");
            }
        }

        for (InspectionTemplateItem item : existingItems.values()) {
            if (!requestedIds.contains(item.getItemId())) {
                itemNames.add(TextNormalizer.required(item.getItemName()));
            }
        }

        for (SaveInspectionTemplateItemRequest request : itemRequests) {
            String itemName = TextNormalizer.required(request.itemName());
            if (!itemNames.add(itemName)) {
                throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_ITEM_DUPLICATED);
            }
        }
    }

    private void validateBatchOptionNames(
            Map<Long, InspectionTemplateOptionResponse> existingOptions,
            List<SaveInspectionTemplateOptionRequest> optionRequests
    ) {
        Set<Long> requestedIds = new HashSet<>();
        Set<String> optionLabels = new HashSet<>();
        Set<String> optionValues = new HashSet<>();

        for (SaveInspectionTemplateOptionRequest request : optionRequests) {
            if (request.optionId() != null && !requestedIds.add(request.optionId())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "검수 선택지 ID가 중복되었습니다.");
            }
        }

        for (InspectionTemplateOptionResponse option : existingOptions.values()) {
            if (!requestedIds.contains(option.optionId())) {
                optionLabels.add(TextNormalizer.required(option.optionLabel()));
                optionValues.add(normalizeOptionValue(option.optionValue(), option.optionLabel()));
            }
        }

        for (SaveInspectionTemplateOptionRequest request : optionRequests) {
            String optionLabel = TextNormalizer.required(request.optionLabel());
            String optionValue = normalizeOptionValue(request.optionValue(), optionLabel);
            if (!optionLabels.add(optionLabel) || !optionValues.add(optionValue)) {
                throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_OPTION_DUPLICATED);
            }
        }
    }

    private InspectionTemplateDetailResponse buildDetail(Long companyId, SearchInspectionTemplateResponse template) {
        List<InspectionTemplateItem> items = inspectionTemplateMapper.findItemsByTemplateId(companyId, template.templateId());
        Map<Long, List<InspectionTemplateOptionResponse>> optionsByItem = inspectionTemplateMapper
                .findOptionsByTemplateId(companyId, template.templateId())
                .stream()
                .collect(Collectors.groupingBy(InspectionTemplateOptionResponse::itemId));

        List<InspectionTemplateItemResponse> itemResponses = items.stream()
                .map((item) -> new InspectionTemplateItemResponse(
                        item.getItemId(),
                        item.getItemGroup(),
                        item.getItemName(),
                        item.getInputType(),
                        item.isRequired(),
                        item.getSortOrder(),
                        item.getGradeImpact(),
                        item.getFailPolicy(),
                        item.isActive(),
                        item.getInputType() == InspectionInputType.SELECT
                                ? List.copyOf(optionsByItem.getOrDefault(item.getItemId(), List.of()))
                                : List.of()
                ))
                .toList();

        long basicItemCount = itemResponses.stream()
                .filter((item) -> item.itemGroup() == InspectionItemGroup.BASIC)
                .count();
        long detailItemCount = itemResponses.stream()
                .filter((item) -> item.itemGroup() == InspectionItemGroup.DETAIL)
                .count();

        return new InspectionTemplateDetailResponse(
                template.templateId(),
                template.categoryId(),
                template.categoryName(),
                template.templateName(),
                template.version(),
                template.active(),
                template.createdByName(),
                template.createdAt(),
                template.updatedAt(),
                basicItemCount,
                detailItemCount,
                template.optionCount(),
                itemResponses
        );
    }

    private InspectionTemplate findTemplateOrThrow(Long companyId, Long templateId) {
        InspectionTemplate template = inspectionTemplateMapper.findTemplateById(companyId, templateId);
        if (template == null) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_NOT_FOUND);
        }
        return template;
    }

    private SearchInspectionTemplateResponse findTemplateSummaryOrThrow(Long companyId, Long templateId) {
        SearchInspectionTemplateResponse response = inspectionTemplateMapper.findTemplateSummaryById(companyId, templateId);
        if (response == null) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_NOT_FOUND);
        }
        return response;
    }

    private InspectionTemplateItem findItemOrThrow(Long companyId, Long templateId, Long itemId) {
        InspectionTemplateItem item = inspectionTemplateMapper.findItemById(companyId, templateId, itemId);
        if (item == null) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_ITEM_NOT_FOUND);
        }
        return item;
    }

    private InspectionTemplateItemOption findOptionOrThrow(
            Long companyId,
            Long templateId,
            Long itemId,
            Long optionId
    ) {
        InspectionTemplateItemOption option = inspectionTemplateMapper.findOptionById(
                companyId,
                templateId,
                itemId,
                optionId
        );
        if (option == null) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_OPTION_NOT_FOUND);
        }
        return option;
    }

    private InspectionTemplate validateActiveCompanyAndFindTemplate(Long companyId, Long templateId) {
        validateCompanyActive(companyId);
        return findTemplateOrThrow(companyId, templateId);
    }

    private InspectionTemplateItem validateActiveCompanyAndFindItem(Long companyId, Long templateId, Long itemId) {
        validateCompanyActive(companyId);
        return findItemOrThrow(companyId, templateId, itemId);
    }

    private InspectionTemplateItem validateActiveCompanyAndFindSelectItem(Long companyId, Long templateId, Long itemId) {
        InspectionTemplateItem item = validateActiveCompanyAndFindItem(companyId, templateId, itemId);
        validateSelectItem(item);
        return item;
    }

    private void validateCompanyActive(Long companyId) {
        workspaceAccessValidator.validateCompanyActive(companyId);
    }

    private void validateCategory(Long companyId, Long categoryId) {
        if (!inspectionTemplateMapper.existsCategory(companyId, categoryId)) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }
    }

    private void validateTemplateDuplicate(
            Long companyId,
            Long categoryId,
            String templateName,
            int version,
            Long excludeTemplateId
    ) {
        if (inspectionTemplateMapper.existsTemplateVersion(companyId, categoryId, templateName, version, excludeTemplateId)) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_DUPLICATED);
        }
    }

    private void validateItemDuplicate(Long companyId, Long templateId, String itemName, Long excludeItemId) {
        if (inspectionTemplateMapper.existsItemName(companyId, templateId, itemName, excludeItemId)) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_ITEM_DUPLICATED);
        }
    }

    private void validateOptionDuplicate(
            Long companyId,
            Long templateId,
            Long itemId,
            String optionLabel,
            String optionValue,
            Long excludeOptionId
    ) {
        if (inspectionTemplateMapper.existsOptionDuplicate(
                companyId,
                templateId,
                itemId,
                optionLabel,
                optionValue,
                excludeOptionId
        )) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_OPTION_DUPLICATED);
        }
    }

    private void validateOrderedIds(List<Long> orderedIds, String targetName) {
        if (orderedIds == null || orderedIds.isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, targetName + " 순서가 필요합니다.");
        }
        Set<Long> uniqueIds = new HashSet<>(orderedIds);
        if (uniqueIds.size() != orderedIds.size()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, targetName + " 순서에 중복 ID가 있습니다.");
        }
    }

    private void validateAllItemsBelongToGroup(
            Long companyId,
            Long templateId,
            InspectionItemGroup itemGroup,
            List<Long> orderedItemIds
    ) {
        InspectionTemplateReorderValidationRow validation = inspectionTemplateMapper.validateItemReorderTargets(
                companyId,
                templateId,
                itemGroup,
                orderedItemIds
        );
        if (validation.totalCount() != orderedItemIds.size()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "항목 순서는 해당 항목 구분의 전체 항목을 포함해야 합니다.");
        }
        if (validation.matchedCount() != orderedItemIds.size()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "정렬 대상 항목이 템플릿 또는 항목 구분과 일치하지 않습니다.");
        }
    }

    private void validateAllOptionsBelongToItem(
            Long companyId,
            Long templateId,
            Long itemId,
            List<Long> orderedOptionIds
    ) {
        InspectionTemplateReorderValidationRow validation = inspectionTemplateMapper.validateOptionReorderTargets(
                companyId,
                templateId,
                itemId,
                orderedOptionIds
        );
        if (validation.totalCount() != orderedOptionIds.size()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "선택지 순서는 해당 항목의 전체 선택지를 포함해야 합니다.");
        }
        if (validation.matchedCount() != orderedOptionIds.size()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "정렬 대상 선택지가 항목과 일치하지 않습니다.");
        }
    }

    private void touchTemplate(Long companyId, Long templateId) {
        inspectionTemplateMapper.touchTemplate(companyId, templateId);
    }

    private void validateSelectItem(InspectionTemplateItem item) {
        if (item.getInputType() != InspectionInputType.SELECT) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "선택형 항목에만 선택지를 등록할 수 있습니다.");
        }
    }

    private String normalizeOptionValue(String optionValue, String optionLabel) {
        String normalized = TextNormalizer.optional(optionValue);
        return normalized == null ? optionLabel : normalized;
    }

    private int normalizeVersion(Integer version) {
        if (version == null) {
            return 1;
        }
        if (version < 1) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "템플릿 버전은 1 이상이어야 합니다.");
        }
        return version;
    }

    private int normalizeSortOrder(Integer sortOrder, int fallback) {
        if (sortOrder == null) {
            return fallback;
        }
        if (sortOrder < 0) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "정렬 순서는 0 이상이어야 합니다.");
        }
        return sortOrder;
    }

    private List<SortOrderUpdate> toSortOrderUpdates(List<Long> orderedIds) {
        return IntStream.range(0, orderedIds.size())
                .mapToObj((index) -> new SortOrderUpdate(orderedIds.get(index), (index + 1) * SORT_ORDER_STEP))
                .toList();
    }
}
