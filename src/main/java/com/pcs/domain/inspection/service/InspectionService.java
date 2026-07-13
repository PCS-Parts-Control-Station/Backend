package com.pcs.domain.inspection.service;

import com.pcs.domain.inspection.dto.request.CreateBulkInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionItemResultRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.dto.response.CreateInspectionResponse;
import com.pcs.domain.inspection.dto.response.InspectionDocumentLineResponse;
import com.pcs.domain.inspection.dto.response.InspectionDocumentLineRow;
import com.pcs.domain.inspection.dto.response.InspectionDocumentUnitResponse;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailResponse;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailRow;
import com.pcs.domain.inspection.dto.response.InspectionItemResultResponse;
import com.pcs.domain.inspection.dto.response.InspectionPartUnitRow;
import com.pcs.domain.inspection.dto.response.InspectionTemplateOptionRow;
import com.pcs.domain.inspection.dto.response.InspectionWaitingDocumentDetailResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentSummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.entity.Inspection;
import com.pcs.domain.inspection.entity.InspectionItemResult;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
import com.pcs.domain.inspection.entity.PartStatusHistory;
import com.pcs.domain.inspection.mapper.InspectionMapper;
import com.pcs.domain.inspection.type.InspectionInputType;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.pagination.PageQuery;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.validation.DateRangeValidator;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;

@Service
public class InspectionService {

    private static final int DEFAULT_SIZE = 20;

    private final InspectionMapper inspectionMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public InspectionService(InspectionMapper inspectionMapper, WorkspaceAccessValidator workspaceAccessValidator) {
        this.inspectionMapper = inspectionMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchWaitingInspectionDocumentResponse, SearchWaitingInspectionDocumentSummaryResponse> searchWaitingDocuments(
            Long companyId,
            String keyword,
            Long partId,
            Boolean hasWaiting,
            Long partnerId,
            String inspectionStatus,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);
        DateRangeValidator.validate(dateFrom, dateTo);
        String normalizedKeyword = TextNormalizer.optional(keyword);
        String normalizedInspectionStatus = normalizeInspectionStatus(inspectionStatus);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
        LocalDateTime from = DateRangeValidator.toStartOfDay(dateFrom);
        LocalDateTime to = DateRangeValidator.toExclusiveEnd(dateTo);

        SearchWaitingInspectionDocumentSummaryResponse summary = inspectionMapper.summarizeWaitingDocuments(
                companyId,
                normalizedKeyword,
                partId,
                hasWaiting,
                partnerId,
                normalizedInspectionStatus,
                from,
                to
        );
        long totalElements = summary.documentCount();
        List<SearchWaitingInspectionDocumentResponse> items = totalElements == 0
                ? List.of()
                : inspectionMapper.searchWaitingDocuments(
                        companyId,
                        normalizedKeyword,
                        partId,
                        hasWaiting,
                        partnerId,
                        normalizedInspectionStatus,
                        from,
                        to,
                        pageQuery.size(),
                        pageQuery.offset()
                );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public InspectionWaitingDocumentDetailResponse getWaitingDocumentUnits(Long companyId, Long documentId) {
        validateCompanyActive(companyId);
        SearchWaitingInspectionDocumentResponse document = inspectionMapper.findWaitingDocument(companyId, documentId);
        if (document == null) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NOT_FOUND);
        }

        List<InspectionDocumentLineRow> lineRows = inspectionMapper.findWaitingDocumentLines(companyId, documentId);
        List<InspectionDocumentUnitResponse> unitRows = inspectionMapper.findWaitingDocumentUnits(companyId, documentId);
        Map<Long, List<InspectionDocumentUnitResponse>> unitsByMovementId = unitRows.stream()
                .collect(Collectors.groupingBy(
                        InspectionDocumentUnitResponse::movementId,
                        LinkedHashMap::new,
                        Collectors.toList()
                ));
        List<InspectionDocumentLineResponse> lines = lineRows.stream()
                .map(line -> new InspectionDocumentLineResponse(
                        line.movementId(),
                        line.partId(),
                        line.categoryId(),
                        line.categoryName(),
                        line.partName(),
                        line.modelName(),
                        line.partCode(),
                        line.quantity(),
                        line.completedCount(),
                        line.waitingCount(),
                        line.defectiveCount(),
                        unitsByMovementId.getOrDefault(line.movementId(), List.of())
                ))
                .toList();

