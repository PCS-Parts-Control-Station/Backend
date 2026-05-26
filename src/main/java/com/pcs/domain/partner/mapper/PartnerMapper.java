package com.pcs.domain.partner.mapper;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.type.PartnerRole;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PartnerMapper {

    boolean isCompanyActive(@Param("companyId") Long companyId);

    List<SearchPartnerResponse> searchPartners(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partnerRole") PartnerRole partnerRole,
            @Param("active") Boolean active,
            @Param("limit") int limit
    );
}
