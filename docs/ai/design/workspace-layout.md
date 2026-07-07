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
- `/w/{companyCode}/partners`
- `/w/{companyCode}/mypage`

## 적용 제외

- `/`
- `/company/register`
- `/w`
- `/w/{companyCode}` 로그인 화면

## CSS 사용 기준

업무 관리 화면은 `css-architecture.md`의 공통 레이어와 페이지 CSS 구조를 사용한다.

```text
src/main/resources/static/{page}.html
src/main/resources/static/css/core/tokens.css
src/main/resources/static/css/core/base.css
src/main/resources/static/css/layouts/workspace.css
src/main/resources/static/css/components/components.css
src/main/resources/static/css/pages/{page}.css
```

모든 화면은 대응하는 페이지 CSS를 가지며, 그 파일에는 해당 화면에서만 필요한 예외만 둔다. 자세한 소유권은 `css-architecture.md`를 따른다. JS 파일은 실제 API 연동이나 화면 상호작용이 있을 때만 만든다.

## 기본 구조

로그인 후 업무 화면은 아래 구조를 기본으로 한다.

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
- 접속 계정 정보와 계정 액션

기준:

- 폭은 248px을 기본으로 한다.
- `position: sticky`, `height: 100vh`로 화면에 고정한다.
- 배경은 흰색 계열, 오른쪽 경계선은 `--line`을 사용한다.
- 현재 페이지 메뉴는 `active`와 `aria-current="page"`로 표시한다.
- active 메뉴는 진한 네이비 배경과 왼쪽 cyan inset line을 사용한다.
- 권한별 메뉴 노출은 `docs/ai/pcs-permission-rules.md`를 따른다.
- `사용자 관리`는 `OWNER / ADMIN`에게만 노출한다.
- 나머지 업무 메뉴는 인증된 `OWNER / ADMIN / STAFF`가 모두 사용할 수 있는 메뉴로 본다.
- 계정 박스에는 접속 계정명, 마이페이지 이동 톱니 아이콘, 로그아웃 아이콘을 둔다.
- 마이페이지 이동 톱니 아이콘은 `OWNER / ADMIN / STAFF` 모두에게 항상 노출한다.
- 톱니 아이콘은 `/w/{companyCode}/mypage`로 이동하며 사용자 관리 화면으로 직접 연결하지 않는다.
- 마이페이지 내부에서 역할별 내용을 분리한다. `OWNER`는 회사 정보 영역, `ADMIN`은 사용자 관리 안내, `STAFF`는 본인 업무 권한 확인 영역을 보여준다.
- 마이페이지의 입력 폼과 주요 작업은 왼쪽 본문 영역에 둔다.
- 마이페이지 오른쪽 `side-panel`에는 입력 폼을 두지 않는다. 대신 계정 요약, 권한별 안내, 빠른 이동, 계정 기준 같은 읽기용 보조 정보만 둔다.
- 마이페이지에 표시되는 문구는 사용자 행동 중심으로 쓴다. `OWNER/ADMIN/STAFF에게 노출`, `API에서 사용 가능`, `권한 차단`처럼 구현 기준을 설명하지 않는다.
- 역할 안내가 필요하면 화면에는 `최고 관리자`, `관리자`, `작업자`처럼 사용자 용어를 쓰고, 각 사용자가 바로 할 수 있는 일을 안내한다.
- 로그아웃 아이콘은 `/api/auth/logout` 처리 후 `/w/{companyCode}` 로그인 화면으로 이동한다.

현재 업무 메뉴 기준:

```text
운영 현황

업무
- 입고
- 검수
- 출고

이력
- 입출고 이력
- 검수 이력

관리
- 입출고 관리
- 입고
- 출고
- 부품 관리
- 검수 템플릿
- 거래처 관리
- 사용자 관리
```

`입출고 관리`는 관리 영역의 접힘 메뉴로 둔다. 기본 메뉴와 같은 글자 크기와 색상 톤을 쓰고, 펼쳐진 하위 메뉴인 `입고`, `출고`는 한 단계 낮은 작은 글자 크기로 표시한다. 하위 메뉴의 현재 화면 표시는 진한 배경 채움보다 얇은 강조선과 텍스트 색상으로 낮게 표현한다.

품목 관리와 품목 분류는 독립 사이드바 메뉴로 두지 않는다. 사이드바의 `부품 관리`에서 관리번호 단위 화면으로 진입하고, 품목 관리와 품목 분류는 부품 관리 또는 관련 업무 화면의 상단 버튼으로 이동한다.

## 업무 페이지 헤더

본문 상단은 업무의 종류와 주요 행동을 빠르게 알려야 한다.

구조:

```text
workspace-header
- menu-toggle
- title block 또는 page-title-row
  - page-icon 선택
  - page-kicker
  - h1
  - page-description
- header-actions
```

예:

```text
기준 정보 관리
품목 분류
CPU, RAM, GPU, SSD 등 품목 분류 기준을 관리합니다.
[운영 현황]
```

기준:

