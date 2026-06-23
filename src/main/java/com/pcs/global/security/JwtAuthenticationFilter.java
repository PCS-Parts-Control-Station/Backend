package com.pcs.global.security;

import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final Logger log = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private final JwtTokenProvider jwtTokenProvider;
    private final AccessTokenSessionValidator accessTokenSessionValidator;
    private final JwtAuthenticationEntryPoint authenticationEntryPoint;

    public JwtAuthenticationFilter(
            JwtTokenProvider jwtTokenProvider,
            AccessTokenSessionValidator accessTokenSessionValidator,
            JwtAuthenticationEntryPoint authenticationEntryPoint
    ) {
        this.jwtTokenProvider = jwtTokenProvider;
        this.accessTokenSessionValidator = accessTokenSessionValidator;
        this.authenticationEntryPoint = authenticationEntryPoint;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String authorizationHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authorizationHeader == null || authorizationHeader.isBlank()) {
            filterChain.doFilter(request, response);
            return;
        }

        if (!authorizationHeader.startsWith(BEARER_PREFIX)) {
            authenticationEntryPoint.commence(
                    request,
                    response,
                    new PcsAuthenticationException(
                            ErrorCode.AUTH_TOKEN_INVALID,
                            ErrorCode.AUTH_TOKEN_INVALID.getMessage()
                    )
            );
            return;
        }

        try {
            String token = authorizationHeader.substring(BEARER_PREFIX.length()).trim();
            JwtClaims claims = jwtTokenProvider.parseAccessToken(token);
            accessTokenSessionValidator.validate(claims);
            PcsPrincipal principal = PcsPrincipal.from(claims);
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    principal,
                    null,
                    principal.authorities()
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);
        } catch (BusinessException exception) {
            SecurityContextHolder.clearContext();
            commence(request, response, exception.getErrorCode(), exception);
            return;
        } catch (RuntimeException exception) {
            SecurityContextHolder.clearContext();
            log.error("Failed to validate access token session.", exception);
            commence(request, response, ErrorCode.INTERNAL_SERVER_ERROR, exception);
            return;
        }

        filterChain.doFilter(request, response);
    }

    private void commence(
            HttpServletRequest request,
            HttpServletResponse response,
            ErrorCode errorCode,
            RuntimeException exception
    ) throws IOException {
        authenticationEntryPoint.commence(
                request,
                response,
                new PcsAuthenticationException(
                        errorCode,
                        errorCode == ErrorCode.INTERNAL_SERVER_ERROR
                                ? errorCode.getMessage()
                                : exception.getMessage(),
                        exception
                )
        );
    }
}
