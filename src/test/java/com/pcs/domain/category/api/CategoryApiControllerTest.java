package com.pcs.domain.category.api;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.pcs.domain.category.dto.request.CategorySpecDefinitionRequest;
import com.pcs.domain.category.dto.request.CategorySpecOptionRequest;
import com.pcs.domain.category.dto.request.CreateCategoryRequest;
import com.pcs.domain.category.dto.request.UpdateCategoryRequest;
import com.pcs.domain.category.dto.response.CategoryDetailResponse;
import com.pcs.domain.category.dto.response.CategorySpecDefinitionResponse;
import com.pcs.domain.category.dto.response.CategorySpecOptionResponse;
import com.pcs.domain.category.dto.response.SearchCategoryResponse;
import com.pcs.domain.category.facade.CategoryFacade;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.GlobalExceptionHandler;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.security.PcsPrincipal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.method.annotation.AuthenticationPrincipalArgumentResolver;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@ExtendWith(MockitoExtension.class)
class CategoryApiControllerTest {

    @Mock
    private CategoryFacade categoryFacade;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;
    private PcsPrincipal principal;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        mockMvc = MockMvcBuilders
                .standaloneSetup(new CategoryApiController(categoryFacade))
                .setControllerAdvice(new GlobalExceptionHandler())
                .setCustomArgumentResolvers(new AuthenticationPrincipalArgumentResolver())
                .setMessageConverters(new MappingJackson2HttpMessageConverter(objectMapper))
                .build();
        principal = new PcsPrincipal(7L, 1L, "acme", "admin", MemberRole.ADMIN, Instant.now().plusSeconds(600));
        authenticate(principal);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void searchCategories_returnsPagedCategoryList() throws Exception {
        SearchCategoryResponse category = new SearchCategoryResponse(
                10L,
                "GPU",
                "Graphic cards",
                3L,
                LocalDateTime.of(2026, 6, 5, 10, 0)
        );
        when(categoryFacade.searchCategories(principal, "acme", "GPU", 1, 5, null))
                .thenReturn(PageResultDto.of(List.of(category), 1, 5, 9, null));

        mockMvc.perform(get("/api/workspaces/acme/categories")
                        .param("keyword", "GPU")
                        .param("page", "1")
                        .param("size", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content[0].categoryName").value("GPU"))
                .andExpect(jsonPath("$.data.content[0].partCount").value(3))
                .andExpect(jsonPath("$.data.page").value(1))
                .andExpect(jsonPath("$.data.size").value(5))
                .andExpect(jsonPath("$.data.totalElements").value(9));

        verify(categoryFacade).searchCategories(principal, "acme", "GPU", 1, 5, null);
    }

    @Test
    void createCategory_returnsCreatedDetail() throws Exception {
        CreateCategoryRequest request = new CreateCategoryRequest(
                "RAM",
                "Memory",
                List.of(new CategorySpecDefinitionRequest(
                        "memory_type",
                        "Memory Type",
                        "SELECT",
                        null,
                        true,
                        true,
                        0,
                        List.of(new CategorySpecOptionRequest("DDR5", "DDR5", 0))
                ))
        );
        when(categoryFacade.createCategory(eq(principal), eq("acme"), any(CreateCategoryRequest.class)))
                .thenReturn(categoryDetail(11L, "RAM"));

        mockMvc.perform(post("/api/workspaces/acme/categories")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.categoryId").value(11))
                .andExpect(jsonPath("$.data.specDefinitions[0].specKey").value("memory_type"))
                .andExpect(jsonPath("$.data.specDefinitions[0].options[0].optionValue").value("DDR5"));
    }

    @Test
    void updateCategory_returnsBusinessErrorWhenNameDuplicated() throws Exception {
        UpdateCategoryRequest request = new UpdateCategoryRequest("RAM", "Memory", null);
        doThrow(new BusinessException(ErrorCode.CATEGORY_NAME_DUPLICATED))
                .when(categoryFacade).updateCategory(eq(principal), eq("acme"), eq(11L), any(UpdateCategoryRequest.class));

        mockMvc.perform(patch("/api/workspaces/acme/categories/11")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.code").value("CATEGORY-002"));
    }

    @Test
    void deleteCategory_returnsOk() throws Exception {
        mockMvc.perform(delete("/api/workspaces/acme/categories/11"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(categoryFacade).deleteCategory(principal, "acme", 11L);
    }

    private void authenticate(PcsPrincipal principal) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();
        TestingAuthenticationToken authentication = new TestingAuthenticationToken(principal, null);
        authentication.setAuthenticated(true);
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    private CategoryDetailResponse categoryDetail(Long categoryId, String name) {
        return new CategoryDetailResponse(
                categoryId,
                name,
                name + " description",
                0L,
                LocalDateTime.of(2026, 6, 5, 10, 0),
                List.of(new CategorySpecDefinitionResponse(
                        101L,
                        categoryId,
                        "memory_type",
                        "Memory Type",
                        "SELECT",
                        null,
                        true,
                        true,
                        0,
                        true,
                        List.of(new CategorySpecOptionResponse(201L, 101L, "DDR5", "DDR5", 0, true))
                ))
        );
    }
}
