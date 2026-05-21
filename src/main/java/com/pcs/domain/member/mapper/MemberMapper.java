package com.pcs.domain.member.mapper;

import com.pcs.domain.member.entity.Member;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MemberMapper {

    void insert(Member member);
}
