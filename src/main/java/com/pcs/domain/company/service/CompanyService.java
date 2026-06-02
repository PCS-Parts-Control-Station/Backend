package com.pcs.domain.company.service;

import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import com.pcs.domain.company.entity.Company;
import com.pcs.domain.company.mapper.CompanyMapper;
import org.springframework.stereotype.Service;

@Service
public class CompanyService {

    private final CompanyMapper companyMapper;

    public CompanyService(CompanyMapper companyMapper) {
        this.companyMapper = companyMapper;
    }

    public boolean existsByCompanyCode(String companyCode) {
        return companyMapper.existsByCompanyCode(companyCode);
    }

    public WorkspacePublicInfoResponse findPublicInfoByCompanyCode(String companyCode) {
        return companyMapper.findPublicInfoByCompanyCode(companyCode);
    }

    public void create(Company company) {
        companyMapper.insert(company);
    }
}
