package com.pcs.domain.partner.api;

import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.facade.PartnerFacade;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
    public ResponseEntity<ApiResultDto<PageResultDto<SearchPartnerResponse, SearchPartnerSummaryResponse>>> searchPartners(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) PartnerType partnerType,
            @RequestParam(required = false) PartnerRole partnerRole,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchPartnerResponse, SearchPartnerSummaryResponse> response = partnerFacade.searchPartners(
                principal,
                companyCode,
                keyword,
                partnerType,
                partnerRole,
                active,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }
}
