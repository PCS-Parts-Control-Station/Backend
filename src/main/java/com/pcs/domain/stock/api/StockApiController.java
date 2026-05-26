package com.pcs.domain.stock.api;

import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.facade.StockFacade;
import com.pcs.global.dto.ApiResultDto;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class StockApiController {

    private final StockFacade stockFacade;

    public StockApiController(StockFacade stockFacade) {
        this.stockFacade = stockFacade;
    }

    @PostMapping("/workspaces/{companyCode}/stock/documents/inbounds")
    public ResponseEntity<ApiResultDto<CreateInboundDocumentResponse>> createInboundDocument(
            @PathVariable String companyCode,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @Valid @RequestBody CreateInboundDocumentRequest request
    ) {
        CreateInboundDocumentResponse response = stockFacade.createInboundDocument(
                authorizationHeader,
                companyCode,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("입고 전표가 등록되었습니다.", response));
    }
}
