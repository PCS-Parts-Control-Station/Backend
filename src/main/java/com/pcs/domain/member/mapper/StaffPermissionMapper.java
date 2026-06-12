package com.pcs.domain.member.mapper;

import com.pcs.domain.member.type.StaffPermission;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface StaffPermissionMapper {

    List<StaffPermission> findDisabledPermissions(@Param("companyId") Long companyId);

    boolean existsDisabledPermission(
            @Param("companyId") Long companyId,
            @Param("permission") StaffPermission permission
    );

    int deleteDisabledPermissions(@Param("companyId") Long companyId);

    int insertDisabledPermissions(
            @Param("companyId") Long companyId,
            @Param("disabledPermissions") List<StaffPermission> disabledPermissions,
            @Param("disabledBy") Long disabledBy
    );
}
