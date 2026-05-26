package com.pcs.domain.stock.service;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.entity.StockDocument;
import com.pcs.domain.stock.entity.StockMovement;
import com.pcs.domain.stock.entity.StockPart;
import com.pcs.domain.stock.entity.StockPartUnit;
import com.pcs.domain.stock.entity.StockPartner;
import com.pcs.domain.stock.mapper.StockMapper;
import com.pcs.domain.stock.type.MovementStatus;
import com.pcs.domain.stock.type.MovementType;
import com.pcs.domain.stock.type.StockDocumentStatus;
import com.pcs.domain.stock.type.StockDocumentType;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

@Service
public class StockService {

    private static final DateTimeFormatter DATE_TOKEN_FORMATTER = DateTimeFormatter.BASIC_ISO_DATE;
    private static final String DOCUMENT_RANDOM_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final int DOCUMENT_RANDOM_LENGTH = 16;
    private static final int DOCUMENT_NO_CREATE_MAX_ATTEMPT = 20;

    private final StockMapper stockMapper;
    private final SecureRandom secureRandom = new SecureRandom();

    public StockService(StockMapper stockMapper) {
        this.stockMapper = stockMapper;
    }

    public CreateInboundDocumentResponse createInboundDocument(
            Long companyId,
            Long memberId,
            CreateInboundDocumentRequest request
    ) {
        if (!stockMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }
        validateInboundPartner(companyId, request.partnerId());

        String dateToken = LocalDate.now().format(DATE_TOKEN_FORMATTER);
        String documentNo = createUniqueInboundDocumentNo(dateToken);
        String documentReason = normalizeOptional(request.reason());

        StockDocument document = new StockDocument(
                companyId,
                request.partnerId(),
                documentNo,
                StockDocumentType.INBOUND,
                StockDocumentStatus.COMPLETED,
                documentReason,
                memberId
        );
        stockMapper.insertDocument(document);

        int totalQuantity = 0;
        int createdUnitCount = 0;

        for (CreateInboundDocumentLineRequest line : request.lines()) {
            StockPart part = stockMapper.findPart(companyId, line.partId());
            if (part == null) {
                throw new BusinessException(ErrorCode.PART_NOT_FOUND, "존재하지 않는 부품입니다. partId=" + line.partId());
            }

            int quantity = line.quantity();
            Integer currentQuantity = stockMapper.findPartStockQuantityForUpdate(companyId, line.partId());
            int beforeQuantity = currentQuantity == null ? 0 : currentQuantity;
            int afterQuantity = beforeQuantity + quantity;

            if (currentQuantity == null) {
                try {
                    stockMapper.insertPartStock(companyId, line.partId(), afterQuantity);
                } catch (DuplicateKeyException exception) {
                    // Another transaction inserted the stock row first. Re-lock and recalculate.
                    currentQuantity = stockMapper.findPartStockQuantityForUpdate(companyId, line.partId());
                    if (currentQuantity == null) {
                        throw exception;
                    }
                    beforeQuantity = currentQuantity;
                    afterQuantity = beforeQuantity + quantity;
                    stockMapper.updatePartStockQuantity(companyId, line.partId(), afterQuantity);
                }
            } else {
                stockMapper.updatePartStockQuantity(companyId, line.partId(), afterQuantity);
            }

            StockMovement movement = new StockMovement(
                    companyId,
                    document.getDocumentId(),
                    line.partId(),
                    MovementType.INBOUND,
                    MovementStatus.COMPLETED,
                    quantity,
                    beforeQuantity,
                    afterQuantity,
                    normalizeOptional(line.reason()),
                    memberId
            );
            stockMapper.insertMovement(movement);

            int serialSequence = stockMapper.findSerialSequence(companyId, part.getPartCode(), dateToken);
            for (int index = 0; index < quantity; index++) {
                StockPartUnit partUnit = createPartUnitWithRetry(
                        companyId,
                        line.partId(),
                        part.getPartCode(),
                        dateToken,
                        memberId,
                        serialSequence
                );
                serialSequence = parseSerialSequence(partUnit.getInternalSerialNo());
                stockMapper.insertMovementUnit(movement.getMovementId(), partUnit.getUnitId(), UnitStatus.IN_STOCK);
                createdUnitCount++;
            }

            totalQuantity += quantity;
        }

        return new CreateInboundDocumentResponse(
                document.getDocumentId(),
                documentNo,
                request.partnerId(),
                request.lines().size(),
                totalQuantity,
                createdUnitCount
        );
    }

