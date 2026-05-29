package com.pcs.domain.partner.api;

import com.pcs.domain.partner.dto.request.CreatePartnerRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerActiveRequest;
import com.pcs.domain.partner.dto.request.UpdatePartnerRequest;
import com.pcs.domain.partner.dto.response.SearchPartnerResponse;
import com.pcs.domain.partner.dto.response.SearchPartnerSummaryResponse;
import com.pcs.domain.partner.facade.PartnerFacade;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.partner.type.PartnerType;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
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

    @PostMapping("/workspaces/{companyCode}/partners")
    public ResponseEntity<ApiResultDto<SearchPartnerResponse>> createPartner(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreatePartnerRequest request
    ) {
        SearchPartnerResponse response = partnerFacade.createPartner(principal, companyCode, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("거래처 등록이 완료되었습니다.", response));
    }

    @GetMapping("/workspaces/{companyCode}/partners/{partnerId}")
    public ResponseEntity<ApiResultDto<SearchPartnerResponse>> getPartner(
            @PathVariable String companyCode,
            @PathVariable Long partnerId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        SearchPartnerResponse response = partnerFacade.getPartner(principal, companyCode, partnerId);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PatchMapping("/workspaces/{companyCode}/partners/{partnerId}")
    public ResponseEntity<ApiResultDto<SearchPartnerResponse>> updatePartner(
            @PathVariable String companyCode,
            @PathVariable Long partnerId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdatePartnerRequest request
    ) {
        SearchPartnerResponse response = partnerFacade.updatePartner(principal, companyCode, partnerId, request);
        return ResponseEntity.ok(ApiResultDto.ok("거래처 수정이 완료되었습니다.", response));
    }

    @PatchMapping("/workspaces/{companyCode}/partners/{partnerId}/active")
    public ResponseEntity<ApiResultDto<Void>> updatePartnerActive(
            @PathVariable String companyCode,
            @PathVariable Long partnerId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdatePartnerActiveRequest request
    ) {
        partnerFacade.updatePartnerActive(principal, companyCode, partnerId, request);
        return ResponseEntity.ok(ApiResultDto.ok("거래 상태가 변경되었습니다.", null));
    }
}
