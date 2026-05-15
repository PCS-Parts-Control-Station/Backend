package com.pcs.domain.inspection.validation;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;

public interface InspectionDecisionValidatable {

    InspectionResult result();

    PartGrade grade();

    SalesStatus salesStatus();
}
