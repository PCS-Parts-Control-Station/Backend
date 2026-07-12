package com.pcs.domain.part.mapper;

import com.pcs.domain.part.dto.response.PartSpecValueResponse;
import com.pcs.domain.part.dto.response.PartUnitInspectionHistoryResponse;
import com.pcs.domain.part.dto.response.PartUnitStockHistoryResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.dto.response.SearchPartSummaryResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitSummaryResponse;
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

    SearchPartSummaryResponse summarizeParts(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active
    );

    List<SearchPartUnitResponse> searchPartUnits(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partId") Long partId,
            @Param("documentId") Long documentId,
            @Param("categoryId") Long categoryId,
            @Param("partState") String partState,
            @Param("size") int size,
            @Param("offset") int offset
    );

    SearchPartUnitSummaryResponse summarizePartUnits(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partId") Long partId,
            @Param("documentId") Long documentId,
            @Param("categoryId") Long categoryId,
            @Param("partState") String partState
    );

    SearchPartUnitResponse findPartUnitById(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId
    );

    List<PartUnitStockHistoryResponse> findPartUnitStockHistories(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId,
            @Param("size") int size
    );

    List<PartUnitInspectionHistoryResponse> findPartUnitInspectionHistories(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId,
            @Param("size") int size
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
