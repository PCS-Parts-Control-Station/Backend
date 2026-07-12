package com.pcs.domain.inspection.validation;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.RETURNS_DEEP_STUBS;
import static org.mockito.Mockito.mock;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import jakarta.validation.ConstraintValidatorContext;
import org.junit.jupiter.api.Test;

class InspectionDecisionValidatorTest {

    private final ValidInspectionDecisionValidator decisionValidator = new ValidInspectionDecisionValidator();
    private final NotNoneGradeValidator gradeValidator = new NotNoneGradeValidator();
    private final ConstraintValidatorContext context = mock(ConstraintValidatorContext.class, RETURNS_DEEP_STUBS);

    @Test
    void acceptsConsistentInspectionDecisions() {
        assertThat(decisionValidator.isValid(decision(InspectionResult.PASS, PartGrade.A, SalesStatus.AVAILABLE), context))
                .isTrue();
        assertThat(decisionValidator.isValid(decision(InspectionResult.FAIL, PartGrade.DEFECTIVE, SalesStatus.UNAVAILABLE), context))
                .isTrue();
    }

    @Test
    void rejectsPassWithDefectiveGrade() {
        assertThat(decisionValidator.isValid(
                decision(InspectionResult.PASS, PartGrade.DEFECTIVE, SalesStatus.UNAVAILABLE),
                context
        )).isFalse();
    }

    @Test
    void rejectsDefectiveGradeWhenSaleIsNotBlocked() {
        assertThat(decisionValidator.isValid(
                decision(InspectionResult.FAIL, PartGrade.DEFECTIVE, SalesStatus.AVAILABLE),
                context
        )).isFalse();
    }

    @Test
    void noneGradeIsRejectedWhileNullIsLeftToNotNullValidation() {
        assertThat(gradeValidator.isValid(PartGrade.NONE, context)).isFalse();
        assertThat(gradeValidator.isValid(PartGrade.A, context)).isTrue();
        assertThat(gradeValidator.isValid(null, context)).isTrue();
    }

    private InspectionDecisionValidatable decision(
            InspectionResult result,
            PartGrade grade,
            SalesStatus salesStatus
    ) {
        return new InspectionDecisionValidatable() {
            @Override
            public InspectionResult result() {
                return result;
            }

            @Override
            public PartGrade grade() {
                return grade;
            }

            @Override
            public SalesStatus salesStatus() {
                return salesStatus;
            }
        };
    }
}
