package com.pcs.global.dto;

import com.pcs.global.error.ErrorCode;

public record ApiResultDto<T>(
        boolean success,
        String code,
        String message,
        T data
) {

    private static final String SUCCESS_CODE = "COMMON-000";
    private static final String SUCCESS_MESSAGE = "요청이 정상 처리되었습니다.";

    public static ApiResultDto<Void> ok() {
        return new ApiResultDto<>(true, SUCCESS_CODE, SUCCESS_MESSAGE, null);
    }

    public static <T> ApiResultDto<T> ok(T data) {
        return new ApiResultDto<>(true, SUCCESS_CODE, SUCCESS_MESSAGE, data);
    }

    public static <T> ApiResultDto<T> ok(String message, T data) {
        return new ApiResultDto<>(true, SUCCESS_CODE, message, data);
    }

    public static ApiResultDto<Void> error(ErrorCode errorCode) {
        return new ApiResultDto<>(false, errorCode.getCode(), errorCode.getMessage(), null);
    }

    public static ApiResultDto<Void> error(ErrorCode errorCode, String message) {
        return new ApiResultDto<>(false, errorCode.getCode(), message, null);
    }

    public static <T> ApiResultDto<T> error(ErrorCode errorCode, T data) {
        return new ApiResultDto<>(false, errorCode.getCode(), errorCode.getMessage(), data);
    }
}
