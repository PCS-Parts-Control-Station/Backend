package com.pcs.domain.auth.mapper;

import com.pcs.domain.auth.entity.AuthMember;
import com.pcs.domain.auth.entity.AuthRefreshToken;
import com.pcs.domain.auth.entity.AuthRefreshTokenSession;
import com.pcs.domain.auth.type.LoginResult;
import com.pcs.domain.auth.type.RefreshTokenRevokedReason;
import java.time.LocalDateTime;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface AuthMapper {

    AuthMember findLoginMember(
            @Param("companyCode") String companyCode,
            @Param("loginId") String loginId
    );

    AuthMember findSessionMember(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId
    );

    void recordLoginFailure(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("lockedUntilAt") LocalDateTime lockedUntilAt
    );

    void recordLoginSuccess(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("lastLoginIp") String lastLoginIp,
            @Param("lastLoginUserAgent") String lastLoginUserAgent
    );

    void insertLoginHistory(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("companyCodeSnapshot") String companyCodeSnapshot,
            @Param("loginIdSnapshot") String loginIdSnapshot,
            @Param("loginResult") LoginResult loginResult,
            @Param("failureReason") String failureReason,
            @Param("loginIp") String loginIp,
            @Param("userAgent") String userAgent
    );

    void insertRefreshToken(AuthRefreshToken refreshToken);

    AuthRefreshTokenSession findRefreshTokenSession(String refreshTokenHash);

    void revokeRefreshToken(
            @Param("tokenId") Long tokenId,
            @Param("revokedReason") RefreshTokenRevokedReason revokedReason,
            @Param("replacedByTokenId") Long replacedByTokenId
    );

    void revokeRefreshTokenFamily(
            @Param("companyId") Long companyId,
            @Param("memberId") Long memberId,
            @Param("tokenFamilyId") String tokenFamilyId,
            @Param("revokedReason") RefreshTokenRevokedReason revokedReason
    );
}
