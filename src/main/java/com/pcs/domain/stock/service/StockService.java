package com.pcs.domain.stock.service;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchStockDocumentSummaryResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailResponse;
import com.pcs.domain.stock.dto.response.StockDocumentDetailRow;
import com.pcs.domain.stock.dto.response.StockDocumentLineResponse;
import com.pcs.domain.stock.dto.response.StockDocumentLineRow;
import com.pcs.domain.stock.dto.response.StockDocumentUnitResponse;
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
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

@Service
public class StockService {

    private static final DateTimeFormatter DATE_TOKEN_FORMATTER = DateTimeFormatter.BASIC_ISO_DATE;
    private static final String DOCUMENT_RANDOM_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final int DOCUMENT_RANDOM_LENGTH = 16;
    private static final int DOCUMENT_NO_CREATE_MAX_ATTEMPT = 20;
    private static final int DEFAULT_SIZE = 20;
    private static final int MAX_SIZE = 100;

    private final StockMapper stockMapper;
    private final SecureRandom secureRandom = new SecureRandom();

    public StockService(StockMapper stockMapper) {
        this.stockMapper = stockMapper;
    }

    public PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> searchDocuments(
            Long companyId,
            StockDocumentType documentType,
            String keyword,
            Long partnerId,
            StockDocumentStatus documentStatus,
            Integer page,
            Integer size,
            Integer limit
    ) {
        if (!stockMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        String normalizedKeyword = normalizeOptional(keyword);
        int normalizedPage = normalizePage(page);
        int normalizedSize = normalizeSize(size, limit);
        int offset = normalizedPage * normalizedSize;
        long totalElements = stockMapper.countDocuments(
                companyId,
                documentType,
                normalizedKeyword,
                partnerId,
                documentStatus
        );
        List<SearchStockDocumentResponse> items = totalElements == 0
                ? List.of()
                : stockMapper.searchDocuments(
                        companyId,
                        documentType,
                        normalizedKeyword,
                        partnerId,
                        documentStatus,
                        normalizedSize,
                        offset
                );
        SearchStockDocumentSummaryResponse summary = stockMapper.summarizeDocuments(
                companyId,
                documentType,
                normalizedKeyword,
                partnerId,
                documentStatus
        );

        return PageResultDto.of(items, normalizedPage, normalizedSize, totalElements, summary);
    }

    public StockDocumentDetailResponse getDocument(Long companyId, Long documentId) {
        if (!stockMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        StockDocumentDetailRow document = stockMapper.findDocumentDetail(companyId, documentId);
        if (document == null) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NOT_FOUND);
        }

        return buildDocumentDetail(companyId, document);
    }

