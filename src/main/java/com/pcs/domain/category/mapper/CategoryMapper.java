package com.pcs.domain.category.mapper;

import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import com.pcs.domain.category.entity.PartSpecDefinition;
import com.pcs.domain.category.entity.PartSpecOption;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface CategoryMapper {

    List<SearchCategoryResponse> searchCategories(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countCategories(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword
    );

    PartCategory findById(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    SearchCategoryResponse findResponseById(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    void insert(PartCategory category);

    void update(PartCategory category);

    void insertSpecDefinition(PartSpecDefinition specDefinition);

    void insertSpecOption(PartSpecOption option);

    long countPartsByCategory(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    int deleteSpecValuesByCategory(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    int deleteSpecOptionsByCategory(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    int deleteSpecDefinitionsByCategory(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    int deleteById(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId
    );

    boolean existsByName(
            @Param("companyId") Long companyId,
            @Param("categoryName") String categoryName,
            @Param("excludeCategoryId") Long excludeCategoryId
    );
}
