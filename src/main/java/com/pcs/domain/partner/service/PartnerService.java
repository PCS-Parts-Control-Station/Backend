package com.pcs.domain.partner.service;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.mapper.PartnerMapper;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.util.List;
import org.springframework.stereotype.Service;

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
}
