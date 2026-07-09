package com.pcs.domain.inspection.mapper;

import com.pcs.domain.inspection.dto.response.InspectionDocumentLineRow;
import com.pcs.domain.inspection.dto.response.InspectionDocumentUnitResponse;
import com.pcs.domain.inspection.dto.response.InspectionHistoryDetailRow;
import com.pcs.domain.inspection.dto.response.InspectionItemResultResponse;
import com.pcs.domain.inspection.dto.response.InspectionPartUnitRow;
import com.pcs.domain.inspection.dto.response.InspectionTemplateOptionRow;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryDocumentSummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistoryResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionHistorySummaryResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentResponse;
import com.pcs.domain.inspection.dto.response.SearchWaitingInspectionDocumentSummaryResponse;
import com.pcs.domain.inspection.entity.Inspection;
import com.pcs.domain.inspection.entity.InspectionItemResult;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
import com.pcs.domain.inspection.entity.PartStatusHistory;
import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.type.InspectionType;
import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import java.time.LocalDateTime;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface InspectionMapper {

    List<SearchWaitingInspectionDocumentResponse> searchWaitingDocuments(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partId") Long partId,
            @Param("hasWaiting") Boolean hasWaiting,
            @Param("partnerId") Long partnerId,
            @Param("inspectionStatus") String inspectionStatus,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countWaitingDocuments(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partId") Long partId,
            @Param("hasWaiting") Boolean hasWaiting,
            @Param("partnerId") Long partnerId,
            @Param("inspectionStatus") String inspectionStatus,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo
    );

    SearchWaitingInspectionDocumentSummaryResponse summarizeWaitingDocuments(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("partId") Long partId,
            @Param("hasWaiting") Boolean hasWaiting,
            @Param("partnerId") Long partnerId,
            @Param("inspectionStatus") String inspectionStatus,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo
    );

    SearchWaitingInspectionDocumentResponse findWaitingDocument(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<InspectionDocumentLineRow> findWaitingDocumentLines(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<InspectionDocumentUnitResponse> findWaitingDocumentUnits(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<SearchInspectionHistoryResponse> searchHistories(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("documentId") Long documentId,
            @Param("unitId") Long unitId,
            @Param("partId") Long partId,
            @Param("inspectionType") InspectionType inspectionType,
            @Param("result") InspectionResult result,
            @Param("grade") PartGrade grade,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo,
            @Param("size") int size,
            @Param("offset") int offset
    );

    List<SearchInspectionHistoryDocumentResponse> searchHistoryDocuments(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("documentId") Long documentId,
            @Param("partId") Long partId,
            @Param("inspectionType") InspectionType inspectionType,
            @Param("result") InspectionResult result,
            @Param("grade") PartGrade grade,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countHistories(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("documentId") Long documentId,
            @Param("unitId") Long unitId,
            @Param("partId") Long partId,
            @Param("inspectionType") InspectionType inspectionType,
            @Param("result") InspectionResult result,
            @Param("grade") PartGrade grade,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo
    );

    long countHistoryDocuments(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("documentId") Long documentId,
            @Param("partId") Long partId,
            @Param("inspectionType") InspectionType inspectionType,
            @Param("result") InspectionResult result,
            @Param("grade") PartGrade grade,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo
    );

    SearchInspectionHistorySummaryResponse summarizeHistories(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("documentId") Long documentId,
            @Param("unitId") Long unitId,
            @Param("partId") Long partId,
            @Param("inspectionType") InspectionType inspectionType,
            @Param("result") InspectionResult result,
            @Param("grade") PartGrade grade,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo
    );

    SearchInspectionHistoryDocumentSummaryResponse summarizeHistoryDocuments(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("documentId") Long documentId,
            @Param("partId") Long partId,
            @Param("inspectionType") InspectionType inspectionType,
            @Param("result") InspectionResult result,
            @Param("grade") PartGrade grade,
            @Param("dateFrom") LocalDateTime dateFrom,
            @Param("dateTo") LocalDateTime dateTo
    );

    InspectionHistoryDetailRow findHistoryDetail(
            @Param("companyId") Long companyId,
            @Param("inspectionId") Long inspectionId
    );

    List<InspectionItemResultResponse> findItemResults(
            @Param("companyId") Long companyId,
            @Param("inspectionId") Long inspectionId
    );

    Inspection findInspection(
            @Param("companyId") Long companyId,
            @Param("inspectionId") Long inspectionId
    );

    InspectionPartUnitRow findPartUnitForUpdate(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId
    );

    InspectionTemplate findActiveTemplate(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    InspectionTemplate findTemplate(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    List<InspectionTemplateItem> findActiveTemplateItems(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    List<InspectionTemplateItem> findTemplateItems(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    List<InspectionTemplateOptionRow> findActiveTemplateOptions(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    List<InspectionTemplateOptionRow> findTemplateOptions(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    void insertInspection(Inspection inspection);

    void insertItemResult(InspectionItemResult itemResult);

    int updatePartUnitInspectionStatus(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId,
            @Param("inspectionStatus") InspectionStatus inspectionStatus,
            @Param("grade") PartGrade grade,
            @Param("salesStatus") SalesStatus salesStatus
    );

    void insertPartStatusHistory(PartStatusHistory history);
}
