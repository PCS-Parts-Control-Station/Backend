package com.pcs.domain.part.service;

import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.category.mapper.PartSpecMapper;
import com.pcs.domain.category.type.PartSpecInputTypes;
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
import com.pcs.domain.part.entity.PartSpecValue;
import com.pcs.domain.part.entity.PcPart;
import com.pcs.domain.part.mapper.PartMapper;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.pagination.PageQuery;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PartService {

    private static final int MAX_CODE_ATTEMPT = 999;
    private static final int PART_UNIT_DEFAULT_SIZE = 20;
    private static final int PART_UNIT_HISTORY_LIMIT = 10;
    private static final Set<String> PART_UNIT_STATE_FILTERS = Set.of(
            "WAITING",
            "A",
            "B",
            "C",
            "DEFECTIVE",
            "OUTBOUND"
    );

    private final PartMapper partMapper;
    private final PartSpecMapper partSpecMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public PartService(
            PartMapper partMapper,
            PartSpecMapper partSpecMapper,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.partMapper = partMapper;
        this.partSpecMapper = partSpecMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchPartResponse, SearchPartSummaryResponse> searchParts(
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
        Boolean normalizedActive = active == null ? Boolean.TRUE : active;
        PageQuery pageQuery = PageQuery.of(page, size, limit);

        long totalElements = partMapper.countParts(companyId, normalizedKeyword, categoryId, normalizedActive);
        List<SearchPartResponse> items = totalElements == 0
                ? List.of()
                : partMapper.searchParts(
                        companyId,
                        normalizedKeyword,
                        categoryId,
                        normalizedActive,
                        pageQuery.size(),
                        pageQuery.offset()
                );
        SearchPartSummaryResponse summary = partMapper.summarizeParts(
                companyId,
                normalizedKeyword,
                categoryId,
                normalizedActive
        );

        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse> searchPartUnits(
            Long companyId,
            String keyword,
            Long categoryId,
            String partState,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);

        String normalizedKeyword = TextNormalizer.optional(keyword);
        String normalizedPartState = normalizePartState(partState);
        PageQuery pageQuery = PageQuery.of(page, size, limit, PART_UNIT_DEFAULT_SIZE);

        SearchPartUnitSummaryResponse summary = partMapper.summarizePartUnits(
                companyId,
                normalizedKeyword,
                categoryId,
                normalizedPartState
        );
        if (summary == null) {
            summary = new SearchPartUnitSummaryResponse(0, 0, 0);
        }

        long totalElements = summary.totalCount();
        List<SearchPartUnitResponse> items = totalElements == 0
                ? List.of()
                : partMapper.searchPartUnits(
                        companyId,
                        normalizedKeyword,
                        categoryId,
                        normalizedPartState,
                        pageQuery.size(),
                        pageQuery.offset()
                );

        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public PartDetailResponse getPart(Long companyId, Long partId) {
        validateCompanyActive(companyId);
        return getPartDetail(companyId, partId);
    }

    public PartUnitDetailResponse getPartUnit(Long companyId, Long unitId) {
        validateCompanyActive(companyId);
        SearchPartUnitResponse unit = partMapper.findPartUnitById(companyId, unitId);
        if (unit == null) {
            throw new BusinessException(ErrorCode.PART_UNIT_NOT_FOUND);
        }
        List<PartUnitStockHistoryResponse> stockHistories = partMapper.findPartUnitStockHistories(
                companyId,
                unitId,
                PART_UNIT_HISTORY_LIMIT
        );
        List<PartUnitInspectionHistoryResponse> inspectionHistories = partMapper.findPartUnitInspectionHistories(
                companyId,
                unitId,
                PART_UNIT_HISTORY_LIMIT
        );
        return new PartUnitDetailResponse(unit, stockHistories, inspectionHistories);
    }

    @Transactional
    public PartDetailResponse createPart(Long companyId, CreatePartRequest request, Long memberId) {
        validateCompanyActive(companyId);
        String categoryName = validateCategory(companyId, request.categoryId());
        List<CategorySpecDefinitionRow> definitions = partSpecMapper.findDefinitionsByCategory(
                companyId,
                request.categoryId()
        );
        List<PartSpecValue> specValues = normalizeSpecValues(
                companyId,
                null,
                definitions,
                request.specValues()
        );
        String partCode = generatePartCode(
                companyId,
                request.categoryId(),
                categoryName,
                request.manufacturer(),
                request.modelName(),
                specValues,
                null
        );

        PcPart part = new PcPart(
                companyId,
                request.categoryId(),
                memberId,
                TextNormalizer.required(request.partName()),
                TextNormalizer.required(request.modelName()),
                TextNormalizer.required(request.manufacturer()),
                partCode,
                normalizeQuantity(request.safeQuantity())
        );
        partMapper.insert(part);
        saveSpecValues(companyId, part.getPartId(), specValues);
        return getPartDetail(companyId, part.getPartId());
    }

    @Transactional
    public PartDetailResponse updatePart(Long companyId, Long partId, UpdatePartRequest request) {
        validateCompanyActive(companyId);
        PcPart part = partMapper.findById(companyId, partId);
        if (part == null) {
            throw new BusinessException(ErrorCode.PART_NOT_FOUND);
        }

        String categoryName = validateCategory(companyId, request.categoryId());
        List<CategorySpecDefinitionRow> definitions = partSpecMapper.findDefinitionsByCategory(
                companyId,
                request.categoryId()
        );
        List<PartSpecValue> specValues = normalizeSpecValues(
                companyId,
                partId,
                definitions,
                request.specValues()
        );

        part.setCategoryId(request.categoryId());
        part.setPartName(TextNormalizer.required(request.partName()));
        part.setModelName(TextNormalizer.required(request.modelName()));
        part.setManufacturer(TextNormalizer.required(request.manufacturer()));
        part.setSafeQuantity(normalizeQuantity(request.safeQuantity()));
        part.setPartCode(generatePartCode(
                companyId,
                request.categoryId(),
                categoryName,
                request.manufacturer(),
                request.modelName(),
                specValues,
                partId
        ));

        partMapper.update(part);
        partMapper.deleteSpecValuesByPart(companyId, partId);
        saveSpecValues(companyId, partId, specValues);
        return getPartDetail(companyId, partId);
    }

    private PartDetailResponse getPartDetail(Long companyId, Long partId) {
        SearchPartResponse part = partMapper.findResponseById(companyId, partId);
        if (part == null) {
            throw new BusinessException(ErrorCode.PART_NOT_FOUND);
        }
        List<PartSpecValueResponse> specValues = partMapper.findSpecValuesByPart(companyId, partId);
        return PartDetailResponse.of(part, specValues);
    }

    private String validateCategory(Long companyId, Long categoryId) {
        if (categoryId == null) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "분류를 선택해 주세요.");
        }
        String categoryName = partMapper.findCategoryName(companyId, categoryId);
        if (categoryName == null) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }
        return categoryName;
    }

    private String normalizePartState(String partState) {
        String normalized = TextNormalizer.optional(partState);
        if (normalized == null) {
            return null;
        }
        String upper = normalized.toUpperCase(Locale.ROOT);
        if (!PART_UNIT_STATE_FILTERS.contains(upper)) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "부품 상태 검색 조건이 올바르지 않습니다.");
        }
        return upper;
    }

    private List<PartSpecValue> normalizeSpecValues(
            Long companyId,
            Long partId,
            List<CategorySpecDefinitionRow> definitions,
            List<PartSpecValueRequest> requests
    ) {
        List<PartSpecValueRequest> safeRequests = requests == null ? List.of() : requests;
        Map<Long, CategorySpecDefinitionRow> definitionById = definitions.stream()
                .collect(Collectors.toMap(CategorySpecDefinitionRow::specDefinitionId, definition -> definition));
        Set<Long> specDefinitionIds = new HashSet<>();

        List<Long> definitionIds = definitions.stream()
                .map(CategorySpecDefinitionRow::specDefinitionId)
                .toList();
        Map<Long, List<CategorySpecOptionResponse>> optionsByDefinition = partSpecMapper.findOptionsByDefinitionIds(definitionIds)
                .stream()
                .collect(Collectors.groupingBy(CategorySpecOptionResponse::specDefinitionId));

        Map<Long, PartSpecValueRequest> requestByDefinitionId = new HashMap<>();
        for (PartSpecValueRequest request : safeRequests) {
            if (request.specDefinitionId() == null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "사양 항목 정보가 올바르지 않습니다.");
            }
            if (!definitionById.containsKey(request.specDefinitionId())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "분류에 없는 사양 항목입니다.");
            }
            if (!specDefinitionIds.add(request.specDefinitionId())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 사양 항목 값이 있습니다.");
            }
            requestByDefinitionId.put(request.specDefinitionId(), request);
        }

        List<PartSpecValue> values = new ArrayList<>();
        for (CategorySpecDefinitionRow definition : definitions) {
            PartSpecValueRequest request = requestByDefinitionId.get(definition.specDefinitionId());
            PartSpecValue value = normalizeSpecValue(
                    companyId,
                    partId,
                    definition,
                    optionsByDefinition.getOrDefault(definition.specDefinitionId(), List.of()),
                    request
            );
            if (value != null) {
                values.add(value);
            }
        }
        return values;
    }

    private PartSpecValue normalizeSpecValue(
            Long companyId,
            Long partId,
            CategorySpecDefinitionRow definition,
            List<CategorySpecOptionResponse> options,
            PartSpecValueRequest request
    ) {
        if (request == null) {
            if (Boolean.TRUE.equals(definition.required()) && !PartSpecInputTypes.isBoolean(definition.inputType())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, definition.specName() + " 값을 입력해 주세요.");
            }
            if (PartSpecInputTypes.isBoolean(definition.inputType())) {
                return new PartSpecValue(
                        companyId,
                        partId,
                        definition.specDefinitionId(),
                        null,
                        null,
                        Boolean.FALSE,
                        null,
                        null,
                        null
                );
            }
            return null;
        }

        if (PartSpecInputTypes.isSelect(definition.inputType())) {
            CategorySpecOptionResponse option = findOption(definition, options, request.selectedOptionId());
            return new PartSpecValue(
                    companyId,
                    partId,
                    definition.specDefinitionId(),
                    null,
                    null,
                    null,
                    option.optionId(),
                    option.optionLabel(),
                    option.optionValue()
            );
        }

        if (PartSpecInputTypes.isNumber(definition.inputType())) {
            BigDecimal valueNumber = request.valueNumber();
            if (valueNumber == null) {
                if (Boolean.TRUE.equals(definition.required())) {
                    throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, definition.specName() + " 값을 입력해 주세요.");
                }
                return null;
            }
            return new PartSpecValue(
                    companyId,
                    partId,
                    definition.specDefinitionId(),
                    null,
                    valueNumber,
                    null,
                    null,
                    null,
                    null
            );
        }

        if (PartSpecInputTypes.isBoolean(definition.inputType())) {
            return new PartSpecValue(
                    companyId,
                    partId,
                    definition.specDefinitionId(),
                    null,
                    null,
                    Boolean.TRUE.equals(request.valueBoolean()),
                    null,
                    null,
                    null
            );
        }

        String valueText = TextNormalizer.optional(request.valueText());
        if (valueText == null) {
            if (Boolean.TRUE.equals(definition.required())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, definition.specName() + " 값을 입력해 주세요.");
            }
            return null;
        }
        return new PartSpecValue(
                companyId,
                partId,
                definition.specDefinitionId(),
                valueText,
                null,
                null,
                null,
                null,
                null
        );
    }

    private CategorySpecOptionResponse findOption(
            CategorySpecDefinitionRow definition,
            List<CategorySpecOptionResponse> options,
            Long selectedOptionId
    ) {
        if (selectedOptionId == null) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, definition.specName() + " 값을 선택해 주세요.");
        }
        return options.stream()
                .filter(option -> selectedOptionId.equals(option.optionId()))
                .findFirst()
                .orElseThrow(() -> new BusinessException(
                        ErrorCode.INVALID_INPUT_VALUE,
                        definition.specName() + " 선택지가 올바르지 않습니다."
                ));
    }

    private void saveSpecValues(Long companyId, Long partId, List<PartSpecValue> specValues) {
        for (PartSpecValue value : specValues) {
            value.setPartId(partId);
            value.setCompanyId(companyId);
            partMapper.insertSpecValue(value);
        }
    }

    private String generatePartCode(
            Long companyId,
            Long categoryId,
            String categoryName,
            String manufacturer,
            String modelName,
            List<PartSpecValue> specValues,
            Long excludePartId
    ) {
        String specSeed = specValues.stream()
                .sorted(Comparator.comparing(PartSpecValue::getSpecDefinitionId))
                .map(this::specValueSeed)
                .filter(value -> !value.isBlank())
                .collect(Collectors.joining("-"));
        String seed = String.join(
                "-",
                categoryName,
                TextNormalizer.required(manufacturer),
                TextNormalizer.required(modelName),
                specSeed
        );
        String baseCode = String.join(
                "-",
                codeSegment(categoryName, "C" + categoryId, 8),
                codeSegment(manufacturer, "MFR", 8),
                codeSegment(modelName + "-" + specSeed, hashSegment(seed), 16)
        );

        for (int sequence = 1; sequence <= MAX_CODE_ATTEMPT; sequence++) {
            String candidate = trimCode(baseCode, sequence);
            if (!partMapper.existsPartCode(companyId, candidate, excludePartId)) {
                return candidate;
            }
        }
        throw new BusinessException(ErrorCode.PART_CODE_DUPLICATED);
    }

    private String specValueSeed(PartSpecValue value) {
        if (value.getSelectedOptionValueSnapshot() != null) {
            return value.getSelectedOptionValueSnapshot();
        }
        if (value.getSelectedOptionLabelSnapshot() != null) {
            return value.getSelectedOptionLabelSnapshot();
        }
        if (value.getValueText() != null) {
            return value.getValueText();
        }
        if (value.getValueNumber() != null) {
            return value.getValueNumber().stripTrailingZeros().toPlainString();
        }
        if (value.getValueBoolean() != null) {
            return Boolean.TRUE.equals(value.getValueBoolean()) ? "Y" : "N";
        }
        return "";
    }

    private String codeSegment(String value, String fallback, int maxLength) {
        String normalized = TextNormalizer.optional(value);
        String segment = normalized == null
                ? ""
                : normalized.toUpperCase(Locale.ROOT)
                        .replaceAll("[^A-Z0-9]+", "")
                        .trim();
        if (segment.isBlank()) {
            segment = fallback;
        }
        return segment.length() > maxLength ? segment.substring(0, maxLength) : segment;
    }

    private String hashSegment(String seed) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(seed.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(bytes).substring(0, 8).toUpperCase(Locale.ROOT);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 algorithm is unavailable.", exception);
        }
    }

    private String trimCode(String baseCode, int sequence) {
        String suffix = "-" + String.format(Locale.ROOT, "%03d", sequence);
        int maxBaseLength = 80 - suffix.length();
        String base = baseCode.length() > maxBaseLength ? baseCode.substring(0, maxBaseLength) : baseCode;
        return base + suffix;
    }

    private void validateCompanyActive(Long companyId) {
        workspaceAccessValidator.validateCompanyActive(companyId);
    }

    private int normalizeQuantity(Integer value) {
        if (value == null) {
            return 0;
        }
        if (value < 0) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "안전 재고는 0 이상이어야 합니다.");
        }
        return value;
    }

}
