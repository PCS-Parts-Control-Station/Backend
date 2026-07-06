package com.pcs.domain.company.api;

import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.pcs.domain.company.dto.response.WorkspacePublicInfoResponse;
import com.pcs.domain.company.facade.CompanyFacade;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class WorkspacePublicApiControllerTest {

    @Mock
    private CompanyFacade companyFacade;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .standaloneSetup(new WorkspacePublicApiController(companyFacade))
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Test
    void publicInfo_returnsWorkspacePublicInfo() throws Exception {
        when(companyFacade.findWorkspacePublicInfo("acme"))
                .thenReturn(new WorkspacePublicInfoResponse("acme", "ACME Parts", true));

        mockMvc.perform(get("/api/workspaces/acme/public-info"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.companyCode").value("acme"))
                .andExpect(jsonPath("$.data.companyName").value("ACME Parts"));
    }

    @Test
    void publicInfo_returnsNotFoundWhenWorkspaceDoesNotExist() throws Exception {
        doThrow(new BusinessException(ErrorCode.COMPANY_NOT_FOUND))
                .when(companyFacade).findWorkspacePublicInfo("missing");

        mockMvc.perform(get("/api/workspaces/missing/public-info"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("COMPANY-001"));
    }
}
