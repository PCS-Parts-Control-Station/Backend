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
| GET | `/api/workspaces/{companyCode}/public-info` | 업체 주소 존재/사용 가능 여부 확인 |
| GET | `/api/owners/company` | Owner 회사 조회 |
| PATCH | `/api/owners/company` | 회사 정보 수정 |

회사 `active` 상태와 비활성 회사 접근 차단은 구현되어 있다. Owner가 상태를 직접 변경하는 API는 현재 제공하지 않으며, 운영 정책 확정 후 별도 구현한다.

## 주요 규칙

- `companyCode`는 전체에서 중복될 수 없다.
- 회사 등록 화면은 회사 정보, 대표 연락처, 최고 관리자 계정을 한 번에 받는다.
- 대표 이메일, 대표 연락처, 사업자등록번호는 선택값이다.
- Owner 회원가입과 회사 생성은 하나의 API에서 처리한다.
- Owner 계정과 회사는 같은 트랜잭션으로 저장한다.
- Owner 또는 회사 중 하나만 저장되는 부분 성공은 허용하지 않는다.
- 회사 생성 후 Owner 계정은 해당 회사의 OWNER 권한으로 연결된다.
- 회사 정보 수정은 로그인한 OWNER의 JWT에 들어 있는 회사 기준으로 처리한다.
- 회사 정보 수정에서 `companyCode`는 바꾸지 않는다. 업체 접속 주소와 토큰 검증 기준에 영향을 주기 때문이다.
- OWNER 권한 기준은 `docs/ai/pcs-permission-rules.md`를 따른다.
- OWNER 계정 저장 규칙은 `docs/features/member-db.md`를 따른다.
- 회사 비활성화 시 업체 업무 API 접근을 차단한다.
- 회사 삭제는 하지 않고 `docs/ai/pcs-status-lifecycle-rules.md` 기준의 `active` 상태만 변경한다.
- `/w/{companyCode}` 공개 로그인 진입에서는 `public-info`로 업체 주소를 한 번 확인한다.
- 존재하지 않거나 비활성화된 업체 주소는 공통 잘못된 접근 페이지로 안내한다.

## 하네스 포인트

- Owner 회원가입 + 회사 생성은 단일 트랜잭션으로 처리한다.
- 회사 생성 실패 시 Owner와 회사 연결이 부분 저장되면 안 된다.
- `companyCode` 중복 예외는 `docs/ai/pcs-backend-common-rules.md` 기준의 ErrorCode로 처리한다.

## Test Coverage

- Unit/facade tests: `CompanyFacadeTest`
- API tests: `OwnerSignupApiControllerTest`, `WorkspacePublicApiControllerTest`
- Required checks:
  - company signup creates company and OWNER account in one flow
  - duplicate company code and business registration number are rejected
  - owner company read/update is OWNER-only
  - public workspace info rejects inactive or missing company codes
