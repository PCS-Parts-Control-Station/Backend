# PCS Auth / JWT Rules

로그인 이후 화면과 `/api/workspaces/{companyCode}/**` API를 구현할 때 따라야 하는 인증 사용 기준이다.

토큰 발급, 만료, 회전, 회사 범위 검증 정책의 원본은 `docs/features/auth.md`이다.  
이 문서는 그 정책을 화면과 API 코드에서 어떻게 사용해야 하는지만 다룬다.

## 토큰 저장 기준

- access token은 로그인 응답 JSON으로 받고 `pcs-api.js`의 메모리 변수에만 저장한다.
- access token을 `localStorage`, `sessionStorage`, Cookie, DOM 속성에 직접 저장하지 않는다.
- 새로고침이나 새 탭으로 메모리 access token이 사라진 경우 첫 인증 API 요청에서 `/api/auth/refresh`를 호출해 복구한다.
- refresh token은 JS에서 직접 다루지 않는다.
- refresh token은 서버가 `HttpOnly Cookie`로 내려주고, 브라우저가 자동 전송한다.
- refresh token 저장 정책은 `docs/features/auth.md`와 `docs/features/auth-db.md`를 따른다.

## 프론트 API 호출

로그인 이후 업무 화면에서 직접 `fetch()`를 반복 작성하지 않는다.

사용:

```js
const data = await window.PcsApi.getData(
    `/api/workspaces/${encodeURIComponent(companyCode)}/partners`,
    {
        authRedirect: true,
        loginCompanyCode: companyCode
    }
);
```

금지:

```js
const token = localStorage.getItem("pcsAccessToken");
await fetch("/api/workspaces/pcs/partners", {
    headers: {
        Authorization: `Bearer ${token}`
    }
});
```

이유:

- access token 첨부
- access token 만료 시 `/api/auth/refresh` 호출
- 원 요청 1회 재시도
- refresh 실패 시 로그인 화면 이동
- legacy `localStorage` access token 제거

위 흐름은 `pcs-api.js`가 공통 처리한다.

## 백엔드 인증 사용자 사용

Controller나 Facade에서 `Authorization` 헤더를 직접 파싱하지 않는다.

사용:

```java
@GetMapping("/workspaces/{companyCode}/partners")
public ApiResultDto<?> partners(
        @PathVariable String companyCode,
        @AuthenticationPrincipal PcsPrincipal principal
) {
    return ApiResultDto.ok(partnerFacade.search(companyCode, principal));
}
```

금지:

```java
String token = request.getHeader("Authorization");
Long memberId = jwtTokenProvider.parse(token);
```

## 회사 범위 검증

회사 범위 검증 정책은 `docs/features/auth.md`를 따른다.  
각 기능은 URL의 `companyCode`만 신뢰하지 말고 인증 사용자 기준으로 회사 범위를 확인해야 한다.

## 재발급 기준

- access token 만료 시 `pcs-api.js`가 `/api/auth/refresh`를 호출한다.
- 로그아웃·비밀번호 변경·관리자 초기화로 access token의 `sid` 세션이 폐기된 경우에도 서버는 `AUTH-003`을 반환하고 같은 refresh 재시도 흐름을 사용한다.
- 폐기된 세션은 refresh도 실패하므로 access token을 제거하고 로그인 화면으로 이동한다.
- refresh token 회전, 만료, 재사용 감지 정책은 `docs/features/auth.md`를 따른다.
- refresh 실패 시 재로그인이 필요하다.

## 임시 비밀번호 흐름

- 로그인 응답의 `passwordChangeRequired`가 `true`이면 대시보드로 이동하지 않는다.
- `/w/{companyCode}/mypage?section=password&required=true`로 이동해 비밀번호 변경을 먼저 완료한다.
- 공통 API가 `MEMBER-005`를 받으면 같은 비밀번호 변경 화면으로 이동한다.
- 비밀번호 변경 성공 후 `PcsApi.logout()`으로 토큰을 정리하고 `/w/{companyCode}` 로그인 화면으로 이동한다.
- 임시 비밀번호 원문은 사용자 관리 초기화 응답에서 한 번만 표시하며 브라우저 저장소에 보관하지 않는다.
