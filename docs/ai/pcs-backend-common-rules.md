# PCS Backend Common Rules

백엔드 기능 구현 시 공통으로 따라야 하는 응답, 예외, ErrorCode 기준이다.

## 공통 응답

모든 `/api/**` 응답은 `ApiResultDto<T>`로 감싼다.

성공:

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "요청이 정상 처리되었습니다.",
  "data": {}
}
```

실패:

```json
{
  "success": false,
  "code": "PARTNER-001",
  "message": "거래처를 찾을 수 없습니다.",
  "data": null
}
```

Controller는 직접 `Map`이나 임의 JSON을 반환하지 않는다.

사용:

```java
return ApiResultDto.success(response);
```

금지:

```java
return Map.of("ok", true, "data", response);
```

## 예외 사용

비즈니스 규칙 위반은 `BusinessException`으로 던진다.

사용:

```java
if (partner == null) {
    throw new BusinessException(ErrorCode.PARTNER_NOT_FOUND);
}
```

금지:

```java
throw new RuntimeException("거래처 없음");
```

## ErrorCode 기준

네이밍:

```text
COMMON_*
AUTH_*
COMPANY_*
MEMBER_*
PARTNER_*
CATEGORY_*
PART_*
STOCK_*
INSPECTION_*
HISTORY_*
```

기준:

- validation 실패: `INVALID_INPUT_VALUE`
- JSON 파싱 실패: `INVALID_REQUEST_BODY`
- 인증 필요: `AUTH_REQUIRED`
- 권한 부족: `AUTH_FORBIDDEN`
- 업체 불일치: `AUTH_WORKSPACE_MISMATCH`
- 리소스 없음: `{DOMAIN}_NOT_FOUND`
- 중복: `{DOMAIN}_DUPLICATED`
- 잘못된 상태 변경: `{DOMAIN}_INVALID_STATUS`

## GlobalExceptionHandler 범위

처리 대상:

- `BusinessException`
- validation 예외
- JSON 요청 본문 파싱 실패
- 인증/인가 예외
- 마지막 fallback으로 예상하지 못한 예외

주의:

- 예상 가능한 업무 오류를 fallback 500으로 보내지 않는다.
- 사용자가 잘못 입력한 값은 400 계열로 처리한다.
- 권한과 회사 범위 문제는 403 계열로 처리한다.

## Controller 기준

Controller 역할:

- URL, Method 매핑
- `@Valid`
- `@AuthenticationPrincipal`
- Request DTO 수신
- Facade 호출
- `ApiResultDto` 반환

금지:

- Service 직접 호출
- Mapper 직접 호출
- SQL 처리
- JWT 직접 파싱
- 복잡한 비즈니스 검증

예:

```java
@PostMapping("/workspaces/{companyCode}/partners")
public ApiResultDto<CreatePartnerResponse> create(
        @PathVariable String companyCode,
        @AuthenticationPrincipal PcsPrincipal principal,
        @Valid @RequestBody CreatePartnerRequest request
) {
    return ApiResultDto.success(partnerFacade.create(companyCode, principal, request));
}
```

## 공통 검증 / 정규화 유틸

도메인마다 같은 검증과 정규화 코드를 반복하지 않는다.

업체 작업공간 검증:

```java
PcsPrincipal checkedPrincipal = workspaceAccessValidator.validateAuthenticatedWorkspace(
        principal,
        companyCode
);
```

기준:

- `/api/workspaces/{companyCode}/**` API는 URL의 `companyCode`와 인증 사용자의 `companyCode`를 비교해야 한다.
- 이 검증은 `com.pcs.global.workspace.WorkspaceAccessValidator`를 우선 사용한다.
- 회사 활성 여부도 같은 validator의 `validateCompanyActive(companyId)`를 사용한다.
- 도메인별 Mapper XML에 `isCompanyActive` SQL을 반복해서 만들지 않는다.

페이징:

```java
PageQuery pageQuery = PageQuery.of(page, size, limit);
```

기준:

- `page`, `size`, `limit`, `offset` 계산은 `com.pcs.global.pagination.PageQuery`를 사용한다.
- 기능별 기본 size가 다르면 `PageQuery.of(page, size, limit, defaultSize)`를 사용한다.
- Service마다 `normalizePage`, `normalizeSize`를 다시 만들지 않는다.

문자열 정규화:

```java
String name = TextNormalizer.required(request.name());
String memo = TextNormalizer.optional(request.memo());
```

기준:

- required/optional trim 처리는 `com.pcs.global.util.TextNormalizer`를 사용한다.
- Service마다 `normalizeRequired`, `normalizeOptional`을 다시 만들지 않는다.
