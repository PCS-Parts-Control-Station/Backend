package com.pcs.domain.dashboard.mapper;

import com.pcs.domain.dashboard.dto.response.DashboardRecentActivityResponse;
import com.pcs.domain.dashboard.dto.response.DashboardOverviewRow;
import com.pcs.domain.dashboard.dto.response.DashboardTodoResponse;
import java.time.LocalDateTime;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface DashboardMapper {

    DashboardOverviewRow summarizeOverview(
            @Param("companyId") Long companyId,
            @Param("todayStart") LocalDateTime todayStart,
            @Param("tomorrowStart") LocalDateTime tomorrowStart
    );

    List<DashboardTodoResponse> findTodos(
            @Param("companyId") Long companyId,
            @Param("size") int size
    );

    List<DashboardRecentActivityResponse> findRecentActivities(
            @Param("companyId") Long companyId,
            @Param("size") int size
    );
}
