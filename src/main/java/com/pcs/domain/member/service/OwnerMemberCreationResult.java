package com.pcs.domain.member.service;

public record OwnerMemberCreationResult(
        Long memberId,
        String loginId
) {
}
