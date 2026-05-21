package com.pcs.domain.member.service;

import com.pcs.domain.member.entity.Member;
import com.pcs.domain.member.mapper.MemberMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class MemberService {

    private static final int OWNER_SLOT = 1;

    private final MemberMapper memberMapper;
    private final PasswordEncoder passwordEncoder;

    public MemberService(MemberMapper memberMapper, PasswordEncoder passwordEncoder) {
        this.memberMapper = memberMapper;
        this.passwordEncoder = passwordEncoder;
    }

    public OwnerMemberCreationResult createOwner(Long companyId, String loginId, String name, String rawPassword) {
        Member owner = new Member(
                companyId,
                loginId,
                passwordEncoder.encode(rawPassword),
                name,
                MemberRole.OWNER,
                OWNER_SLOT,
                PasswordStatus.ACTIVE,
                null,
                null
        );
        memberMapper.insert(owner);
        return new OwnerMemberCreationResult(owner.getMemberId(), owner.getLoginId());
    }
}
