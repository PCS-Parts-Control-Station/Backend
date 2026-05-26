package com.pcs.global.security;

import com.pcs.global.error.ErrorCode;
import org.springframework.security.core.AuthenticationException;

public class PcsAuthenticationException extends AuthenticationException {

    private final ErrorCode errorCode;

    public PcsAuthenticationException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public PcsAuthenticationException(ErrorCode errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    public ErrorCode getErrorCode() {
        return errorCode;
    }
}
