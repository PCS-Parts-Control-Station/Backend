package com.pcs.domain.part.mapper;

import com.pcs.domain.category.dto.response.CategorySpecDefinitionRow;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.part.dto.response.PartSpecValueResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.entity.PartSpecValue;
import com.pcs.domain.part.entity.PcPart;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PartMapper {

    List<SearchPartResponse> searchParts(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countParts(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active
    );

    PcPart findById(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId
    );

    SearchPartResponse findResponseById(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId
    );

    String findCategoryName(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    boolean existsPartCode(
            @Param("companyId") Long companyId,
            @Param("partCode") String partCode,
            @Param("excludePartId") Long excludePartId
    );

    void insert(PcPart part);

    void update(PcPart part);

    List<CategorySpecDefinitionRow> findSpecDefinitionsByCategory(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    List<CategorySpecOptionResponse> findSpecOptions(
            @Param("specDefinitionIds") List<Long> specDefinitionIds
    );

    List<PartSpecValueResponse> findSpecValuesByPart(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId
    );

    void insertSpecValue(PartSpecValue specValue);

    int deleteSpecValuesByPart(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId
    );
}
