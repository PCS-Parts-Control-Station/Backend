# PCS AI INDEX

작업별로 읽을 문서를 고르는 라우팅 인덱스다. 모든 문서를 매번 읽지 않는다.

## 원본 문서 소유권

| 내용 | 원본 |
|---|---|
| 에이전트 작업·서버 제어·완료 | `AGENTS.md` |
| 프로젝트 정체성과 범위 | `docs/ai/pcs-agent-context.md` |
| 계층·패키지·DTO·MyBatis·프론트 구조 | `docs/ai/pcs-project-structure-reference.md` |
| API 응답·예외·공통 백엔드 처리 | `docs/ai/pcs-backend-common-rules.md` |
| 인증 정책 | `docs/features/auth.md` |
| 브라우저 인증 API 사용법 | `docs/ai/pcs-auth-client-rules.md` |
| 페이징 | `docs/ai/pcs-pagination-rules.md` |
| 권한 | `docs/ai/pcs-permission-rules.md` |
| active와 이력 보존 | `docs/ai/pcs-status-lifecycle-rules.md` |
| 화면/기술 용어 | `docs/ai/pcs-terminology-rules.md` |
| 테스트 정책 | `docs/ai/pcs-test-strategy.md` |
| 하네스 | `docs/ai/pcs-harness-rules.md` |
| 디자인 토큰 | `docs/ai/pcs-design-system.md` |
| CSS 파일 소유권 | `docs/ai/design/css-architecture.md` |
| 기능 계약 | `docs/features/{feature}.md` |
| DB 동작 계약 | `docs/features/{feature}-db.md` |
| 물리 스키마 | `docs/sql/pcs-schema-ddl.sql` |

다른 문서는 위 내용을 다시 정의하지 않고 원본을 참조한 뒤 자기 예외만 적는다.

## 작업 유형별 문서

### 화면 디자인 / HTML / CSS

필수:

- `docs/ai/pcs-design-system.md`
- `docs/ai/design/design-md-rules.md`
- `docs/ai/design/css-architecture.md`
- 아래 화면 유형 문서 1~3개

조건부:

- 화면 문구 변경: `pcs-terminology-rules.md`
- 도메인 필드·상태 확인: 해당 feature 문서

읽지 않음: 전체 API 인덱스, 관련 없는 feature, DDL.

작업 순서: 공통 CSS 검색 → 기존 class 사용 → 공통 modifier/컴포넌트 보완 → 페이지 예외. 같은 유형 대표 화면 2개와 `processResources`를 확인한다.

### 프론트 JS / API 연동

필수:

- `pcs-project-structure-reference.md`
- `pcs-frontend-js-rules.md`
- 해당 feature 문서

조건부:

- 인증 API: `pcs-auth-client-rules.md`
- 페이징: `pcs-pagination-rules.md`
- URL 상태 복원: `pcs-navigation-state-guide.md`
- 모달/토스트: `design/modal-dialog.md`
- 신규·불명확한 경로: `pcs-api-spec.md`의 해당 도메인만 검색

### 백엔드 구조 / 패키지 생성

필수:

- `pcs-project-structure-reference.md`
- `pcs-harness-rules.md`
- 해당 feature 문서

조건부: 용어가 다르면 `pcs-terminology-rules.md`.

### API 구현

필수:

- `pcs-project-structure-reference.md`
- `pcs-backend-common-rules.md`
- 해당 feature 문서

조건부:

- 인증 업무 API: `pcs-auth-client-rules.md`
- 목록: `pcs-pagination-rules.md`
- 권한 분기: `pcs-permission-rules.md`
- active·취소·이력 보존: `pcs-status-lifecycle-rules.md`
- 신규·불명확한 경로: `pcs-api-spec.md` 대상 섹션만 검색

### DB / SQL / Mapper XML

필수:

- `pcs-project-structure-reference.md`
- 해당 feature 문서
- 해당 `{feature}-db.md`

조건부:

- 신규 테이블·컬럼·인덱스·제약: DDL에서 대상 테이블 블록만 검색
- 페이징 목록: `pcs-pagination-rules.md`
- active 의미: `pcs-status-lifecycle-rules.md`

