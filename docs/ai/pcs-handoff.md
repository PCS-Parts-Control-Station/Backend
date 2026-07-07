# PCS Handoff

작성일: 2026-05-22

이 문서는 새 채팅에서 현재 작업을 이어가기 위한 핵심 인수인계다.

## 먼저 읽을 문서

새 채팅 시작 시 아래 순서로 읽는다.

```text
AGENTS.md
docs/ai/AI_INDEX.md
docs/ai/pcs-handoff.md
```

화면/HTML/CSS 작업이면 추가로 읽는다.

```text
docs/ai/pcs-design-system.md
docs/ai/design/workspace-layout.md
docs/ai/design/responsive-layout.md
docs/ai/design/data-table.md
docs/ai/design/workflow-panel.md
```

DB/SQL/API 작업이면 `AI_INDEX.md` 기준으로 필요한 feature 문서와 `docs/sql/pcs-schema-ddl.sql`을 읽는다.

## 프로젝트 방향

PCS는 중고 PC 부품을 `관리번호` 단위로 입고, 검수, 출고, 이력까지 추적하는 국내 업무용 재고 관리 시스템이다.

현재 구현 방향:

- Spring Boot 기반
- JPA 사용 안 함
- DB 접근은 MyBatis Mapper/XML 기준
- 화면은 우선 정적 HTML/CSS로 작성
- PageController는 정적 HTML forward만 담당
- 화면 데이터는 추후 JS에서 `/api/**` 호출로 연결

업무 흐름:

```text
회사/업체 공간 생성
-> 사용자 관리
-> 거래처 관리
-> 카테고리 관리
-> 부품 마스터 관리
-> 입고
-> 검수
-> 출고
-> 이력 조회
```

## 문서 정리 상태

문서는 `docs/ai` 기준으로 정리되어 있다.

중요 문서:

```text
docs/ai/AI_INDEX.md
docs/ai/pcs-agent-context.md
docs/ai/pcs-api-spec.md
docs/ai/pcs-design-system.md
docs/ai/pcs-project-structure-reference.md
docs/ai/pcs-harness-rules.md
docs/ai/pcs-handoff.md
```

디자인 하위 문서:

```text
docs/ai/design/workspace-layout.md
docs/ai/design/responsive-layout.md
docs/ai/design/data-table.md
docs/ai/design/form-panel.md
docs/ai/design/workflow-panel.md
docs/ai/design/detail-page.md
docs/ai/design/history-timeline.md
docs/ai/design/dashboard.md
docs/ai/design/public-pages.md
```

최근 추가된 문서:

- `docs/ai/design/workflow-panel.md`
    - 입고/검수/출고/이력 화면 오른쪽 업무 흐름 보조 패널 기준
- `docs/ai/design/responsive-layout.md`
    - 업무 화면 반응형, 햄버거 사이드바, 모바일 전표 카드 기준

## DB / DDL 상태

`docs/sql/pcs-schema-ddl.sql`은 사용자가 제공한 MySQL DDL 기준으로 정리했다.

주요 테이블:

```text
tb_company
tb_member
tb_auth_refresh_token
tb_auth_login_history
tb_trade_partner
tb_part_category
tb_pc_part
tb_pc_part_unit
tb_part_stock
tb_stock_document
tb_stock_movement
tb_stock_movement_unit
tb_inspection
tb_inspection_item_result
tb_inspection_template
tb_inspection_template_item
tb_inspection_template_item_option
tb_part_status_history
```

중요 결정:

- 입출고는 `tb_stock_document` 전표와 `tb_stock_movement` 라인 기준이다.
- 개별 부품은 `tb_pc_part_unit`으로 관리한다.
- 입고 완료 후 개별 부품은 검수 대기, 판매 보류 상태로 시작한다.
- 입고 오류는 원본 수정 대신 취소 전표/취소 movement로 보존하는 방향이다.
- 검수는 개별 부품(`unit_id`) 기준이다.

## 현재 화면 구현 상태

### 카테고리 화면

파일:

```text
src/main/resources/static/categories.html
src/main/resources/static/css/pages/categories.css
```

라우트:

```text
/w/{companyCode}/categories
```

구성:

- 공통 사이드바
- 페이지 헤더
- 검색/필터 카드
- 카테고리 목록 테이블
- 목록 상단 요약 박스
- 오른쪽 카테고리 등록 패널

### 입고 화면

파일:

```text
src/main/resources/static/inbound.html
src/main/resources/static/inbound-register.html
src/main/resources/static/css/layouts/workspace.css
src/main/resources/static/css/components/workflow.css
src/main/resources/static/css/components/feedback.css
src/main/resources/static/css/pages/inbound-register.css
src/main/resources/static/js/pcs-ui.js
src/main/resources/static/js/inbound-register.js
```

