# Management Page

품목, 품목 분류, 거래처, 사용자, 검수 템플릿처럼 검색·목록·등록·상세·수정을 한 화면에서 처리하는 관리형 페이지의 공통 기준이다.

검수 템플릿 관리 화면의 전체 구성을 기준 구현으로 사용한다. 특정 상세 패널만 복사하는 규칙이 아니라 헤더부터 검색, 목록, 요약, 오른쪽 패널, 하위 항목 편집까지의 화면 흐름을 공통화한다.

## 참조 문서

- 전체 업무공간 골격: `workspace-layout.md`
- 검색, 목록, 요약: `data-table.md`
- 오른쪽 등록·상세·수정: `form-panel.md`
- 항목 등록·수정 모달: `modal-dialog.md`
- 화면 폭 전환: `responsive-layout.md`
- CSS 파일 소유권: `css-architecture.md`

이 문서는 위 문서의 토큰과 세부 규칙을 반복해서 정의하지 않고 관리형 페이지에서의 조합만 정한다.

## 화면 구성

```text
workspace-header
content-grid
- content-main
  - filter-card.management-filter-card
  - table-card
    - table-header.inline-summary-header.management-summary-header
    - data-table
  - table-card.management-editor-card (필요한 화면만)
- side-panel
  - panel-card.side-work-panel
    - create / detail / edit mode
  - panel-card.muted-panel
```

기준:

- 검색과 목록은 모든 관리형 페이지에서 같은 순서로 둔다.
- 오른쪽 패널은 등록, 선택 상세, 수정 모드를 같은 자리에서 전환한다.
- 하위 항목이나 선택지를 편집하는 화면만 `management-editor-card`를 목록 아래에 추가한다.
- 기능별 `data-*` 속성과 API 이름은 도메인 이름을 유지하고, 시각 클래스에는 도메인 이름을 넣지 않는다.
- 검수 템플릿에만 필요한 열 너비와 모바일 셀 노출 순서는 페이지 CSS에 남긴다.

목록 전체 너비를 우선하는 품목 관리와 품목 분류 화면은 아래 드로어 변형을 사용한다.

```text
workspace-header
- 품목 분류
- 품목 등록
content-main full width
- filter-card.management-filter-card
- table-card
management-detail-drawer
- create / detail / edit mode
```

- 최초 진입 시 드로어는 닫혀 있어야 한다.
- 헤더의 등록 버튼은 등록 모드, 목록 행 선택은 상세 모드로 드로어를 연다.
- 수정과 취소는 같은 드로어 안에서 상세/수정 모드를 전환한다.
- 드로어 밖의 본문을 클릭하면 드로어를 닫고 선택 행 표시를 해제한다.
- 다른 목록 행을 클릭하면 드로어를 닫지 않고 선택 표시와 상세 내용만 교체한다.
- 드로어 표면은 `--surface`의 불투명 배경을 사용해 뒤의 목록 내용이 비치지 않게 한다.
- 드로어의 위치, 폭, 그림자, 모바일 전환은 입출고 이력 드로어와 같은 `management-detail-drawer`를 사용한다.
- 드로어 셸과 패널 기본 배치는 공통 CSS가 소유하고, 페이지 CSS는 목록 전체 너비와 도메인별 내부 배치만 소유한다.
- `management-detail-drawer`와 `management-detail-drawer-panel` 자체에는 세로 스크롤을 만들지 않는다.
- 드로어 안에서 내용이 길어지는 경우 제목/닫기 버튼 아래의 `drawer-scroll-body`만 세로 스크롤을 가진다.
- 등록/상세/수정 모드의 제목 영역은 고정된 판단 영역으로 유지하고, 긴 폼·상세 목록·하위 항목 목록만 `drawer-scroll-body` 안에 둔다.
- 품목 분류의 분류명/설명 입력은 드로어 안에 두고, 반복적으로 길어질 수 있는 사양 항목 입력은 모달로 분리한다.

## 공통 클래스

기본 관리 화면:

```text
management-filter-card
management-filter-form
management-filter-form-compact
management-data-row
management-summary-header
side-work-panel
panel-mode
side-detail-card
detail-badge-row
detail-list
management-detail-drawer
management-detail-drawer-panel
drawer-scroll-body
```

하위 항목 편집:

```text
management-editor-card
management-editor-empty
management-editor-body
management-editor-layout
management-editor-list-panel
management-editor-detail-panel
management-editor-item-card
management-editor-option-value
management-editor-form
management-editor-advanced-fields
management-editor-empty-note
```

공통 클래스의 스타일은 `css/components/components.css`와 `css/components/management-page.css`가 소유한다. 드로어 셸은 `components.css`가 소유하며 페이지 CSS에서 동일한 선언을 복사하지 않는다.

## 요약과 둥근 요소

- `management-summary-header`의 수치 요약은 작은 캡슐 형태를 사용할 수 있다.
- 사용 중, 중지, 입력 방식처럼 의미가 있는 상태는 공통 `badge`를 사용한다.
- `panel-link-button`은 주 동작이 아닌 짧은 전환 동작에만 사용한다.
- 일반 카드, 검색 카드, 입력창, 기본 버튼은 최상위 디자인 시스템의 8px radius를 따른다.
- 장식 목적의 둥근 박스, 상단 컬러 선, 별도 강조 테두리를 임의로 추가하지 않는다.

## 하위 항목 편집 상태

```text
미선택: management-editor-empty
선택됨: management-editor-body
항목 선택: management-editor-item-card.is-selected
비활성: is-inactive
드래그 중: is-dragging
드롭 위치: is-drop-before / is-drop-after
```

- 넓은 화면에서는 목록과 선택 항목 설정을 두 열로 둔다.
- 중간 폭에서는 한 열로 전환해 오른쪽 설정 영역이 잘리지 않게 한다.
- 항목 이름은 배지 때문에 잘리지 않아야 하고, 필요한 경우 말줄임을 사용한다.
- 드래그 저장은 도메인별 정렬 API를 한 번 호출한다.

## 전용 CSS 허용 범위

페이지 CSS에는 아래만 허용한다.

- 데이터 열 수에 따른 `grid-template-columns`
- 해당 도메인에만 존재하는 필드의 배치
- 모바일에서 숨길 열과 노출 순서
- 공통 컴포넌트로 표현할 수 없는 실제 페이지 예외

공통 카드, 선택 상태, 요약 캡슐, 편집 폼, 접이식 고급 설정, 드래그 상태를 페이지 CSS에 다시 작성하지 않는다.
