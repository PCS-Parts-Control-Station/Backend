package com.pcs.global.error;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.error.exception.BusinessException;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.Map;
import java.util.stream.Stream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class GlobalExceptionHandlerTest {

    private MockMvc mockMvc;

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .standaloneSetup(new ContractController())
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void successResponse_hasCommonContract() throws Exception {
        mockMvc.perform(get("/api/test/success"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.code").value("COMMON-000"))
                .andExpect(jsonPath("$.message").value("요청이 정상 처리되었습니다."))
                .andExpect(jsonPath("$.data.value").value("ok"));
    }

    @Test
    void businessException_hasCommonErrorContract() throws Exception {
        mockMvc.perform(get("/api/test/business"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("PARTNER-001"))
                .andExpect(jsonPath("$.message").value("거래처를 찾을 수 없습니다."))
                .andExpect(jsonPath("$.data").value(nullValue()));
    }

    @Test
    void validationFailure_returnsStableFieldErrors() throws Exception {
        mockMvc.perform(post("/api/test/body")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("COMMON-001"))
                .andExpect(jsonPath("$.data", hasSize(1)))
                .andExpect(jsonPath("$.data[0].field").value("name"));
    }

    @Test
    void missingParameter_doesNotExposeFrameworkMessage() throws Exception {
        mockMvc.perform(get("/api/test/missing"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-003"))
                .andExpect(jsonPath("$.message").value("필수 요청 파라미터가 누락되었습니다."))
                .andExpect(jsonPath("$.data").value(nullValue()));
    }

    @Test
    void typeMismatch_doesNotExposeFrameworkMessage() throws Exception {
        mockMvc.perform(get("/api/test/type").param("value", "not-a-number"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-001"))
                .andExpect(jsonPath("$.message").value("요청 값이 올바르지 않습니다."));
    }

    @Test
    void malformedBody_usesInvalidRequestBodyCode() throws Exception {
        mockMvc.perform(post("/api/test/body")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{invalid-json"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-002"))
                .andExpect(jsonPath("$.data").value(nullValue()));
    }

    @Test
    void unexpectedException_hidesInternalMessage() throws Exception {
        mockMvc.perform(get("/api/test/internal"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("COMMON-999"))
                .andExpect(jsonPath("$.message").value("서버 오류가 발생했습니다."))
                .andExpect(jsonPath("$.data").value(nullValue()));
    }

    @ParameterizedTest
    @MethodSource("duplicateKeyMappings")
    void duplicateKey_mapsKnownConstraintToConflict(String constraintName, ErrorCode expectedErrorCode) {
        DuplicateKeyException exception = duplicate(constraintName);

        ResponseEntity<ApiResultDto<Void>> response = handler.handleDuplicateKey(exception);

        assertEquals(409, response.getStatusCode().value());
        assertEquals(expectedErrorCode.getCode(), response.getBody().code());
    }

    @Test
    void duplicateKey_mapsUnknownConstraintToInternalServerError() {
        ResponseEntity<ApiResultDto<Void>> response = handler.handleDuplicateKey(duplicate("uk_unknown"));

        assertEquals(500, response.getStatusCode().value());
        assertEquals(ErrorCode.INTERNAL_SERVER_ERROR.getCode(), response.getBody().code());
    }

    private static Stream<Arguments> duplicateKeyMappings() {
        return Stream.of(
                Arguments.of("uk_company_code", ErrorCode.COMPANY_CODE_DUPLICATED),
                Arguments.of(
                        "uk_company_business_registration_no",
                        ErrorCode.COMPANY_BUSINESS_REGISTRATION_NO_DUPLICATED
                ),
                Arguments.of("uk_member_company_login", ErrorCode.MEMBER_LOGIN_ID_DUPLICATED),
                Arguments.of("uk_part_category_company_name", ErrorCode.CATEGORY_NAME_DUPLICATED),
                Arguments.of("uk_pc_part_company_code", ErrorCode.PART_CODE_DUPLICATED),
                Arguments.of("uk_trade_partner_company_name", ErrorCode.PARTNER_NAME_DUPLICATED),
                Arguments.of("uk_stock_document_document_no", ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED),
                Arguments.of("uk_stock_document_company_document_no", ErrorCode.STOCK_DOCUMENT_NO_DUPLICATED),
                Arguments.of("uk_pc_part_unit_internal_serial", ErrorCode.PART_UNIT_SERIAL_DUPLICATED),
                Arguments.of("uk_pc_part_unit_manufacturer_serial", ErrorCode.PART_UNIT_SERIAL_DUPLICATED),
                Arguments.of("uk_inspection_template_version", ErrorCode.INSPECTION_TEMPLATE_DUPLICATED),
                Arguments.of("uk_inspection_template_item_name", ErrorCode.INSPECTION_TEMPLATE_ITEM_DUPLICATED),
                Arguments.of(
                        "uk_inspection_template_item_option_value",
                        ErrorCode.INSPECTION_TEMPLATE_OPTION_DUPLICATED
                ),
                Arguments.of(
                        "uk_inspection_template_item_option_label",
                        ErrorCode.INSPECTION_TEMPLATE_OPTION_DUPLICATED
                )
        );
    }

    private DuplicateKeyException duplicate(String constraintName) {
        return new DuplicateKeyException("duplicate", new RuntimeException(constraintName));
    }

    @RestController
    static class ContractController {

        @GetMapping("/api/test/success")
        ApiResultDto<Map<String, String>> success() {
            return ApiResultDto.ok(Map.of("value", "ok"));
        }

        @GetMapping("/api/test/business")
        ApiResultDto<Void> business() {
            throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
        }

        @GetMapping("/api/test/missing")
        ApiResultDto<Void> missing(@RequestParam String required) {
            return ApiResultDto.ok();
        }

        @GetMapping("/api/test/type")
        ApiResultDto<Void> type(@RequestParam Integer value) {
            return ApiResultDto.ok();
        }

        @PostMapping("/api/test/body")
        ApiResultDto<Void> body(@Valid @RequestBody TestRequest request) {
            return ApiResultDto.ok();
        }

        @GetMapping("/api/test/internal")
        ApiResultDto<Void> internal() {
            throw new IllegalStateException("database password must never be exposed");
        }
    }

    record TestRequest(@NotBlank String name) {
    }
}
