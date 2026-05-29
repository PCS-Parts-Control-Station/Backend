# Company Feature

## 목적

Owner 회원가입, 업체 작업 공간 생성, 회사 정보 관리를 담당한다.

## 패키지

```text
com.pcs.domain.company
```

## API

| Method | API | 설명 |
|---|---|---|
| POST | `/api/owners/signup` | Owner 회원가입 + 회사 생성 / 회사 코드 발급 |
| GET | `/api/owners/company` | Owner 회사 조회 |
| PATCH | `/api/owners/company` | 회사 정보 수정 |
| PATCH | `/api/owners/company/active` | 회사 활성 여부 변경 |

## 주요 규칙

- `companyCode`는 전체에서 중복될 수 없다.
- 회사 등록 화면은 회사 정보, 대표 연락처, 최고 관리자 계정을 한 번에 받는다.
- 대표 이메일, 대표 연락처, 사업자등록번호는 선택값이다.
- Owner 회원가입과 회사 생성은 하나의 API에서 처리한다.
- Owner 계정과 회사는 같은 트랜잭션으로 저장한다.
- Owner 또는 회사 중 하나만 저장되는 부분 성공은 허용하지 않는다.
- 회사 생성 후 Owner 계정은 해당 회사의 OWNER 권한으로 연결된다.
- OWNER 권한 기준은 `docs/ai/pcs-permission-rules.md`를 따른다.
- OWNER 계정 저장 규칙은 `docs/features/member-db.md`를 따른다.
- 회사 비활성화 시 업체 업무 API 접근을 차단한다.
- 회사 삭제는 하지 않고 `docs/ai/pcs-status-lifecycle-rules.md` 기준의 `active` 상태만 변경한다.

## 하네스 포인트

- Owner 회원가입 + 회사 생성은 단일 트랜잭션으로 처리한다.
- 회사 생성 실패 시 Owner와 회사 연결이 부분 저장되면 안 된다.
- `companyCode` 중복 예외는 `docs/ai/pcs-backend-common-rules.md` 기준의 ErrorCode로 처리한다.
