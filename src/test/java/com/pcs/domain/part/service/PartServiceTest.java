package com.pcs.domain.part.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.category.mapper.PartSpecMapper;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.mapper.PartMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PartServiceTest {

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
        Long companyId = 1L;
        when(partMapper.countParts(companyId, "RTX", null, true)).thenReturn(1L);
        when(partMapper.searchParts(companyId, "RTX", null, true, 10, 0)).thenReturn(List.of(part()));

        var response = partService.searchParts(companyId, " RTX ", null, null, null, null, null);

        assertEquals(1, response.content().size());
        assertEquals(0, response.page());
        assertEquals(10, response.size());
        verify(partMapper).searchParts(companyId, "RTX", null, true, 10, 0);
    }

    @Test
    void searchParts_capsLimitToMax() {
        Long companyId = 1L;
        when(partMapper.countParts(companyId, null, 3L, false)).thenReturn(1L);
        when(partMapper.searchParts(companyId, null, 3L, false, 100, 100)).thenReturn(List.of(part()));

        partService.searchParts(companyId, " ", 3L, false, 1, 200, null);

        verify(partMapper).searchParts(companyId, null, 3L, false, 100, 100);
    }

    @Test
    void searchParts_failsWhenCompanyInactive() {
        Long companyId = 1L;
        doThrow(new BusinessException(ErrorCode.COMPANY_INACTIVE))
                .when(workspaceAccessValidator).validateCompanyActive(companyId);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partService.searchParts(companyId, null, null, true, null, 20, null)
        );

        assertEquals(ErrorCode.COMPANY_INACTIVE, exception.getErrorCode());
    }

    private SearchPartResponse part() {
        return new SearchPartResponse(
                1L,
                3L,
                "그래픽카드",
                "RTX 3060",
                "Ventus 2X",
                "MSI",
                "VGA-RTX3060-MSI",
                BigDecimal.valueOf(200000),
                2,
                1,
                true
        );
    }
}
