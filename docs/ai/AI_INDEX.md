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
- `docs/ai/pcs-terminology-rules.md`
    - 화면 용어와 API/DB/패키지 기술 용어가 다를 때 기준 확인
- `docs/ai/pcs-permission-rules.md`
    - 권한/role 분기 기준 확인
- `docs/ai/pcs-status-lifecycle-rules.md`
    - `active`, 사용 중지, 상태 보존 기준 확인

## 문서 선택 규칙

작업 시작 기준:

- 사용자가 "관련 MD 참고", "규칙 보고", "문서 기준으로", "하네스 기준으로"라고 말하면 먼저 이 `AI_INDEX.md`에서 작업 유형을 고른다.
- 대화 기억만으로 문서를 추정하지 않는다.
- 아래 작업 유형 중 하나를 고른 뒤, 해당 유형의 필수 문서와 조건부 문서만 읽는다.
- 새 공통 규칙이 필요하면 먼저 기존 문서 중 가장 책임이 맞는 문서를 찾고, 새 문서는 마지막 선택으로 둔다.
- 디자인 작업은 이전 대화에서 읽었더라도 현재 저장소의 디자인 문서를 다시 읽는다.

### 1. 화면 디자인 / HTML / CSS 작업

읽을 문서:

- `docs/ai/pcs-design-system.md`
- `docs/ai/design/design-md-rules.md`
- `docs/ai/design/css-architecture.md`
- 화면 문구가 바뀌면 `docs/ai/pcs-terminology-rules.md`
- 화면 유형에 맞는 `docs/ai/design/*.md` 문서 1~3개

필수 작업 순서:

1. 위 필수 문서와 화면 유형 문서를 읽는다.
2. 대상 페이지 MD, 페이지 CSS, 해당 화면이 로드하는 공통 CSS를 읽는다.
3. `rg`로 같은 class, 상태, 반응형 규칙이 이미 있는지 검색한다.
4. 기존 공통 사용 → 공통 modifier 보완 → 공통 컴포넌트 추가 → 페이지 예외 순서로 결정한다.
5. 디자인 수정과 함께 대상 페이지 MD/CSS 전체의 기존 중복도 정리한다.
6. 페이지 MD에는 공통 문서 참조와 도메인 계약만, 페이지 CSS에는 공통화 불가능한 최소 예외만 남긴다.
7. 같은 유형의 대표 화면 2개 이상을 실행 확인하고 `processResources`를 수행한다.

디자인 변경에서 페이지 MD/CSS를 바로 늘리는 구현은 금지한다. 공통으로 이동할 수 없는 근거를 먼저 확인한 뒤 최소 범위만 추가한다.

화면 유형별 추가 문서:

- 공개/진입 화면 → `docs/ai/design/public-pages.md`
- 로그인 후 업무 화면 공통 레이아웃 → `docs/ai/design/workspace-layout.md`
- 업무 화면 반응형/햄버거 사이드바 → `docs/ai/design/responsive-layout.md`
- 디자인 MD 추가/수정 위치 판단 → `docs/ai/design/design-md-rules.md`
- 대시보드 → `docs/ai/design/dashboard.md`
- 품목·분류·거래처·사용자·검수 템플릿 같은 관리형 화면 → `docs/ai/design/management-page.md`
- 검색/목록/테이블 → `docs/ai/design/data-table.md`
- 등록/수정 패널 → `docs/ai/design/form-panel.md`
- 모달/확인창/토스트 → `docs/ai/design/modal-dialog.md`
- 업무 흐름 보조 패널 → `docs/ai/design/workflow-panel.md`
- 전표 등록 같은 단계형 업무 입력 화면 → `docs/ai/design/operation-flow.md`
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
- 디자인 MD 구조 정리 또는 새 디자인 규칙 추가

---

