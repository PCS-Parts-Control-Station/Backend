package com.pcs.domain.company.mapper;

import com.pcs.domain.company.entity.Company;
import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CompanyMapper {

    boolean existsByCompanyCode(String companyCode);

    WorkspacePublicInfoResponse findPublicInfoByCompanyCode(String companyCode);

    void insert(Company company);
}
