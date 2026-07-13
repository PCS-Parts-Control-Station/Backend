package com.pcs.global.security;

import com.pcs.global.error.ApiErrorResponseWriter;
import com.pcs.global.error.ErrorCode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ApiErrorResponseWriter errorResponseWriter;

    public JwtAuthenticationEntryPoint(ApiErrorResponseWriter errorResponseWriter) {
        this.errorResponseWriter = errorResponseWriter;
    }

    @Override
    public void commence(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException authException
    ) throws IOException {
        ErrorCode errorCode = ErrorCode.AUTH_REQUIRED;
        String message = errorCode.getMessage();

        if (authException instanceof PcsAuthenticationException pcsException) {
            errorCode = pcsException.getErrorCode();
            message = pcsException.getMessage();
        }

        errorResponseWriter.write(response, errorCode, message);
    }
}