라우트:

```text
/w/{companyCode}/inbound
/w/{companyCode}/inbound/new
```

구성:

- 공통 사이드바
- 페이지 헤더와 입고 아이콘
- 입고 전표 검색 카드
- 입고 전표 목록
- 오른쪽 업무 흐름 보조 패널
- 입고 규칙 패널
- `입고 등록` 버튼은 `/w/{companyCode}/inbound/new` 등록 화면으로 이동

목록 mock 데이터:

```text
IN-20260521-004 완료
IN-20260521-003 완료
IN-20260520-009 완료
IN-20260519-006 취소
```

취소 상태 전표는 관리 영역에 `취소됨` disabled 버튼을 표시한다.

입고 화면 API 연결 예정 주석:

```text
GET /api/workspaces/{companyCode}/stock/documents?documentType=INBOUND
GET /api/workspaces/{companyCode}/stock/documents/{documentId}
GET /api/workspaces/{companyCode}/stock/documents/{documentId}/movements
POST /api/workspaces/{companyCode}/stock/documents/{documentId}/cancel
```

입고 등록 화면 구성:

- 공통 사이드바와 반응형 햄버거
- 전표 기본 정보 입력
- 부품 검색 영역
- 검색 결과는 카드 그리드가 아니라 스크롤 가능한 리스트형으로 표시
- 검색 결과에서 부품 선택 후 수량/라인 사유 입력
- `새 부품 등록`은 화면 이동 없이 모달로 빠른 등록
- 모달 등록 후 검색 결과 맨 위에 추가하고 즉시 선택
- 라인 추가 시 부품 라인 목록에 추가, 같은 부품은 기존 라인 수량 합산
- 부품 라인 목록에서는 수량/라인 사유 수정과 삭제
- 라인별 관리번호 발급 예시
- 저장 후 처리 안내
- 오른쪽 입고 등록 흐름 패널
- 저장 성공 후 `/w/{companyCode}/inbound`로 이동
- 화면 이동 후 토스트는 `pcs-ui.js`의 flash toast를 사용하고 `sessionStorage`에서 한 번만 소비
- 방금 등록한 전표의 상단 임시 강조 행도 `sessionStorage`에서 한 번만 소비

입고 등록 화면 API 연결 예정 주석:

```text
GET /api/workspaces/{companyCode}/parts?keyword=&categoryId=&active=true
POST /api/workspaces/{companyCode}/parts
POST /api/workspaces/{companyCode}/stock/documents/inbounds
```

### 검수 화면

파일:

```text
src/main/resources/static/inspection.html
src/main/resources/static/css/pages/inspection.css
src/main/resources/static/js/inspection.js
src/main/resources/static/css/layouts/workspace.css
src/main/resources/static/css/components/workflow.css
```

라우트:

```text
/w/{companyCode}/inspection
```

현재 구조:

```text
1. 검수할 전표 선택
2. 부품별 검수 대상
3. 검수 등록
4. 최근 검수 이력
```

중요 결정:

- 검수 업무는 전표를 출발점으로 삼되, 실제 검수 저장 단위는 개별 부품 `관리번호`다.
- 사이드바에 `전표` 메뉴를 독립 업무로 추가하지 않는다.
- 전표 목록은 검수 화면의 1단계로 둔다.
- 오른쪽 패널은 상세/등록을 담당하지 않고, 본래 역할인 업무 흐름 안내와 검수 처리 기준만 담당한다.
- `최근 검수 이력`은 전표 기준이 아니라 개별 관리번호 기준이다.
- 이력 목록에는 추적 보조 정보로 `전표 번호`를 같이 표시한다.

현재 mock 동작:

- 1단계 `전표 선택`을 누르면 2단계에 선택 전표 요약과 부품 묶음이 표시된다.
- 부품 묶음 안에는 관리번호 체크박스, `선택 검수 등록`, `대기 전체 검수`, 개별 `검수 등록`/`재검수` 버튼이 있다.
- 2단계에서 관리번호를 선택하면 3단계 검수 등록 폼이 활성화된다.
- 3단계 폼은 검수 템플릿, 검수 결과, 등급, 판매 상태, 항목별 결과, 메모를 입력한다.
- `불합격` 또는 `불량` 선택 시 판매 상태는 `판매 불가`로 자동 보정한다.
- 저장은 아직 API 미연결 상태이며 mock 안내 메시지만 표시한다.
- 4단계 `최근 검수 이력`의 `상세`를 누르면 같은 카드 안에 이력 상세와 항목별 결과가 펼쳐진다.

검수 화면 API 연결 예정:

