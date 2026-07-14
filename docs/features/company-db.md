# Company DB Rules

## 목적

회사와 최초 OWNER가 한 트랜잭션으로 생성되는지 정의한다. 회원 row 자체 규칙은 `member-db.md`가 원본이다.

## 테이블과 저장

| 테이블 | 저장 |
|---|---|
| `tb_company` | 이름, 코드, 선택 연락처·사업자번호, active, 시각 |
| `tb_member` | 같은 companyId의 OWNER 계정 |

업체 접속 주소는 저장값이 아니라 `/w/{companyCode}`로 계산한다.

## 제약

- companyCode는 전체 unique다.
- businessRegistrationNo는 값이 있을 때 unique다.
- OWNER의 loginId·ownerSlot 제약은 `member-db.md`를 따른다.
- 물리 제약 이름과 컬럼은 DDL이 원본이다.

## 트랜잭션

```text
company insert -> OWNER insert -> commit
```

- 어느 insert든 실패하면 둘 다 남지 않는다.
- company만 또는 OWNER만 존재하는 부분 성공을 허용하지 않는다.
- OWNER의 role, ownerSlot, 비밀번호 상태는 `member-db.md` 기준으로 저장한다.

## 실패

- 중복 companyCode 또는 businessRegistrationNo
- OWNER loginId/ownerSlot 제약 위반
- company 저장 후 OWNER 저장 실패

## DB 통합 테스트 수용 기준

- `CompanyPersistenceIntegrationTest`
- company와 OWNER가 함께 저장·롤백된다.
- 회사 코드와 사업자번호 unique가 적용된다.
- 비OWNER가 OWNER 회사 정보를 변경할 수 없다.
