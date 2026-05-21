package com.pcs.domain.company.api;

import com.pcs.domain.company.dto.request.OwnerSignupRequest;
import com.pcs.domain.company.dto.response.OwnerSignupResponse;
import com.pcs.domain.company.facade.CompanyFacade;
import com.pcs.global.dto.ApiResultDto;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
}
