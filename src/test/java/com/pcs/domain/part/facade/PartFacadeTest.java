package com.pcs.domain.part.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.dto.response.SearchPartSummaryResponse;
import com.pcs.domain.part.dto.response.SearchPartUnitSummaryResponse;
import com.pcs.domain.part.service.PartService;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
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
    private WorkspaceAccessValidator workspaceAccessValidator;

    private PartFacade partFacade;

    @BeforeEach
    void setUp() {
        partFacade = new PartFacade(partService, workspaceAccessValidator);
    }

    @Test
    void searchParts_success() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        SearchPartSummaryResponse summary = new SearchPartSummaryResponse(0, 0, 0);
        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "acme")).thenReturn(principal);
        when(partService.searchParts(1L, "RTX", null, true, 0, 20, null))
                .thenReturn(PageResultDto.of(List.of(), 0, 20, 0, summary));

        var response = partFacade.searchParts(principal, "acme", "RTX", null, true, 0, 20, null);

        assertEquals(0, response.content().size());
        assertEquals(summary, response.summary());
        verify(partService).searchParts(1L, "RTX", null, true, 0, 20, null);
    }

    @Test
    void searchParts_failsWhenAuthorizationMissing() {
        doThrow(new BusinessException(ErrorCode.AUTH_REQUIRED))
                .when(workspaceAccessValidator)
                .validateAuthenticatedWorkspace(null, "acme");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.searchParts(null, "acme", null, null, true, 0, 20, null)
        );

        assertEquals(ErrorCode.AUTH_REQUIRED, exception.getErrorCode());
    }

    @Test
    void searchParts_failsWhenWorkspaceMismatch() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        doThrow(new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH))
                .when(workspaceAccessValidator)
                .validateAuthenticatedWorkspace(principal, "other");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.searchParts(principal, "other", null, null, true, 0, 20, null)
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    @Test
    void searchPartUnits_success() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        SearchPartUnitSummaryResponse summary = new SearchPartUnitSummaryResponse(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        when(workspaceAccessValidator.validateAuthenticatedWorkspace(principal, "acme")).thenReturn(principal);
        when(partService.searchPartUnits(1L, "RTX", 77L, 10L, "WAITING", 0, 20, null))
                .thenReturn(PageResultDto.of(List.of(), 0, 20, 0, summary));

        var response = partFacade.searchPartUnits(principal, "acme", "RTX", 77L, 10L, "WAITING", 0, 20, null);

        assertEquals(0, response.content().size());
        assertEquals(summary, response.summary());
        verify(partService).searchPartUnits(1L, "RTX", 77L, 10L, "WAITING", 0, 20, null);
    }

    @Test
    void getPartUnit_failsWhenWorkspaceMismatch() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        doThrow(new BusinessException(ErrorCode.AUTH_WORKSPACE_MISMATCH))
                .when(workspaceAccessValidator)
                .validateAuthenticatedWorkspace(principal, "other");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.getPartUnit(principal, "other", 101L)
        );

        assertEquals(ErrorCode.AUTH_WORKSPACE_MISMATCH, exception.getErrorCode());
    }

    private PcsPrincipal principal(Long companyId, Long memberId, String companyCode) {
        return new PcsPrincipal(
                memberId,
                companyId,
                companyCode,
                "admin",
                MemberRole.ADMIN,
                Instant.now().plusSeconds(1800)
        );
    }
}
