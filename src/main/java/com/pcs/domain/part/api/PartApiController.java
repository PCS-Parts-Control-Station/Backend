package com.pcs.domain.part.api;

import com.pcs.domain.part.dto.request.CreatePartRequest;
import com.pcs.domain.part.dto.request.UpdatePartRequest;
import com.pcs.domain.part.dto.response.PartDetailResponse;
import com.pcs.domain.part.dto.response.PartUnitDetailResponse;
import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.dto.response.SearchPartSummaryResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitSummaryResponse;
import com.pcs.domain.part.facade.PartFacade;
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
public class PartApiController {

    private final PartFacade partFacade;

    public PartApiController(PartFacade partFacade) {
        this.partFacade = partFacade;
    }

    @GetMapping("/workspaces/{companyCode}/parts")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchPartResponse, SearchPartSummaryResponse>>> searchParts(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchPartResponse, SearchPartSummaryResponse> response = partFacade.searchParts(
                principal,
                companyCode,
                keyword,
                categoryId,
                active,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/part-units")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse>>> searchPartUnits(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long partId,
            @RequestParam(required = false) Long documentId,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String partState,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse> response = partFacade.searchPartUnits(
                principal,
                companyCode,
                keyword,
                partId,
                documentId,
                categoryId,
                partState,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/parts")
    public ResponseEntity<ApiResultDto<PartDetailResponse>> createPart(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreatePartRequest request
    ) {
        PartDetailResponse response = partFacade.createPart(principal, companyCode, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("품목 등록이 완료되었습니다.", response));
    }

    @GetMapping("/workspaces/{companyCode}/parts/{partId}")
    public ResponseEntity<ApiResultDto<PartDetailResponse>> getPart(
            @PathVariable String companyCode,
            @PathVariable Long partId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        PartDetailResponse response = partFacade.getPart(principal, companyCode, partId);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/part-units/{unitId}")
    public ResponseEntity<ApiResultDto<PartUnitDetailResponse>> getPartUnit(
            @PathVariable String companyCode,
            @PathVariable Long unitId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        PartUnitDetailResponse response = partFacade.getPartUnit(principal, companyCode, unitId);
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PatchMapping("/workspaces/{companyCode}/parts/{partId}")
    public ResponseEntity<ApiResultDto<PartDetailResponse>> updatePart(
            @PathVariable String companyCode,
            @PathVariable Long partId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody UpdatePartRequest request
    ) {
        PartDetailResponse response = partFacade.updatePart(principal, companyCode, partId, request);
        return ResponseEntity.ok(ApiResultDto.ok("품목 수정이 완료되었습니다.", response));
    }
}
