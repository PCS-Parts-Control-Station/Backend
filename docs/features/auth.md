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

## 사용 테이블

```text
tb_member
tb_auth_refresh_token
tb_auth_login_history
```

## 주요 규칙

- access token은 API 인증에 사용한다.
- refresh token은 HttpOnly Cookie로 관리한다.
- refresh token 원문은 저장하지 않고 SHA-256 해시값만 `tb_auth_refresh_token.refresh_token_hash`에 저장한다.
- refresh token 재발급은 토큰 회전 방식으로 처리하고, 이전 토큰은 `revoked_reason = ROTATED`로 폐기한다.
- 재사용이 감지된 refresh token은 `revoked_reason = REUSE_DETECTED`로 남긴다.
- 로그아웃 시 refresh token은 `revoked_reason = LOGOUT`으로 폐기한다.
- `companyCode`는 URL 값만 믿지 않고 JWT와 DB 기준으로 검증한다.
- 비활성 회사 또는 비활성 계정은 로그인할 수 없다.
- 임시 비밀번호 상태면 비밀번호 변경이 필요한 상태로 응답한다.
- 로그인 실패 횟수는 `tb_member.login_failed_count`에 누적한다.
- 잠긴 계정은 `tb_member.locked_until_at` 기준으로 로그인 차단한다.
- 로그인 성공 시 `last_login_at`, `last_login_ip`, `last_login_user_agent`를 갱신한다.
- 로그인 시도 결과는 성공/실패 모두 `tb_auth_login_history`에 기록한다.

## 로그인 이력 결과

```text
SUCCESS
FAIL
LOCKED
INACTIVE
TEMP_PASSWORD_EXPIRED
```

## Refresh Token 폐기 사유

```text
LOGOUT
ROTATED
REUSE_DETECTED
ADMIN_REVOKED
```

## 하네스 포인트

- 인증 실패 API 응답은 HTML이 아니라 `ApiResultDto` JSON이어야 한다.
- `/api/**`는 인증 실패 시 JSON 에러를 반환해야 한다.
- Security 설정은 stateless 기준을 유지한다.
- refresh token 원문 저장은 FAIL이다.
- 로그인 성공/실패 이력 누락은 FAIL이다.
