package com.pcs.domain.company.api;

import com.pcs.domain.company.dto.request.OwnerSignupRequest;
import com.pcs.domain.company.dto.request.UpdateOwnerCompanyRequest;
import com.pcs.domain.company.dto.response.OwnerCompanyResponse;
import com.pcs.domain.company.dto.response.OwnerSignupResponse;
import com.pcs.domain.company.facade.CompanyFacade;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.security.PcsPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/owners")
public class OwnerSignupApiController {

    private final CompanyFacade companyFacade;

    public OwnerSignupApiController(CompanyFacade companyFacade) {
        this.companyFacade = companyFacade;
    }

    @PostMapping("/signup")
    public ResponseEntity<ApiResultDto<OwnerSignupResponse>> signup(
            @Valid @RequestBody OwnerSignupRequest request
    ) {
        OwnerSignupResponse response = companyFacade.signupOwner(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("회사 등록이 완료되었습니다.", response));
    }

    @GetMapping("/company")
    public ResponseEntity<ApiResultDto<OwnerCompanyResponse>> getOwnerCompany(
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        OwnerCompanyResponse response = companyFacade.getOwnerCompany(principal);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PatchMapping("/company")
    public ResponseEntity<ApiResultDto<OwnerCompanyResponse>> updateOwnerCompany(
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdateOwnerCompanyRequest request
    ) {
        OwnerCompanyResponse response = companyFacade.updateOwnerCompany(principal, request);
        return ResponseEntity.ok(ApiResultDto.ok("회사 정보가 저장되었습니다.", response));
    }
}
