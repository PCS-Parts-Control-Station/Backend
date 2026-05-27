package com.pcs.domain.part.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.part.mapper.PartMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
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

    private PartService partService;

    @BeforeEach
    void setUp() {
        partService = new PartService(partMapper);
    }

    @Test
    void searchParts_usesDefaultActiveAndLimit() {
        Long companyId = 1L;
        when(partMapper.isCompanyActive(companyId)).thenReturn(true);
        when(partMapper.searchParts(companyId, "RTX", null, true, 20)).thenReturn(List.of());

        List<?> response = partService.searchParts(companyId, " RTX ", null, null, null);

        assertEquals(0, response.size());
        verify(partMapper).searchParts(companyId, "RTX", null, true, 20);
    }

    @Test
    void searchParts_capsLimitToMax() {
        Long companyId = 1L;
        when(partMapper.isCompanyActive(companyId)).thenReturn(true);
        when(partMapper.searchParts(companyId, null, 3L, false, 50)).thenReturn(List.of());

        partService.searchParts(companyId, " ", 3L, false, 100);

        verify(partMapper).searchParts(companyId, null, 3L, false, 50);
    }

    @Test
    void searchParts_failsWhenCompanyInactive() {
        Long companyId = 1L;
        when(partMapper.isCompanyActive(companyId)).thenReturn(false);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partService.searchParts(companyId, null, null, true, 20)
        );

        assertEquals(ErrorCode.COMPANY_INACTIVE, exception.getErrorCode());
    }
}
