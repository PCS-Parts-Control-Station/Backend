package com.pcs.domain.part.service;

import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.mapper.PartMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class PartService {

    private static final int DEFAULT_LIMIT = 20;
    private static final int MAX_LIMIT = 50;

    private final PartMapper partMapper;

    public PartService(PartMapper partMapper) {
        this.partMapper = partMapper;
    }

    public List<SearchPartResponse> searchParts(
            Long companyId,
            String keyword,
            Long categoryId,
            Boolean active,
            Integer limit
    ) {
        if (!partMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        return partMapper.searchParts(
                companyId,
                normalizeOptional(keyword),
                categoryId,
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
        if (limit == null) {
            return DEFAULT_LIMIT;
        }
        if (limit < 1) {
            return DEFAULT_LIMIT;
        }
        return Math.min(limit, MAX_LIMIT);
    }
}