### 2. 프론트 JS / API 연동 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-frontend-js-rules.md`
- 화면 문구 또는 필드명이 바뀌면 `docs/ai/pcs-terminology-rules.md`
- 페이징 목록이면 `docs/ai/pcs-pagination-rules.md`
- 등록/수정 완료 피드백이나 토스트를 다루면 `docs/ai/design/modal-dialog.md`
- 해당 기능 문서 1개
- 로그인 후 업무 화면에서 인증 API를 호출하면 `docs/ai/pcs-auth-client-rules.md`도 확인
- 신규 API 경로를 연결하거나 기존 경로가 불확실할 때만 `docs/ai/pcs-api-spec.md`의 대상 라우트 섹션을 검색해서 확인

예시:

- 품목 목록 JS 작성 → `docs/features/part.md`
- 마이페이지 JS 작성 → `docs/features/mypage.md`
- 검수 등록 JS 작성 → `docs/features/inspection.md`
- 검수 이력 JS 작성 → `docs/features/inspection-history.md`
- 검수 템플릿 관리 JS 작성 → `docs/features/inspection-template.md`
- 로그인 JS 작성 → `docs/features/auth.md` + `docs/ai/pcs-auth-client-rules.md`
- 대시보드/거래처/품목 등 업무 화면 API 연동 → 해당 기능 문서 + `docs/ai/pcs-auth-client-rules.md`
- 품목 관리/품목 분류/거래처 관리/사용자 관리 같은 관리형 페이지 JS 수정 → `docs/ai/pcs-frontend-js-rules.md`의 "관리형 페이지 JS 기준" + `src/main/resources/static/js/pcs-common.js` + `src/main/resources/static/js/pcs-pagination.js`
- 사용자 관리는 `docs/features/member.md`, 마이페이지는 `docs/features/mypage.md`를 분리해서 본다.

---

### 3. 백엔드 구조 / 패키지 생성 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-harness-rules.md`
- 도메인명과 화면 용어가 다르면 `docs/ai/pcs-terminology-rules.md`
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
- 요청/응답 필드와 화면 용어가 다르면 `docs/ai/pcs-terminology-rules.md`
- 목록 API 또는 페이징 API면 `docs/ai/pcs-pagination-rules.md`
- 권한/role 분기가 있으면 `docs/ai/pcs-permission-rules.md`
- `active`, 사용 중지, 상태 보존을 다루면 `docs/ai/pcs-status-lifecycle-rules.md`
- 해당 기능 문서 1개
- `/api/workspaces/{companyCode}/**`처럼 인증이 필요한 API면 `docs/ai/pcs-auth-client-rules.md`도 확인

조건부 문서:

- 신규 API 경로를 추가하거나 기존 API 경로가 불확실할 때만 `docs/ai/pcs-api-spec.md`를 확인한다.
- `pcs-api-spec.md`는 전체 파일을 읽지 않는다.
- 먼저 도메인명, API 경로, DTO명으로 검색하고 관련 섹션만 읽는다.
- 단순 내부 로직 수정, Service 검증 수정, Mapper SQL 수정에는 `pcs-api-spec.md`를 읽지 않는다.

예시:

- Owner 회원가입 구현 → `docs/features/company.md`
- 업체 로그인 구현 → `docs/features/auth.md`
- 입고 전표 등록 구현 → `docs/features/stock.md`
- 검수 이력 API 구현 → `docs/features/inspection-history.md` + `docs/ai/pcs-auth-client-rules.md`
- 검수 템플릿 API 구현 → `docs/features/inspection-template.md` + `docs/ai/pcs-auth-client-rules.md`
- 거래처/품목/입출고/검수 API 구현 → 해당 기능 문서 + `docs/ai/pcs-auth-client-rules.md`

---

### 5. DB / SQL / Mapper XML 작업

읽을 문서:

- `docs/ai/pcs-project-structure-reference.md`
- 화면 용어와 DB 컬럼명이 다르면 `docs/ai/pcs-terminology-rules.md`
- 해당 기능 문서 1개
- DB 검증 기준이 있으면 `docs/features/{feature}-db.md`
- `active` 의미나 상태 보존 기준을 판단해야 하면 `docs/ai/pcs-status-lifecycle-rules.md`

조건부 문서:

