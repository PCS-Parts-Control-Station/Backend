package com.pcs.global.util;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;

public final class TextNormalizer {

    private TextNormalizer() {
    }

    public static String optional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    public static String required(String value) {
        String normalized = optional(value);
        if (normalized == null) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return normalized;
    }
}
