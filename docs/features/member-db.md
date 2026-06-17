# Member DB Feature

## 목적

`tb_member` 테이블과 사용자 관리에서 사용하는 STAFF 공통 권한 테이블의 DB 규칙을 검증한다.

이 문서는 사용자 관리 기능 전체를 검사하지 않는다.  
회사 등록처럼 다른 기능에서 `tb_member`를 함께 사용하는 경우, 회원 기능 전체가 아니라 회원 DB 구조만 확인하기 위해 사용한다.

## 사용 테이블

```text
tb_member
tb_company
tb_company_staff_permission_disabled
```

`tb_company`는 테스트용 회사 row를 만들기 위한 선행 테이블이다.
`tb_company_staff_permission_disabled`는 업체 단위 STAFF 권한 중 꺼진 항목만 저장한다.

## 저장 컬럼

```text
member_id
company_id
login_id
password_hash
name
role
owner_slot
password_status
temp_password_expires_at
password_changed_at
active
last_login_at
login_failed_count
locked_until_at
last_login_ip
last_login_user_agent
created_by
created_at
updated_at
```

`tb_company_staff_permission_disabled`:

```text
disabled_permission_id
company_id
permission_code
disabled_by
disabled_at
```

## 제약 조건

```text
tb_member.uk_member_company_login
tb_member.uk_member_company_owner
tb_member.chk_member_owner_slot
tb_company_staff_permission_disabled.uk_company_staff_permission_disabled
```

## 역할별 저장 규칙

OWNER:

- `role = OWNER`
- `owner_slot = 1`
- 회사당 1명만 허용

ADMIN:

- `role = ADMIN`
- `owner_slot = NULL`

STAFF:

- `role = STAFF`
- `owner_slot = NULL`

`owner_slot`은 OWNER 단일 계정 보장을 위한 슬롯 컬럼이다.
ADMIN/STAFF에는 `0` 같은 값을 넣지 않고 `NULL`을 유지한다.
회사당 OWNER 1명 제한은 `UNIQUE(company_id, owner_slot)`과 `chk_member_owner_slot` 제약으로 검증한다.

## 비밀번호 기준

- DB에는 원문 비밀번호를 저장하지 않는다.
- DB 컬럼은 `password_hash`이다.
- 응답 DTO로 `password_hash`를 노출하지 않는다.
- 비밀번호 변경 시각은 `password_changed_at`에 저장한다.
- 임시 비밀번호 만료 시각은 `temp_password_expires_at`에 저장한다.

## 로그인 보안 기준

- 로그인 실패 횟수는 `login_failed_count`에 저장한다.
- 로그인 잠금 해제 시각은 `locked_until_at`에 저장한다.
- 로그인 성공 시 `last_login_at`, `last_login_ip`, `last_login_user_agent`를 갱신한다.
- 계정 잠금 여부는 `locked_until_at`이 현재 시각보다 미래인지로 판단한다.

## 실패 시나리오

- 같은 회사 안에서 `login_id`가 중복되면 실패한다.
- 같은 회사에 OWNER가 2명 저장되면 실패한다.
- OWNER인데 `owner_slot`이 `NULL`이면 실패한다.
- ADMIN/STAFF인데 `owner_slot = 1`이면 실패한다.
- 같은 회사에 같은 `permission_code`가 중복 저장되면 실패한다.
- 권한 설정 row가 없으면 STAFF 업무 권한은 전체 허용으로 판단한다.

## 하네스 기준

실행 명령과 `-DbFeature member` 사용 기준은 `docs/ai/pcs-harness-rules.md`를 따른다.  
회사 등록처럼 `tb_member` 구조만 확인하면 `member.md`의 사용자 관리 기능 전체가 아니라 이 문서의 DB 규칙만 검사한다.