    private void validateInboundPartner(Long companyId, Long partnerId) {
        StockPartner partner = stockMapper.findPartner(companyId, partnerId);
        if (partner == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }
        if (!partner.isActive()) {
            throw new BusinessException(ErrorCode.PARTNER_INACTIVE);
        }
        if (partner.getPartnerRole() != PartnerRole.SUPPLIER && partner.getPartnerRole() != PartnerRole.BOTH) {
            throw new BusinessException(ErrorCode.PARTNER_INACTIVE, "입고에는 공급 가능한 거래처만 선택할 수 있습니다.");
        }
    }

    private String createUniqueInboundDocumentNo(String dateToken) {
        for (int attempt = 0; attempt < DOCUMENT_NO_CREATE_MAX_ATTEMPT; attempt++) {
            String documentNo = createInboundDocumentNo(dateToken);
            if (!stockMapper.existsDocumentNo(documentNo)) {
                return documentNo;
            }
        }
        throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED);
    }

    private String createInboundDocumentNo(String dateToken) {
        return "IN-" + dateToken + "-" + randomDocumentToken();
    }

    private String randomDocumentToken() {
        StringBuilder builder = new StringBuilder(DOCUMENT_RANDOM_LENGTH);
        for (int index = 0; index < DOCUMENT_RANDOM_LENGTH; index++) {
            int alphabetIndex = secureRandom.nextInt(DOCUMENT_RANDOM_ALPHABET.length());
            builder.append(DOCUMENT_RANDOM_ALPHABET.charAt(alphabetIndex));
        }
        return builder.toString();
    }

    private StockPartUnit createPartUnitWithRetry(
            Long companyId,
            Long partId,
            String partCode,
            String dateToken,
            Long memberId,
            int currentSequence
    ) {
        int sequence = currentSequence;
        for (int attempt = 0; attempt < 20; attempt++) {
            sequence++;
            String internalSerialNo = createInternalSerialNo(partCode, dateToken, sequence);
            StockPartUnit partUnit = new StockPartUnit(
                    companyId,
                    partId,
                    internalSerialNo,
                    null,
                    UnitStatus.IN_STOCK,
                    PartGrade.NONE,
                    InspectionStatus.WAITING,
                    SalesStatus.HOLD,
                    memberId
            );
            try {
                stockMapper.insertPartUnit(partUnit);
                return partUnit;
            } catch (DuplicateKeyException exception) {
                Integer latestSequence = stockMapper.findSerialSequence(companyId, partCode, dateToken);
                sequence = latestSequence == null ? sequence : latestSequence;
            }
        }
        throw new BusinessException(ErrorCode.PART_UNIT_SERIAL_DUPLICATED);
    }

    private int parseSerialSequence(String internalSerialNo) {
        int index = internalSerialNo.lastIndexOf('-');
        if (index < 0 || index == internalSerialNo.length() - 1) {
            return 0;
        }
        try {
            return Integer.parseInt(internalSerialNo.substring(index + 1));
        } catch (NumberFormatException exception) {
            return 0;
        }
    }

    private String createInternalSerialNo(String partCode, String dateToken, int sequence) {
        String normalizedPartCode = normalizeRequired(partCode, "PART");
        return normalizedPartCode + "-" + dateToken + "-" + String.format("%04d", sequence);
    }

    private String normalizeOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeRequired(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }
}