- `page-kicker`: 13px, cyan, 굵게
- `h1`: 30~42px 범위, navy, 800 weight
- 설명문은 한 줄에서 두 줄 안에 끝낸다
- 우측 액션에서 primary는 생성/추가, secondary는 보조 이동에 사용한다
- 업무 성격을 아이콘으로 빠르게 구분해야 하면 `page-title-row`와 `page-icon`을 사용한다.
- 부품/품목/분류 관리 화면은 같은 도메인 안에서 자주 왕복하므로 `page-title-row`와 `page-icon`을 사용한다.
- 아이콘 매핑은 `부품 관리 = 박스 아이콘`, `품목 관리 = 목록/품목 아이콘`, `품목 분류 = 도형 분류 아이콘`을 사용한다.
- 위 아이콘은 페이지 헤더, 사이드바의 부품 관리 항목, 부품/품목/분류 간 이동 버튼에서 같은 의미로 재사용한다.
- 사용자가 특정 업무나 이력 화면의 아이콘 SVG를 제공하면 페이지 헤더만 바꾸지 말고 같은 `data-route`를 가진 사이드바 항목에도 같은 의미의 아이콘을 함께 적용한다.
- 제공된 SVG는 공통 `page-icon`과 `sidebar-nav-icon` 크기 체계에 맞게 정규화하고, 아이콘 크기 보정을 위해 페이지 전용 CSS를 새로 만들지 않는다.
- 아이콘 변경 후에는 실제 렌더링 화면에서 기존 아이콘과 나란히 비교한다. 시각 크기, 여백, 굵기, 위치가 어긋나면 SVG의 `viewBox` 또는 내부 `g transform`을 조정하고 다시 렌더링해 확인한다.

## 스크롤 빠른 작업바

목록이 길어져 헤더의 주요 액션이 화면 밖으로 사라지는 업무 화면은 `workspace-quick-bar`를 사용할 수 있다.

목적:

- 사용자가 스크롤을 내린 상태에서도 사이드바를 바로 열 수 있게 한다.
- 헤더 오른쪽의 핵심 액션만 다시 제공한다.
- 가운데 페이지명을 클릭하면 현재 페이지 맨 위로 이동한다.

구조:

```text
workspace-quick-bar
- menu-toggle
- workspace-quick-brand
  - current page name
- workspace-quick-actions
  - header-actions에서 반복되는 핵심 버튼
```

기준:

- `workspace-quick-bar`는 기본 숨김이며, 헤더 액션 영역이 화면 위로 사라진 뒤에만 노출한다.
- 화면 최상단에 붙는 고정 바이며, 가로 폭은 `100%`를 사용한다.
- 떠 있는 카드처럼 보이는 상단 여백, 좌우 여백, 둥근 모서리는 사용하지 않는다.
- 높이는 약 60px 기준으로 유지한다.
- 오른쪽 액션 버튼은 공통 `.btn`의 기본 크기와 무게를 유지한다.
- 가운데 페이지명은 버튼보다 튀지 않되 상단바 높이에 맞춰 읽히는 크기로 둔다.
- 가운데 페이지명은 오른쪽 액션 버튼 개수나 폭에 영향받지 않고 상단바의 실제 가로 중앙에 위치해야 한다.
- 왼쪽은 `data-sidebar-toggle`을 가진 동일한 메뉴 버튼을 사용한다.
- 가운데는 현재 페이지명을 배치하고 `data-scroll-top`으로 맨 위 이동을 연결한다.
- 오른쪽에는 해당 화면의 핵심 액션만 둔다. 설명, 상태값, 보조 안내 문구는 넣지 않는다.
- 디자인은 흰 배경, 하단 border, 낮은 shadow 정도로 제한한다.
- CSS는 `layouts/workspace.css`, 동작은 `js/workspace-layout.js`에서 관리한다.
- 처음 도입하는 화면은 품목 관리이며, 다른 업무 화면에 적용할 때도 같은 클래스와 데이터 속성을 재사용한다.

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

목록을 보면서 바로 추가하거나 수정하는 관리 화면은 이 구조를 우선 사용한다.

좌측 목록과 오른쪽 패널을 동시에 쓰는 화면은 `has-collapsible-sidebar` 구조를 사용하고, 사이드바는 모든 화면에서 기본 닫힘인 오프캔버스로 동작해 본문 폭을 우선 확보한다.

업무 흐름 맥락이 중요한 화면은 오른쪽 `side-panel`에 등록 폼 대신 `workflow-panel.md` 기준의 업무 흐름 보조 패널을 둘 수 있다.

## 반응형 기준

업무 화면 반응형 상세 기준은 `docs/ai/design/responsive-layout.md`를 따른다.

요약:

- 모든 화면에서 좌측 사이드바를 기본 닫힘인 오프캔버스로 사용하고 햄버거 버튼을 노출한다.
- 햄버거 메뉴는 왼쪽 슬라이드, 배경 blur/dim, 오버레이 클릭 닫기, `Escape` 닫기를 지원한다.
- 좁은 화면에서는 `content-grid`를 1컬럼으로 전환해 오른쪽 패널을 본문 아래에 둔다.
- 모바일 폭에서는 헤더 액션, 검색 폼, 목록 행을 모바일 배치로 전환한다.

## 금지

- 업무 화면마다 다른 사이드바 폭을 즉흥적으로 쓰지 않는다.
- 업무 메뉴명을 화면마다 다르게 부르지 않는다.
- active 메뉴 표시를 텍스트 색만으로 처리하지 않는다.
- 사이드바 안에 많은 설명문을 넣지 않는다.
