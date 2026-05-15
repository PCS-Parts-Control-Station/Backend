package com.pcs.domain.inspection.validation;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class ValidInspectionDecisionValidator
        implements ConstraintValidator<ValidInspectionDecision, InspectionDecisionValidatable> {

    @Override
    public boolean isValid(InspectionDecisionValidatable value, ConstraintValidatorContext context) {
        if (value == null || value.result() == null || value.grade() == null || value.salesStatus() == null) {
            return true;
        }

        boolean valid = true;
        context.disableDefaultConstraintViolation();

        if (value.result() == InspectionResult.PASS && value.grade() == PartGrade.DEFECTIVE) {
            addViolation(context, "PASS 결과에 DEFECTIVE 등급은 사용할 수 없습니다.", "grade");
            valid = false;
        }

        if (value.grade() == PartGrade.DEFECTIVE && value.salesStatus() != SalesStatus.UNAVAILABLE) {
            addViolation(context, "DEFECTIVE 등급은 salesStatus=UNAVAILABLE 이어야 합니다.", "salesStatus");
            valid = false;
        }

        return valid;
    }

    private void addViolation(ConstraintValidatorContext context, String message, String property) {
        context.buildConstraintViolationWithTemplate(message)
                .addPropertyNode(property)
                .addConstraintViolation();
    }
}