- `docs/sql/pcs-schema-ddl.sql`은 기본 필수 문서가 아니라 조건부 문서로 둔다.
- 신규 테이블, 신규 컬럼, 조인 대상, 인덱스, 제약 조건 확인이 필요할 때만 `docs/sql/pcs-schema-ddl.sql`을 확인한다.
- `pcs-schema-ddl.sql`은 전체 파일을 읽지 않는다.
- 먼저 대상 테이블명으로 검색하고 해당 `CREATE TABLE`, 관련 `KEY`, 관련 `CHECK` 범위만 확인한다.
- 단순 WHERE 조건, ORDER BY, Mapper resultMap 수정이면 대상 Mapper XML과 feature-db 문서를 우선한다.

예시:

- MyBatis XML 작성
- 목록 검색 SQL 작성
- 집계 SQL 작성
- 재고 정합성 SQL 작성
- 페이징 목록 SQL 작성 → `docs/ai/pcs-pagination-rules.md`
- 품목 저장/수정 SQL 작성 → `docs/features/part.md` + `docs/features/part-db.md`
- 사용자 관리 SQL 작성 → `docs/features/member.md` + `docs/features/member-db.md`
- 마이페이지 계정 수정/비밀번호 SQL 작성 → `docs/features/mypage.md` + `docs/features/member-db.md`
- 검수/검수 이력/검수 템플릿 SQL/DB 검증 작성 → `docs/features/inspection.md` + `docs/features/inspection-history.md` + `docs/features/inspection-template.md` + `docs/features/inspection-db.md`
- 품목 분류 SQL/DB 검증 작성 → `docs/features/category.md` + `docs/features/category-db.md`

SQL 참조 기준:

- 기본 DB 구조 확인이 필요한 경우에만 `docs/sql/pcs-schema-ddl.sql`의 대상 테이블 블록을 본다.
- `docs/sql/*-alter.sql` 파일은 과거 수동 반영 기록이므로, 사용자가 직접 지정하거나 특정 컬럼 변경 이력을 확인할 때만 본다.
- DDL과 feature DB 문서가 충돌하면 먼저 실제 DB/DDL 기준을 확인하고 feature DB 문서를 최신화한다.

---

### 6. 하네스 수정 작업

읽을 문서:

- `docs/ai/pcs-harness-rules.md`
- `docs/ai/pcs-powershell-harness-rules.md`
- Codex lifecycle 훅 작업이면 `docs/ai/pcs-codex-hook-rules.md`
- `docs/ai/pcs-agent-context.md`
- 필요한 경우 `docs/ai/pcs-project-structure-reference.md`

확인 대상:

- `harness/run-harness.ps1`
- `harness/run-feedback-loop.ps1`
- `harness/install-hooks.ps1`
- `harness/hooks/*`
- `harness/config/features.json`
- `.codex/hooks.json`
- `.codex/hooks/*.ps1`

기준:

- Feature 경로와 DB 의존성은 `harness/config/features.json` 한 곳에서 관리한다.
- 실제 검사는 `run-harness.ps1`에 구현하고, `run-feedback-loop.ps1`은 옵션 전달과 실패 요약 생성을 담당한다.
- PowerShell 하네스 코드는 Windows/macOS 검증 로직을 복제하지 않고, 공통 검증 로직 + OS 어댑터 구조를 따른다.
- Git pre-push 훅은 `bootstrap`이나 `full`이 아니라 `gate` 모드로 변경 파일 기준 feature 검사와 공통 검증을 실행한다.
- Codex Stop 훅도 `gate`를 사용하며 서버를 제어하지 않는다.
- `.gitignore` 필수 패턴, Git 추적 금지 파일, pre-push 변경 파일 금지 검사는 `docs/ai/pcs-harness-rules.md`의 `.gitignore 규칙` 기준을 따른다.

---

## 문서 추가 규칙

새로운 `.md` 문서를 추가하면 이 파일에도 연결 기준을 추가한다.

기준:

