package com.pcs.domain.company.api;

import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import com.pcs.domain.company.facade.CompanyFacade;
import com.pcs.global.dto.ApiResultDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class WorkspacePublicApiController {

    private final CompanyFacade companyFacade;

    public WorkspacePublicApiController(CompanyFacade companyFacade) {
        this.companyFacade = companyFacade;
    }

    @GetMapping("/workspaces/{companyCode}/public-info")
    public ResponseEntity<ApiResultDto<WorkspacePublicInfoResponse>> publicInfo(
            @PathVariable String companyCode
    ) {
        return ResponseEntity.ok(ApiResultDto.ok(companyFacade.findWorkspacePublicInfo(companyCode)));
    }
}
