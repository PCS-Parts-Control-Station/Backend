# Company DB Feature

## 목적

회사 등록 시 `tb_company`와 `tb_member`가 하나의 트랜잭션으로 저장되는지 검증한다.

화면은 회사 등록이지만 DB 기준으로는 아래 흐름이다.

```text
회사 생성 -> OWNER 계정 생성 -> 업체 접속 주소 반환
```

## 사용 테이블

```text
tb_company
tb_member
```

## 저장 컬럼

`tb_company`:

```text
company_id
company_name
company_code
representative_email
representative_phone
business_registration_no
active
created_at
updated_at
```

`tb_member`:

```text
member_id
company_id
login_id
password_hash
name
role
owner_slot
password_status
active
created_by
created_at
updated_at
```

## 제약 조건

```text
tb_company.uk_company_code
tb_company.uk_company_business_registration_no
tb_member.uk_member_company_login
tb_member.uk_member_company_owner
tb_member.chk_member_owner_slot
```

## 정상 시나리오

회사 등록 성공 시:

- `tb_company`에 회사 정보가 저장된다.
- `tb_member`에 같은 `company_id`를 가진 OWNER 계정이 저장된다.
- OWNER 계정은 `role = OWNER`이다.
- OWNER 계정은 `owner_slot = 1`이다.
- OWNER 계정은 `password_status = ACTIVE`이다.
- 비밀번호는 원문이 아니라 `password_hash`로 저장된다.
- 응답용 업체 접속 주소는 `/w/{companyCode}` 기준이다.

## 실패 시나리오

- `company_code`가 중복되면 실패한다.
- `business_registration_no`가 중복되면 실패한다.
- 회사 저장 후 OWNER 저장이 실패하면 둘 다 남지 않아야 한다.
- OWNER 저장 후 회사만 존재하는 부분 성공은 허용하지 않는다.

## 하네스 기준

```powershell
.\harness\run-harness.ps1 -Mode bootstrap -Feature company -RunBuild -RunDb
```

이 명령은 아래 기준을 함께 확인한다.

- `company.md` 기능 구조
- `checkdb.md` DB 사전검사
- `company-db.md` 회사 등록 DB 시나리오
- `compileJava`
