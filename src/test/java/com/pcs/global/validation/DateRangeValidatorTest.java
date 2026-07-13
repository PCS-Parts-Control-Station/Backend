package com.pcs.global.validation;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import java.time.LocalDate;
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
}
