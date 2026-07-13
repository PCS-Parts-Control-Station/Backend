package com.pcs.global.error;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.pcs.global.dto.ApiResultDto;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.ResponseEntity;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void duplicateTemplateItemName_mapsToConflict() {
        DuplicateKeyException exception = duplicate("uk_inspection_template_item_name");

        ResponseEntity<ApiResultDto<Void>> response = handler.handleDuplicateKey(exception);

        assertEquals(409, response.getStatusCode().value());
        assertEquals(ErrorCode.INSPECTION_TEMPLATE_ITEM_DUPLICATED.getCode(), response.getBody().code());
    }

    @Test
    void duplicateStockDocumentNo_mapsToConflict() {
        DuplicateKeyException exception = duplicate("uk_stock_document_company_document_no");

        ResponseEntity<ApiResultDto<Void>> response = handler.handleDuplicateKey(exception);

        assertEquals(409, response.getStatusCode().value());
        assertEquals(ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED.getCode(), response.getBody().code());
    }

    private DuplicateKeyException duplicate(String constraintName) {
        return new DuplicateKeyException("duplicate", new RuntimeException(constraintName));
    }
}
