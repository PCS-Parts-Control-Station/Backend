package com.pcs.global.error;

import org.springframework.http.HttpStatus;

public enum ErrorCode {

    INVALID_INPUT_VALUE(HttpStatus.BAD_REQUEST, "COMMON-001", "요청 값이 올바르지 않습니다."),
    INVALID_REQUEST_BODY(HttpStatus.BAD_REQUEST, "COMMON-002", "요청 본문이 올바르지 않습니다."),
    MISSING_REQUEST_PARAMETER(HttpStatus.BAD_REQUEST, "COMMON-003", "필수 요청 파라미터가 누락되었습니다."),
    UNSUPPORTED_HTTP_METHOD(HttpStatus.METHOD_NOT_ALLOWED, "COMMON-004", "지원하지 않는 HTTP 메서드입니다."),
    RESOURCE_NOT_FOUND(HttpStatus.NOT_FOUND, "COMMON-005", "요청한 리소스를 찾을 수 없습니다."),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "COMMON-999", "서버 오류가 발생했습니다."),

    AUTH_LOGIN_FAILED(HttpStatus.UNAUTHORIZED, "AUTH-001", "아이디 또는 비밀번호가 올바르지 않습니다."),
    AUTH_REQUIRED(HttpStatus.UNAUTHORIZED, "AUTH-002", "로그인이 필요합니다."),
    AUTH_TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "AUTH-003", "인증 토큰이 올바르지 않습니다."),
    AUTH_TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "AUTH-004", "인증 토큰이 만료되었습니다."),
    AUTH_FORBIDDEN(HttpStatus.FORBIDDEN, "AUTH-005", "접근 권한이 없습니다."),
    AUTH_WORKSPACE_MISMATCH(HttpStatus.FORBIDDEN, "AUTH-006", "업체 코드와 로그인 정보가 일치하지 않습니다."),
    AUTH_ACCOUNT_LOCKED(HttpStatus.UNAUTHORIZED, "AUTH-007", "로그인 실패가 반복되어 계정이 잠시 잠겼습니다."),
    AUTH_STAFF_PERMISSION_DENIED(HttpStatus.FORBIDDEN, "AUTH-008", "해당 업무 권한이 없습니다."),

    COMPANY_NOT_FOUND(HttpStatus.NOT_FOUND, "COMPANY-001", "업체를 찾을 수 없습니다."),
    COMPANY_CODE_DUPLICATED(HttpStatus.CONFLICT, "COMPANY-002", "이미 사용 중인 업체 코드입니다."),
    COMPANY_INACTIVE(HttpStatus.FORBIDDEN, "COMPANY-003", "비활성화된 업체입니다."),
    COMPANY_BUSINESS_REGISTRATION_NO_DUPLICATED(
            HttpStatus.CONFLICT,
            "COMPANY-004",
            "이미 등록된 사업자등록번호입니다."
    ),

    MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "MEMBER-001", "사용자를 찾을 수 없습니다."),
    MEMBER_LOGIN_ID_DUPLICATED(HttpStatus.CONFLICT, "MEMBER-002", "이미 사용 중인 로그인 ID입니다."),
    MEMBER_INACTIVE(HttpStatus.FORBIDDEN, "MEMBER-003", "비활성화된 사용자입니다."),
    MEMBER_TEMP_PASSWORD_EXPIRED(HttpStatus.UNAUTHORIZED, "MEMBER-004", "임시 비밀번호가 만료되었습니다."),
    MEMBER_PASSWORD_CHANGE_REQUIRED(HttpStatus.FORBIDDEN, "MEMBER-005", "임시 비밀번호를 먼저 변경해 주세요."),

    PARTNER_NOT_FOUND(HttpStatus.NOT_FOUND, "PARTNER-001", "거래처를 찾을 수 없습니다."),
    PARTNER_NAME_DUPLICATED(HttpStatus.CONFLICT, "PARTNER-002", "이미 사용 중인 거래처명입니다."),
    PARTNER_INACTIVE(HttpStatus.BAD_REQUEST, "PARTNER-003", "사용할 수 없는 거래처입니다."),

    CATEGORY_NOT_FOUND(HttpStatus.NOT_FOUND, "CATEGORY-001", "분류를 찾을 수 없습니다."),
    CATEGORY_NAME_DUPLICATED(HttpStatus.CONFLICT, "CATEGORY-002", "이미 사용 중인 분류명입니다."),
    CATEGORY_IN_USE(HttpStatus.CONFLICT, "CATEGORY-003", "연결된 품목이 있는 분류는 삭제할 수 없습니다."),

    PART_NOT_FOUND(HttpStatus.NOT_FOUND, "PART-001", "부품을 찾을 수 없습니다."),
    PART_CODE_DUPLICATED(HttpStatus.CONFLICT, "PART-002", "이미 사용 중인 부품 코드입니다."),
    PART_UNIT_NOT_FOUND(HttpStatus.NOT_FOUND, "PART-003", "개별 부품을 찾을 수 없습니다."),
    PART_UNIT_SERIAL_DUPLICATED(HttpStatus.CONFLICT, "PART-004", "이미 사용 중인 관리번호 또는 제조사 시리얼 번호입니다."),
    PART_INVALID_STATUS_CHANGE(HttpStatus.BAD_REQUEST, "PART-005", "변경할 수 없는 부품 상태입니다."),

    STOCK_NOT_ENOUGH(HttpStatus.BAD_REQUEST, "STOCK-001", "출고 가능한 재고가 부족합니다."),
    STOCK_DOCUMENT_NOT_FOUND(HttpStatus.NOT_FOUND, "STOCK-002", "입출고 전표를 찾을 수 없습니다."),
    STOCK_MOVEMENT_NOT_FOUND(HttpStatus.NOT_FOUND, "STOCK-003", "재고 변화 이력을 찾을 수 없습니다."),
    STOCK_DOCUMENT_ALREADY_CANCELED(HttpStatus.CONFLICT, "STOCK-004", "이미 취소된 입출고 전표입니다."),
    STOCK_INVALID_CANCEL_REQUEST(HttpStatus.BAD_REQUEST, "STOCK-005", "취소할 수 없는 입출고 전표입니다."),
    STOCK_DOCUMENT_NO_DUPLICATED(HttpStatus.CONFLICT, "STOCK-006", "이미 사용 중인 입출고 전표 번호입니다."),
    STOCK_STATE_CONFLICT(HttpStatus.CONFLICT, "STOCK-007", "재고 상태가 변경되어 요청을 처리할 수 없습니다."),

    INSPECTION_NOT_FOUND(HttpStatus.NOT_FOUND, "INSPECTION-001", "검수 이력을 찾을 수 없습니다."),
    INSPECTION_TEMPLATE_NOT_FOUND(HttpStatus.NOT_FOUND, "INSPECTION-002", "검수 템플릿을 찾을 수 없습니다."),
    INSPECTION_TEMPLATE_ITEM_NOT_FOUND(HttpStatus.NOT_FOUND, "INSPECTION-003", "검수 항목을 찾을 수 없습니다."),
    INSPECTION_TEMPLATE_OPTION_NOT_FOUND(HttpStatus.NOT_FOUND, "INSPECTION-004", "검수 선택지를 찾을 수 없습니다."),
    INSPECTION_ALREADY_COMPLETED(HttpStatus.CONFLICT, "INSPECTION-005", "이미 검수 완료된 개별 부품입니다."),
    INSPECTION_TEMPLATE_DUPLICATED(HttpStatus.CONFLICT, "INSPECTION-006", "이미 등록된 검수 템플릿입니다."),
    INSPECTION_TEMPLATE_ITEM_DUPLICATED(HttpStatus.CONFLICT, "INSPECTION-007", "이미 등록된 검수 항목입니다."),
    INSPECTION_TEMPLATE_OPTION_DUPLICATED(HttpStatus.CONFLICT, "INSPECTION-008", "이미 등록된 검수 선택지입니다.");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;

    ErrorCode(HttpStatus httpStatus, String code, String message) {
        this.httpStatus = httpStatus;
        this.code = code;
        this.message = message;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