```text
GET /api/workspaces/{companyCode}/inspections/waiting-documents?keyword=&partnerId=&inspectionStatus=&page=&size=
GET /api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units
POST /api/workspaces/{companyCode}/inspections
POST /api/workspaces/{companyCode}/inspections/bulk
GET /api/workspaces/{companyCode}/inspections?keyword=&inspectionType=&grade=&page=&size=
GET /api/workspaces/{companyCode}/inspections/{inspectionId}
```

API 설계 시 유의:

- 화면은 여러 관리번호를 한 번에 선택할 수 있지만 서버 저장은 개별 `unitId`별 검수 row로 남겨야 한다.
- 일괄 검수 API는 `unitIds`, `templateId`, `result`, `grade`, `salesStatus`, `memo`, `itemResults`를 받는 구조가 자연스럽다.
- `grade = DEFECTIVE`이면 `salesStatus = UNAVAILABLE`이어야 한다.
- 검수 결과는 원본 row 수정이 아니라 신규 이력 row로 저장한다.
- 상태 변경 시 `tb_part_status_history`도 함께 저장한다.

## 반응형 결정

업무 화면은 `layouts/workspace.css`의 공통 반응형을 사용한다.

CSS 분리 기준:

```text
core/*: 공통 토큰과 기본 요소
layouts/workspace.css: 업무 화면 공통 레이아웃과 사이드바
components/components.css: 버튼, 카드, 폼, 목록, 모달
components/workflow.css: 입고/검수/출고/이력 오른쪽 업무 흐름 패널
components/feedback.css: 공통 토스트 메시지
pages/inbound.css, pages/inbound-register.css: 입고 화면별 전용 규칙
pages/inspection.css: 검수 화면 전용 규칙
```

현재 기준:

```text
전체 폭: 좌측 사이드바 기본 닫힘 오프캔버스, 햄버거 버튼 노출
1180px 이하: content-grid 1컬럼, 오른쪽 패널은 아래로 이동
840px 이하: 헤더 액션/검색 폼 모바일 배치
640px 이하: 입고 전표 목록은 요약 카드형 행
560px 이하: 헤더 설명문과 버튼 폭 추가 압축
```

햄버거 사이드바:

- `body.has-collapsible-sidebar`에서 동작
- 햄버거 버튼: `.menu-toggle`
- 배경 오버레이: `.sidebar-backdrop`
- 열림 상태: `body.sidebar-open`
- 배경 클릭, 햄버거 재클릭, `Escape`로 닫힘
- `aria-expanded`, `aria-label` 갱신

입고 전표 모바일 카드 기준:

```text
전표 번호              상태 배지
거래처 / 입고 내용
수량                 입고일
[상세] [취소]
```

중요:

- 모바일에서 `전표 번호`, `입고 내용`, `관리` 라벨을 반복 노출하지 않는다.
- `수량`, `입고일`처럼 의미 보강이 필요한 값만 작은 라벨을 붙인다.
- 셀마다 큰 구분선을 넣지 않고 전표 1건을 하나의 카드로 읽히게 한다.

## PageController 상태

`src/main/java/com/pcs/web/controller/PageController.java`에 정적 화면 라우트가 추가되어 있다.

확인할 라우트:

```text
/
/main
/w/{companyCode}/categories
/w/{companyCode}/inbound
/w/{companyCode}/inbound/new
/w/{companyCode}/inspection
```

새 업무 화면을 만들 때는 동일하게 정적 HTML forward만 추가한다.

## 검증 내역

최근 확인:

- `git diff --check` 통과
- `sh ./gradlew test` 통과
- 입고 화면 반응형 스크린샷 확인
    - 1600px: 기존 사이드바 유지, 2컬럼 겹침 없음
    - 1440px: 햄버거 노출, 사이드바 접힘, 2컬럼 겹침 없음
    - 1100px: 본문 1컬럼 전환
    - 모바일 폭: 검색 폼 1열, 전표 카드형 행, 가로 스크롤 없음
- 테스트 서버는 작업 후 종료했다.
- 검수 화면은 현재 정적 서버 제공과 JS 문법 검사를 확인했다.
    - `node --check src/main/resources/static/js/inspection.js` 통과
    - `python3 -m http.server ...`로 `inspection.html`, `inspection.css`, `inspection.js` 정상 제공 확인
- 현재 채팅에서는 Browser 제어 도구가 노출되지 않아 검수 화면 클릭/스크린샷 QA는 수행하지 못했다.

주의:

- `./gradlew test`는 실행 권한 문제로 실패할 수 있다.
- 테스트는 `sh ./gradlew test`로 실행한다.
- 로컬 서버 확인 중 `/favicon.ico` 404가 로그에 잡힐 수 있으나 현재 기능에는 영향 없다.

