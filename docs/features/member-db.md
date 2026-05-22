# Member DB Feature

## 목적

`tb_member` 테이블 자체의 공통 DB 규칙을 검증한다.

이 문서는 사용자 관리 기능 전체를 검사하지 않는다.  
회사 등록처럼 다른 기능에서 `tb_member`를 함께 사용하는 경우, 회원 기능 전체가 아니라 회원 DB 구조만 확인하기 위해 사용한다.

## 사용 테이블

```text
tb_member
tb_company
```

`tb_company`는 테스트용 회사 row를 만들기 위한 선행 테이블이다.

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

## 제약 조건

```text
tb_member.uk_member_company_login
tb_member.uk_member_company_owner
tb_member.chk_member_owner_slot
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

## 비밀번호 기준

- DB에는 원문 비밀번호를 저장하지 않는다.
- DB 컬럼은 `password_hash`이다.
- 응답 DTO로 `password_hash`를 노출하지 않는다.

## 실패 시나리오

- 같은 회사 안에서 `login_id`가 중복되면 실패한다.
- 같은 회사에 OWNER가 2명 저장되면 실패한다.
- OWNER인데 `owner_slot`이 `NULL`이면 실패한다.
- ADMIN/STAFF인데 `owner_slot = 1`이면 실패한다.

## 하네스 기준

회사 등록 기능이 `tb_member` 구조를 함께 건드렸지만 사용자 관리 기능 전체를 검사하지 않을 때는 아래처럼 실행한다.

```powershell
.\harness\run-harness.ps1 -Mode bootstrap -DbFeature member
```

이 명령은 `member.md`의 사용자 관리 기능 전체가 아니라 `member-db.md`의 DB 규칙만 검사한다.
