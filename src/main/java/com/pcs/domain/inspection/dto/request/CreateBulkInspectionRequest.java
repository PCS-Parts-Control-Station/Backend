package com.pcs.domain.inspection.dto.request;

import com.pcs.domain.inspection.type.InspectionResult;
import com.pcs.domain.inspection.validation.InspectionDecisionValidatable;
import com.pcs.domain.inspection.validation.NotNoneGrade;
import com.pcs.domain.inspection.validation.ValidInspectionDecision;
import com.pcs.domain.part.type.PartGrade;
import com.pcs.domain.part.type.SalesStatus;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

@ValidInspectionDecision
public record CreateBulkInspectionRequest(
        @NotEmpty(message = "unitIds는 1개 이상 필요합니다.")
        @Size(max = 100, message = "한 번에 최대 100개까지 검수할 수 있습니다.")
        List<@NotNull Long> unitIds,

        Long templateId,

        @NotNull(message = "result는 필수입니다.")
        InspectionResult result,

        @NotNull(message = "grade는 필수입니다.")
        @NotNoneGrade
        PartGrade grade,

        @NotNull(message = "salesStatus는 필수입니다.")
        SalesStatus salesStatus,

        @Size(max = 1000, message = "memo는 최대 1000자까지 입력할 수 있습니다.")
        String memo,

        @Valid
        List<CreateInspectionItemResultRequest> itemResults
) implements InspectionDecisionValidatable {
}
