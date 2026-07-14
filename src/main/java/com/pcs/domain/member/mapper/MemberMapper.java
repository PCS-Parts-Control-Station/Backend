package com.pcs.domain.member.mapper;

import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.entity.Member;
import com.pcs.domain.member.entity.MemberAccount;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import java.time.LocalDateTime;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface MemberMapper {

    void insert(Member member);

    List<SearchMemberResponse> searchMembers(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("role") MemberRole role,
            @Param("passwordStatus") PasswordStatus passwordStatus,
            @Param("manageableRoles") List<MemberRole> manageableRoles,
            @Param("createdFrom") LocalDateTime createdFrom,
            @Param("createdTo") LocalDateTime createdTo,
            @Param("size") int size,
            @Param("offset") int offset
    );

    SearchMemberSummaryResponse summarizeMembers(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("role") MemberRole role,
            @Param("passwordStatus") PasswordStatus passwordStatus,
            @Param("manageableRoles") List<MemberRole> manageableRoles,
            @Param("createdFrom") LocalDateTime createdFrom,
            @Param("createdTo") LocalDateTime createdTo
    );

    SearchMemberResponse findResponseById(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId
    );

    boolean existsByLoginId(
            @Param("companyId") Long companyId,
            @Param("loginId") String loginId
    );

    int updateMember(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("memberName") String memberName,
            @Param("role") MemberRole role
    );

    int updateTemporaryPassword(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("passwordHash") String passwordHash,
            @Param("expiresAt") LocalDateTime expiresAt
    );

    MemberAccount findAccount(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId
    );

    int updateMypageName(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("name") String name
    );

    int updateMypagePassword(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("passwordHash") String passwordHash
    );
}
