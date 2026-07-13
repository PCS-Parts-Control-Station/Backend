package com.pcs.global.error;

import static org.assertj.core.api.Assertions.assertThat;

import com.pcs.domain.auth.api.AuthApiController;
import com.pcs.domain.category.api.CategoryApiController;
import com.pcs.domain.company.api.OwnerSignupApiController;
import com.pcs.domain.company.api.WorkspacePublicApiController;
import com.pcs.domain.dashboard.api.DashboardApiController;
import com.pcs.domain.inspection.api.InspectionApiController;
import com.pcs.domain.inspection.api.InspectionTemplateApiController;
import com.pcs.domain.member.api.MemberApiController;
import com.pcs.domain.part.api.PartApiController;
import com.pcs.domain.partner.api.PartnerApiController;
import com.pcs.domain.stock.api.StockApiController;
import com.pcs.global.dto.ApiResultDto;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.Modifier;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.core.annotation.AnnotatedElementUtils;

class ApiControllerContractTest {

    private static final List<Class<?>> API_CONTROLLERS = List.of(
            AuthApiController.class,
            CategoryApiController.class,
            OwnerSignupApiController.class,
            WorkspacePublicApiController.class,
            DashboardApiController.class,
            InspectionApiController.class,
            InspectionTemplateApiController.class,
            MemberApiController.class,
            PartApiController.class,
            PartnerApiController.class,
            StockApiController.class
    );

    @Test
    void everyApiEndpoint_wrapsResponseWithApiResultDto() {
        for (Class<?> controller : API_CONTROLLERS) {
            for (Method method : controller.getDeclaredMethods()) {
                if (!Modifier.isPublic(method.getModifiers())
                        || !AnnotatedElementUtils.hasAnnotation(method, RequestMapping.class)) {
                    continue;
                }

                ParameterizedType responseEntityType = requireParameterizedType(
                        method.getGenericReturnType(),
                        controller,
                        method
                );
                assertThat(responseEntityType.getRawType())
                        .as("%s#%s must return ResponseEntity", controller.getSimpleName(), method.getName())
                        .isEqualTo(ResponseEntity.class);

                Type responseBodyType = responseEntityType.getActualTypeArguments()[0];
                ParameterizedType apiResultType = requireParameterizedType(responseBodyType, controller, method);
                assertThat(apiResultType.getRawType())
                        .as("%s#%s must wrap its body with ApiResultDto", controller.getSimpleName(), method.getName())
                        .isEqualTo(ApiResultDto.class);
            }
        }
    }

    private ParameterizedType requireParameterizedType(Type type, Class<?> controller, Method method) {
        assertThat(type)
                .as("%s#%s must declare its generic response contract", controller.getSimpleName(), method.getName())
                .isInstanceOf(ParameterizedType.class);
        return (ParameterizedType) type;
    }
}
