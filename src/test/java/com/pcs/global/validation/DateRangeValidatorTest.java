package com.pcs.global.validation;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class DateRangeValidatorTest {

    @Test
    void validate_acceptsSameDate() {
        LocalDate date = LocalDate.of(2026, 7, 13);

        assertDoesNotThrow(() -> DateRangeValidator.validate(date, date));
    }

    @Test
    void validate_rejectsReversedRange() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> DateRangeValidator.validate(
                        LocalDate.of(2026, 7, 14),
                        LocalDate.of(2026, 7, 13)
                )
        );

        assertEquals(ErrorCode.INVALID_INPUT_VALUE, exception.getErrorCode());
    }

    @Test
    void normalize_convertsInclusiveDatesToHalfOpenDateTimeRange() {
        DateRangeValidator.NormalizedDateRange range = DateRangeValidator.normalize(
                LocalDate.of(2026, 7, 1),
                LocalDate.of(2026, 7, 13)
        );

        assertEquals(LocalDateTime.of(2026, 7, 1, 0, 0), range.fromInclusive());
        assertEquals(LocalDateTime.of(2026, 7, 14, 0, 0), range.toExclusive());
    }

    @Test
    void normalize_rejectsMaximumEndDateInsteadOfOverflowing() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> DateRangeValidator.normalize(null, LocalDate.MAX)
        );

        assertEquals(ErrorCode.INVALID_INPUT_VALUE, exception.getErrorCode());
    }
}
