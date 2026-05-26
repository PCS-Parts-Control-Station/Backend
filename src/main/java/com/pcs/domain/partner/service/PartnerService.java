package com.pcs.domain.partner.service;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.mapper.PartnerMapper;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class PartnerService {

    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_LIMIT = 100;

    private final PartnerMapper partnerMapper;

    public PartnerService(PartnerMapper partnerMapper) {
        this.partnerMapper = partnerMapper;
    }

    public List<SearchPartnerResponse> searchPartners(
            Long companyId,
            String keyword,
            PartnerRole partnerRole,
            Boolean active,
            Integer limit
    ) {
        if (!partnerMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        return partnerMapper.searchPartners(
                companyId,
                normalizeOptional(keyword),
                partnerRole,
                active == null ? Boolean.TRUE : active,
                normalizeLimit(limit)
        );
    }

    private String normalizeOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private int normalizeLimit(Integer limit) {
        if (limit == null || limit < 1) {
            return DEFAULT_LIMIT;
        }
        return Math.min(limit, MAX_LIMIT);
    }
}
