package com.pcs.domain.stock.service;

import com.pcs.domain.part.type.InspectionStatus;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import com.pcs.domain.part.type.UnitStatus;
import com.pcs.domain.partner.type.PartnerRole;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateInboundDocumentRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentLineRequest;
import com.pcs.domain.stock.dto.request.CreateOutboundDocumentRequest;
import com.pcs.domain.stock.dto.response.CancelStockDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateInboundDocumentResponse;
import com.pcs.domain.stock.dto.response.CreateOutboundDocumentResponse;
import com.pcs.domain.stock.dto.response.SearchOutboundCandidateResponse;
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
import com.pcs.global.pagination.PageQuery;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.validation.DateRangeValidator;
import com.pcs.global.validation.DateRangeValidator.NormalizedDateRange;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

@Service
public class StockService {

    private static final DateTimeFormatter DATE_TOKEN_FORMATTER = DateTimeFormatter.BASIC_ISO_DATE;
    private static final String INBOUND_DOCUMENT_PREFIX = "IN";
    private static final String OUTBOUND_DOCUMENT_PREFIX = "OUT";
    private static final String DOCUMENT_RANDOM_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final int DOCUMENT_RANDOM_LENGTH = 16;
    private static final int DOCUMENT_NO_CREATE_MAX_ATTEMPT = 20;
    private static final int DEFAULT_SIZE = 20;
    private static final int MAX_DOCUMENT_UNIT_COUNT = 1000;

    private final StockMapper stockMapper;
    private final WorkspaceAccessValidator workspaceAccessValidator;
    private final SecureRandom secureRandom = new SecureRandom();

    public StockService(StockMapper stockMapper, WorkspaceAccessValidator workspaceAccessValidator) {
        this.stockMapper = stockMapper;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    public PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse> searchDocuments(
            Long companyId,
            StockDocumentType documentType,
            String keyword,
            Long partnerId,
            StockDocumentStatus documentStatus,
            LocalDate dateFrom,
            LocalDate dateTo,
            Integer page,
            Integer size,
            Integer limit
    ) {
        workspaceAccessValidator.validateCompanyActive(companyId);
        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
        NormalizedDateRange dateRange = DateRangeValidator.normalize(dateFrom, dateTo);
        SearchStockDocumentSummaryResponse summary = stockMapper.summarizeDocuments(
                companyId,
                documentType,
                normalizedKeyword,
                partnerId,
                documentStatus,
                dateRange.fromInclusive(),
                dateRange.toExclusive()
        );
        long totalElements = summary.totalCount();
        List<SearchStockDocumentResponse> items = totalElements == 0
                ? List.of()
                : stockMapper.searchDocuments(
                        companyId,
                        documentType,
                        normalizedKeyword,
                        partnerId,
                        documentStatus,
                        dateRange.fromInclusive(),
                        dateRange.toExclusive(),
                        pageQuery.size(),
                        pageQuery.offset()
                );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    public PageResultDto<SearchOutboundCandidateResponse, Void> searchOutboundCandidates(
            Long companyId,
            String keyword,
            Long categoryId,
            Long partId,
            PartGrade grade,
            Integer page,
            Integer size,
            Integer limit
    ) {
        workspaceAccessValidator.validateCompanyActive(companyId);

        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
        long totalElements = stockMapper.countOutboundCandidates(
                companyId,
                normalizedKeyword,
                categoryId,
                partId,
                grade
        );
        List<SearchOutboundCandidateResponse> items = totalElements == 0
                ? List.of()
                : stockMapper.searchOutboundCandidates(
                        companyId,
                        normalizedKeyword,
                        categoryId,
                        partId,
                        grade,
                        pageQuery.size(),
                        pageQuery.offset()
                );

        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, null);
    }

    public StockDocumentDetailResponse getDocument(Long companyId, Long documentId) {
        workspaceAccessValidator.validateCompanyActive(companyId);

        StockDocumentDetailRow document = stockMapper.findDocumentDetail(companyId, documentId);
        if (document == null) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NOT_FOUND);
        }

