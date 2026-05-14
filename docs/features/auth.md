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
- refresh token은 HttpOnly Cookie로 관리한다.
- `companyCode`는 URL 값만 믿지 않고 JWT와 DB 기준으로 검증한다.
- 비활성 회사 또는 비활성 계정은 로그인할 수 없다.
- 임시 비밀번호 상태면 비밀번호 변경이 필요한 상태로 응답한다.

## 하네스 포인트

- 인증 실패 API 응답은 HTML이 아니라 `ApiResultDto` JSON이어야 한다.
- `/api/**`는 인증 실패 시 JSON 에러를 반환해야 한다.
- Security 설정은 stateless 기준을 유지한다.
