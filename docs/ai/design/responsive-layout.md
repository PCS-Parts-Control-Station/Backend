# Responsive Layout Design

로그인 후 업무 화면의 반응형 레이아웃 공통 기준이다.

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

## 목적

업무 화면은 성격에 따라 등록/처리 화면과 조회 중심 관리 화면으로 나눈다.

반응형 기준의 우선순위는 아래 순서다.

1. 본문 영역과 오른쪽 패널이 겹치지 않아야 한다.
2. 등록/처리 화면은 오른쪽 업무 흐름 보조 패널을 유지한다.
3. 조회 중심 관리 화면은 목록 전체 너비를 우선하고, 상세는 오른쪽 슬라이드 패널로 연다.
4. 중간 폭에서는 좌측 사이드바를 접어 본문 가용 폭을 확보한다.
5. 작은 화면에서는 테이블을 억지로 줄이지 않고 카드형 또는 가로 스크롤 패턴으로 전환한다.
6. 햄버거 메뉴는 열림/닫힘 상태, 배경 오버레이, 키보드 닫기를 제공한다.

## 브레이크포인트

현재 업무 화면 기준은 아래 폭을 사용한다.

```text
전체 폭: 사이드바 기본 닫힘, 햄버거 버튼으로 오프캔버스 열기
1280px 이하: 필터가 많은 화면은 2줄 검색 폼 전환 가능
1180px 이하: 본문 content-grid 1컬럼 전환
840px 전후: 헤더/폼/기본 테이블 모바일 전환 시작
640px 이하: 전표형 목록은 카드형 행 전환
560px 이하: 헤더 설명문과 버튼 폭 추가 압축
```

기준:

- 브레이크포인트는 viewport 기준으로 잡는다.
- 실제 겹침이 발생하면 사이드바 축소를 먼저 고려한다.
- 등록/처리 화면의 오른쪽 업무 흐름 보조 패널은 너무 일찍 아래로 내리기보다, 중간 폭에서는 사이드바를 접어 본문 폭을 확보한다.
- 그래도 본문과 오른쪽 업무 흐름 보조 패널을 함께 두기 어렵다면 `1180px` 이하에서 1컬럼으로 전환한다.
- 조회 중심 관리 화면의 상세 슬라이드 패널은 본문 그리드의 2컬럼 대상이 아니다.

## 공통 사이드바 레이아웃

업무 화면의 좌측 사이드바는 화면 폭과 관계없이 기본 닫힘 상태인 오프캔버스로 사용한다.

등록/처리 화면:

```text
workspace-layout
- workspace-main
  - workspace-header
  - content-grid
    - content-main
    - side-panel
- workspace-sidebar: fixed off-canvas
- sidebar-backdrop
```

조회 중심 관리 화면:

```text
workspace-layout
- workspace-sidebar: 248px sticky
- workspace-main
  - workspace-header
  - content-main full width
  - document-detail-drawer fixed right
```

기준:

- `1520px` 초과에서 사이드바는 `position: sticky`, `height: 100vh`를 유지한다.
- 햄버거 버튼은 보이며, 데스크톱에서는 오프캔버스가 아니라 본문 폭을 넓히는 접힘 상태를 제어한다.
- 접힌 상태에서는 사이드바 영역을 0으로 줄이고 본문이 전체 폭을 사용한다.
- `1520px` 이하에서는 사이드바를 닫힌 상태의 오프캔버스로 전환한다.
- 등록/처리 화면의 `content-grid`는 `minmax(0, 1fr) 336px` 구조를 기본으로 한다.
- 오른쪽 업무 흐름 `side-panel`은 336px 전후로 둔다.
- 조회 중심 관리 화면은 목록 가독성을 위해 본문을 전체 너비로 사용한다.

## 사이드바 구조

모든 화면에서 동일한 사이드바 마크업을 사용하고, 화면 폭에 따라 고정형과 오프캔버스를 전환한다.

HTML 기준:

