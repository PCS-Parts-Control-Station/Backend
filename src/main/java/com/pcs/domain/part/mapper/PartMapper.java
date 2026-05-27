package com.pcs.domain.part.mapper;

import com.pcs.domain.part.dto.response.SearchPartResponse;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PartMapper {

    boolean isCompanyActive(@Param("companyId") Long companyId);

    List<SearchPartResponse> searchParts(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active,
            @Param("limit") int limit
    );
}
