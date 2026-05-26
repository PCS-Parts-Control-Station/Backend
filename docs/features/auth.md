# Auth Feature

## 목적

Owner와 업체 작업자의 로그인, 토큰 재발급, 로그아웃, 현재 세션 조회를 담당한다.

## 패키지

```text
com.pcs.domain.auth
```

## API

| Method | API | 설명 |
|---|---|---|
| POST | `/api/owners/login` | Owner 로그인 |
| POST | `/api/workspaces/login` | 업체 코드 + 아이디 + 비밀번호 로그인 |
| POST | `/api/workspaces/{companyCode}/login` | 특정 업체 로그인 |
| POST | `/api/auth/refresh` | 토큰 재발급 |
| POST | `/api/auth/logout` | 로그아웃 |
| GET | `/api/workspaces/{companyCode}/me` | 내 세션 정보 조회 |

## 주요 규칙

- access token은 API 인증에 사용한다.
- access token은 JWT이며 `Authorization: Bearer {token}` 헤더로 전달한다.
- access token 기본 만료 시간은 10분이다.
- access token에는 `memberId`, `companyId`, `companyCode`, `loginId`, `role`, `tokenType`, `exp`를 담는다.
- refresh token은 HttpOnly Cookie로 관리한다.
- refresh token 원문은 DB에 저장하지 않고 SHA-256 해시만 저장한다.
- refresh token cookie의 `Secure` 속성은 환경 설정으로 제어한다. 로컬 HTTP는 `false`, 운영 HTTPS는 `true`로 설정한다.
- 운영 프로필에서는 기본 JWT secret을 사용할 수 없다.
- `companyCode`는 URL 값만 믿지 않고 JWT와 DB 기준으로 검증한다.
- 비활성 회사 또는 비활성 계정은 로그인할 수 없다.
- 임시 비밀번호 상태면 비밀번호 변경이 필요한 상태로 응답한다.
- 임시 비밀번호 만료 시간이 지난 계정은 로그인할 수 없다.
- 로그인 실패가 반복되면 계정을 일정 시간 잠근다.
- 로그인 성공/실패는 `tb_auth_login_history`에 기록한다.
- refresh token 재발급은 rotation 방식으로 처리한다. 재발급 성공 시 새 access token과 새 refresh token을 함께 발급하고, 기존 refresh token은 `ROTATED`로 폐기한다.
- refresh token 만료는 `EXPIRED`, 회전된 토큰 재사용은 `REUSE_DETECTED`로 분리한다.
- 회전된 refresh token이 다시 사용되면 같은 token family의 활성 refresh token을 `REUSE_DETECTED`로 폐기한다.
- 정적 화면의 인증 API 호출은 `/js/pcs-api.js` 공통 fetch 래퍼를 사용한다.
- 공통 fetch 래퍼는 `localStorage.pcsAccessToken`을 `Authorization` 헤더에 싣고, 401 또는 인증 ErrorCode 응답을 받으면 `/api/auth/refresh`를 한 번 호출한 뒤 원 요청을 재시도한다.
- API 인증 판별은 Spring Security에서 처리한다.
- JWT 파싱과 `SecurityContext` 인증 객체 생성은 `global/security/JwtAuthenticationFilter`가 담당한다.
- 인증이 필요한 Controller는 Authorization 헤더를 직접 파싱하지 않고 `@AuthenticationPrincipal PcsPrincipal`을 사용한다.
- Security 인증 실패/권한 실패 응답도 `ApiResultDto` JSON 형식으로 반환한다.

## 응답 기준

로그인 성공 응답:

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "로그인되었습니다.",
  "data": {
    "accessToken": "jwt",
    "tokenType": "Bearer",
    "expiresInSeconds": 600,
    "companyId": 1,
    "companyCode": "seoul-parts",
    "memberId": 1,
    "loginId": "admin01",
    "name": "관리자",
    "role": "ADMIN",
    "passwordChangeRequired": false
  }
}
```

Cookie:

```text
pcsRefreshToken={token}; HttpOnly; SameSite=Strict; Path=/api/auth
```

## 예외와 응답 코드

- 업체 코드/아이디/비밀번호 불일치: `AUTH_LOGIN_FAILED`
- access token 없음: `AUTH_REQUIRED`
- access token 위조 또는 형식 오류: `AUTH_TOKEN_INVALID`
- access token 또는 refresh token 만료: `AUTH_TOKEN_EXPIRED`
- 비활성 회사: `COMPANY_INACTIVE`
- 비활성 사용자: `MEMBER_INACTIVE`
- 임시 비밀번호 만료: `MEMBER_TEMP_PASSWORD_EXPIRED`
- URL 업체 코드와 JWT 업체 코드 불일치: `AUTH_WORKSPACE_MISMATCH`

## 하네스 포인트

- 인증 실패 API 응답은 HTML이 아니라 `ApiResultDto` JSON이어야 한다.
- `/api/**`는 인증 실패 시 JSON 에러를 반환해야 한다.
- Security 설정은 stateless 기준을 유지한다.
- Controller는 `ApiResultDto`만 반환하고 인증 흐름은 Facade/Service가 담당한다.
- JWT 생성/검증 로직은 `global/jwt`, 요청 인증 연결은 `global/security`에서 처리한다.
- MyBatis Mapper XML namespace는 Mapper FQCN과 일치해야 한다.
- refresh token 저장, 로그인 이력 저장, 로그인 성공 시 `tb_member.last_login_at` 갱신을 확인한다.
- 업무 화면 JS는 인증 API를 직접 `fetch`하지 않고 `/js/pcs-api.js`를 통해 access token 첨부와 refresh 재시도를 공통 처리한다.
