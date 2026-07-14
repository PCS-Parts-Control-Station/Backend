# PCS Backend Common Rules

Backend의 공통 응답, 예외, Controller, 검증 계약 정본입니다. 계층과 Mapper 구조는 [프로젝트 구조](pcs-project-structure-reference.md), 권한은 [Permission Rules](pcs-permission-rules.md)를 따릅니다.

## API 응답

모든 `/api/**` 응답은 `ApiResultDto<T>`로 감쌉니다.

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "요청을 정상 처리했습니다.",
  "data": {}
}
```

실패 시 `success=false`, 도메인 오류 코드와 안전한 사용자 메시지를 반환하고 `data=null`로 둡니다. Controller, Security filter, 인증 진입점에서 임의의 `Map`이나 JSON 문자열을 만들지 않습니다.

목록 응답의 paging 구조는 [Pagination Rules](pcs-pagination-rules.md)를 따릅니다.

## 예외와 오류 코드

예측 가능한 업무 오류는 `BusinessException(ErrorCode)`으로 전달합니다. 원문 예외 메시지나 내부 상세는 API 응답에 노출하지 않습니다.

오류 코드 계열:

```text
COMMON_*  AUTH_*  COMPANY_*  MEMBER_*  PARTNER_*
CATEGORY_*  PART_*  STOCK_*  INSPECTION_*  HISTORY_*
```

공통 의미:

| 상황 | 코드 기준 | HTTP 계열 |
|---|---|---:|
| validation 실패 | `INVALID_INPUT_VALUE` | 400 |
| JSON 파싱 실패 | `INVALID_REQUEST_BODY` | 400 |
| 인증 필요 | `AUTH_REQUIRED` | 401 |
| 권한 부족 | `AUTH_FORBIDDEN` | 403 |
| 업체 불일치 | `AUTH_WORKSPACE_MISMATCH` | 403 |
| 리소스 없음 | `{DOMAIN}_NOT_FOUND` | 404 |
| 중복 | `{DOMAIN}_DUPLICATED` | 409 |
| 잘못된 상태 전이 | `{DOMAIN}_INVALID_STATUS` | 409 |

`GlobalExceptionHandler`는 업무 예외, validation, JSON 파싱, 인증·인가, 마지막 500 fallback을 처리합니다. 알 수 없는 오류의 상세는 서버 로그에만 남기고 응답에는 공통 내부 오류 메시지만 사용합니다.

## Controller 계약

Controller가 담당하는 일:

- URL과 HTTP method 매핑
- `@Valid`, `@AuthenticationPrincipal`, Request DTO 수신
- Facade 호출
- `ApiResultDto` 반환

Controller에서 하지 않는 일:

- Service/Mapper 직접 호출과 SQL 처리
- JWT 직접 파싱
- 복합 업무 검증이나 트랜잭션 조합
- 수동 응답 JSON 조립

## 공통 검증·정규화

중복 구현하지 않고 다음 공통 도구를 사용합니다.

| 목적 | 정본 API |
|---|---|
| 작업공간 인증·업체 코드 검증 | `WorkspaceAccessValidator.validateAuthenticatedWorkspace(principal, companyCode)` |
| 회사 활성 상태 | 공통 validator의 `validateCompanyActive(companyId)` |
| paging 계산 | `PageQuery.of(page, size, limit[, defaultSize])` |
| 필수 문자열 trim | `TextNormalizer.required(value)` |
| 선택 문자열 trim | `TextNormalizer.optional(value)` |

규칙:

- `/api/workspaces/{companyCode}/**`는 URL 업체 코드와 인증 사용자의 업체를 비교합니다.
- 모든 업무 SQL은 검증된 `companyId` 범위를 포함합니다.
- 도메인 Mapper에 회사 활성 확인 SQL을 반복하지 않습니다.
- Service마다 page/size/offset 계산이나 문자열 정규화 함수를 만들지 않습니다.
- 여러 테이블이나 상태를 함께 바꾸는 작업은 Facade 트랜잭션 안에서 처리합니다.

## 완료 기준

- 성공·실패 응답이 `ApiResultDto` 계약을 지킵니다.
- 오류 코드가 상황과 HTTP 상태에 맞습니다.
- Controller가 얇고 업무 로직이 적절한 계층에 있습니다.
- 공통 validator, paging, normalizer를 재사용합니다.
- 업체 범위와 권한을 API와 SQL 양쪽에서 보장합니다.
