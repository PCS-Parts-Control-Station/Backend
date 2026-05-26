package com.pcs.domain.stock.mapper;

import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.stock.entity.StockDocument;
import com.pcs.domain.stock.entity.StockMovement;
import com.pcs.domain.stock.entity.StockPart;
import com.pcs.domain.stock.entity.StockPartUnit;
import com.pcs.domain.stock.entity.StockPartner;
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
}