        return buildDocumentDetail(companyId, document);
    }

    public StockDocumentType getDocumentType(Long companyId, Long documentId) {
        workspaceAccessValidator.validateCompanyActive(companyId);
        StockDocumentType documentType = stockMapper.findDocumentType(companyId, documentId);
        if (documentType == null) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NOT_FOUND);
        }
        return documentType;
    }

    public CancelStockDocumentResponse cancelDocument(Long companyId, Long memberId, Long documentId) {
        StockDocumentDetailRow document = findCancelableDocument(companyId, documentId);
        if (document.documentType() == StockDocumentType.INBOUND) {
            return cancelInboundDocument(companyId, memberId, document);
        }
        if (document.documentType() == StockDocumentType.OUTBOUND) {
            return cancelOutboundDocument(companyId, memberId, document);
        }
        throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
    }

    private StockDocumentDetailRow findCancelableDocument(Long companyId, Long documentId) {
        workspaceAccessValidator.validateCompanyActive(companyId);

        StockDocumentDetailRow document = stockMapper.findDocumentForUpdate(companyId, documentId);
        if (document == null) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NOT_FOUND);
        }
        if (document.documentStatus() == StockDocumentStatus.CANCELED) {
            throw new BusinessException(ErrorCode.STOCK_DOCUMENT_ALREADY_CANCELED);
        }
        return document;
    }

    private CancelStockDocumentResponse cancelInboundDocument(
            Long companyId,
            Long memberId,
            StockDocumentDetailRow document
    ) {
        List<StockDocumentLineRow> movements = stockMapper.findOriginalInboundMovementsForUpdate(
                companyId,
                document.documentId()
        );
        if (movements.isEmpty()) {
            throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
        }
        if (stockMapper.countInvalidInboundCancelUnits(companyId, document.documentId()) > 0) {
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
                    document.documentId(),
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
            updatePartStockQuantity(companyId, movement.partId(), afterQuantity, ErrorCode.STOCK_INVALID_CANCEL_REQUEST);

            List<Long> unitIds = stockMapper.findMovementUnitIds(companyId, movement.movementId());
            for (Long unitId : unitIds) {
                insertMovementUnitStatusChange(
                        companyId,
                        cancelMovement.getMovementId(),
                        unitId,
                        UnitStatus.IN_STOCK,
                        UnitStatus.CANCELED
                );
                updatePartUnitStatusForInboundCancel(companyId, unitId);
                canceledUnitCount++;
            }
        }

        updateDocumentMovementStatus(companyId, document.documentId(), MovementStatus.CANCELED, movements.size());
        updateDocumentStatus(companyId, document.documentId(), StockDocumentStatus.CANCELED);

        return new CancelStockDocumentResponse(
                document.documentId(),
                document.documentNo(),
                StockDocumentStatus.CANCELED,
                movements.size(),
                canceledUnitCount
        );
    }

    private CancelStockDocumentResponse cancelOutboundDocument(
            Long companyId,
            Long memberId,
            StockDocumentDetailRow document
    ) {
        List<StockDocumentLineRow> movements = stockMapper.findOriginalOutboundMovementsForUpdate(
                companyId,
                document.documentId()
        );
        if (movements.isEmpty()) {
            throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
        }
        if (stockMapper.countInvalidOutboundCancelUnits(companyId, document.documentId()) > 0) {
            throw new BusinessException(
                    ErrorCode.STOCK_INVALID_CANCEL_REQUEST,
                    "이미 후속 처리된 관리번호가 있어 출고를 취소할 수 없습니다."
            );
        }

        int canceledUnitCount = 0;
        for (StockDocumentLineRow movement : movements) {
            Integer currentQuantity = stockMapper.findPartStockQuantityForUpdate(companyId, movement.partId());
            int beforeQuantity = currentQuantity == null ? 0 : currentQuantity;
            int afterQuantity = beforeQuantity + movement.quantity();

            StockMovement cancelMovement = new StockMovement(
                    companyId,
                    document.documentId(),
                    movement.partId(),
                    MovementType.OUTBOUND_CANCEL,
                    MovementStatus.COMPLETED,
                    movement.movementId(),
                    movement.quantity(),
                    beforeQuantity,
                    afterQuantity,
                    "출고 전표 취소",
                    memberId
            );
            stockMapper.insertMovement(cancelMovement);
            if (currentQuantity == null) {
                stockMapper.insertPartStock(companyId, movement.partId(), afterQuantity);
            } else {
                updatePartStockQuantity(companyId, movement.partId(), afterQuantity, ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
            }

            List<Long> unitIds = stockMapper.findMovementUnitIds(companyId, movement.movementId());
            for (Long unitId : unitIds) {
                insertMovementUnitStatusChange(
                        companyId,
                        cancelMovement.getMovementId(),
                        unitId,
                        UnitStatus.OUTBOUND,
                        UnitStatus.IN_STOCK
                );
                updatePartUnitStatusForOutboundCancel(companyId, unitId);
                canceledUnitCount++;
            }
        }

        updateDocumentMovementStatus(companyId, document.documentId(), MovementStatus.CANCELED, movements.size());
        updateDocumentStatus(companyId, document.documentId(), StockDocumentStatus.CANCELED);

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
        workspaceAccessValidator.validateCompanyActive(companyId);
        validateInboundLines(request.lines());
        validateInboundPartner(companyId, request.partnerId());

        String dateToken = LocalDate.now().format(DATE_TOKEN_FORMATTER);
        String documentNo = createUniqueDocumentNo(INBOUND_DOCUMENT_PREFIX, dateToken);
        String documentReason = TextNormalizer.optional(request.reason());

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
                    updatePartStockQuantity(companyId, line.partId(), afterQuantity, ErrorCode.STOCK_STATE_CONFLICT);
                }
            } else {
                updatePartStockQuantity(companyId, line.partId(), afterQuantity, ErrorCode.STOCK_STATE_CONFLICT);
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
                    TextNormalizer.optional(line.reason()),
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
                insertMovementUnit(companyId, movement.getMovementId(), partUnit.getUnitId(), UnitStatus.IN_STOCK);
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

    public CreateOutboundDocumentResponse createOutboundDocument(
            Long companyId,
            Long memberId,
            CreateOutboundDocumentRequest request
    ) {
        workspaceAccessValidator.validateCompanyActive(companyId);
        validateOutboundPartner(companyId, request.partnerId());
        validateOutboundLines(request.lines());

        String dateToken = LocalDate.now().format(DATE_TOKEN_FORMATTER);
        String documentNo = createUniqueDocumentNo(OUTBOUND_DOCUMENT_PREFIX, dateToken);
        String documentReason = TextNormalizer.optional(request.reason());

        StockDocument document = new StockDocument(
                companyId,
                request.partnerId(),
                documentNo,
                StockDocumentType.OUTBOUND,
                StockDocumentStatus.COMPLETED,
                documentReason,
                memberId
        );
        stockMapper.insertDocument(document);

        int totalQuantity = 0;
        int outboundUnitCount = 0;

        for (CreateOutboundDocumentLineRequest line : request.lines()) {
            StockPart part = stockMapper.findPart(companyId, line.partId());
            if (part == null) {
                throw new BusinessException(ErrorCode.PART_NOT_FOUND, "존재하지 않는 부품입니다. partId=" + line.partId());
            }

            List<Long> unitIds = line.unitIds();
            int quantity = unitIds.size();
            Integer currentQuantity = stockMapper.findPartStockQuantityForUpdate(companyId, line.partId());
            if (currentQuantity == null || currentQuantity < quantity) {
                throw new BusinessException(ErrorCode.STOCK_NOT_ENOUGH);
            }

            List<SearchOutboundCandidateResponse> candidates = stockMapper.findOutboundCandidateUnitsForUpdate(
                    companyId,
                    line.partId(),
                    unitIds
            );
            if (candidates.size() != quantity) {
                throw new BusinessException(
                        ErrorCode.STOCK_NOT_ENOUGH,
                        "출고할 수 없는 관리번호가 포함되어 있습니다."
                );
            }

            int afterQuantity = currentQuantity - quantity;
            StockMovement movement = new StockMovement(
                    companyId,
                    document.getDocumentId(),
                    line.partId(),
                    MovementType.OUTBOUND,
                    MovementStatus.COMPLETED,
                    quantity,
                    currentQuantity,
                    afterQuantity,
                    TextNormalizer.optional(line.reason()),
                    memberId
            );
            stockMapper.insertMovement(movement);
            updatePartStockQuantity(companyId, line.partId(), afterQuantity, ErrorCode.STOCK_STATE_CONFLICT);

            for (SearchOutboundCandidateResponse candidate : candidates) {
                insertMovementUnitStatusChange(
                        companyId,
                        movement.getMovementId(),
                        candidate.unitId(),
                        UnitStatus.IN_STOCK,
                        UnitStatus.OUTBOUND
                );
                updatePartUnitStatusForOutbound(companyId, candidate.unitId());
                outboundUnitCount++;
            }

            totalQuantity += quantity;
        }

        return new CreateOutboundDocumentResponse(
                document.getDocumentId(),
                documentNo,
                request.partnerId(),
                request.lines().size(),
                totalQuantity,
                outboundUnitCount
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
        if (document.documentType() == StockDocumentType.INBOUND
                && stockMapper.countInvalidInboundCancelUnits(companyId, document.documentId()) > 0) {
            return "검수 또는 출고 흐름이 시작된 부품이 있어 취소할 수 없습니다.";
        }
        if (document.documentType() == StockDocumentType.OUTBOUND
                && stockMapper.countInvalidOutboundCancelUnits(companyId, document.documentId()) > 0) {
            return "이미 후속 처리된 관리번호가 있어 출고를 취소할 수 없습니다.";
        }
        return null;
    }

    private void validateInboundPartner(Long companyId, Long partnerId) {
        validatePartner(
                companyId,
                partnerId,
                PartnerRole.SUPPLIER,
                "입고에는 공급 가능한 거래처만 선택할 수 있습니다."
        );
    }

    private void validateOutboundPartner(Long companyId, Long partnerId) {
        validatePartner(
                companyId,
                partnerId,
                PartnerRole.CUSTOMER,
                "출고에는 구매 가능한 거래처만 선택할 수 있습니다."
        );
    }

    private void validatePartner(Long companyId, Long partnerId, PartnerRole requiredRole, String invalidRoleMessage) {
        StockPartner partner = stockMapper.findPartner(companyId, partnerId);
        if (partner == null) {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }
        if (!partner.isActive()) {
            throw new BusinessException(ErrorCode.PARTNER_INACTIVE);
        }
        if (partner.getPartnerRole() != requiredRole && partner.getPartnerRole() != PartnerRole.BOTH) {
            throw new BusinessException(ErrorCode.PARTNER_INACTIVE, invalidRoleMessage);
        }
    }

    private void insertMovementUnit(
            Long companyId,
            Long movementId,
            Long unitId,
            UnitStatus afterUnitStatus
    ) {
        int inserted = stockMapper.insertMovementUnit(companyId, movementId, unitId, afterUnitStatus);
        if (inserted != 1) {
            throw new BusinessException(ErrorCode.PART_UNIT_NOT_FOUND);
        }
    }

    private void insertMovementUnitStatusChange(
            Long companyId,
            Long movementId,
            Long unitId,
            UnitStatus beforeUnitStatus,
            UnitStatus afterUnitStatus
    ) {
        int inserted = stockMapper.insertMovementUnitStatusChange(
                companyId,
                movementId,
                unitId,
                beforeUnitStatus,
                afterUnitStatus
        );
        if (inserted != 1) {
            throw new BusinessException(ErrorCode.PART_UNIT_NOT_FOUND);
        }
    }

    private void updatePartStockQuantity(
            Long companyId,
            Long partId,
            Integer quantity,
            ErrorCode errorCode
    ) {
        int updated = stockMapper.updatePartStockQuantity(companyId, partId, quantity);
        if (updated != 1) {
            throw new BusinessException(errorCode);
        }
    }

    private void updatePartUnitStatusForInboundCancel(Long companyId, Long unitId) {
        int updated = stockMapper.updatePartUnitStatusForInboundCancel(companyId, unitId);
        if (updated != 1) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE);
        }
    }

    private void updatePartUnitStatusForOutbound(Long companyId, Long unitId) {
        int updated = stockMapper.updatePartUnitStatusForOutbound(companyId, unitId);
        if (updated != 1) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE);
        }
    }

    private void updatePartUnitStatusForOutboundCancel(Long companyId, Long unitId) {
        int updated = stockMapper.updatePartUnitStatusForOutboundCancel(companyId, unitId);
        if (updated != 1) {
            throw new BusinessException(ErrorCode.PART_INVALID_STATUS_CHANGE);
        }
    }

    private void updateDocumentMovementStatus(
            Long companyId,
            Long documentId,
            MovementStatus movementStatus,
            int expectedCount
    ) {
        int updated = stockMapper.updateDocumentMovementStatus(companyId, documentId, movementStatus);
        if (updated != expectedCount) {
            throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
        }
    }

    private void updateDocumentStatus(
            Long companyId,
            Long documentId,
            StockDocumentStatus documentStatus
    ) {
        int updated = stockMapper.updateDocumentStatus(companyId, documentId, documentStatus);
        if (updated != 1) {
            throw new BusinessException(ErrorCode.STOCK_INVALID_CANCEL_REQUEST);
        }
    }

    private void validateOutboundLines(List<CreateOutboundDocumentLineRequest> lines) {
        if (lines == null || lines.isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "출고 라인은 최소 1개 이상 필요합니다.");
        }

        Set<Long> uniqueUnitIds = new HashSet<>();
        for (CreateOutboundDocumentLineRequest line : lines) {
            if (line == null || line.partId() == null) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "출고 라인의 부품 정보가 올바르지 않습니다.");
            }
            if (line.unitIds() == null || line.unitIds().isEmpty()) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "출고할 관리번호를 선택해 주세요.");
            }
            for (Long unitId : line.unitIds()) {
                if (unitId == null) {
                    throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "출고할 관리번호 정보가 올바르지 않습니다.");
                }
                if (!uniqueUnitIds.add(unitId)) {
                    throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 관리번호가 있습니다.");
                }
            }
        }
        if (uniqueUnitIds.size() > MAX_DOCUMENT_UNIT_COUNT) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "전표당 최대 1000개까지 출고할 수 있습니다.");
        }
    }

    private void validateInboundLines(List<CreateInboundDocumentLineRequest> lines) {
        if (lines == null || lines.isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "부품 라인은 최소 1개 이상 필요합니다.");
        }
        if (lines.size() > 100) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "부품 라인은 최대 100개까지 등록할 수 있습니다.");
        }

        long totalQuantity = 0;
        Set<Long> partIds = new HashSet<>();
        for (CreateInboundDocumentLineRequest line : lines) {
            if (line == null || line.partId() == null || line.quantity() == null || line.quantity() < 1) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "입고 라인의 부품과 수량 정보가 올바르지 않습니다.");
            }
            if (!partIds.add(line.partId())) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "중복된 부품 라인이 있습니다.");
            }
            totalQuantity += line.quantity();
            if (totalQuantity > MAX_DOCUMENT_UNIT_COUNT) {
                throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "전표당 최대 1000개까지 입고할 수 있습니다.");
            }
        }
    }

    private String createUniqueDocumentNo(String prefix, String dateToken) {
        for (int attempt = 0; attempt < DOCUMENT_NO_CREATE_MAX_ATTEMPT; attempt++) {
            String documentNo = createDocumentNo(prefix, dateToken);
            if (!stockMapper.existsDocumentNo(documentNo)) {
                return documentNo;
            }
        }
        throw new BusinessException(ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED);
    }

    private String createDocumentNo(String prefix, String dateToken) {
        return prefix + "-" + dateToken + "-" + randomDocumentToken();
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
        String normalizedPartCode = TextNormalizer.requiredOrDefault(partCode, "PART");
        return normalizedPartCode + "-" + dateToken + "-" + String.format("%04d", sequence);
    }
}
