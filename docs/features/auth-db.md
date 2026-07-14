# Auth DB Rules

## 목적

로그인 상태, refresh token family, 로그인 이력과 access token 세션 검증의 DB 계약을 정의한다. 회원 공통 필드는 `member-db.md`가 원본이다.

## 테이블 역할

| 테이블 | 역할 |
|---|---|
| `tb_company` | 회사 코드와 활성 상태 |
| `tb_member` | 계정·비밀번호·잠금·최근 로그인 |
| `tb_auth_refresh_token` | token hash, family, 만료·폐기·교체 |
| `tb_auth_login_history` | 성공·실패와 외부 노출하지 않는 원인 |

## 핵심 인덱스

```text
uk_auth_refresh_token_hash
idx_auth_refresh_member_active
idx_auth_refresh_family
idx_auth_login_history_company_date
idx_auth_login_history_member_date
idx_auth_login_history_company_ip_date
```

상세 정의는 DDL이 원본이다.

## 로그인

- companyCode와 loginId로 활성 회사·회원을 함께 조회한다.
- 비밀번호는 `PasswordEncoder.matches`로 검증한다.
- 성공 시 lastLogin 정보를 갱신하고 실패 횟수를 0으로 만든다.
- 실패 시 횟수·잠금과 login history를 저장한다.
- 존재하지 않는 계정도 유사한 비밀번호 비교 비용을 사용한다.
- 비활성·잠금·불일치의 외부 응답은 하나로 통일하고 상세 원인은 history에만 남긴다.
- 같은 회사 코드·IP의 최근 1분 실패 30건 이상은 계정 조회 전에 차단한다.

## Refresh token

- 원문이 아니라 SHA-256 hash만 저장한다.
- 로그인은 새 family와 활성 token을 만든다.
- refresh 성공은 기존 token을 ROTATED로 폐기하고 replacement를 연결한다.
- 만료는 EXPIRED, 회전 token 재사용은 REUSE_DETECTED다.
- 재사용 감지와 로그아웃은 같은 family의 활성 token 전체를 폐기한다.
- 비밀번호 초기화·변경은 회원의 활성 token을 ADMIN_REVOKED로 폐기한다.

## Access token 세션

- JWT의 companyId, memberId, sid로 활성 family 존재 여부를 조회한다.
- token 미폐기, refresh 만료 전, 활성 회사·회원 조건을 모두 만족해야 한다.
- `idx_auth_refresh_family`를 사용한다.
- 활성 row가 없으면 access token 자체 만료 전이라도 거부한다.

## 트랜잭션

- refresh rotation과 replacement 저장
- password 초기화·변경과 활성 token 폐기
- 임시 비밀번호 재발급과 token 폐기

위 작업은 각각 하나의 트랜잭션이며 token 폐기 실패 시 비밀번호 변경도 롤백한다.

## DB 통합 테스트 수용 기준

- `AuthPersistenceIntegrationTest`
- 성공·실패 로그인이 member 상태와 history를 갱신한다.
- 원문 refresh token을 저장하지 않는다.
- 만료·rotation·reuse·logout family 폐기를 검증한다.
- session 조회가 회사 불일치와 폐기된 sid를 거부한다.