단순 WHERE, ORDER BY, resultMap 수정은 대상 Mapper와 feature-db를 우선한다.

### 하네스 / Hook

필수:

- `pcs-harness-rules.md`
- `docs/ai/pcs-powershell-harness-rules.md`
- Codex lifecycle이면 `docs/ai/pcs-codex-hook-rules.md`

확인 대상은 `harness/config/features.json`, 변경하는 스크립트, `.codex/hooks.json`이다. Feature 경로와 테스트 selector는 `features.json`만 원본으로 한다.

### 테스트

필수:

- `pcs-test-strategy.md`
- 해당 feature 문서
- DB 검증이면 `{feature}-db.md`

조건부: 공통 응답은 `pcs-backend-common-rules.md`, 권한은 `pcs-permission-rules.md`, 하네스 연결은 `pcs-harness-rules.md`.

### 문서 정리

- 이 파일의 소유권 표에서 원본을 먼저 정한다.
- 중복 규칙은 원본에 한 번만 남기고 다른 문서는 참조 문장으로 바꾼다.
- 라우팅이 달라지면 이 파일도 갱신한다.

## 디자인 문서 선택

| 화면/작업 | 문서 |
|---|---|
| 공개·회사 등록·로그인·오류 | `design/public-pages.md` |
| 업무 레이아웃·사이드바·헤더 | `design/workspace-layout.md` |
| breakpoint·폭별 전환 | `design/responsive-layout.md` |
| 검색·목록·테이블 | `design/data-table.md` |
| 관리형 화면 조합 | `design/management-page.md` |
| 등록·수정 폼 내용 | `design/form-panel.md` |
| 오른쪽 드로어 | `design/side-drawer.md` |
| 확인·입력 모달·토스트 | `design/modal-dialog.md` |
| 업무 흐름 보조 패널 | `design/workflow-panel.md` |
| 단계형 업무 입력 | `design/operation-flow.md` |
| 대시보드 | `design/dashboard.md` |
| 상세 | `design/detail-page.md` |
| 이력·타임라인 | `design/history-timeline.md` |

## 기능 문서 지도

| 영역 | 기능 | DB |
|---|---|---|
| 인증 | `auth.md` | `auth-db.md`, `member-db.md` |
| 회사 | `company.md` | `company-db.md`, `member-db.md` |
| 사용자·마이페이지 | `member.md`, `mypage.md` | `member-db.md` |
| 거래처 | `partner.md` | `partner-db.md` |
| 품목 분류 | `category.md` | `category-db.md` |
| 품목 | `part.md` | `part-db.md` |
| 개별 부품 | `part-unit.md` | `part-unit-db.md` |
| 입출고·재고 | `stock.md` | `stock-db.md` |
| 검수 저장 | `inspection.md` | `inspection-db.md` |
| 검수 이력 | `inspection-history.md` | `inspection-db.md` |
| 검수 템플릿 | `inspection-template.md` | `inspection-db.md` |
| 대시보드 | `dashboard.md` | `dashboard-db.md` |

`history.md`는 독립 기능 계약이 아니라 `stock.md`와 `inspection-history.md`로 연결하는 호환 문서다.

## 큰 인덱스 사용

- `pcs-api-spec.md`: feature 문서를 원본으로 하는 경로 검색용 파생 인덱스다. 도메인·경로로 대상 섹션만 본다.
- `pcs-schema-ddl.sql`: 물리 스키마 원본이다. 테이블명으로 검색해 관련 `CREATE TABLE`, `KEY`, `CHECK`만 본다.
- 자동 생성 리포트는 규칙 문서가 아니다. 실패 시 `agent-failures.md`의 최신 FAIL만 우선 확인한다.

## 문서 추가·수정

- 새 feature/design/DB 문서는 이 인덱스에서 찾을 수 있어야 한다.
- 새 문서는 기존 원본 문서로 표현할 수 없을 때만 만든다.
- API·DB·디자인·테스트 공통 규칙은 feature 문서에 복사하지 않는다.
- 완료 응답에는 실제로 읽은 문서만 적는다.
