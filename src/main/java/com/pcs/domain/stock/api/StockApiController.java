package com.pcs.domain.stock.api;

import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateOutboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchOutboundCandidateResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailResponse;
import com.pcs.domain.stock.facade.StockFacade;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.dto.PageResultDto;
import jakarta.validation.Valid;
import java.time.LocalDate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class StockApiController {

    private final StockFacade stockFacade;

    public StockApiController(StockFacade stockFacade) {
        this.stockFacade = stockFacade;
    }

    @GetMapping("/workspaces/{companyCode}/stock/documents")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse>>> searchDocuments(
            @PathVariable String companyCode,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @RequestParam(required = false) StockDocumentType documentType,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long partnerId,
            @RequestParam(required = false) StockDocumentStatus documentStatus,
            @RequestParam(required = false) LocalDate dateFrom,
            @RequestParam(required = false) LocalDate dateTo,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> response = stockFacade.searchDocuments(
                authorizationHeader,
                companyCode,
                documentType,
                keyword,
                partnerId,
                documentStatus,
                dateFrom,
                dateTo,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/stock/outbound-candidates")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchOutboundCandidateResponse, Void>>> searchOutboundCandidates(
            @PathVariable String companyCode,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long partId,
            @RequestParam(required = false) PartGrade grade,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchOutboundCandidateResponse, Void> response = stockFacade.searchOutboundCandidates(
                authorizationHeader,
                companyCode,
                keyword,
                categoryId,
                partId,
                grade,
                page,
                size,
                limit
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/stock/documents/{documentId}")
    public ResponseEntity<ApiResultDto<StockDocumentDetailResponse>> getDocument(
            @PathVariable String companyCode,
            @PathVariable Long documentId,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader
    ) {
        StockDocumentDetailResponse response = stockFacade.getDocument(
                authorizationHeader,
                companyCode,
                documentId
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/stock/documents/{documentId}/cancel")
    public ResponseEntity<ApiResultDto<CancelStockDocumentResponse>> cancelDocument(
            @PathVariable String companyCode,
            @PathVariable Long documentId,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader
    ) {
        CancelStockDocumentResponse response = stockFacade.cancelDocument(
                authorizationHeader,
                companyCode,
                documentId
        );
        return ResponseEntity.ok(ApiResultDto.ok("입출고 전표가 취소되었습니다.", response));
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

    @PostMapping("/workspaces/{companyCode}/stock/documents/outbounds")
    public ResponseEntity<ApiResultDto<CreateOutboundDocumentResponse>> createOutboundDocument(
            @PathVariable String companyCode,
            @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @Valid @RequestBody CreateOutboundDocumentRequest request
    ) {
        CreateOutboundDocumentResponse response = stockFacade.createOutboundDocument(
                authorizationHeader,
                companyCode,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("출고 전표가 등록되었습니다.", response));
    }
}
