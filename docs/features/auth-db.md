# Auth DB Feature

## 목적

JWT 로그인 과정에서 회원 상태, refresh token, 로그인 이력이 DB에 올바르게 기록되는지 검증한다.

## 사용 테이블

```text
tb_company
tb_member
tb_auth_refresh_token
tb_auth_login_history
```

## 조회/수정 컬럼

`tb_member`:

```text
company_id
member_id
login_id
password_hash
role
password_status
temp_password_expires_at
active
last_login_at
login_failed_count
locked_until_at
last_login_ip
last_login_user_agent
```

`tb_auth_refresh_token`:

```text
token_id
company_id
member_id
refresh_token_hash
token_family_id
expires_at
last_used_at
revoked_at
revoked_reason
replaced_by_token_id
created_ip
created_user_agent
created_at
```

`tb_auth_login_history`:

```text
history_id
company_id
member_id
company_code_snapshot
login_id_snapshot
login_result
failure_reason
login_ip
user_agent
created_at
```

## 제약 조건

```text
tb_auth_refresh_token.uk_auth_refresh_token_hash
tb_auth_refresh_token.idx_auth_refresh_member_active
tb_auth_refresh_token.idx_auth_refresh_family
tb_auth_login_history.idx_auth_login_history_company_date
tb_auth_login_history.idx_auth_login_history_member_date
```

## 정상 시나리오

로그인 성공 시:

- 업체 코드와 로그인 ID로 `tb_company`, `tb_member`를 함께 조회한다.
- 비활성 회사 또는 비활성 사용자는 `docs/ai/pcs-status-lifecycle-rules.md` 기준에 따라 로그인할 수 없다.
- 비밀번호는 `password_hash`와 `PasswordEncoder.matches`로 검증한다.
- `tb_member.last_login_at`을 갱신한다.
- `tb_member.login_failed_count`는 `0`으로 초기화한다.
- refresh token DB 저장 방식은 `docs/features/auth.md` 기준을 따른다.
- `tb_auth_login_history.login_result = SUCCESS` 이력이 저장된다.

토큰 재발급, 만료, 재사용 감지 시 DB 저장 흐름은 `docs/features/auth.md`의 refresh token rotation 정책을 따른다.

로그아웃 시:

- refresh token을 `revoked_reason = LOGOUT`으로 폐기한다.
- refresh cookie를 만료시킨다.

비밀번호 초기화/변경 시:

- 해당 `company_id`, `member_id`의 `revoked_at IS NULL` refresh token을 모두 폐기한다.
- 폐기 사유는 `ADMIN_REVOKED`를 사용한다.
- 비밀번호 초기화와 refresh token 폐기는 하나의 트랜잭션으로 처리한다.

## 실패 시나리오

- 업체 코드 또는 로그인 ID가 없으면 로그인 실패 이력을 남긴다.
- 비밀번호가 틀리면 로그인 실패 횟수를 증가시킨다.
- 로그인 실패가 기준 횟수 이상이면 `locked_until_at`을 설정한다.
- 비활성 회사/사용자, 잠긴 계정, 임시 비밀번호 만료는 `docs/features/auth.md`의 예외 기준을 따른다.
- URL 업체 코드와 인증 사용자 회사가 다를 때의 응답은 `docs/features/auth.md`의 회사 범위 검증 기준을 따른다.

## 하네스 기준

실행 명령과 `-Feature`, `-DbFeature` 조합 기준은 `docs/ai/pcs-harness-rules.md`를 따른다.  
인증 검증 시에는 `auth.md`, `auth-db.md`, `member-db.md`, `checkdb.md` 기준을 함께 확인한다.
