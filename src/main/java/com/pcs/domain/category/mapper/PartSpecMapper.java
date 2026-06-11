package com.pcs.domain.category.mapper;

import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PartSpecMapper {

    List<CategorySpecDefinitionRow> findDefinitionsByCategory(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    List<CategorySpecOptionResponse> findOptionsByDefinitionIds(
            @Param("specDefinitionIds") List<Long> specDefinitionIds
    );
}