- 새 feature 문서가 생기면 해당 작업 유형의 “읽을 문서” 기준에 포함한다.
- 새 design 문서가 생기면 “화면 유형별 추가 문서”에 포함한다.
- 새 DB 문서가 생기면 DB / SQL / Mapper XML 작업 기준에 포함한다.
- 특정 기능에서만 읽어야 하는 문서는 전체 필수 문서로 올리지 않고, 해당 작업 유형이나 예시에 연결한다.
- 문서가 생겼는데 `AI_INDEX.md`에서 찾을 수 없으면 팀원 에이전트가 참고하지 못하는 문서로 본다.

## 공통 구현 참조 규칙

기능 구현 중 이미 있는 공통 구현을 따라야 할 때는 아래 파일을 먼저 확인한다.

백엔드:

- 업체 코드/JWT 회사 범위 검증: `src/main/java/com/pcs/global/workspace/WorkspaceAccessValidator.java`
- Security URL role 그룹: `src/main/java/com/pcs/global/security/PcsRoleGroups.java`
- 회사 활성 여부 조회: `src/main/java/com/pcs/global/workspace/WorkspaceMapper.java`
- 페이지/size/offset 정규화: `src/main/java/com/pcs/global/pagination/PageQuery.java`
- 문자열 trim/null/required 처리: `src/main/java/com/pcs/global/util/TextNormalizer.java`
- API 응답/예외: `docs/ai/pcs-backend-common-rules.md`

프론트:

- 인증 API 호출, access token 재발급: `src/main/resources/static/js/pcs-api.js`
- 페이징 query, 응답 정규화, 스크롤 보존: `src/main/resources/static/js/pcs-pagination.js`
- 토스트/공통 UI 피드백: `src/main/resources/static/js/pcs-ui.js`
- 회사 코드 추출, 링크 갱신, 포맷, 공통 폼/테이블/드로어 유틸: `src/main/resources/static/js/pcs-common.js`
- HTML escape 공통 유틸: `src/main/resources/static/js/pcs-common.js`의 `window.PcsHtml.escape`
- 관리형 페이지의 검색/목록/등록/수정 JS 기준: `docs/ai/pcs-frontend-js-rules.md`

사양 항목:

- 사양 입력 타입 기준: `src/main/java/com/pcs/domain/category/type/PartSpecInputTypes.java`
- 분류별 사양 항목/선택지 공통 조회: `src/main/java/com/pcs/domain/category/mapper/PartSpecMapper.java`, `src/main/resources/mapper/category/PartSpecMapper.xml`

새 기능에서 위와 같은 기능을 다시 만들지 않는다. 먼저 공통 구현을 사용할 수 있는지 확인하고, 부족하면 공통 구현을 확장한다.

## 토큰 절약 규칙

- 문서 개수보다 작업 관련성을 우선한다.
- 위 문서 선택 규칙에 적힌 필수 문서와 조건부 문서만 읽는다.
- 조건부 문서는 해당 조건에 맞을 때만 읽는다. 예: 페이징이면 `pcs-pagination-rules.md`, 인증 API면 `pcs-auth-client-rules.md`.
- feature 문서는 기본적으로 해당 도메인 문서 1개만 읽고, DB 작업이면 같은 도메인의 `{feature}-db.md`만 추가로 읽는다.
- 큰 문서는 전체 파일을 읽지 않는다.
- `pcs-api-spec.md`는 신규/불확실한 API 경로 확인이 필요할 때만 대상 API 경로, 도메인명, DTO명으로 먼저 검색한다.
- `pcs-schema-ddl.sql`은 DB 구조 확인이 필요할 때만 대상 테이블명으로 먼저 검색한다.
- 공통 JS/CSS/Java 파일은 해당 기능이 직접 사용할 때만 읽는다.
- 전체 리팩토링, 전체 중복 제거, 전체 문서 재정리는 사용자가 명시적으로 요청한 경우에만 한다.
- 작은 수정은 대상 파일과 직접 관련된 규칙 문서만 확인한다.
- 이미 읽은 문서라도 내용이 불확실하면 전체 재독해보다 관련 섹션만 확인한다.
- 작업 완료 후 실제로 참조한 문서만 짧게 적는다.
