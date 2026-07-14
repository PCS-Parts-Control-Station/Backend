package com.pcs.domain.category.type;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.util.TextNormalizer;
import java.util.Locale;
import java.util.Set;

public final class PartSpecInputTypes {

    public static final String TEXT = "TEXT";
    public static final String NUMBER = "NUMBER";
    public static final String SELECT = "SELECT";
    public static final String BOOLEAN = "BOOLEAN";

    private static final Set<String> VALUES = Set.of(TEXT, NUMBER, SELECT, BOOLEAN);

    private PartSpecInputTypes() {
    }

    public static String normalizeOrDefault(String value) {
        String inputType = TextNormalizer.optional(value);
        if (inputType == null) {
            return TEXT;
        }

        inputType = inputType.toUpperCase(Locale.ROOT);
        if (!VALUES.contains(inputType)) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "사양 입력 방식이 올바르지 않습니다.");
        }
        return inputType;
    }

    public static boolean isNumber(String value) {
        return NUMBER.equals(value);
    }

    public static boolean isSelect(String value) {
        return SELECT.equals(value);
    }

    public static boolean isBoolean(String value) {
        return BOOLEAN.equals(value);
    }
}
