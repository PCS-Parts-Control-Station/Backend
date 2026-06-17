package com.pcs.domain.member.dto.response;

public record SearchMemberSummaryResponse(
        long totalCount,
        long adminCount,
        long staffCount
) {
}