## 현재 작업 트리 주의

작업 전 항상 확인한다.

```bash
git status --short
```

현재 변경/추가가 있을 가능성이 높은 파일:

```text
docs/ai/AI_INDEX.md
docs/ai/pcs-design-system.md
docs/ai/design/workspace-layout.md
docs/ai/design/data-table.md
docs/ai/design/form-panel.md
docs/ai/design/workflow-panel.md
docs/ai/design/responsive-layout.md
docs/sql/pcs-schema-ddl.sql
src/main/java/com/pcs/web/controller/PageController.java
src/main/resources/static/css/layouts/workspace.css
src/main/resources/static/css/pages/inbound.css
src/main/resources/static/css/pages/inspection.css
src/main/resources/static/inbound.html
src/main/resources/static/inspection.html
src/main/resources/static/js/inspection.js
```

주의:

- 사용자가 만든 변경을 되돌리지 않는다.
- 문서/화면 변경이 섞여 있으므로 커밋 전 diff를 꼭 나눠 본다.
- 현재 md 문서 정리 작업과 입고 화면 작업이 같은 작업 트리에 같이 있을 수 있다.

## 다음 작업 후보

우선순위 높은 후보:

1. 검수 화면 브라우저 시각 QA
    - 새 채팅에서 Browser/Node REPL 도구가 노출되는지 먼저 확인
    - 정적 서버로 `inspection.html` 열기
    - `전표 선택` 클릭
    - 2단계 부품 묶음/관리번호 표시 확인
    - 체크박스 선택, `선택 검수 등록`, `대기 전체 검수` 클릭
    - 3단계 검수 등록 폼 활성화 확인
    - 4단계 최근 검수 이력 상세 클릭
    - 1440px, 1366px, 1180px 이하, 모바일 폭에서 깨짐 확인
2. 검수 화면 API 연결 설계
    - `docs/features/inspection.md`
    - `docs/ai/pcs-api-spec.md`
    - `docs/sql/pcs-schema-ddl.sql`
    - 검수 대기 전표 조회, 전표별 관리번호 조회, 단건/일괄 검수 등록 API 필요
3. 출고 화면 HTML 작성
    - 입고 화면 구조를 재사용
    - 오른쪽 workflow panel은 출고 단계를 active로 변경
4. 입고 API 구현
    - `docs/features/stock.md`
    - `docs/sql/pcs-schema-ddl.sql`
    - `docs/ai/pcs-api-spec.md`
    - MyBatis 기준
5. 정적 화면 JS 연결
    - URL에서 `companyCode` 추출
    - mock 데이터를 API 응답으로 교체

## 새 채팅 시작 프롬프트 예시

검수 화면 브라우저 검증을 이어서 할 때:

```text
docs/ai/AI_INDEX.md와 docs/ai/pcs-handoff.md를 먼저 읽고,
Browser 또는 in-app browser 도구가 사용 가능한지 확인해줘.
가능하면 정적 서버로 src/main/resources/static/inspection.html을 열어서
검수 화면을 클릭 테스트하고 스크린샷 기준으로 UI를 다듬어줘.

현재 검수 화면은 아래 파일로 구성돼 있어.
- src/main/resources/static/inspection.html
- src/main/resources/static/css/pages/inspection.css
- src/main/resources/static/js/inspection.js

현재 구조는 1. 검수할 전표 선택 -> 2. 부품별 검수 대상 -> 3. 검수 등록 -> 4. 최근 검수 이력이고,
오른쪽 패널은 업무 흐름 안내/처리 기준만 담당하는 방향이야.

반드시 확인할 클릭 흐름:
1. 전표 선택
2. 체크박스 선택 후 선택 검수 등록
3. 대기 전체 검수
4. 검수 등록 폼 활성화
5. 최근 검수 이력 상세
6. 1440px, 1366px, 1180px 이하, 모바일 폭 레이아웃
```

화면을 이어서 할 때:

```text
docs/ai/AI_INDEX.md와 docs/ai/pcs-handoff.md를 먼저 읽고,
현재 화면 상태를 확인한 뒤 다음 화면 작업을 이어서 진행해줘.
```

출고 화면을 만들 때:

```text
docs/ai/AI_INDEX.md와 docs/ai/pcs-handoff.md를 먼저 읽고,
입고 화면과 공통 반응형 기준을 참고해서 출고 화면 HTML을 만들어줘.
```

입고 API를 구현할 때:

```text
docs/ai/AI_INDEX.md와 docs/ai/pcs-handoff.md를 먼저 읽고,
stock feature 문서와 DDL 기준으로 입고 전표 API 구현을 시작해줘.
JPA는 쓰지 말고 MyBatis 기준으로 진행해줘.
```