```html
<body class="has-collapsible-sidebar">
<div class="workspace-layout">
    <aside class="workspace-sidebar" id="workspace-sidebar" aria-label="업무 메뉴">
        ...
    </aside>
    <button class="sidebar-backdrop" type="button" data-sidebar-backdrop aria-label="메뉴 닫기"></button>

    <main class="workspace-main">
        <header class="workspace-header">
            <button
                class="menu-toggle"
                type="button"
                data-sidebar-toggle
                aria-controls="workspace-sidebar"
                aria-expanded="false"
                aria-label="메뉴 열기">
                ...
            </button>
            ...
        </header>
    </main>
</div>
</body>
```

CSS 기준:

```css
@media (max-width: 1520px) {
    .has-collapsible-sidebar .workspace-layout {
        display: block;
    }

    .has-collapsible-sidebar .workspace-sidebar {
        position: fixed;
        z-index: 50;
        width: min(280px, calc(100vw - 48px));
        height: 100dvh;
        transform: translateX(-102%);
        transition: transform 220ms ease;
    }

    .has-collapsible-sidebar.sidebar-open .workspace-sidebar {
        transform: translateX(0);
    }

    .has-collapsible-sidebar .sidebar-backdrop {
        display: block;
    }

    .has-collapsible-sidebar.sidebar-open .sidebar-backdrop {
        opacity: 1;
        pointer-events: auto;
    }

    .has-collapsible-sidebar .menu-toggle {
        display: inline-flex;
    }
}
```

기준:

- 메뉴는 왼쪽에서 슬라이드로 열린다.
- 배경은 반투명 딤과 약한 blur를 사용한다.
- 메뉴가 열리면 본문 스크롤은 잠근다.
- 메뉴 닫기는 햄버거 재클릭, 오버레이 클릭, `Escape` 키를 모두 지원한다.
- `aria-expanded`와 `aria-label`은 열림 상태에 맞게 갱신한다.

## 헤더 전환

중간 폭에서는 햄버거 버튼, 페이지 제목, 우측 액션이 한 줄 구조를 유지한다.

기준:

- `workspace-header`는 `44px minmax(0, 1fr) auto` grid를 사용한다.
- 햄버거 버튼은 44px 정사각형으로 둔다.
- 페이지 아이콘을 사용하는 화면은 아이콘과 제목을 `page-title-row` 안에서 유지한다.
- 아이콘이 없는 화면은 title block이 같은 grid 칸을 차지한다.
- `840px` 이하에서는 우측 액션 버튼을 다음 줄로 내린다.

## 본문 그리드 전환

`content-grid` 기준:

```text
등록/처리 화면
- 1520px 초과: 사이드바 고정형 + 본문 2컬럼
- 1520px 이하: 사이드바 오프캔버스 + 본문 2컬럼 유지 가능
- 1180px 이하: 본문 1컬럼

조회 중심 관리 화면
- 목록 본문 전체 너비
- 상세는 오른쪽 슬라이드 패널
```

기준:

- 2컬럼 유지 중 겹침이 발생하면 `content-main`, `side-panel`, 카드 요소에 `min-width: 0`을 확인한다.
- 오른쪽 업무 흐름 보조 패널은 본문을 가리지 않아야 한다.
- 등록/처리 화면은 `1180px` 이하에서 오른쪽 업무 흐름 보조 패널을 목록 아래로 내린다.
- 업무 흐름 보조 패널은 1컬럼 전환 후에도 본문 아래에서 그대로 읽히게 한다.
- 조회 중심 관리 화면은 본문 목록을 1컬럼으로 유지하고, 상세 슬라이드 패널은 viewport 오른쪽에 고정한다.

## 상세 슬라이드 패널

조회 중심 관리 화면에서 전표나 관리번호 행을 선택하면 오른쪽 상세 슬라이드 패널을 연다.

데스크톱 기준:

