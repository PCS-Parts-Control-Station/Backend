# Member DB Rules

## 목적

회원 계정과 업체 단위 STAFF 비활성 권한의 DB 원본 규칙이다. 다른 기능이 회원 구조만 사용할 때 이 문서를 참조한다.

## 테이블 역할

| 테이블 | 역할 |
|---|---|
| `tb_member` | 계정, 역할, 비밀번호, active, 로그인 보안 상태 |
| `tb_company_staff_permission_disabled` | 업체에서 끈 STAFF 권한만 저장 |

## 핵심 제약

```text
uk_member_company_login
uk_member_company_owner
chk_member_owner_slot
uk_company_staff_permission_disabled
```

상세 컬럼과 정의는 DDL이 원본이다.

## 역할 저장

| role | ownerSlot |
|---|---|
| OWNER | 1 |
| ADMIN | null |
| STAFF | null |

- 회사당 OWNER는 한 명이다.
- ADMIN/STAFF에 0 같은 ownerSlot 값을 저장하지 않는다.
- 같은 회사 안에서 loginId는 unique다.

## 목록

- 모든 조건은 companyId 범위를 포함한다.
- 기본 정렬은 `updated_at DESC, member_id DESC`다.
- 가입일은 반열린 createdAt 구간을 사용한다.
- 이름·loginId `%keyword%`가 B-Tree 인덱스를 사용한다고 가정하지 않는다.
- 역할별 노출 범위는 `pcs-permission-rules.md`를 따른다.

## 비밀번호

- 원문을 저장·응답하지 않는다.
- 임시 발급: status TEMPORARY, expiresAt 설정, changedAt null
- 변경 성공: status ACTIVE, expiresAt null, changedAt 현재 시각
- 임시 발급·변경과 refresh token 폐기는 같은 트랜잭션이다.
- 로그인 실패·잠금·최근 로그인 필드는 `auth-db.md`가 동작을 정의한다.

## STAFF 권한

- 꺼진 permission code만 회사별로 저장한다.
- 같은 회사·code 중복을 허용하지 않는다.
- row가 없으면 전체 허용이다.
- 개인별 예외 권한은 초기 범위가 아니다.

## 실패

- 같은 회사 loginId 중복
- OWNER 2명 또는 잘못된 ownerSlot
- 같은 회사 permissionCode 중복
- password 변경과 token 폐기의 부분 성공

## DB 통합 테스트 수용 기준

- `MemberPersistenceIntegrationTest`
- 임시 비밀번호는 hash와 TEMPORARY 상태로 저장된다.
- OWNER/ADMIN 목록 범위가 권한 규칙과 일치한다.
- STAFF disabled 권한이 회사별로 저장된다.
- 임시 발급·비밀번호 변경이 refresh token을 함께 폐기한다.
