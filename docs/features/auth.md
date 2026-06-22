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
- access token은 Spring Security Nimbus JWT 구현으로 HS256 서명·검증한다.
- access token에는 표준 claim `iss`, `aud`, `sub`, `jti`, `iat`, `exp`와 업무 claim `memberId`, `companyId`, `companyCode`, `loginId`, `role`, `tokenType`, `sid`를 담는다.
- `jti`는 Access Token별 UUID, `sid`는 연결된 refresh token family ID를 사용한다.
- refresh token은 HttpOnly Cookie로 관리한다.
- refresh token 원문은 DB에 저장하지 않고 SHA-256 해시만 저장한다.
- refresh token cookie의 `Secure` 속성은 환경 설정으로 제어한다. 로컬 HTTP는 `false`, 운영 HTTPS는 `true`로 설정한다.
- 운영 프로필에서는 기본 JWT secret을 사용할 수 없다.
- `companyCode`는 URL 값만 믿지 않고 JWT와 DB 기준으로 검증한다.
- 비활성 회사 또는 비활성 계정은 `docs/ai/pcs-status-lifecycle-rules.md` 기준에 따라 로그인할 수 없다.
- 임시 비밀번호 상태면 비밀번호 변경이 필요한 상태로 응답한다.
- 임시 비밀번호 만료 시간이 지난 계정은 로그인할 수 없다.
- 임시 비밀번호 로그인 성공 시 프론트는 대시보드가 아니라 `/w/{companyCode}/mypage?section=password&required=true`로 이동한다.
- 임시 비밀번호 상태의 access token은 세션/마이페이지 조회, 비밀번호 변경, 로그아웃 외 API에 사용할 수 없다.
- 임시 비밀번호 상태에서는 refresh token 재발급도 허용하지 않는다.
- 비밀번호 초기화와 비밀번호 변경 시 해당 회원의 활성 refresh token을 모두 `ADMIN_REVOKED`로 폐기한다.
- 로그인 실패가 반복되면 계정을 일정 시간 잠근다.
- 로그인 API의 업체/아이디/비밀번호 불일치, 비활성 회사·사용자, 잠금 상태 응답은 모두 `AUTH_LOGIN_FAILED`로 통일하고 상세 원인은 서버 로그인 이력에만 남긴다.
- 같은 업체 코드와 IP에서 최근 1분간 실패 이력이 30건 이상이면 계정 조회 전에 `AUTH_LOGIN_FAILED`로 차단한다.
- 로그인 IP는 임의의 `X-Forwarded-For` 헤더를 직접 신뢰하지 않고 서버의 `remoteAddr`를 사용한다. 프록시 배포에서는 신뢰 프록시 범위를 제한한 컨테이너 설정으로 원격 주소를 전달한다.
- 로그인 성공/실패는 `tb_auth_login_history`에 기록한다.
- refresh token 재발급은 rotation 방식으로 처리한다. 재발급 성공 시 새 access token과 새 refresh token을 함께 발급하고, 기존 refresh token은 `ROTATED`로 폐기한다.
- refresh token 만료는 `EXPIRED`, 회전된 토큰 재사용은 `REUSE_DETECTED`로 분리한다.
- 회전된 refresh token이 다시 사용되면 같은 token family의 활성 refresh token을 `REUSE_DETECTED`로 폐기한다.
- 로그인 이후 정적 화면의 인증 API 호출 방식은 `docs/ai/pcs-auth-client-rules.md`를 따른다.
- API 인증 판별은 Spring Security에서 처리한다.
- JWT 파싱과 `SecurityContext` 인증 객체 생성은 `global/security/JwtAuthenticationFilter`가 담당한다.
- 인증이 필요한 Controller는 Authorization 헤더를 직접 파싱하지 않고 `@AuthenticationPrincipal PcsPrincipal`을 사용한다.
- Security 인증 실패/권한 실패 응답도 `docs/ai/pcs-backend-common-rules.md` 기준의 JSON 형식으로 반환한다.

## 파트1-1 배포 전환

