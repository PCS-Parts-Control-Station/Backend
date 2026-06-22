package com.pcs.domain.part.facade;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.part.service.PartService;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import com.pcs.global.workspace.WorkspaceMapper;
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
    private WorkspaceMapper workspaceMapper;

    private PartFacade partFacade;

    @BeforeEach
    void setUp() {
        partFacade = new PartFacade(partService, new WorkspaceAccessValidator(workspaceMapper));
    }

    @Test
    void searchParts_success() {
        PcsPrincipal principal = principal(1L, 10L, "acme");
        when(partService.searchParts(1L, "RTX", null, true, 0, 20, null))
                .thenReturn(PageResultDto.of(List.of(), 0, 20, 0, null));

        var response = partFacade.searchParts(principal, "acme", "RTX", null, true, 0, 20, null);

        assertEquals(0, response.content().size());
        verify(partService).searchParts(1L, "RTX", null, true, 0, 20, null);
    }

    @Test
    void searchParts_failsWhenAuthorizationMissing() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.searchParts(null, "acme", null, null, true, 0, 20, null)
        );

        assertEquals(ErrorCode.AUTH_REQUIRED, exception.getErrorCode());
    }

    @Test
    void searchParts_failsWhenWorkspaceMismatch() {
        PcsPrincipal principal = principal(1L, 10L, "acme");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> partFacade.searchParts(principal, "other", null, null, true, 0, 20, null)
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
