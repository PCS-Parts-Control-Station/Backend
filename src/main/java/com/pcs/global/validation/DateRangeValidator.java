package com.pcs.global.validation;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.LocalDateTime;

public final class DateRangeValidator {

    private DateRangeValidator() {
    }

    public static void validate(LocalDate dateFrom, LocalDate dateTo) {
        if (dateFrom != null && dateTo != null && dateFrom.isAfter(dateTo)) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "시작일은 종료일보다 늦을 수 없습니다.");
        }
    }

    public static LocalDateTime toStartOfDay(LocalDate date) {
        return date == null ? null : date.atStartOfDay();
    }

    public static LocalDateTime toExclusiveEnd(LocalDate date) {
        if (date == null) {
            return null;
        }
        try {
            return date.plusDays(1).atStartOfDay();
        } catch (DateTimeException exception) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "종료일 범위가 올바르지 않습니다.");
        }
    }
}
