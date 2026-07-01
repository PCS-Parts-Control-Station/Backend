package com.pcs.domain.partner.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.partner.dto.request.CreatePartnerRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.entity.Partner;
import com.pcs.domain.partner.mapper.PartnerMapper;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PartnerServiceTest {

    @Mock
    private PartnerMapper partnerMapper;
    @Mock
    private WorkspaceAccessValidator workspaceAccessValidator;

    private PartnerService partnerService;

    @BeforeEach
    void setUp() {
        partnerService = new PartnerService(partnerMapper, workspaceAccessValidator);
    }

    @Test
    void searchPartners_appliesFiltersPaginationAndSummary() {
        Long companyId = 1L;
        SearchPartnerResponse partner = partnerResponse(10L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, true);
        SearchPartnerSummaryResponse summary = new SearchPartnerSummaryResponse(1, 1, 0, 1);

        when(partnerMapper.countPartners(companyId, "Yongsan", PartnerType.COMPANY, PartnerRole.SUPPLIER, true))
                .thenReturn(1L);
        when(partnerMapper.searchPartners(companyId, "Yongsan", PartnerType.COMPANY, PartnerRole.SUPPLIER, true, 10, 10))
                .thenReturn(List.of(partner));
        when(partnerMapper.summarizePartners(companyId, "Yongsan", PartnerType.COMPANY, PartnerRole.SUPPLIER, true))
                .thenReturn(summary);

        var response = partnerService.searchPartners(
                companyId,
                " Yongsan ",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                true,
                1,
                10,
                null
        );

        assertThat(response.content()).containsExactly(partner);
        assertThat(response.page()).isEqualTo(1);
        assertThat(response.size()).isEqualTo(10);
        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.summary()).isEqualTo(summary);
    }

    @Test
    void searchPartners_skipsListQueryWhenNoRowsAndCapsLimit() {
        Long companyId = 1L;
        SearchPartnerSummaryResponse summary = new SearchPartnerSummaryResponse(0, 0, 0, 0);

        when(partnerMapper.countPartners(companyId, null, null, PartnerRole.SUPPLIER, true)).thenReturn(0L);
        when(partnerMapper.summarizePartners(companyId, null, null, PartnerRole.SUPPLIER, true)).thenReturn(summary);

        var response = partnerService.searchPartners(companyId, " ", null, PartnerRole.SUPPLIER, true, null, null, 500);

        assertThat(response.content()).isEmpty();
        assertThat(response.page()).isZero();
        assertThat(response.size()).isEqualTo(100);
        verify(partnerMapper, never()).searchPartners(companyId, null, null, PartnerRole.SUPPLIER, true, 100, 0);
    }

    @Test
    void searchPartners_failsWhenCompanyInactive() {
        Long companyId = 1L;
        doThrow(new BusinessException(ErrorCode.COMPANY_INACTIVE))
                .when(workspaceAccessValidator).validateCompanyActive(companyId);

        assertThatThrownBy(() -> partnerService.searchPartners(companyId, null, null, null, null, 0, 10, null))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.COMPANY_INACTIVE);
    }

    @Test
    void createPartner_defaultsActiveAndStoresNormalizedValues() {
        Long companyId = 1L;
        Long memberId = 7L;
        CreatePartnerRequest request = new CreatePartnerRequest(
                " Yongsan Parts ",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                " 010-1234-5678 ",
                " ",
                " Seoul ",
                null,
                null
        );

        when(partnerMapper.existsByName(companyId, "Yongsan Parts", null)).thenReturn(false);
        doAnswer(invocation -> {
            Partner partner = invocation.getArgument(0);
            partner.setPartnerId(10L);
            return null;
        }).when(partnerMapper).insert(any(Partner.class));
        when(partnerMapper.findResponseById(companyId, 10L))
                .thenReturn(partnerResponse(10L, "Yongsan Parts", PartnerType.COMPANY, PartnerRole.SUPPLIER, true));

        SearchPartnerResponse response = partnerService.createPartner(companyId, request, memberId);

        ArgumentCaptor<Partner> captor = ArgumentCaptor.forClass(Partner.class);
        verify(partnerMapper).insert(captor.capture());
        Partner saved = captor.getValue();
        assertThat(saved.getPartnerName()).isEqualTo("Yongsan Parts");
        assertThat(saved.getPhone()).isEqualTo("010-1234-5678");
        assertThat(saved.getEmail()).isNull();
        assertThat(saved.getAddress()).isEqualTo("Seoul");
        assertThat(saved.isActive()).isTrue();
        assertThat(saved.getCreatedBy()).isEqualTo(memberId);
        assertThat(response.partnerId()).isEqualTo(10L);
    }

    @Test
    void createPartner_rejectsDuplicateNameInSameCompany() {
        Long companyId = 1L;
        CreatePartnerRequest request = new CreatePartnerRequest(
                "Yongsan Parts",
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                null,
                null,
                null,
                null,
                true
        );
        when(partnerMapper.existsByName(companyId, "Yongsan Parts", null)).thenReturn(true);

        assertThatThrownBy(() -> partnerService.createPartner(companyId, request, 7L))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PARTNER_NAME_DUPLICATED);

        verify(partnerMapper, never()).insert(any(Partner.class));
    }

    @Test
    void updatePartner_preservesActiveWhenRequestOmitsActive() {
        Long companyId = 1L;
        Long partnerId = 10L;
        Partner existing = partnerEntity(companyId, partnerId, "Old Partner", false);
        UpdatePartnerRequest request = new UpdatePartnerRequest(
                " New Partner ",
                PartnerType.PERSON,
                PartnerRole.CUSTOMER,
                null,
                null,
                null,
                " memo ",
                null
        );

        when(partnerMapper.findById(companyId, partnerId)).thenReturn(existing);
        when(partnerMapper.existsByName(companyId, "New Partner", partnerId)).thenReturn(false);
        when(partnerMapper.findResponseById(companyId, partnerId))
                .thenReturn(partnerResponse(partnerId, "New Partner", PartnerType.PERSON, PartnerRole.CUSTOMER, false));

        SearchPartnerResponse response = partnerService.updatePartner(companyId, partnerId, request);

        ArgumentCaptor<Partner> captor = ArgumentCaptor.forClass(Partner.class);
        verify(partnerMapper).update(captor.capture());
        assertThat(captor.getValue().getPartnerName()).isEqualTo("New Partner");
        assertThat(captor.getValue().getMemo()).isEqualTo("memo");
        assertThat(captor.getValue().isActive()).isFalse();
        assertThat(response.active()).isFalse();
    }

    @Test
    void updatePartner_changesActiveWhenRequestIncludesActive() {
        Long companyId = 1L;
        Long partnerId = 10L;
        Partner existing = partnerEntity(companyId, partnerId, "Old Partner", false);
        UpdatePartnerRequest request = new UpdatePartnerRequest(
                "Old Partner",
                PartnerType.COMPANY,
                PartnerRole.BOTH,
                null,
                null,
                null,
                null,
                true
        );

        when(partnerMapper.findById(companyId, partnerId)).thenReturn(existing);
        when(partnerMapper.existsByName(companyId, "Old Partner", partnerId)).thenReturn(false);
        when(partnerMapper.findResponseById(companyId, partnerId))
                .thenReturn(partnerResponse(partnerId, "Old Partner", PartnerType.COMPANY, PartnerRole.BOTH, true));

        SearchPartnerResponse response = partnerService.updatePartner(companyId, partnerId, request);

        ArgumentCaptor<Partner> captor = ArgumentCaptor.forClass(Partner.class);
        verify(partnerMapper).update(captor.capture());
        assertThat(captor.getValue().isActive()).isTrue();
        assertThat(response.active()).isTrue();
    }

    @Test
    void updatePartnerActive_failsWhenPartnerMissing() {
        Long companyId = 1L;
        Long partnerId = 99L;
        when(partnerMapper.findById(companyId, partnerId)).thenReturn(null);

        assertThatThrownBy(() -> partnerService.updatePartnerActive(companyId, partnerId, false))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(ErrorCode.PARTNER_NOT_FOUND);

        verify(partnerMapper, never()).updateActive(companyId, partnerId, false);
    }

    private SearchPartnerResponse partnerResponse(
            Long partnerId,
            String partnerName,
            PartnerType partnerType,
            PartnerRole partnerRole,
            boolean active
    ) {
        return new SearchPartnerResponse(
                partnerId,
                partnerName,
                partnerType,
                partnerRole,
                "010-1234-5678",
                null,
                null,
                null,
                active,
                LocalDateTime.of(2026, 6, 1, 10, 0)
        );
    }

    private Partner partnerEntity(Long companyId, Long partnerId, String partnerName, boolean active) {
        Partner partner = new Partner(
                companyId,
                partnerName,
                PartnerType.COMPANY,
                PartnerRole.SUPPLIER,
                null,
                null,
                null,
                null,
                7L
        );
        partner.setPartnerId(partnerId);
        partner.setActive(active);
        return partner;
    }
}
