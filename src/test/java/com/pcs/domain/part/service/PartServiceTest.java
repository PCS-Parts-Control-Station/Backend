package com.pcs.domain.part.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.category.mapper.PartSpecMapper;
import com.pcs.domain.part.dto.request.CreatePartRequest;
import com.pcs.domain.part.dto.request.PartSpecValueRequest;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.dto.response.PartSpecValueResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.dto.response.SearchPartSummaryResponse;
import com.pcs.domain.part.entity.PartSpecValue;
import com.pcs.domain.part.entity.PcPart;
import com.pcs.domain.part.mapper.PartMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PartServiceTest {

    private static final Long COMPANY_ID = 1L;
    private static final Long MEMBER_ID = 7L;
    private static final Long CATEGORY_ID = 10L;

    @Mock
    private PartMapper partMapper;
    @Mock
    private PartSpecMapper partSpecMapper;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private PartService partService;

    @BeforeEach
    void setUp() {
        partService = new PartService(partMapper, partSpecMapper, workspaceAccessValidator);
    }

    @Test
    void searchParts_usesDefaultActiveAndLimit() {
        SearchPartResponse part = partResponse(1L, "RTX 3060", "VGA-RTX3060-MSI-001", true, 2);
        when(partMapper.countParts(COMPANY_ID, "RTX", null, true)).thenReturn(1L);
        when(partMapper.searchParts(COMPANY_ID, "RTX", null, true, 10, 0)).thenReturn(List.of(part));
        when(partMapper.summarizeParts(COMPANY_ID, "RTX", null, true))
                .thenReturn(new SearchPartSummaryResponse(1, 2, 1));

        var response = partService.searchParts(COMPANY_ID, " RTX ", null, null, null, null, null);

        assertThat(response.content()).containsExactly(part);
        assertThat(response.page()).isZero();
        assertThat(response.size()).isEqualTo(10);
        assertThat(response.summary().totalCount()).isEqualTo(1);
        assertThat(response.summary().totalStock()).isEqualTo(2);
        assertThat(response.summary().lowStockCount()).isEqualTo(1);
        verify(partMapper).searchParts(COMPANY_ID, "RTX", null, true, 10, 0);
    }

    @Test
    void searchParts_capsLimitToMaxSize() {
        when(partMapper.countParts(COMPANY_ID, null, CATEGORY_ID, false)).thenReturn(1L);
        when(partMapper.searchParts(COMPANY_ID, null, CATEGORY_ID, false, 100, 100))
                .thenReturn(List.of(partResponse(1L, "RTX 3060", "CODE", false, 0)));
        when(partMapper.summarizeParts(COMPANY_ID, null, CATEGORY_ID, false))
                .thenReturn(new SearchPartSummaryResponse(1, 0, 1));

        partService.searchParts(COMPANY_ID, " ", CATEGORY_ID, false, 1, 200, null);

        verify(partMapper).searchParts(COMPANY_ID, null, CATEGORY_ID, false, 100, 100);
    }

    @Test
    void searchParts_failsWhenCompanyInactive() {
        doThrow(new BusinessException(ErrorCode.COMPANY_INACTIVE))
                .when(workspaceAccessValidator).validateCompanyActive(COMPANY_ID);

        assertThatThrownBy(() -> partService.searchParts(COMPANY_ID, null, null, true, null, 20, null))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.COMPANY_INACTIVE);
    }

    @Test
    void createPart_generatesPartCodeAndStoresNormalizedSpecValues() {
        stubCategoryAndDefinitions();
        stubPartInsert(20L);
        when(partMapper.existsPartCode(eq(COMPANY_ID), anyString(), isNull())).thenReturn(false);
        stubPartDetail(20L, "GPU-MSI-GAMING-001");

        CreatePartRequest request = new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                null,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 201L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null)
                )
        );

        partService.createPart(COMPANY_ID, request, MEMBER_ID);

        ArgumentCaptor<PcPart> partCaptor = ArgumentCaptor.forClass(PcPart.class);
        ArgumentCaptor<PartSpecValue> valueCaptor = ArgumentCaptor.forClass(PartSpecValue.class);
        verify(partMapper).insert(partCaptor.capture());
        verify(partMapper, org.mockito.Mockito.times(3)).insertSpecValue(valueCaptor.capture());

        PcPart insertedPart = partCaptor.getValue();
        assertThat(insertedPart.getPartCode()).isNotBlank();
        assertThat(insertedPart.getPartCode()).hasSizeLessThanOrEqualTo(80);
        assertThat(insertedPart.getSafeQuantity()).isZero();
        assertThat(valueCaptor.getAllValues())
                .extracting(PartSpecValue::getSpecDefinitionId)
                .containsExactly(101L, 102L, 103L);
        assertThat(valueCaptor.getAllValues().get(0).getSelectedOptionValueSnapshot()).isEqualTo("RTX_3060");
        assertThat(valueCaptor.getAllValues().get(2).getValueBoolean()).isFalse();
    }

    @Test
    void createPart_usesNextSequenceWhenGeneratedCodeAlreadyExists() {
        stubCategoryAndDefinitions();
        stubPartInsert(20L);
        when(partMapper.existsPartCode(eq(COMPANY_ID), anyString(), isNull()))
                .thenReturn(true)
                .thenReturn(false);
        stubPartDetail(20L, "CODE");

        CreatePartRequest request = createValidRequest();

        partService.createPart(COMPANY_ID, request, MEMBER_ID);

        ArgumentCaptor<PcPart> partCaptor = ArgumentCaptor.forClass(PcPart.class);
        verify(partMapper).insert(partCaptor.capture());
        assertThat(partCaptor.getValue().getPartCode()).endsWith("-002");
    }

    @Test
    void createPart_failsWhenRequiredSpecIsMissing() {
        stubCategoryAndDefinitions();
        CreatePartRequest request = new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                2,
                List.of(new PartSpecValueRequest(101L, null, null, null, 201L))
        );

        assertThatThrownBy(() -> partService.createPart(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        verify(partMapper, never()).insert(any(PcPart.class));
    }

    @Test
    void createPart_failsWhenSelectOptionDoesNotBelongToSpec() {
        stubCategoryAndDefinitions();
        CreatePartRequest request = new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                2,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 999L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null)
                )
        );

        assertThatThrownBy(() -> partService.createPart(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createPart_failsWhenSpecDefinitionValueIsDuplicated() {
        stubCategoryAndDefinitions();
        CreatePartRequest request = new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                2,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 201L),
                        new PartSpecValueRequest(101L, null, null, null, 202L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null)
                )
        );

        assertThatThrownBy(() -> partService.createPart(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createPart_failsWhenSpecDefinitionDoesNotBelongToCategory() {
        stubCategoryAndDefinitions();
        CreatePartRequest request = new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                2,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 201L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null),
                        new PartSpecValueRequest(999L, "bad", null, null, null)
                )
        );

        assertThatThrownBy(() -> partService.createPart(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void createPart_failsWhenSafeQuantityIsNegative() {
        stubCategoryAndDefinitions();
        CreatePartRequest request = new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                -1,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 201L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null)
                )
        );

        assertThatThrownBy(() -> partService.createPart(COMPANY_ID, request, MEMBER_ID))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void updatePart_replacesSpecValuesAndRegeneratesPartCode() {
        PcPart existing = new PcPart(COMPANY_ID, CATEGORY_ID, MEMBER_ID, "Old", "Old Model", "MSI", "OLD-001", 1);
        existing.setPartId(20L);
        when(partMapper.findById(COMPANY_ID, 20L)).thenReturn(existing);
        stubCategoryAndDefinitions();
        when(partMapper.existsPartCode(eq(COMPANY_ID), anyString(), eq(20L))).thenReturn(false);
        stubPartDetail(20L, "GPU-ASUS-GAMING-001");

        UpdatePartRequest request = new UpdatePartRequest(
                CATEGORY_ID,
                "RTX 4060",
                "ASUS",
                "DUAL RTX 4060",
                3,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 202L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("8"), null, null)
                )
        );

        partService.updatePart(COMPANY_ID, 20L, request);

        assertThat(existing.getPartName()).isEqualTo("RTX 4060");
        assertThat(existing.getManufacturer()).isEqualTo("ASUS");
        assertThat(existing.getSafeQuantity()).isEqualTo(3);
        assertThat(existing.getPartCode()).isNotEqualTo("OLD-001");

        InOrder inOrder = inOrder(partMapper);
        inOrder.verify(partMapper).update(existing);
        inOrder.verify(partMapper).deleteSpecValuesByPart(COMPANY_ID, 20L);
        inOrder.verify(partMapper, org.mockito.Mockito.times(3)).insertSpecValue(any(PartSpecValue.class));
    }

    @Test
    void updatePart_failsWhenPartDoesNotExist() {
        when(partMapper.findById(COMPANY_ID, 20L)).thenReturn(null);

        assertThatThrownBy(() -> partService.updatePart(COMPANY_ID, 20L, updateValidRequest()))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PART_NOT_FOUND);
    }

    private void stubCategoryAndDefinitions() {
        when(partMapper.findCategoryName(COMPANY_ID, CATEGORY_ID)).thenReturn("GPU");
        when(partSpecMapper.findDefinitionsByCategory(COMPANY_ID, CATEGORY_ID)).thenReturn(List.of(
                definition(101L, "gpu_chip", "GPU chip", "SELECT", null, true, true, 0),
                definition(102L, "memory_gb", "Memory", "NUMBER", "GB", true, true, 1),
                definition(103L, "rgb", "RGB", "BOOLEAN", null, false, false, 2)
        ));
        when(partSpecMapper.findOptionsByDefinitionIds(List.of(101L, 102L, 103L))).thenReturn(List.of(
                option(201L, 101L, "RTX 3060", "RTX_3060", 0),
                option(202L, 101L, "RTX 4060", "RTX_4060", 1)
        ));
    }

    private void stubPartInsert(Long partId) {
        doAnswer(invocation -> {
            PcPart part = invocation.getArgument(0);
            part.setPartId(partId);
            return null;
        }).when(partMapper).insert(any(PcPart.class));
    }

    private void stubPartDetail(Long partId, String partCode) {
        when(partMapper.findResponseById(COMPANY_ID, partId))
                .thenReturn(partResponse(partId, "RTX", partCode, true, 0));
        when(partMapper.findSpecValuesByPart(COMPANY_ID, partId)).thenReturn(List.of(
                new PartSpecValueResponse(1L, 101L, "gpu_chip", "GPU chip", "SELECT", null, null, null, null, 201L, "RTX 3060", "RTX_3060")
        ));
    }

    private CreatePartRequest createValidRequest() {
        return new CreatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                2,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 201L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null)
                )
        );
    }

    private UpdatePartRequest updateValidRequest() {
        return new UpdatePartRequest(
                CATEGORY_ID,
                "RTX 3060 Gaming",
                "MSI",
                "RTX 3060 Gaming X",
                2,
                List.of(
                        new PartSpecValueRequest(101L, null, null, null, 201L),
                        new PartSpecValueRequest(102L, null, new BigDecimal("12"), null, null)
                )
        );
    }

    private SearchPartResponse partResponse(Long partId, String partName, String partCode, boolean active, int stock) {
        return new SearchPartResponse(
                partId,
                CATEGORY_ID,
                "GPU",
                partName,
                "Model",
                "MSI",
                partCode,
                2,
                stock,
                active
        );
    }

    private CategorySpecDefinitionRow definition(
            Long id,
            String key,
            String name,
            String inputType,
            String unit,
            boolean required,
            boolean searchable,
            int sortOrder
    ) {
        return new CategorySpecDefinitionRow(id, CATEGORY_ID, key, name, inputType, unit, required, searchable, sortOrder, true);
    }

    private CategorySpecOptionResponse option(Long id, Long definitionId, String label, String value, int sortOrder) {
        return new CategorySpecOptionResponse(id, definitionId, label, value, sortOrder, true);
    }
}