- 너비는 420~520px 범위를 우선한다.
- `width: min(520px, calc(100vw - 32px))`처럼 화면보다 커지지 않게 한다.
- `position: fixed`로 viewport 오른쪽에 붙인다.
- 화면 높이를 최대한 사용하고, 패널 내부 본문만 세로 스크롤한다.
- 배경 오버레이를 깔지 않는다.
- 패널이 열려도 본문 스크롤을 잠그지 않는다.
- 패널 외부 클릭으로 닫지 않는다.
- 다른 목록 행을 클릭하면 패널을 닫지 않고 상세 내용만 교체한다.
- 닫기 버튼과 `Escape` 키 닫기를 지원한다.

태블릿 기준:

- 패널 너비는 화면의 60~70% 수준을 우선한다.
- 목록의 긴 텍스트는 말줄임 처리하고, 필요한 표는 가로 스크롤을 허용한다.

모바일 기준:

- 패널은 화면 전체 너비로 표시한다.
- 목록은 카드형으로 전환한다.
- 확인, 취소, 삭제 같은 실행 전 확인은 별도 모달 기준을 따른다.

## 검색 폼 전환

필터가 많은 화면은 중간 폭에서도 한 줄 배치를 유지할 수 있다.

필터가 2~3개인 화면 예:

```text
검색어 / 거래처 / 상태 / 검색
```

필터가 4개 이상인 화면 예:

```text
검색어 / 유형 / 역할 / 거래 상태 / 검색
```

공통 modifier 기준:

```text
filter-form.management-filter-form
filter-form.document-filter-form
```

- `management-filter-form`은 필터가 4개 이상인 선택형 관리 목록 검색 폼에 사용한다.
- `document-filter-form`은 전표형 목록 검색 폼에 사용한다.
- modifier는 grid 폭 조정용이며, 기본 동작은 공통 `filter-form` 기준을 따른다.

기준:

- `1520px 이하`라도 사이드바가 접히면 본문 폭이 충분하므로 한 줄 폼을 유지할 수 있다.
- 기본 검색 폼은 `840px 이하`에서 1열로 전환한다.
- 모바일에서 입력창이 화면 밖으로 밀리면 개별 화면 클래스보다 공통 `filter-form` 전환 기준을 먼저 조정한다.
- 필터가 4개 이상인 경우에도 검색어 입력칸은 우선 넓게 두고, 선택 필터와 검색 버튼은 중간 폭에서 줄어들 수 있는 고정 범위로 둔다.
- 한 줄 유지가 어려워지는 `1280px` 전후에서는 `검색어`를 한 줄 전체로 올리고, 나머지 필터와 검색 버튼을 다음 줄에 둔다.
- 필터가 많은 화면은 태블릿 폭에서 위 2줄 검색 폼을 유지할 수 있고, 더 좁은 모바일 폭에서만 전체 1열로 내린다.
- 인라인 목록 요약은 데스크톱과 태블릿 폭에서 목록 헤더 오른쪽 끝에 붙이고, 모바일 폭에서 제목 아래로 내린다.
- 인라인 목록 요약은 매우 좁은 모바일 폭에서만 2열 요약으로 전환한다.

인라인 요약 modifier 예:

```text
table-header.inline-summary-header
```

- `inline-summary-header`는 `list-summary-box`를 border/background 없는 인라인 요약으로 표시한다.
- 요약 항목이 3개 이하인 경우 `summary-compact`로 폭을 줄인다.
- 중간 폭에서는 오른쪽 정렬을 유지하고, 모바일 폭에서만 제목 아래로 내린다.

## 테이블 전환

목록은 화면 특성에 따라 두 패턴 중 하나를 사용한다.

### 카드형 전환

단순 관리 목록은 `840px 이하`에서 카드형 행으로 바꾼다.

기준:

- 4열 전후의 단순 관리 목록은 `simple-management-data-row`를 사용할 수 있다.
- 테이블 헤더는 숨긴다.
- 각 cell은 `data-label` 또는 `::before` 라벨로 제목을 표시한다.
- 행별 액션은 행 하단에 배치한다.

전표형 목록은 한 행의 업무 단위가 명확하므로 `640px 이하`에서 요약 카드형으로 압축한다.

