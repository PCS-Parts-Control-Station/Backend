package com.pcs.domain.partner.api;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.facade.PartnerFacade;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.global.dto.ApiResultDto;
import java.util.List;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class PartnerApiController {

    private final PartnerFacade partnerFacade;

    public PartnerApiController(PartnerFacade partnerFacade) {
        this.partnerFacade = partnerFacade;
    }

    @GetMapping("/workspaces/{companyCode}/partners")
    public ResponseEntity<ApiResultDto<List<SearchPartnerResponse>>> searchPartners(
            @PathVariable String companyCode,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) PartnerRole partnerRole,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) Integer limit
    ) {
        List<SearchPartnerResponse> response = partnerFacade.searchPartners(
                authorizationHeader,
                companyCode,
                keyword,
                partnerRole,
                active,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }
}
