package com.pcs.domain.partner.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.mapper.PartnerMapper;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.PageResultDto;
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
class PartnerServiceTest {

    @Mock
    private PartnerMapper partnerMapper;

    private PartnerService partnerService;

    @BeforeEach
    void setUp() {
        partnerService = new PartnerService(partnerMapper);
    }

    @Test
    void searchPartners_usesZeroBasedPageAndSizeWithoutDefaultActiveFilter() {
        Long companyId = 1L;
        SearchPartnerResponse partner = new SearchPartnerResponse(
                10L,
                "용산전자",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                "010-1234-5678",
                null,
                null,
                null,
                true,
                LocalDateTime.of(2026, 5, 27, 10, 0)
        );
        SearchPartnerSummaryResponse summary = new SearchPartnerSummaryResponse(1, 1, 0, 1);

        when(partnerMapper.isCompanyActive(companyId)).thenReturn(true);
        when(partnerMapper.countPartners(companyId, "용산", PartnerType.COMPANY, null, null)).thenReturn(1L);
        when(partnerMapper.searchPartners(companyId, "용산", PartnerType.COMPANY, null, null, 10, 0))
                .thenReturn(List.of(partner));
        when(partnerMapper.summarizePartners(companyId, "용산", PartnerType.COMPANY, null, null))
                .thenReturn(summary);

        PageResultDto<SearchPartnerResponse, SearchPartnerSummaryResponse> response = partnerService.searchPartners(
                companyId,
                " 용산 ",
                PartnerType.COMPANY,
                null,
                null,
                0,
                10,
                null
        );

        assertEquals(1, response.content().size());
        assertEquals(0, response.page());
        assertEquals(10, response.size());
        assertEquals(1, response.totalElements());
        verify(partnerMapper).searchPartners(companyId, "용산", PartnerType.COMPANY, null, null, 10, 0);
    }

    @Test
    void searchPartners_usesLimitAsSizeAliasAndCapsToMax() {
        Long companyId = 1L;
        SearchPartnerSummaryResponse summary = new SearchPartnerSummaryResponse(0, 0, 0, 0);

        when(partnerMapper.isCompanyActive(companyId)).thenReturn(true);
        when(partnerMapper.countPartners(companyId, null, null, PartnerRole.SUPPLIER, true)).thenReturn(0L);
        when(partnerMapper.summarizePartners(companyId, null, null, PartnerRole.SUPPLIER, true))
                .thenReturn(summary);

        PageResultDto<SearchPartnerResponse, SearchPartnerSummaryResponse> response = partnerService.searchPartners(
                companyId,
                " ",
                null,
                PartnerRole.SUPPLIER,
                true,
                null,
                null,
                500
        );

        assertEquals(0, response.page());
        assertEquals(100, response.size());
        assertTrue(response.content().isEmpty());
        verify(partnerMapper, never()).searchPartners(companyId, null, null, PartnerRole.SUPPLIER, true, 100, 0);
    }

    @Test
    void searchPartners_failsWhenCompanyInactive() {
        Long companyId = 1L;
        when(partnerMapper.isCompanyActive(companyId)).thenReturn(false);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partnerService.searchPartners(companyId, null, null, null, null, 0, 10, null)
        );

        assertEquals(ErrorCode.COMPANY_INACTIVE, exception.getErrorCode());
    }
}