구조:

```text
전표번호              상태 배지
거래처 / 입고 내용
수량                 입고일
[상세] [취소]
```

기준:

- `전표번호`와 `상태`는 카드 상단 한 줄에 둔다.
- `입고 내용`은 본문에서 가장 크게 읽히게 둔다.
- `수량`, `입고일`은 작은 메타 정보로 한 줄에 압축한다.
- `관리` 라벨은 숨기고 버튼만 하단 오른쪽에 둔다.
- 셀마다 큰 구분선을 넣지 않는다.
- 전표 하나가 하나의 카드로 보이도록 행 사이에만 구분 여백을 둔다.

### 가로 스크롤 유지

전표형 또는 이력형 목록처럼 업무상 열 구분이 중요한 목록은 중간 폭에서 가로 스크롤을 허용한다.

기준:

- 테이블 컨테이너에 `overflow-x: auto`를 둔다.
- 행에는 명확한 `min-width`를 둔다.
- 헤더는 유지해서 열 제목을 잃지 않게 한다.
- 너무 좁은 `640px 이하`에서는 카드형 행으로 전환한다.

전표형 목록 modifier 기준:

```text
data-table.document-data-table
data-row.document-data-row
```

- `document-data-table`은 내부 가로 스크롤을 허용한다.
- `document-data-row`는 중간 폭에서 명확한 `min-width`를 유지한다.
- 매우 좁은 폭에서 카드형으로 전환할 때도 전표번호, 상태, 입고 내용, 수량, 입고일, 관리 버튼의 우선순위를 유지한다.

## 모바일 폭

`640px 이하` 기준:

- 헤더 액션은 1열 또는 2열 버튼으로 배치한다.
- 본문 카드는 `16px` 좌우 여백을 기준으로 둔다.
- 긴 설명문은 2줄 안에 들어오게 줄인다.
- 등록/처리 화면의 오른쪽 업무 흐름 보조 패널은 본문 하단에 배치한다.
- 조회 상세 슬라이드 패널은 전체 화면 폭을 사용한다.
- 테이블은 카드형 행을 우선한다.

## 검증 기준

반응형 수정 후 최소 아래 폭을 확인한다.

```text
1600px: 햄버거 오프캔버스, 기본 닫힘, 2컬럼 겹침 없음
1440px: 햄버거 오프캔버스, 기본 닫힘, 2컬럼 겹침 없음
1280px: 햄버거 노출, 2컬럼 또는 화면별 안정 배치
1100px: 본문 1컬럼, 오른쪽 패널 아래 배치
390px: 모바일 검색/목록/메뉴 가로 스크롤 없음
```

상호작용 확인:

- 모든 화면에서 햄버거 클릭 시 메뉴가 왼쪽에서 열린다.
- 배경은 흐려지고 클릭하면 닫힌다.
- `Escape` 키로 닫힌다.
- 메뉴 열림 상태에서 `aria-expanded="true"`가 된다.
- 닫힘 상태에서 `aria-expanded="false"`가 된다.
- 조회 상세 슬라이드가 열린 상태에서도 다른 목록 행을 바로 클릭할 수 있다.
- 조회 상세 슬라이드는 반투명 오버레이로 목록 조작을 막지 않는다.

## 금지

- 등록/처리 화면의 오른쪽 업무 흐름 보조 패널을 본문 위에 겹쳐 보이게 두지 않는다.
- 조회 상세 슬라이드에 반투명 오버레이를 깔아 목록 클릭을 막지 않는다.
- 사이드바를 줄이지 않고 본문 카드만 계속 압축하지 않는다.
- 모바일에서 검색 폼을 2~4열로 억지 유지하지 않는다.
- 테이블 열 제목이 사라진 상태로 데이터만 세로로 나열하지 않는다.
- 메뉴 오버레이를 열어 둔 채 본문이 스크롤되게 하지 않는다.
- 화면마다 다른 햄버거 메뉴 구조를 만들지 않는다.
