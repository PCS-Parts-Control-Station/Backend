package com.pcs.domain.inspection.validation;

import com.pcs.domain.part.type.PartGrade;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class NotNoneGradeValidator implements ConstraintValidator<NotNoneGrade, PartGrade> {

    @Override
    public boolean isValid(PartGrade value, ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }
        return value != PartGrade.NONE;
    }
}
