# Workspace Layout Design

로그인 후 `/w/{companyCode}/**` 업무 화면의 공통 골격 원본이다. 공개·로그인 화면은 `public-pages.md`를 따른다.

## CSS

공통 로딩과 파일 소유권은 `css-architecture.md`를 따른다. 업무 화면은 `workspace.css`와 대응하는 `pages/{page}.css`를 사용한다.

## 기본 구조

```text
workspace-layout
- workspace-sidebar: 기본 닫힘 off-canvas
- sidebar-backdrop
- workspace-main
  - workspace-header
  - content-main 또는 content-grid
```

모든 화면에서 본문 폭을 우선한다. 좌측 사이드바는 viewport 폭과 관계없이 기본 닫힘이며 햄버거로 연다.

## 좌측 사이드바

- `position: fixed`, `height: 100dvh`인 공통 off-canvas를 사용한다.
- 햄버거 재클릭, backdrop 클릭, `Escape`로 닫는다.
- 열림 상태에서는 본문 스크롤을 잠근다.
- `aria-expanded`, `aria-label`, `aria-current`를 상태에 맞게 갱신한다.
- 업체명/코드, 업무 메뉴, 접속 계정과 마이페이지·로그아웃을 제공한다.
- 메뉴 권한은 `docs/ai/pcs-permission-rules.md`를 따른다.

현재 메뉴:

```text
운영 현황

업무
- 입고
- 검수
- 출고

이력
- 검수 이력

관리
- 전표 통합 조회
- 부품 관리
- 검수 템플릿
- 거래처 관리
- 사용자 관리
```

- 사용자 관리는 OWNER/ADMIN만 표시한다.
- 품목 관리와 품목 분류는 독립 메뉴가 아니라 부품 관리와 관련 화면의 상단 버튼으로 진입한다.
- 마이페이지는 모든 역할에 표시하고 역할별 내용은 `mypage.md`를 따른다.
- 로그아웃 후 `/w/{companyCode}` 로그인 화면으로 이동한다.

## 업무 헤더

```text
workspace-header
- menu-toggle
- page-title-row 또는 title block
  - page-icon 선택
  - page-kicker
  - h1
  - page-description
- header-actions
```

- 제목과 설명은 현재 업무와 주요 행동을 바로 알려야 한다.
- 설명은 두 줄 이내로 유지한다.
- primary는 생성·저장, secondary는 보조 이동에 사용한다.
- 부품·품목·분류처럼 연결된 화면은 같은 의미의 아이콘을 재사용한다.
- SVG 크기는 공통 `page-icon`, `sidebar-nav-icon` 체계에서 맞추고 페이지 CSS로 보정하지 않는다.

## 본문 유형

등록·처리 화면:

```text
content-grid
- content-main
- side-panel: workflow 또는 읽기용 보조 정보
```

조회·관리 화면:

```text
content-main: full width 검색과 목록
right-side-drawer: 필요할 때 등록·상세·수정
```

- 검색과 목록은 `data-table.md`를 따른다.
- 관리형 조합은 `management-page.md`를 따른다.
- 드로어 동작은 `side-drawer.md`를 따른다.
- 단계형 입력은 `operation-flow.md`, 업무 흐름 보조는 `workflow-panel.md`를 따른다.

## 빠른 작업바

목록 스크롤로 헤더 액션이 사라지는 화면은 `workspace-quick-bar`를 사용할 수 있다.

```text
workspace-quick-bar
- menu-toggle
- current page name / scroll top
- 핵심 header action
```

- 헤더 액션이 viewport 위로 벗어난 뒤에만 표시한다.
- 상단에 붙는 전체 폭 bar이며 떠 있는 카드 모양으로 만들지 않는다.
- 현재 페이지명은 실제 가로 중앙에 둔다.
- 헤더의 핵심 행동만 반복하고 설명·상태는 넣지 않는다.
- CSS는 `workspace.css`, 동작은 `workspace-layout.js`가 소유한다.

## 금지

- 화면마다 다른 사이드바 구조·폭·열림 동작
- 사이드바를 고정 열어 본문 폭 축소
- 권한이나 페이지별 CSS로 공통 레이아웃 복제
- 사이드바에 긴 설명 추가
