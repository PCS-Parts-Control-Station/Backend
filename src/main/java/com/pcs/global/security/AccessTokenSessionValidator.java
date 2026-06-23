package com.pcs.global.security;

import com.pcs.domain.auth.mapper.AuthMapper;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import org.springframework.stereotype.Component;

@Component
public class AccessTokenSessionValidator {

    private final AuthMapper authMapper;

    public AccessTokenSessionValidator(AuthMapper authMapper) {
        this.authMapper = authMapper;
    }

    public void validate(JwtClaims claims) {
        boolean active = authMapper.existsActiveRefreshTokenFamily(
                claims.companyId(),
                claims.memberId(),
                claims.sessionId()
        );
        if (!active) {
            throw new BusinessException(ErrorCode.AUTH_TOKEN_INVALID);
        }
    }
}
