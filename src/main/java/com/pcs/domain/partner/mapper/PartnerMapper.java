package com.pcs.domain.partner.mapper;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PartnerMapper {

    List<SearchPartnerResponse> searchPartners(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partnerType") PartnerType partnerType,
            @Param("partnerRole") PartnerRole partnerRole,
            @Param("active") Boolean active,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countPartners(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partnerType") PartnerType partnerType,
            @Param("partnerRole") PartnerRole partnerRole,
            @Param("active") Boolean active
    );

    SearchPartnerSummaryResponse summarizePartners(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partnerType") PartnerType partnerType,
            @Param("partnerRole") PartnerRole partnerRole,
            @Param("active") Boolean active
    );

    com.pcs.domain.partner.entity.Partner findById(@Param("companyId") Long companyId, @Param("partnerId") Long partnerId);

    SearchPartnerResponse findResponseById(@Param("companyId") Long companyId, @Param("partnerId") Long partnerId);

    void insert(com.pcs.domain.partner.entity.Partner partner);

    void update(com.pcs.domain.partner.entity.Partner partner);

    void updateActive(
            @Param("companyId") Long companyId,
            @Param("partnerId") Long partnerId,
            @Param("active") boolean active
    );

    boolean existsByName(
            @Param("companyId") Long companyId,
            @Param("partnerName") String partnerName,
            @Param("excludePartnerId") Long excludePartnerId
    );
}
