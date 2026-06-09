package com.pcs.domain.category.service;

import com.pcs.domain.category.dto.request.CategorySpecDefinitionRequest;
import com.pcs.domain.category.dto.request.CategorySpecOptionRequest;
import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.CategoryDetailResponse;
import com.pcs.domain.category.dto.response.CategorySpecDefinitionResponse;
import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.entity.PartSpecDefinition;
import com.pcs.domain.category.entity.PartSpecOption;
import com.pcs.domain.category.mapper.CategoryMapper;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CategoryService {

    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 100;
    private static final int MAX_SPEC_COUNT = 20;
    private static final int MAX_SPEC_OPTION_COUNT = 30;
    private static final Set<String> SPEC_INPUT_TYPES = Set.of("TEXT", "NUMBER", "SELECT", "BOOLEAN");

    private final CategoryMapper categoryMapper;

    public CategoryService(CategoryMapper categoryMapper) {
        this.categoryMapper = categoryMapper;
    }

    public PageResultDto<SearchCategoryResponse, Void> searchCategories(
            Long companyId,
            String keyword,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);

        String normalizedKeyword = normalizeOptional(keyword);
        int normalizedPage = normalizePage(page);
        int normalizedSize = normalizeSize(size, limit);
        int offset = normalizedPage * normalizedSize;

        long totalElements = categoryMapper.countCategories(companyId, normalizedKeyword);
        List<SearchCategoryResponse> items = totalElements == 0
                ? List.of()
                : categoryMapper.searchCategories(companyId, normalizedKeyword, normalizedSize, offset);

        return PageResultDto.of(items, normalizedPage, normalizedSize, totalElements, null);
    }

    @Transactional
    public CategoryDetailResponse createCategory(Long companyId, CreateCategoryRequest request, Long memberId) {
        validateCompanyActive(companyId);
        String categoryName = normalizeRequired(request.categoryName());
        if (categoryMapper.existsByName(companyId, categoryName, null)) {
            throw new BusinessException(ErrorCode.CATEGORY_NAME_DUPLICATED);
        }

        PartCategory category = new PartCategory(
                companyId,
                categoryName,
                normalizeOptional(request.description()),
                memberId
        );
        categoryMapper.insert(category);
        createSpecDefinitions(companyId, category.getCategoryId(), request.specDefinitions(), memberId);

        return getCategory(companyId, category.getCategoryId());
    }

    public CategoryDetailResponse getCategory(Long companyId, Long categoryId) {
        validateCompanyActive(companyId);
        SearchCategoryResponse response = categoryMapper.findResponseById(companyId, categoryId);
        if (response == null) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }
        return CategoryDetailResponse.of(response, findSpecDefinitions(companyId, categoryId));
    }

    @Transactional
    public CategoryDetailResponse updateCategory(
            Long companyId,
            Long categoryId,
            UpdateCategoryRequest request,
            Long memberId
    ) {
        validateCompanyActive(companyId);
        PartCategory category = categoryMapper.findById(companyId, categoryId);
        if (category == null) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }
        long partCount = categoryMapper.countPartsByCategory(companyId, categoryId);
        if (request.specDefinitions() != null && partCount > 0) {
            throw new BusinessException(
                    ErrorCode.INVALID_INPUT_VALUE,
                    "연결된 부품이 있는 카테고리는 스펙 항목을 수정할 수 없습니다."
            );
        }

        String categoryName = normalizeRequired(request.categoryName());
        if (categoryMapper.existsByName(companyId, categoryName, categoryId)) {
            throw new BusinessException(ErrorCode.CATEGORY_NAME_DUPLICATED);
        }

        category.setCategoryName(categoryName);
        category.setDescription(normalizeOptional(request.description()));
        categoryMapper.update(category);

        if (request.specDefinitions() != null) {
            replaceSpecDefinitions(companyId, categoryId, request.specDefinitions(), memberId);
        }

        return getCategory(companyId, categoryId);
    }

    @Transactional
    public void deleteCategory(Long companyId, Long categoryId) {
        validateCompanyActive(companyId);
        PartCategory category = categoryMapper.findById(companyId, categoryId);
        if (category == null) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }
        if (categoryMapper.countPartsByCategory(companyId, categoryId) > 0) {
            throw new BusinessException(ErrorCode.CATEGORY_IN_USE);
        }
        categoryMapper.deleteSpecValuesByCategory(companyId, categoryId);
        categoryMapper.deleteSpecOptionsByCategory(companyId, categoryId);
        categoryMapper.deleteSpecDefinitionsByCategory(companyId, categoryId);
        categoryMapper.deleteById(companyId, categoryId);
    }

    private void replaceSpecDefinitions(
            Long companyId,
            Long categoryId,
            List<CategorySpecDefinitionRequest> requests,
            Long memberId
    ) {
        categoryMapper.deleteSpecValuesByCategory(companyId, categoryId);
        categoryMapper.deleteSpecOptionsByCategory(companyId, categoryId);
        categoryMapper.deleteSpecDefinitionsByCategory(companyId, categoryId);
        createSpecDefinitions(companyId, categoryId, requests, memberId);
    }

    private void createSpecDefinitions(
            Long companyId,
            Long categoryId,
            List<CategorySpecDefinitionRequest> requests,
            Long memberId
    ) {
        List<CategorySpecDefinitionRequest> specRequests = requests == null ? List.of() : requests;
        if (specRequests.size() > MAX_SPEC_COUNT) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "스펙 항목은 20개 이하로 입력해 주세요.");
        }

        Set<String> specKeys = new HashSet<>();
        Set<String> specNames = new HashSet<>();
        for (int index = 0; index < specRequests.size(); index++) {
            CategorySpecDefinitionRequest request = specRequests.get(index);
            String specName = normalizeRequired(request.specName());
            String specNameKey = specName.toLowerCase(Locale.ROOT);
            if (!specNames.add(specNameKey)) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 스펙 항목명이 있습니다.");
            }

            String specKey = normalizeSpecKey(request.specKey(), index);
            if (!specKeys.add(specKey)) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 스펙 키가 있습니다.");
            }

            String inputType = normalizeInputType(request.inputType());
            int sortOrder = normalizeSortOrder(request.sortOrder(), index);
            PartSpecDefinition specDefinition = new PartSpecDefinition(
                    companyId,
                    categoryId,
                    specKey,
                    specName,
                    inputType,
                    normalizeOptional(request.unit()),
                    Boolean.TRUE.equals(request.required()),
                    Boolean.TRUE.equals(request.searchable()),
                    sortOrder,
                    memberId
            );
            categoryMapper.insertSpecDefinition(specDefinition);

            if ("SELECT".equals(inputType)) {
                createSpecOptions(specDefinition.getSpecDefinitionId(), request.options(), specName);
            }
        }
    }

    private void createSpecOptions(
            Long specDefinitionId,
            List<CategorySpecOptionRequest> requests,
            String specName
    ) {
        List<CategorySpecOptionRequest> optionRequests = requests == null ? List.of() : requests;
        if (optionRequests.isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, specName + " 선택지를 1개 이상 입력해 주세요.");
        }
        if (optionRequests.size() > MAX_SPEC_OPTION_COUNT) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "스펙 선택지는 30개 이하로 입력해 주세요.");
        }

        Set<String> optionValues = new HashSet<>();
        for (int index = 0; index < optionRequests.size(); index++) {
            CategorySpecOptionRequest request = optionRequests.get(index);
            String optionLabel = normalizeRequired(request.optionLabel());
            String optionValue = normalizeOptional(request.optionValue());
            if (optionValue == null) {
                optionValue = optionLabel;
            }
            String optionValueKey = optionValue.toLowerCase(Locale.ROOT);
            if (!optionValues.add(optionValueKey)) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 스펙 선택지가 있습니다.");
            }

            PartSpecOption option = new PartSpecOption(
                    specDefinitionId,
                    optionLabel,
                    optionValue,
                    normalizeSortOrder(request.sortOrder(), index)
            );
            categoryMapper.insertSpecOption(option);
        }
    }

    private List<CategorySpecDefinitionResponse> findSpecDefinitions(Long companyId, Long categoryId) {
        List<CategorySpecDefinitionRow> rows = categoryMapper.findSpecDefinitions(companyId, categoryId);
        if (rows.isEmpty()) {
            return List.of();
        }

        List<Long> specDefinitionIds = rows.stream()
                .map(CategorySpecDefinitionRow::specDefinitionId)
                .toList();
        Map<Long, List<CategorySpecOptionResponse>> optionsByDefinitionId = categoryMapper.findSpecOptions(specDefinitionIds)
                .stream()
                .collect(Collectors.groupingBy(CategorySpecOptionResponse::specDefinitionId));

        List<CategorySpecDefinitionResponse> responses = new ArrayList<>();
        for (CategorySpecDefinitionRow row : rows) {
            responses.add(CategorySpecDefinitionResponse.of(
                    row,
                    optionsByDefinitionId.getOrDefault(row.specDefinitionId(), List.of())
            ));
        }
        return responses;
    }

    private void validateCompanyActive(Long companyId) {
        if (!categoryMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
    }

    private String normalizeRequired(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeInputType(String value) {
        String inputType = normalizeOptional(value);
        if (inputType == null) {
            return "TEXT";
        }
        inputType = inputType.toUpperCase(Locale.ROOT);
        if (!SPEC_INPUT_TYPES.contains(inputType)) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "스펙 입력 방식이 올바르지 않습니다.");
        }
        return inputType;
    }

    private String normalizeSpecKey(String value, int index) {
        String specKey = normalizeOptional(value);
        if (specKey == null) {
            return "spec_" + (index + 1);
        }

        specKey = specKey.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9_-]", "_")
                .replaceAll("_+", "_")
                .replaceAll("^_|_$", "");
        if (specKey.isBlank()) {
            return "spec_" + (index + 1);
        }
        return specKey;
    }

    private int normalizeSortOrder(Integer sortOrder, int index) {
        if (sortOrder == null) {
            return index;
        }
        if (sortOrder < 0) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "정렬 순서는 0 이상이어야 합니다.");
        }
        return sortOrder;
    }

    private int normalizePage(Integer page) {
        if (page == null || page < 0) {
            return 0;
        }
        return page;
    }

    private int normalizeSize(Integer size, Integer limit) {
        Integer requestedSize = size == null ? limit : size;
        if (requestedSize == null || requestedSize < 1) {
            return DEFAULT_SIZE;
        }
        return Math.min(requestedSize, MAX_SIZE);
    }
}
