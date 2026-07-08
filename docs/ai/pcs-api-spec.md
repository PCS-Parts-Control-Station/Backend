# PCS API Route Index

이 문서는 PCS API 경로를 빠르게 찾기 위한 라우트 인덱스다.

- 상세 요청/응답, 예외, 권한, 비즈니스 규칙은 각 `docs/features/{feature}.md`를 기준으로 한다.
- 이 문서는 전체를 반복해서 읽지 않는다.
- 작업 시 도메인명, API 경로, 화면명, DTO명으로 필요한 섹션만 검색한다.
- 긴 요청/응답 JSON 예시는 이 문서에 두지 않는다.

## 사용 규칙

- 신규 API 경로 추가, 기존 API 경로 확인, 도메인별 API 위치 확인이 필요할 때만 이 문서를 본다.
- 상세 요청/응답 JSON은 feature 문서에서 확인한다.
- 공통 응답/예외는 `docs/ai/pcs-backend-common-rules.md`를 따른다.
- 페이징은 `docs/ai/pcs-pagination-rules.md`를 따른다.
- 권한은 `docs/ai/pcs-permission-rules.md`를 따른다.
- 인증/JWT는 `docs/features/auth.md`와 `docs/ai/pcs-auth-client-rules.md`를 따른다.
- DB 컬럼과 제약 조건은 필요한 경우에만 `docs/sql/pcs-schema-ddl.sql`의 대상 테이블 블록만 확인한다.

## 공통 원칙

- 화면 URL과 API URL은 분리한다.
- PageController는 정적 HTML forward만 담당한다.
- 실제 데이터 처리는 `/api/**`에서 수행한다.
- 업체 업무 API는 `/api/workspaces/{companyCode}/**` 아래에 둔다.
- API 응답은 `ApiResultDto<T>`로 감싼다.
- 목록/검색/통계는 SQL에서 필터링/집계한다.
- 마스터 데이터 삭제는 기본적으로 물리 삭제가 아니라 `active` 상태 변경을 사용한다.
- 입출고, 검수, 이력성 데이터는 원본 수정/삭제 대신 취소/정정/재검수 이력으로 남긴다.

## 도메인별 원본 문서

| 도메인 | 원본 문서 |
|---|---|
| auth | `docs/features/auth.md` |
| company | `docs/features/company.md` |
| member | `docs/features/member.md` |
| mypage | `docs/features/mypage.md` |
| partner | `docs/features/partner.md` |
| category | `docs/features/category.md` |
| part | `docs/features/part.md` |
| stock | `docs/features/stock.md` |
| inspection | `docs/features/inspection.md` |
| inspection-history | `docs/features/inspection-history.md` |
| inspection-template | `docs/features/inspection-template.md` |
| history | `docs/features/history.md` |
| dashboard | `docs/features/dashboard.md` |

## API Routes

### 인증 / 세션 `auth`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| POST | `/api/owners/login` | Owner 로그인 | `docs/features/auth.md` |
| POST | `/api/workspaces/login` | 업체 코드 + 아이디 + 비밀번호 로그인 | `docs/features/auth.md` |
| POST | `/api/workspaces/{companyCode}/login` | 특정 업체 로그인 | `docs/features/auth.md` |
| POST | `/api/auth/refresh` | 토큰 재발급 | `docs/features/auth.md` |
| POST | `/api/auth/logout` | 로그아웃 | `docs/features/auth.md` |
| GET | `/api/workspaces/{companyCode}/me` | 내 세션 정보 조회 | `docs/features/auth.md` |

### 회사 / Owner 가입 `company`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| POST | `/api/owners/signup` | Owner 회원가입 + 회사 생성 / 회사 코드 발급 | `docs/features/company.md` |
| GET | `/api/workspaces/{companyCode}/public-info` | 업체 주소 존재/사용 가능 여부 확인 | `docs/features/company.md` |
| GET | `/api/owners/company` | Owner 회사 조회 | `docs/features/company.md` |
| PATCH | `/api/owners/company` | 회사 정보 수정 | `docs/features/company.md` |
| PATCH | `/api/owners/company/active` | 회사 활성 여부 변경 | `docs/features/company.md` |

