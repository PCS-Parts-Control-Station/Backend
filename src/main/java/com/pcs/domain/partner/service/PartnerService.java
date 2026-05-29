package com.pcs.domain.partner.service;

import com.pcs.domain.partner.dto.request.CreatePartnerRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.entity.Partner;
import com.pcs.domain.partner.mapper.PartnerMapper;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PartnerService {

    private static final int DEFAULT_SIZE = 20;
    private static final int MAX_SIZE = 100;

    private final PartnerMapper partnerMapper;

    public PartnerService(PartnerMapper partnerMapper) {
        this.partnerMapper = partnerMapper;
    }

    public PageResultDto<SearchPartnerResponse, SearchPartnerSummaryResponse> searchPartners(
            Long companyId,
            String keyword,
            PartnerType partnerType,
            PartnerRole partnerRole,
            Boolean active,
            Integer page,
            Integer size,
            Integer limit
    ) {
        if (!partnerMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        String normalizedKeyword = normalizeOptional(keyword);
        int normalizedPage = normalizePage(page);
        int normalizedSize = normalizeSize(size, limit);
        int offset = normalizedPage * normalizedSize;
        long totalElements = partnerMapper.countPartners(
                companyId,
                normalizedKeyword,
                partnerType,
                partnerRole,
                active
        );
        List<SearchPartnerResponse> items = totalElements == 0
                ? List.of()
                : partnerMapper.searchPartners(
                        companyId,
                        normalizedKeyword,
                        partnerType,
                        partnerRole,
                        active,
                        normalizedSize,
                        offset
                );
        SearchPartnerSummaryResponse summary = partnerMapper.summarizePartners(
                companyId,
                normalizedKeyword,
                partnerType,
                partnerRole,
                active
        );
        return PageResultDto.of(items, normalizedPage, normalizedSize, totalElements, summary);
    }

    private String normalizeOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
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

    @Transactional
    public SearchPartnerResponse createPartner(Long companyId, CreatePartnerRequest request, Long memberId) {
        if (!partnerMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        if (partnerMapper.existsByName(companyId, request.partnerName().trim(), null)) {
            throw new BusinessException(ErrorCode.PARTNER_NAME_DUPLICATED);
        }

        Partner partner = new Partner(
                companyId,
                request.partnerName().trim(),
                request.partnerType(),
                request.partnerRole(),
                request.phone(),
                request.email(),
                request.address(),
                request.memo(),
                memberId
        );
        partnerMapper.insert(partner);

        return partnerMapper.findResponseById(companyId, partner.getPartnerId());
    }

    public SearchPartnerResponse getPartner(Long companyId, Long partnerId) {
        if (!partnerMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        SearchPartnerResponse response = partnerMapper.findResponseById(companyId, partnerId);
        if (response == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }
        return response;
    }

    @Transactional
    public SearchPartnerResponse updatePartner(Long companyId, Long partnerId, UpdatePartnerRequest request) {
        if (!partnerMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        Partner partner = partnerMapper.findById(companyId, partnerId);
        if (partner == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }

        if (partnerMapper.existsByName(companyId, request.partnerName().trim(), partnerId)) {
            throw new BusinessException(ErrorCode.PARTNER_NAME_DUPLICATED);
        }

        partner.setPartnerName(request.partnerName().trim());
        partner.setPartnerType(request.partnerType());
        partner.setPartnerRole(request.partnerRole());
        partner.setPhone(request.phone());
        partner.setEmail(request.email());
        partner.setAddress(request.address());
        partner.setMemo(request.memo());

        partnerMapper.update(partner);

        return partnerMapper.findResponseById(companyId, partnerId);
    }

    @Transactional
    public void updatePartnerActive(Long companyId, Long partnerId, boolean active) {
        if (!partnerMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        Partner partner = partnerMapper.findById(companyId, partnerId);
        if (partner == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }

        partnerMapper.updateActive(companyId, partnerId, active);
    }
}
