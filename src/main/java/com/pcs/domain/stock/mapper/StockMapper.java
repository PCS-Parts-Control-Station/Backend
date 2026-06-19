package com.pcs.domain.stock.mapper;

import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.dto.response.SearchOutboundCandidateResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailRow;
import com.pcs.domain.stock.dto.response.StockDocumentLineRow;
import com.pcs.domain.stock.dto.response.StockDocumentUnitResponse;
import com.pcs.domain.stock.entity.StockDocument;
import com.pcs.domain.stock.entity.StockMovement;
import com.pcs.domain.stock.entity.StockPart;
import com.pcs.domain.stock.entity.StockPartUnit;
import com.pcs.domain.stock.entity.StockPartner;
import com.pcs.domain.stock.type.MovementStatus;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface StockMapper {

    boolean isCompanyActive(@Param("companyId") Long companyId);

    StockPartner findPartner(
            @Param("companyId") Long companyId,
            @Param("partnerId") Long partnerId
    );

    StockPart findPart(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId
    );

    boolean existsDocumentNo(@Param("documentNo") String documentNo);

    List<SearchStockDocumentResponse> searchDocuments(
            @Param("companyId") Long companyId,
            @Param("documentType") StockDocumentType documentType,
            @Param("keyword") String keyword,
            @Param("partnerId") Long partnerId,
            @Param("documentStatus") StockDocumentStatus documentStatus,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countDocuments(
            @Param("companyId") Long companyId,
            @Param("documentType") StockDocumentType documentType,
            @Param("keyword") String keyword,
            @Param("partnerId") Long partnerId,
            @Param("documentStatus") StockDocumentStatus documentStatus
    );

    SearchStockDocumentSummaryResponse summarizeDocuments(
            @Param("companyId") Long companyId,
            @Param("documentType") StockDocumentType documentType,
            @Param("keyword") String keyword,
            @Param("partnerId") Long partnerId,
            @Param("documentStatus") StockDocumentStatus documentStatus
    );

    List<SearchOutboundCandidateResponse> searchOutboundCandidates(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("partId") Long partId,
            @Param("grade") PartGrade grade,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countOutboundCandidates(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("partId") Long partId,
            @Param("grade") PartGrade grade
    );

    List<SearchOutboundCandidateResponse> findOutboundCandidateUnitsForUpdate(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId,
            @Param("unitIds") List<Long> unitIds
    );

    StockDocumentDetailRow findDocumentDetail(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    StockDocumentDetailRow findDocumentForUpdate(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<StockDocumentLineRow> findDocumentLines(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<StockDocumentLineRow> findOriginalInboundMovementsForUpdate(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<StockDocumentLineRow> findOriginalOutboundMovementsForUpdate(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<StockDocumentUnitResponse> findDocumentUnits(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    List<Long> findMovementUnitIds(
            @Param("movementId") Long movementId
    );

    int countInvalidInboundCancelUnits(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    int countInvalidOutboundCancelUnits(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId
    );

    void updateDocumentStatus(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId,
            @Param("documentStatus") StockDocumentStatus documentStatus
    );

    void updateDocumentMovementStatus(
            @Param("companyId") Long companyId,
            @Param("documentId") Long documentId,
            @Param("movementStatus") MovementStatus movementStatus
    );

    void insertDocument(StockDocument document);

    Integer findPartStockQuantityForUpdate(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId
    );

    void insertPartStock(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId,
            @Param("quantity") Integer quantity
    );

    void updatePartStockQuantity(
            @Param("companyId") Long companyId,
            @Param("partId") Long partId,
            @Param("quantity") Integer quantity
    );

    void insertMovement(StockMovement movement);

    Integer findSerialSequence(
            @Param("companyId") Long companyId,
            @Param("serialPrefix") String serialPrefix,
            @Param("dateToken") String dateToken
    );

    void insertPartUnit(StockPartUnit unit);

    void insertMovementUnit(
            @Param("movementId") Long movementId,
            @Param("unitId") Long unitId,
            @Param("afterUnitStatus") UnitStatus afterUnitStatus
    );

    void insertMovementUnitStatusChange(
            @Param("movementId") Long movementId,
            @Param("unitId") Long unitId,
            @Param("beforeUnitStatus") UnitStatus beforeUnitStatus,
            @Param("afterUnitStatus") UnitStatus afterUnitStatus
    );

    void updatePartUnitStatusForInboundCancel(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId
    );

    void updatePartUnitStatusForOutbound(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId
    );

    void updatePartUnitStatusForOutboundCancel(
            @Param("companyId") Long companyId,
            @Param("unitId") Long unitId
    );
}