### 사용자 / 마이페이지 `member`, `mypage`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/users` | 사용자 목록 | `docs/features/member.md` |
| POST | `/api/workspaces/{companyCode}/users` | 사용자 생성 | `docs/features/member.md` |
| GET | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 상세 | `docs/features/member.md` |
| PATCH | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 수정 | `docs/features/member.md` |
| POST | `/api/workspaces/{companyCode}/users/{memberId}/temporary-password` | 임시 비밀번호 발급 | `docs/features/member.md` |
| GET | `/api/workspaces/{companyCode}/users/staff-permissions` | STAFF 공통 업무 권한 조회 | `docs/features/member.md` |
| PATCH | `/api/workspaces/{companyCode}/users/staff-permissions` | STAFF 공통 업무 권한 저장 | `docs/features/member.md` |
| GET | `/api/workspaces/{companyCode}/mypage` | 내 정보 조회 | `docs/features/mypage.md` |
| PATCH | `/api/workspaces/{companyCode}/mypage` | 내 정보 수정 | `docs/features/mypage.md` |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` | 비밀번호 변경 | `docs/features/mypage.md` |

### 거래처 `partner`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/partners` | 거래처 목록 검색 | `docs/features/partner.md` |
| POST | `/api/workspaces/{companyCode}/partners` | 거래처 생성 | `docs/features/partner.md` |
| GET | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 상세 | `docs/features/partner.md` |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 수정 | `docs/features/partner.md` |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}/active` | 거래 가능 여부 변경 | `docs/features/partner.md` |

### 품목 분류 `category`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/categories` | 품목 분류 목록 검색 | `docs/features/category.md` |
| POST | `/api/workspaces/{companyCode}/categories` | 품목 분류 생성 | `docs/features/category.md` |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 상세 | `docs/features/category.md` |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 수정 | `docs/features/category.md` |
| DELETE | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 삭제 | `docs/features/category.md` |

### 품목 / 기준 `part`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/parts` | 품목/재고 목록 검색 | `docs/features/part.md` |
| POST | `/api/workspaces/{companyCode}/parts` | 품목 마스터 등록 | `docs/features/part.md` |
| GET | `/api/workspaces/{companyCode}/parts/{partId}` | 품목 상세 | `docs/features/part.md` |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}` | 품목 마스터 수정 | `docs/features/part.md` |

### 입고 / 출고 / 재고 변화 `stock`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` | 입고 전표 등록 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/outbound-candidates` | 출고 가능한 관리번호 목록 | `docs/features/stock.md` |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` | 출고 전표 등록 | `docs/features/stock.md` |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` | 입출고 전표 취소 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/documents` | 입출고 전표 목록 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` | 입출고 전표 상세 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}/movements` | 전표의 부품별 재고 변화 라인 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/movements` | 입출고 재고 변화 라인 목록 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}` | 입출고 재고 변화 라인 상세 | `docs/features/stock.md` |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}/units` | 라인에 포함된 개별 부품 목록 | `docs/features/stock.md` |

### 검수 `inspection`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents` | 검수 대상 입고 전표 목록 | `docs/features/inspection.md` |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units` | 전표별 검수 대상 관리번호 목록 | `docs/features/inspection.md` |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 등록 | `docs/features/inspection.md` |
| POST | `/api/workspaces/{companyCode}/inspections/bulk` | 여러 관리번호 일괄 최초 검수 등록 | `docs/features/inspection.md` |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` | 검수 정정 이력 생성 | `docs/features/inspection.md` |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` | 재검수 이력 생성 | `docs/features/inspection.md` |

### 검수 이력 `inspection-history`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` | 검수 이력 전표 목록 | `docs/features/inspection-history.md` |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록 | `docs/features/inspection-history.md` |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 | `docs/features/inspection-history.md` |

### 검수 템플릿 `inspection-template`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 목록 | `docs/features/inspection-template.md` |
| POST | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 생성 | `docs/features/inspection-template.md` |
| GET | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` | 검수 템플릿 상세 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` | 검수 템플릿 수정 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/active` | 검수 템플릿 사용 여부 변경 | `docs/features/inspection-template.md` |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items` | 검수 항목 추가 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}` | 검수 항목 수정 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/active` | 검수 항목 사용 여부 변경 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/sort-order` | 검수 항목 순서 일괄 저장 | `docs/features/inspection-template.md` |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options` | 선택지 추가 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}` | 선택지 수정 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}/active` | 선택지 사용 여부 변경 | `docs/features/inspection-template.md` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/sort-order` | 선택지 순서 일괄 저장 | `docs/features/inspection-template.md` |

### 이력 `history`

현재 별도 `/history/*` API는 사용하지 않는다. 입출고 이력은 `stock` 도메인의 전표/재고 변화 조회 API를 사용하고, 검수 이력은 `inspection` 도메인의 이력 조회 API를 사용한다. 화면별 조합 기준은 `docs/features/history.md`를 따른다.

### 대시보드 `dashboard`

| Method | API | 설명 | 원본 문서 |
|---|---|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard` | 운영 현황 통합 조회 | `docs/features/dashboard.md` |
