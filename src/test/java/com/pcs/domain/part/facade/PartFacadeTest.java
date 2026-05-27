package com.pcs.domain.part.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.service.PartService;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.jwt.JwtClaims;
import com.pcs.global.jwt.JwtTokenProvider;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PartFacadeTest {

    @Mock
    private PartService partService;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    private PartFacade partFacade;

    @BeforeEach
    void setUp() {
        partFacade = new PartFacade(partService, jwtTokenProvider);
    }

    @Test
    void searchParts_success() {
        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));
        when(partService.searchParts(1L, "RTX", null, true, 20)).thenReturn(List.of());

        List<?> response = partFacade.searchParts("Bearer token", "acme", "RTX", null, true, 20);

        assertEquals(0, response.size());
        verify(partService).searchParts(1L, "RTX", null, true, 20);
    }

    @Test
    void searchParts_failsWhenAuthorizationMissing() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.searchParts(null, "acme", null, null, true, 20)
        );

        assertEquals(ErrorCode.AUTH_REQUIRED, exception.getErrorCode());
    }

    @Test
    void searchParts_failsWhenWorkspaceMismatch() {
        when(jwtTokenProvider.parseAccessToken("token")).thenReturn(claims(1L, 10L, "acme"));

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.searchParts("Bearer token", "other", null, null, true, 20)
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    private JwtClaims claims(Long companyId, Long memberId, String companyCode) {
        return new JwtClaims(
                memberId,
                companyId,
                companyCode,
                "admin",
                MemberRole.ADMIN,
                "ACCESS",
                Instant.now().plusSeconds(1800)
        );
    }
}
