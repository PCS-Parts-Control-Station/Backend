# PCS AI INDEX

이 문서는 코덱스가 작업별로 어떤 문서를 읽을지 결정하기 위한 문서다.
모든 문서를 매번 읽지 않는다.

## 프로젝트 한 줄 요약

PCS는 중고 PC 부품을 관리번호 단위로 입고, 검수, 재고, 출고, 이력까지 추적하는 국내 업무용 재고관리 시스템이다.

## 기본 참조 문서

작업 성격을 판단하기 위해 필요한 경우에만 읽는다.

- `docs/ai/pcs-agent-context.md`
    - 프로젝트 정체성, 전체 작업 원칙, 계층 역할 확인
- `docs/ai/pcs-harness-rules.md`
    - 하네스 검사 기준, 금지 규칙, 완료 기준 확인
- `docs/ai/pcs-backend-common-rules.md`
    - 공통 응답, 예외, ErrorCode, Controller 처리 기준 확인

## 문서 선택 규칙

### 1. 화면 디자인 / HTML / CSS 작업

읽을 문서:

- `docs/ai/pcs-design-system.md`
- 화면 유형에 맞는 `docs/ai/design/*.md` 문서 1~3개

화면 유형별 추가 문서:

- 공개/진입 화면 → `docs/ai/design/public-pages.md`
- 로그인 후 업무 화면 공통 레이아웃 → `docs/ai/design/workspace-layout.md`
- 업무 화면 반응형/햄버거 사이드바 → `docs/ai/design/responsive-layout.md`
- 대시보드 → `docs/ai/design/dashboard.md`
- 검색/목록/테이블 → `docs/ai/design/data-table.md`
- 등록/수정 패널 → `docs/ai/design/form-panel.md`
- 모달/확인창/토스트 → `docs/ai/design/modal-dialog.md`
- 업무 흐름 보조 패널 → `docs/ai/design/workflow-panel.md`
- 상세 화면 → `docs/ai/design/detail-page.md`
- 이력/타임라인 → `docs/ai/design/history-timeline.md`

읽지 말 문서:

- `docs/sql/pcs-schema-ddl.sql`
- 관련 없는 feature 문서
- 전체 API 명세

예시 작업:

- 메인 화면 디자인 수정
- 관리자 화면 UI 개선
- CSS 리팩토링
- 상태 배지 디자인 정리
- 등록/수정 모달 또는 저장 확인 모달 추가

---

### 2. 프론트 JS / API 연동 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-frontend-js-rules.md`
- 필요한 경우 `docs/ai/pcs-api-spec.md`
- 페이징 목록이면 `docs/ai/pcs-pagination-rules.md`
- 해당 기능 문서 1개
- 로그인 후 업무 화면에서 인증 API를 호출하면 `docs/ai/pcs-auth-client-rules.md`도 확인

예시:

- 부품 목록 JS 작성 → `docs/features/part.md`
- 검수 등록 JS 작성 → `docs/features/inspection.md`
- 로그인 JS 작성 → `docs/features/auth.md` + `docs/ai/pcs-auth-client-rules.md`
- 대시보드/거래처/부품 등 업무 화면 API 연동 → 해당 기능 문서 + `docs/ai/pcs-auth-client-rules.md`

---

### 3. 백엔드 구조 / 패키지 생성 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-harness-rules.md`
- 해당 기능 문서 1개

예시:

- `domain/part` 생성
- Controller/Facade/Service/Mapper 기본 구조 생성
- 공통 응답 구조 생성

---

### 4. API 구현 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-backend-common-rules.md`
- `docs/ai/pcs-api-spec.md`
- 목록 API 또는 페이징 API면 `docs/ai/pcs-pagination-rules.md`
- 해당 기능 문서 1개
- `/api/workspaces/{companyCode}/**`처럼 인증이 필요한 API면 `docs/ai/pcs-auth-client-rules.md`도 확인

예시:

- Owner 회원가입 구현 → `docs/features/company.md`
- 업체 로그인 구현 → `docs/features/auth.md`
- 입고 전표 등록 구현 → `docs/features/stock.md`
- 거래처/부품/입출고/검수 API 구현 → 해당 기능 문서 + `docs/ai/pcs-auth-client-rules.md`

---

### 5. DB / SQL / Mapper XML 작업

읽을 문서:

- `docs/ai/pcs-project-structure-reference.md`
- `docs/sql/pcs-schema-ddl.sql`
- 해당 기능 문서 1개
- DB 검증 기준이 있으면 `docs/features/{feature}-db.md`

예시:

- MyBatis XML 작성
- 목록 검색 SQL 작성
- 집계 SQL 작성
- 재고 정합성 SQL 작성
- 페이징 목록 SQL 작성 → `docs/ai/pcs-pagination-rules.md`

SQL 참조 기준:

- 기본 DB 구조 확인은 `docs/sql/pcs-schema-ddl.sql`만 본다.
- `docs/sql/*-alter.sql` 파일은 과거 수동 반영 기록이므로, 사용자가 직접 지정하거나 특정 컬럼 변경 이력을 확인할 때만 본다.
- DDL과 feature DB 문서가 충돌하면 먼저 실제 DB/DDL 기준을 확인하고 feature DB 문서를 최신화한다.

---

### 6. 하네스 수정 작업

읽을 문서:

- `docs/ai/pcs-harness-rules.md`
- `docs/ai/pcs-agent-context.md`
- 필요한 경우 `docs/ai/pcs-project-structure-reference.md`

확인 대상:

- `harness/run-harness.ps1`
- `harness/run-feedback-loop.ps1`

기준:

- 새 `-Feature` 또는 `-DbFeature` 값을 추가하면 두 스크립트의 허용값을 함께 맞춘다.
- 실제 검사는 `run-harness.ps1`에 구현하고, `run-feedback-loop.ps1`은 옵션 전달과 실패 요약 생성을 담당한다.

---

## 문서 추가 규칙

새로운 `.md` 문서를 추가하면 이 파일에도 연결 기준을 추가한다.

기준:

- 새 feature 문서가 생기면 해당 작업 유형의 “읽을 문서” 기준에 포함한다.
- 새 design 문서가 생기면 “화면 유형별 추가 문서”에 포함한다.
- 새 DB 문서가 생기면 DB / SQL / Mapper XML 작업 기준에 포함한다.
- 특정 기능에서만 읽어야 하는 문서는 전체 필수 문서로 올리지 않고, 해당 작업 유형이나 예시에 연결한다.
- 문서가 생겼는데 `AI_INDEX.md`에서 찾을 수 없으면 팀원 에이전트가 참고하지 못하는 문서로 본다.

## 토큰 절약 규칙

- 문서 개수보다 작업 관련성을 우선한다.
- 위 문서 선택 규칙에 적힌 필수 문서와 조건부 문서만 읽는다.
- 조건부 문서는 해당 조건에 맞을 때만 읽는다. 예: 페이징이면 `pcs-pagination-rules.md`, 인증 API면 `pcs-auth-client-rules.md`.
- feature 문서는 기본적으로 해당 도메인 문서 1개만 읽고, DB 작업이면 같은 도메인의 `{feature}-db.md`만 추가로 읽는다.
- `pcs-api-spec.md`와 `pcs-schema-ddl.sql`은 크므로 API 흐름이나 DB 구조 확인이 필요한 경우에만 읽는다.
- 이미 읽은 문서라도 내용이 불확실하면 전체 재독해보다 관련 섹션만 확인한다.
- 작업 완료 후 참조한 문서를 명시한다.
