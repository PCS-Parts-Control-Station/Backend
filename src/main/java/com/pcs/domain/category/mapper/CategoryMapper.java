package com.pcs.domain.category.mapper;

import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.entity.PartCategory;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface CategoryMapper {

    boolean isCompanyActive(@Param("companyId") Long companyId);

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

    long countPartsByCategory(
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