        return new InspectionWaitingDocumentDetailResponse(
                document.documentId(),
                document.documentNo(),
                document.partnerId(),
                document.partnerName(),
                document.summary(),
                document.totalUnitCount(),
                document.completedCount(),
                document.waitingCount(),
                document.defectiveCount(),
                document.progressRate(),
                document.inspectionStatus(),
                document.createdAt(),
                lines
        );
    }

    public CreateInspectionResponse createInitialInspection(
            Long companyId,
            Long memberId,
            CreateInspectionRequest request
    ) {
        validateCompanyActive(companyId);
        LocalDateTime inspectedAt = LocalDateTime.now();
        Inspection inspection = saveInspection(
                companyId,
                memberId,
                request.unitId(),
                request.templateId(),
                InspectionType.INITIAL,
                null,
                request.result(),
                request.grade(),
                request.salesStatus(),
                request.memo(),
                request.itemResults(),
                inspectedAt,
                InspectionStatus.WAITING,
                true,
                true
        );
        return new CreateInspectionResponse(
                List.of(inspection.getInspectionId()),
                1,
                InspectionType.INITIAL,
                request.result(),
                request.grade(),
                request.salesStatus(),
                inspectedAt
        );
    }

    public CreateInspectionResponse createBulkInitialInspection(
            Long companyId,
            Long memberId,
            CreateBulkInspectionRequest request
    ) {
        validateCompanyActive(companyId);
        validateUniqueIds(request.unitIds());
        LocalDateTime inspectedAt = LocalDateTime.now();
        List<InspectionPartUnitRow> units = inspectionMapper.findPartUnitsForUpdate(companyId, request.unitIds());
        Map<Long, InspectionPartUnitRow> unitsById = units.stream()
                .collect(Collectors.toMap(InspectionPartUnitRow::unitId, Function.identity()));
        if (unitsById.size() != request.unitIds().size()) {
            throw new BusinessException(ErrorCode.PART_UNIT_NOT_FOUND);
        }

        for (InspectionPartUnitRow unit : units) {
            validateUnit(unit, InspectionStatus.WAITING);
        }
        if (request.templateId() != null) {
            Long categoryId = units.get(0).categoryId();
            if (units.stream().anyMatch(unit -> !unit.categoryId().equals(categoryId))) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "같은 템플릿으로 검수할 부품의 카테고리가 일치해야 합니다.");
            }
        }
        TemplateSnapshot templateSnapshot = validateTemplateAndBuildSnapshot(
                companyId,
                units.get(0).categoryId(),
                request.templateId(),
                request.itemResults(),
                true,
                true
        );

        List<Long> inspectionIds = new ArrayList<>();
        List<InspectionItemResult> itemResults = new ArrayList<>();
        List<PartStatusHistory> histories = new ArrayList<>();
        for (Long unitId : request.unitIds()) {
            InspectionPartUnitRow unit = unitsById.get(unitId);
            Inspection inspection = insertInspection(
                    companyId,
                    memberId,
                    unitId,
                    request.templateId(),
                    InspectionType.INITIAL,
                    null,
                    request.result(),
                    request.grade(),
                    request.salesStatus(),
                    request.memo(),
                    inspectedAt
            );
            inspectionIds.add(inspection.getInspectionId());
            itemResults.addAll(templateSnapshot.toItemResults(inspection.getInspectionId(), request.itemResults()));
            histories.add(toStatusHistory(companyId, memberId, unit, request.grade(), request.salesStatus(), InspectionType.INITIAL));
        }
        if (!itemResults.isEmpty()) {
            inspectionMapper.insertItemResults(itemResults);
        }
        int updated = inspectionMapper.updatePartUnitInspectionStatuses(
                companyId,
                request.unitIds(),
                InspectionStatus.WAITING,
                InspectionStatus.COMPLETED,
                request.grade(),
                request.salesStatus()
        );
        if (updated != request.unitIds().size()) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE);
        }
        inspectionMapper.insertPartStatusHistories(histories);
        return new CreateInspectionResponse(
                inspectionIds,
                inspectionIds.size(),
                InspectionType.INITIAL,
                request.result(),
                request.grade(),
                request.salesStatus(),
                inspectedAt
        );
    }

    public CreateInspectionResponse createCorrection(
            Long companyId,
            Long memberId,
            Long baseInspectionId,
            CreateInspectionRevisionRequest request
    ) {
        return createRevision(companyId, memberId, baseInspectionId, request, InspectionType.CORRECTION);
    }

    public CreateInspectionResponse createReinspection(
            Long companyId,
            Long memberId,
            Long baseInspectionId,
            CreateInspectionRevisionRequest request
    ) {
        return createRevision(companyId, memberId, baseInspectionId, request, InspectionType.REINSPECTION);
    }

    public PageResultDto<SearchInspectionHistoryResponse, SearchInspectionHistorySummaryResponse> searchHistories(
            Long companyId,
            String keyword,
            Long documentId,
            Long unitId,
            Long partId,
            InspectionType inspectionType,
            InspectionResult result,
            PartGrade grade,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);
        DateRangeValidator.validate(dateFrom, dateTo);
        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
        LocalDateTime from = DateRangeValidator.toStartOfDay(dateFrom);
        LocalDateTime to = DateRangeValidator.toExclusiveEnd(dateTo);

        SearchInspectionHistorySummaryResponse summary = inspectionMapper.summarizeHistories(
                companyId,
                normalizedKeyword,
                documentId,
                unitId,
                partId,
                inspectionType,
                result,
                grade,
                from,
                to
        );
        long totalElements = summary.totalCount();
        List<SearchInspectionHistoryResponse> items = totalElements == 0
                ? List.of()
                : inspectionMapper.searchHistories(
                        companyId,
                        normalizedKeyword,
                        documentId,
                        unitId,
                        partId,
                        inspectionType,
                        result,
                        grade,
                        from,
                        to,
                        pageQuery.size(),
                        pageQuery.offset()
                );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public PageResultDto<SearchInspectionHistoryDocumentResponse, SearchInspectionHistoryDocumentSummaryResponse> searchHistoryDocuments(
            Long companyId,
            String keyword,
            Long documentId,
            Long partId,
            InspectionType inspectionType,
            InspectionResult result,
            PartGrade grade,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);
        DateRangeValidator.validate(dateFrom, dateTo);
        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
        LocalDateTime from = DateRangeValidator.toStartOfDay(dateFrom);
        LocalDateTime to = DateRangeValidator.toExclusiveEnd(dateTo);

        SearchInspectionHistoryDocumentSummaryResponse summary = inspectionMapper.summarizeHistoryDocuments(
                companyId,
                normalizedKeyword,
                documentId,
                partId,
                inspectionType,
                result,
                grade,
                from,
                to
        );
        long totalElements = summary.documentCount();
        List<SearchInspectionHistoryDocumentResponse> items = totalElements == 0
                ? List.of()
                : inspectionMapper.searchHistoryDocuments(
                        companyId,
                        normalizedKeyword,
                        documentId,
                        partId,
                        inspectionType,
                        result,
                        grade,
                        from,
                        to,
                        pageQuery.size(),
                        pageQuery.offset()
                );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public InspectionHistoryDetailResponse getHistoryDetail(Long companyId, Long inspectionId) {
        validateCompanyActive(companyId);
        InspectionHistoryDetailRow row = inspectionMapper.findHistoryDetail(companyId, inspectionId);
        if (row == null) {
            throw new BusinessException(ErrorCode.INSPECTION_NOT_FOUND);
        }
        List<InspectionItemResultResponse> itemResults = inspectionMapper.findItemResults(companyId, inspectionId);
        return new InspectionHistoryDetailResponse(
                row.inspectionId(),
                row.inspectionType(),
                row.originalInspectionId(),
                row.documentId(),
                row.documentNo(),
                row.unitId(),
                row.internalSerialNo(),
                row.unitStatus(),
                row.partId(),
                row.categoryId(),
                row.categoryName(),
                row.partName(),
                row.modelName(),
                row.templateId(),
                row.templateName(),
                row.result(),
                row.grade(),
                row.salesStatus(),
                row.memo(),
                row.inspectedByName(),
                row.inspectedAt(),
                itemResults
        );
    }

    private CreateInspectionResponse createRevision(
            Long companyId,
            Long memberId,
            Long baseInspectionId,
            CreateInspectionRevisionRequest request,
            InspectionType inspectionType
    ) {
        validateCompanyActive(companyId);
        Inspection baseInspection = inspectionMapper.findInspection(companyId, baseInspectionId);
        if (baseInspection == null) {
            throw new BusinessException(ErrorCode.INSPECTION_NOT_FOUND);
        }

        Long originalInspectionId = baseInspection.getOriginalInspectionId() == null
                ? baseInspection.getInspectionId()
                : baseInspection.getOriginalInspectionId();
        Long templateId = request.templateId() == null
                ? baseInspection.getTemplateId()
                : request.templateId();
        LocalDateTime inspectedAt = LocalDateTime.now();
        Inspection inspection = saveInspection(
                companyId,
                memberId,
                baseInspection.getUnitId(),
                templateId,
                inspectionType,
                originalInspectionId,
                request.result(),
                request.grade(),
                request.salesStatus(),
                request.memo(),
                request.itemResults(),
                inspectedAt,
                InspectionStatus.COMPLETED,
                false,
                false
        );
        return new CreateInspectionResponse(
                List.of(inspection.getInspectionId()),
                1,
                inspectionType,
                request.result(),
                request.grade(),
                request.salesStatus(),
                inspectedAt
        );
    }

    private Inspection saveInspection(
            Long companyId,
            Long memberId,
            Long unitId,
            Long templateId,
            InspectionType inspectionType,
            Long originalInspectionId,
            InspectionResult result,
            PartGrade grade,
            SalesStatus salesStatus,
            String memo,
            List<CreateInspectionItemResultRequest> itemResultRequests,
            LocalDateTime inspectedAt,
            InspectionStatus requiredInspectionStatus,
            boolean activeTemplateOnly,
            boolean enforceRequiredItems
    ) {
        InspectionPartUnitRow unit = validateAndFindUnit(companyId, unitId, requiredInspectionStatus);
        TemplateSnapshot templateSnapshot = validateTemplateAndBuildSnapshot(
                companyId,
                unit.categoryId(),
                templateId,
                itemResultRequests,
                activeTemplateOnly,
                enforceRequiredItems
        );

        Inspection inspection = insertInspection(
                companyId,
                memberId,
                unitId,
                templateId,
                inspectionType,
                originalInspectionId,
                result,
                grade,
                salesStatus,
                TextNormalizer.optional(memo),
                inspectedAt
        );

        for (InspectionItemResult itemResult : templateSnapshot.toItemResults(
                inspection.getInspectionId(),
                itemResultRequests
        )) {
            inspectionMapper.insertItemResult(itemResult);
        }

        updatePartUnitInspectionStatus(
                companyId,
                unitId,
                unit.inspectionStatus(),
                InspectionStatus.COMPLETED,
                grade,
                salesStatus
        );
        inspectionMapper.insertPartStatusHistory(toStatusHistory(
                companyId,
                memberId,
                unit,
                grade,
                salesStatus,
                inspectionType
        ));
        return inspection;
    }

    private Inspection insertInspection(
            Long companyId,
            Long memberId,
            Long unitId,
            Long templateId,
            InspectionType inspectionType,
            Long originalInspectionId,
            InspectionResult result,
            PartGrade grade,
            SalesStatus salesStatus,
            String memo,
            LocalDateTime inspectedAt
    ) {
        Inspection inspection = new Inspection(
                companyId,
                unitId,
                templateId,
                memberId,
                inspectionType,
                originalInspectionId,
                salesStatus,
                result,
                grade,
                TextNormalizer.optional(memo),
                inspectedAt
        );
        inspectionMapper.insertInspection(inspection);
        return inspection;
    }

    private PartStatusHistory toStatusHistory(
            Long companyId,
            Long memberId,
            InspectionPartUnitRow unit,
            PartGrade grade,
            SalesStatus salesStatus,
            InspectionType inspectionType
    ) {
        return new PartStatusHistory(
                companyId,
                unit.unitId(),
                memberId,
                unit.inspectionStatus(),
                InspectionStatus.COMPLETED,
                unit.grade(),
                grade,
                unit.salesStatus(),
                salesStatus,
                inspectionType.name()
        );
    }

    private InspectionPartUnitRow validateAndFindUnit(
            Long companyId,
            Long unitId,
            InspectionStatus requiredInspectionStatus
    ) {
        InspectionPartUnitRow unit = inspectionMapper.findPartUnitForUpdate(companyId, unitId);
        if (unit == null) {
            throw new BusinessException(ErrorCode.PART_UNIT_NOT_FOUND);
        }
        validateUnit(unit, requiredInspectionStatus);
        return unit;
    }

    private void validateUnit(InspectionPartUnitRow unit, InspectionStatus requiredInspectionStatus) {
        if (!unit.active() || unit.unitStatus() != UnitStatus.IN_STOCK) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE, "검수 가능한 재고 상태가 아닙니다.");
        }
        if (requiredInspectionStatus == InspectionStatus.WAITING
                && unit.inspectionStatus() == InspectionStatus.COMPLETED) {
            throw new BusinessException(ErrorCode.INSPECTION_ALREADY_COMPLETED);
        }
        if (unit.inspectionStatus() != requiredInspectionStatus) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE);
        }
    }

    private void updatePartUnitInspectionStatus(
            Long companyId,
            Long unitId,
            InspectionStatus expectedInspectionStatus,
            InspectionStatus inspectionStatus,
            PartGrade grade,
            SalesStatus salesStatus
    ) {
        int updated = inspectionMapper.updatePartUnitInspectionStatus(
                companyId,
                unitId,
                expectedInspectionStatus,
                inspectionStatus,
                grade,
                salesStatus
        );
        if (updated != 1) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE);
        }
    }

    private TemplateSnapshot validateTemplateAndBuildSnapshot(
            Long companyId,
            Long unitCategoryId,
            Long templateId,
            List<CreateInspectionItemResultRequest> itemResultRequests,
            boolean activeTemplateOnly,
            boolean enforceRequiredItems
    ) {
        List<CreateInspectionItemResultRequest> requests = normalizeItemResults(itemResultRequests);
        if (templateId == null) {
            if (!requests.isEmpty()) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "템플릿 없이 항목별 결과를 저장할 수 없습니다.");
            }
            return TemplateSnapshot.empty();
        }

        InspectionTemplate template = activeTemplateOnly
                ? inspectionMapper.findActiveTemplate(companyId, templateId)
                : inspectionMapper.findTemplate(companyId, templateId);
        if (template == null) {
            throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_NOT_FOUND);
        }
        if (!template.getCategoryId().equals(unitCategoryId)) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "부품 카테고리와 템플릿 카테고리가 일치하지 않습니다.");
        }

        List<InspectionTemplateItem> items = activeTemplateOnly
                ? inspectionMapper.findActiveTemplateItems(companyId, templateId)
                : inspectionMapper.findTemplateItems(companyId, templateId);
        List<InspectionTemplateOptionRow> options = activeTemplateOnly
                ? inspectionMapper.findActiveTemplateOptions(companyId, templateId)
                : inspectionMapper.findTemplateOptions(companyId, templateId);
        TemplateSnapshot snapshot = new TemplateSnapshot(items, options);
        snapshot.validateRequests(requests, enforceRequiredItems);
        return snapshot;
    }

    private void validateCompanyActive(Long companyId) {
        workspaceAccessValidator.validateCompanyActive(companyId);
    }

    private void validateUniqueIds(List<Long> unitIds) {
        Set<Long> uniqueIds = new HashSet<>();
        for (Long unitId : unitIds) {
            if (!uniqueIds.add(unitId)) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 unitId가 있습니다.");
            }
        }
    }

    private List<CreateInspectionItemResultRequest> normalizeItemResults(
            List<CreateInspectionItemResultRequest> itemResultRequests
    ) {
        if (itemResultRequests == null) {
            return List.of();
        }
        return itemResultRequests;
    }

    private String normalizeInspectionStatus(String inspectionStatus) {
        String value = TextNormalizer.optional(inspectionStatus);
        if (value == null) {
            return null;
        }
        if (!Set.of("WAITING", "IN_PROGRESS", "COMPLETED").contains(value)) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "지원하지 않는 검수 진행 상태입니다.");
        }
        return value;
    }

    private record TemplateSnapshot(
            Map<Long, InspectionTemplateItem> itemsById,
            Map<Long, InspectionTemplateOptionRow> optionsById
    ) {

        static TemplateSnapshot empty() {
            return new TemplateSnapshot(Map.of(), Map.of());
        }

        TemplateSnapshot(
                List<InspectionTemplateItem> items,
                List<InspectionTemplateOptionRow> options
        ) {
            this(
                    items.stream().collect(Collectors.toMap(
                            InspectionTemplateItem::getItemId,
                            Function.identity(),
                            (left, right) -> left,
                            LinkedHashMap::new
                    )),
                    options.stream().collect(Collectors.toMap(
                            InspectionTemplateOptionRow::optionId,
                            Function.identity()
                    ))
            );
        }

        void validateRequests(List<CreateInspectionItemResultRequest> requests, boolean enforceRequiredItems) {
            Map<Long, CreateInspectionItemResultRequest> requestsByItemId = new LinkedHashMap<>();
            for (CreateInspectionItemResultRequest request : requests) {
                if (requestsByItemId.put(request.itemId(), request) != null) {
                    throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 검수 항목 결과가 있습니다.");
                }
                InspectionTemplateItem item = itemsById.get(request.itemId());
                if (item == null) {
                    throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_ITEM_NOT_FOUND);
                }
                validateRequestByInputType(item, request);
            }

            if (enforceRequiredItems) {
                for (InspectionTemplateItem item : itemsById.values()) {
                    if (item.isRequired() && !requestsByItemId.containsKey(item.getItemId())) {
                        throw new BusinessException(
                                ErrorCode.INVALID_INPUT_VALUE,
                                "필수 검수 항목 결과가 누락되었습니다. itemId=" + item.getItemId()
                        );
                    }
                }
            }
        }

        List<InspectionItemResult> toItemResults(
                Long inspectionId,
                List<CreateInspectionItemResultRequest> requests
        ) {
            if (requests == null || requests.isEmpty()) {
                return List.of();
            }

            List<InspectionItemResult> results = new ArrayList<>();
            for (CreateInspectionItemResultRequest request : requests) {
                InspectionTemplateItem item = itemsById.get(request.itemId());
                InspectionTemplateOptionRow option = request.selectedOptionId() == null
                        ? null
                        : optionsById.get(request.selectedOptionId());
                results.add(new InspectionItemResult(
                        inspectionId,
                        item.getItemId(),
                        item.getItemName(),
                        request.result(),
                        normalizeText(request.valueText()),
                        request.valueNumber(),
                        option == null ? null : option.optionId(),
                        option == null ? null : option.optionLabel(),
                        option == null ? null : option.optionValue(),
                        normalizeText(request.memo())
                ));
            }
            return results;
        }

        private void validateRequestByInputType(
                InspectionTemplateItem item,
                CreateInspectionItemResultRequest request
        ) {
            if (item.getInputType() == InspectionInputType.SELECT) {
                if (request.selectedOptionId() == null) {
                    throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "선택형 항목은 선택지가 필요합니다.");
                }
                InspectionTemplateOptionRow option = optionsById.get(request.selectedOptionId());
                if (option == null || !option.itemId().equals(item.getItemId())) {
                    throw new BusinessException(ErrorCode.INSPECTION_TEMPLATE_OPTION_NOT_FOUND);
                }
                return;
            }
            if (request.selectedOptionId() != null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "선택형 항목만 선택지를 저장할 수 있습니다.");
            }
            if (item.getInputType() == InspectionInputType.NUMBER && request.valueNumber() == null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "숫자 입력 항목은 숫자 값이 필요합니다.");
            }
            if (item.getInputType() == InspectionInputType.TEXT && normalizeText(request.valueText()) == null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "텍스트 입력 항목은 텍스트 값이 필요합니다.");
            }
        }

        private static String normalizeText(String value) {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }
            return value.trim();
        }
    }
}