- 배포 전에 `docs/sql/pcs-auth-part1-1-alter.sql`을 실행한다.
- 기존 활성 refresh token은 모두 `ADMIN_REVOKED`로 폐기하여 새 `sid` 세션으로 다시 로그인하게 한다.
- 기존 형식 Access Token은 `iss`, `aud`, `jti`, `sid` 검증을 통과하지 못하므로 배포 후 즉시 사용할 수 없다.
- 기존 `TEMPORARY` 계정은 임시 비밀번호를 만료 처리한다. 관리자가 사용자 관리에서 난수 임시 비밀번호를 다시 발급해야 한다.

## 기능 개발 시 인증 사용 규칙

새 기능을 만들 때 인증을 기존 구조에 끼워 맞추지 말고 아래 기준을 따른다.

백엔드 API:

- `/api/workspaces/{companyCode}/**` API는 인증이 필요한 업무 API로 본다.
- 단, `/api/workspaces/{companyCode}/public-info`는 로그인 전 업체 주소 확인용 공개 API다.
- Controller, Facade, Service에서 `Authorization` 헤더를 직접 읽거나 JWT를 직접 파싱하지 않는다.
- 인증 사용자 정보가 필요하면 Controller 메서드에서 `@AuthenticationPrincipal PcsPrincipal principal`을 받는다.
- URL의 `companyCode`는 사용자 입력값이므로 단독 신뢰하지 않는다.
- `companyCode`, `companyId`, `memberId`, `role`은 `PcsPrincipal` 기준으로 확인한다.
- 회사 범위 데이터 조회/수정은 항상 `principal.companyId()` 범위 안에서 처리한다.
- URL의 `companyCode`와 `principal.companyCode()`가 다르면 `AUTH_WORKSPACE_MISMATCH`로 처리한다.
- 권한 분기는 문자열 직접 비교보다 프로젝트 Enum과 `docs/ai/pcs-permission-rules.md` 기준을 사용한다.

프론트 JS:

- 로그인 이후 업무 화면의 토큰 저장, refresh 재시도, 공통 fetch 사용 방식은 `docs/ai/pcs-auth-client-rules.md`를 따른다.

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

- 로그인 업체/계정/비밀번호/활성/잠금 상태 실패: `AUTH_LOGIN_FAILED`
- access token 없음: `AUTH_REQUIRED`
- access token 위조 또는 형식 오류: `AUTH_TOKEN_INVALID`
- access token 또는 refresh token 만료: `AUTH_TOKEN_EXPIRED`
- 로그인 이후 세션 검증 중 비활성 회사: `COMPANY_INACTIVE`
- 로그인 이후 세션 검증 중 비활성 사용자: `MEMBER_INACTIVE`
- 임시 비밀번호 만료: `MEMBER_TEMP_PASSWORD_EXPIRED`
- 임시 비밀번호 변경 필요: `MEMBER_PASSWORD_CHANGE_REQUIRED`
- URL 업체 코드와 JWT 업체 코드 불일치: `AUTH_WORKSPACE_MISMATCH`

## 하네스 포인트

- 인증 실패 API 응답은 HTML이 아니라 `docs/ai/pcs-backend-common-rules.md` 기준의 JSON이어야 한다.
- `/api/**`는 인증 실패 시 JSON 에러를 반환해야 한다.
- Security 설정은 stateless 기준을 유지한다.
- `TemporaryPasswordAuthorizationFilter`가 임시 비밀번호 상태의 허용 API 범위를 강제해야 한다.
- Controller 응답 형식은 `docs/ai/pcs-backend-common-rules.md`를 따른다.
- JWT 생성/검증 로직은 `global/jwt`, 요청 인증 연결은 `global/security`에서 처리한다.
- MyBatis Mapper XML namespace는 Mapper FQCN과 일치해야 한다.
- refresh token 저장, 로그인 이력 저장, 로그인 성공 시 `tb_member.last_login_at` 갱신을 확인한다.
- 업무 화면 JS는 `docs/ai/pcs-auth-client-rules.md` 기준으로 인증 API를 호출한다.
- URL 업체 코드가 존재하지 않거나 로그인 계정의 업체와 다르면 공통 잘못된 접근 페이지로 이동한다.
