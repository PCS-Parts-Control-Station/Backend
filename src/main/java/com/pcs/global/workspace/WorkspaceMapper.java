package com.pcs.global.workspace;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface WorkspaceMapper {

    boolean isCompanyActive(@Param("companyId") Long companyId);
}