    public CancelStockDocumentResponse cancelInboundDocument(Long companyId, Long memberId, Long documentId) {
        if (!stockMapper.isCompanyActive(companyId)) {
            throw new BusinessException(ErrorCode.COMPANY_INACTIVE);
        }

        StockDocumentDetailRow document = stockMapper.findDocumentForUpdate(companyId, documentId);
        if (document == null) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NOT_FOUND);
        }
        if (document.documentStatus() == StockDocumentStatus.CANCELED) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_ALREADY_CANCELED);
        }
        if (document.documentType() != StockDocumentType.INBOUND) {
            throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST, "현재 화면에서는 입고 전표만 취소할 수 있습니다.");
        }

        List<StockDocumentLineRow> movements = stockMapper.findOriginalInboundMovementsForUpdate(companyId, documentId);
        if (movements.isEmpty()) {
            throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
        }
        if (stockMapper.countInvalidInboundCancelUnits(companyId, documentId) > 0) {
            throw new BusinessException(
                    ErrorCode.STOCK_INVALID_CANCEL_REQUEST,
                    "검수 또는 출고 흐름이 시작된 부품이 있어 취소할 수 없습니다."
            );
        }

        int canceledUnitCount = 0;
        for (StockDocumentLineRow movement : movements) {
            Integer currentQuantity = stockMapper.findPartStockQuantityForUpdate(companyId, movement.partId());
            if (currentQuantity == null || currentQuantity < movement.quantity()) {
                throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST, "현재 재고 수량이 부족해 취소할 수 없습니다.");
            }

            int afterQuantity = currentQuantity - movement.quantity();
            StockMovement cancelMovement = new StockMovement(
                    companyId,
                    documentId,
                    movement.partId(),
                    MovementType.INBOUND_CANCEL,
                    MovementStatus.COMPLETED,
                    movement.movementId(),
                    movement.quantity(),
                    currentQuantity,
                    afterQuantity,
                    "입고 전표 취소",
                    memberId
            );
            stockMapper.insertMovement(cancelMovement);
            stockMapper.updatePartStockQuantity(companyId, movement.partId(), afterQuantity);

            List<Long> unitIds = stockMapper.findMovementUnitIds(movement.movementId());
            for (Long unitId : unitIds) {
                stockMapper.insertMovementUnitStatusChange(
                        cancelMovement.getMovementId(),
                        unitId,
                        UnitStatus.IN_STOCK,
                        UnitStatus.CANCELED
                );
                stockMapper.updatePartUnitStatusForInboundCancel(companyId, unitId);
                canceledUnitCount++;
            }
        }

        stockMapper.updateDocumentMovementStatus(companyId, documentId, MovementStatus.CANCELED);
        stockMapper.updateDocumentStatus(companyId, documentId, StockDocumentStatus.CANCELED);

        return new CancelStockDocumentResponse(
                document.documentId(),
                document.documentNo(),
                StockDocumentStatus.CANCELED,
                movements.size(),
                canceledUnitCount
        );
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

    private StockDocumentDetailResponse buildDocumentDetail(Long companyId, StockDocumentDetailRow document) {
        List<StockDocumentLineRow> lineRows = stockMapper.findDocumentLines(companyId, document.documentId());
        List<StockDocumentUnitResponse> unitRows = stockMapper.findDocumentUnits(companyId, document.documentId());
        Map<Long, List<StockDocumentUnitResponse>> unitsByMovementId = unitRows.stream()
                .collect(Collectors.groupingBy(StockDocumentUnitResponse::movementId));
        List<StockDocumentLineResponse> lines = lineRows.stream()
                .map(line -> new StockDocumentLineResponse(
                        line.movementId(),
                        line.partId(),
                        line.partName(),
                        line.modelName(),
                        line.partCode(),
                        line.movementType(),
                        line.movementStatus(),
                        line.quantity(),
                        line.beforeQuantity(),
                        line.afterQuantity(),
                        line.reason(),
                        unitsByMovementId.getOrDefault(line.movementId(), List.of())
                ))
                .toList();

        String cancelBlockedReason = getCancelBlockedReason(companyId, document);
        return new StockDocumentDetailResponse(
                document.documentId(),
                document.documentNo(),
                document.documentType(),
                document.documentStatus(),
                document.partnerId(),
                document.partnerName(),
                document.reason(),
                document.processedByName(),
                document.createdAt(),
                document.lineCount(),
                document.totalQuantity(),
                cancelBlockedReason == null,
                cancelBlockedReason,
                lines
        );
    }

    private String getCancelBlockedReason(Long companyId, StockDocumentDetailRow document) {
        if (document.documentStatus() == StockDocumentStatus.CANCELED) {
            return "이미 취소된 전표입니다.";
        }
        if (document.documentType() != StockDocumentType.INBOUND) {
            return "입고 전표만 이 화면에서 취소할 수 있습니다.";
        }
        if (stockMapper.countInvalidInboundCancelUnits(companyId, document.documentId()) > 0) {
            return "검수 또는 출고 흐름이 시작된 부품이 있어 취소할 수 없습니다.";
        }
        return null;
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

    private int normalizePage(Integer page) {
        if (page == null || page < 0) {
            return 0;
        }
        return page;
    }

    private int normalizeSize(Integer size, Integer limit) {
        Integer requestedSize = size == null ? limit : size;
        if (requestedSize == null || requestedSize < 1) {
            return DEFAULT_SIZE;
        }
        return Math.min(requestedSize, MAX_SIZE);
    }

    private String normalizeRequired(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }
}
