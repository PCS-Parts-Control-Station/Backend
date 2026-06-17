package com.pcs.domain.company.mapper;

import com.pcs.domain.company.dto.response.OwnerCompanyResponse;
import com.pcs.domain.company.entity.Company;
import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface CompanyMapper {

    boolean existsByCompanyCode(String companyCode);

    WorkspacePublicInfoResponse findPublicInfoByCompanyCode(String companyCode);

    void insert(Company company);

    OwnerCompanyResponse findOwnerCompanyById(Long companyId);

    int updateOwnerCompany(
            @Param("companyId") Long companyId,
            @Param("companyName") String companyName,
            @Param("representativeEmail") String representativeEmail,
            @Param("representativePhone") String representativePhone,
            @Param("businessRegistrationNo") String businessRegistrationNo
    );
}
