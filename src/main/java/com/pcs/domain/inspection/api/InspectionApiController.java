package com.pcs.domain.inspection.api;

import com.pcs.domain.inspection.dto.request.CreateBulkInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRequest;
import com.pcs.domain.inspection.dto.request.CreateInspectionRevisionRequest;
import com.pcs.domain.inspection.dto.response.CreateInspectionResponse;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailResponse;
import com.pcs.domain.inspection.dto.response.InspectionWaitingDocumentDetailResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentSummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.facade.InspectionFacade;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.security.PcsPrincipal;
import jakarta.validation.Valid;
import java.time.LocalDate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class InspectionApiController {

    private final InspectionFacade inspectionFacade;

    public InspectionApiController(InspectionFacade inspectionFacade) {
        this.inspectionFacade = inspectionFacade;
    }

    @GetMapping("/workspaces/{companyCode}/inspections/waiting-documents")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchWaitingInspectionDocumentResponse, SearchWaitingInspectionDocumentSummaryResponse>>> searchWaitingDocuments(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long partnerId,
            @RequestParam(required = false) String inspectionStatus,
            @RequestParam(required = false) LocalDate dateFrom,
            @RequestParam(required = false) LocalDate dateTo,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchWaitingInspectionDocumentResponse, SearchWaitingInspectionDocumentSummaryResponse> response =
                inspectionFacade.searchWaitingDocuments(
                        principal,
                        companyCode,
                        keyword,
                        partnerId,
                        inspectionStatus,
                        dateFrom,
                        dateTo,
                        page,
                        size,
                        limit
                );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units")
    public ResponseEntity<ApiResultDto<InspectionWaitingDocumentDetailResponse>> getWaitingDocumentUnits(
            @PathVariable String companyCode,
            @PathVariable Long documentId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        InspectionWaitingDocumentDetailResponse response = inspectionFacade.getWaitingDocumentUnits(
                principal,
                companyCode,
                documentId
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/inspections")
    public ResponseEntity<ApiResultDto<CreateInspectionResponse>> createInitialInspection(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateInspectionRequest request
    ) {
        CreateInspectionResponse response = inspectionFacade.createInitialInspection(
                principal,
                companyCode,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("검수 결과를 등록했습니다.", response));
    }

    @PostMapping("/workspaces/{companyCode}/inspections/bulk")
    public ResponseEntity<ApiResultDto<CreateInspectionResponse>> createBulkInitialInspection(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateBulkInspectionRequest request
    ) {
        CreateInspectionResponse response = inspectionFacade.createBulkInitialInspection(
                principal,
                companyCode,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("선택한 관리번호의 검수 결과를 등록했습니다.", response));
    }

    @GetMapping("/workspaces/{companyCode}/inspections/history-documents")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchInspectionHistoryDocumentResponse, SearchInspectionHistoryDocumentSummaryResponse>>> searchHistoryDocuments(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long documentId,
            @RequestParam(required = false) Long partId,
            @RequestParam(required = false) InspectionType inspectionType,
            @RequestParam(required = false) InspectionResult result,
            @RequestParam(required = false) PartGrade grade,
            @RequestParam(required = false) LocalDate dateFrom,
            @RequestParam(required = false) LocalDate dateTo,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchInspectionHistoryDocumentResponse, SearchInspectionHistoryDocumentSummaryResponse> response =
                inspectionFacade.searchHistoryDocuments(
                        principal,
                        companyCode,
                        keyword,
                        documentId,
                        partId,
                        inspectionType,
                        result,
                        grade,
                        dateFrom,
                        dateTo,
                        page,
                        size,
                        limit
                );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/inspections")
    public ResponseEntity<ApiResultDto<PageResultDto<SearchInspectionHistoryResponse, SearchInspectionHistorySummaryResponse>>> searchHistories(
            @PathVariable String companyCode,
            @AuthenticationPrincipal PcsPrincipal principal,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long documentId,
            @RequestParam(required = false) Long unitId,
            @RequestParam(required = false) Long partId,
            @RequestParam(required = false) InspectionType inspectionType,
            @RequestParam(required = false) InspectionResult result,
            @RequestParam(required = false) PartGrade grade,
            @RequestParam(required = false) LocalDate dateFrom,
            @RequestParam(required = false) LocalDate dateTo,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) Integer limit
    ) {
        PageResultDto<SearchInspectionHistoryResponse, SearchInspectionHistorySummaryResponse> response =
                inspectionFacade.searchHistories(
                        principal,
                        companyCode,
                        keyword,
                        documentId,
                        unitId,
                        partId,
                        inspectionType,
                        result,
                        grade,
                        dateFrom,
                        dateTo,
                        page,
                        size,
                        limit
                );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @GetMapping("/workspaces/{companyCode}/inspections/{inspectionId}")
    public ResponseEntity<ApiResultDto<InspectionHistoryDetailResponse>> getHistoryDetail(
            @PathVariable String companyCode,
            @PathVariable Long inspectionId,
            @AuthenticationPrincipal PcsPrincipal principal
    ) {
        InspectionHistoryDetailResponse response = inspectionFacade.getHistoryDetail(
                principal,
                companyCode,
                inspectionId
        );
        return ResponseEntity.ok(ApiResultDto.ok(response));
    }

    @PostMapping("/workspaces/{companyCode}/inspections/{inspectionId}/corrections")
    public ResponseEntity<ApiResultDto<CreateInspectionResponse>> createCorrection(
            @PathVariable String companyCode,
            @PathVariable Long inspectionId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateInspectionRevisionRequest request
    ) {
        CreateInspectionResponse response = inspectionFacade.createCorrection(
                principal,
                companyCode,
                inspectionId,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("검수 정정 이력을 등록했습니다.", response));
    }

    @PostMapping("/workspaces/{companyCode}/inspections/{inspectionId}/reinspections")
    public ResponseEntity<ApiResultDto<CreateInspectionResponse>> createReinspection(
            @PathVariable String companyCode,
            @PathVariable Long inspectionId,
            @AuthenticationPrincipal PcsPrincipal principal,
            @Valid @RequestBody CreateInspectionRevisionRequest request
    ) {
        CreateInspectionResponse response = inspectionFacade.createReinspection(
                principal,
                companyCode,
                inspectionId,
                request
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResultDto.ok("재검수 이력을 등록했습니다.", response));
    }
}
