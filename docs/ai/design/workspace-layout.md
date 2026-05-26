# Workspace Layout Design

로그인 후 업체 업무 페이지의 공통 레이아웃 기준이다.

## 적용 대상

- `/w/{companyCode}/dashboard`
- `/w/{companyCode}/categories`
- `/w/{companyCode}/parts`
- `/w/{companyCode}/inbound`
- `/w/{companyCode}/inspection`
- `/w/{companyCode}/outbound`
- `/w/{companyCode}/history`
- `/w/{companyCode}/users`

## 적용 제외

- `/`
- `/company/register`
- `/w`
- `/w/{companyCode}` 로그인 화면

## CSS 사용 기준

업무 관리 화면은 개별 CSS보다 `admin.css` 공통 레이아웃을 우선 사용한다.

```text
src/main/resources/static/{page}.html
src/main/resources/static/css/admin.css
```

개별 CSS는 해당 화면에만 필요한 복잡한 예외가 있을 때만 만든다. JS 파일은 실제 API 연동이나 화면 상호작용이 있을 때만 만든다.

## 기본 구조

카테고리 관리 화면에서 확정된 업무 레이아웃을 기준으로 한다.

```text
workspace-layout
- workspace-sidebar
  - sidebar-brand
  - sidebar-nav
  - sidebar-footer
- workspace-main
  - workspace-header
  - content-grid 또는 화면별 본문
```

기본 CSS 구조:

```css
.workspace-layout {
    display: grid;
    grid-template-columns: 248px minmax(0, 1fr);
    min-height: 100vh;
}

.workspace-main {
    min-width: 0;
    padding: 32px;
}
```

## 좌측 사이드바

사이드바는 업무 메뉴를 고정해 반복 업무 이동을 빠르게 한다.

구성:

- 로고
- 업체 코드 또는 업체명
- 업무 메뉴
- 접속 계정 정보

기준:

- 폭은 248px을 기본으로 한다.
- `position: sticky`, `height: 100vh`로 화면에 고정한다.
- 배경은 흰색 계열, 오른쪽 경계선은 `--line`을 사용한다.
- 현재 페이지 메뉴는 `active`와 `aria-current="page"`로 표시한다.
- active 메뉴는 진한 네이비 배경과 왼쪽 cyan inset line을 사용한다.

현재 업무 메뉴 기준:

```text
운영 현황
카테고리
부품 관리
입고 관리
검수 관리
출고 관리
이력 관리
사용자 관리
```

## 업무 페이지 헤더

본문 상단은 업무의 종류와 주요 행동을 빠르게 알려야 한다.

구조:

```text
workspace-header
- page-kicker
- h1
- page-description
- header-actions
```

예:

```text
기준 정보 관리
카테고리 관리
CPU, RAM, GPU, SSD 등 부품 분류 기준을 관리합니다.
[운영 현황] [카테고리 추가]
```

기준:

- `page-kicker`: 13px, cyan, 굵게
- `h1`: 30~42px 범위, navy, 800 weight
- 설명문은 한 줄에서 두 줄 안에 끝낸다
- 우측 액션에서 primary는 생성/추가, secondary는 보조 이동에 사용한다

## 콘텐츠 영역

업무 화면 본문은 화면 성격에 맞춰 아래 패턴을 조합한다.

```text
content-grid
- content-main
  - filter-card
  - table-card
- side-panel
  - panel-card
  - muted-panel
```

카테고리, 사용자, 거래처, 기준 관리처럼 목록을 보면서 바로 추가하는 화면은 이 구조를 우선 사용한다.

입고, 검수, 출고, 이력처럼 업무 흐름 맥락이 중요한 화면은 오른쪽 `side-panel`에 등록 폼 대신 `workflow-panel.md` 기준의 업무 흐름 보조 패널을 둘 수 있다.

## 반응형 기준

업무 화면 반응형 상세 기준은 `docs/ai/design/responsive-layout.md`를 따른다.

요약:

- `1520px` 초과에서는 좌측 사이드바를 sticky로 고정 표시한다.
- `1520px` 이하에서는 좌측 사이드바를 오프캔버스로 접고 햄버거 버튼을 노출한다.
- 햄버거 메뉴는 왼쪽 슬라이드, 배경 blur/dim, 오버레이 클릭 닫기, `Escape` 닫기를 지원한다.
- `1180px` 이하에서는 `content-grid`를 1컬럼으로 전환해 오른쪽 패널을 본문 아래에 둔다.
- `840px` 이하에서는 헤더 액션과 검색 폼을 모바일 배치로 전환한다.
- `640px` 이하에서는 좁은 목록을 카드형 행으로 전환할 수 있다.

## 금지

- 업무 화면마다 다른 사이드바 폭을 즉흥적으로 쓰지 않는다.
- 업무 메뉴명을 화면마다 다르게 부르지 않는다.
- active 메뉴 표시를 텍스트 색만으로 처리하지 않는다.
- 사이드바 안에 많은 설명문을 넣지 않는다.
