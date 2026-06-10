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
import com.pcs.global.pagination.PageQuery;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PartnerService {

    private static final int DEFAULT_SIZE = 20;

    private final PartnerMapper partnerMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;

    public PartnerService(PartnerMapper partnerMapper, WorkspaceAccessValidator workspaceAccessValidator) {
        this.partnerMapper = partnerMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
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
        validateCompanyActive(companyId);

        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
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
                        pageQuery.size(),
                        pageQuery.offset()
                );
        SearchPartnerSummaryResponse summary = partnerMapper.summarizePartners(
                companyId,
                normalizedKeyword,
                partnerType,
                partnerRole,
                active
        );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    @Transactional
    public SearchPartnerResponse createPartner(Long companyId, CreatePartnerRequest request, Long memberId) {
        validateCompanyActive(companyId);
        String partnerName = TextNormalizer.required(request.partnerName());
        if (partnerMapper.existsByName(companyId, partnerName, null)) {
            throw new BusinessException(ErrorCode.PARTNER_NAME_DUPLICATED);
        }

        Partner partner = new Partner(
                companyId,
                partnerName,
                request.partnerType(),
                request.partnerRole(),
                TextNormalizer.optional(request.phone()),
                TextNormalizer.optional(request.email()),
                TextNormalizer.optional(request.address()),
                TextNormalizer.optional(request.memo()),
                memberId
        );
        partner.setActive(request.active() == null || request.active());
        partnerMapper.insert(partner);

        return partnerMapper.findResponseById(companyId, partner.getPartnerId());
    }

    public SearchPartnerResponse getPartner(Long companyId, Long partnerId) {
        validateCompanyActive(companyId);
        SearchPartnerResponse response = partnerMapper.findResponseById(companyId, partnerId);
        if (response == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }
        return response;
    }

    @Transactional
    public SearchPartnerResponse updatePartner(Long companyId, Long partnerId, UpdatePartnerRequest request) {
        validateCompanyActive(companyId);

        Partner partner = partnerMapper.findById(companyId, partnerId);
        if (partner == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }

        String partnerName = TextNormalizer.required(request.partnerName());
        if (partnerMapper.existsByName(companyId, partnerName, partnerId)) {
            throw new BusinessException(ErrorCode.PARTNER_NAME_DUPLICATED);
        }

        partner.setPartnerName(partnerName);
        partner.setPartnerType(request.partnerType());
        partner.setPartnerRole(request.partnerRole());
        partner.setPhone(TextNormalizer.optional(request.phone()));
        partner.setEmail(TextNormalizer.optional(request.email()));
        partner.setAddress(TextNormalizer.optional(request.address()));
        partner.setMemo(TextNormalizer.optional(request.memo()));
        if (request.active() != null) {
            partner.setActive(request.active());
        }

        partnerMapper.update(partner);

        return partnerMapper.findResponseById(companyId, partnerId);
    }

    @Transactional
    public void updatePartnerActive(Long companyId, Long partnerId, boolean active) {
        validateCompanyActive(companyId);

        Partner partner = partnerMapper.findById(companyId, partnerId);
        if (partner == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }

        partnerMapper.updateActive(companyId, partnerId, active);
    }

    private void validateCompanyActive(Long companyId) {
        workspaceAccessValidator.validateCompanyActive(companyId);
    }
}
