package com.pcs.domain.part.api;

import com.pcs.domain.part.dto.response.SearchPartResponse;
import com.pcs.domain.part.facade.PartFacade;
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
public class PartApiController {

    private final PartFacade partFacade;

    public PartApiController(PartFacade partFacade) {
        this.partFacade = partFacade;
    }

    @GetMapping("/workspaces/{companyCode}/parts")
    public ResponseEntity<ApiResultDto<List<SearchPartResponse>>> searchParts(
            @PathVariable String companyCode,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) Integer limit
    ) {
        List<SearchPartResponse> response = partFacade.searchParts(
                authorizationHeader,
                companyCode,
                keyword,
                categoryId,
                active,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }
}
