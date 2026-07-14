# Management Page Design

검색·목록·등록·상세·수정을 한 화면에서 처리하는 관리형 페이지의 조합 기준이다.

## 참조

- 업무 골격: `workspace-layout.md`
- 검색·목록·요약: `data-table.md`
- 폼 내용: `form-panel.md`
- 드로어 동작: `side-drawer.md`
- 하위 입력 모달: `modal-dialog.md`
- 반응형: `responsive-layout.md`
- CSS 소유권: `css-architecture.md`

이 문서는 위 규칙을 다시 정의하지 않고 조합만 정한다.

## 구성

```text
workspace-header
content-main full width
- filter-card.management-filter-card
- table-card
  - table-header.inline-summary-header
  - data-table
- management-editor-card 선택
management-detail-drawer
- create / detail / edit
```

- 최초 진입 시 드로어는 닫혀 있다.
- 헤더 등록 버튼은 create, 목록 행은 detail을 연다.
- 수정·취소는 같은 드로어 안에서 모드를 전환한다.
- 하위 항목·선택지를 편집하는 화면만 editor card를 추가한다.
- 시각 class는 역할 이름, JS 식별은 도메인 `data-*`를 사용한다.

## 공통 class

```text
management-filter-card
management-filter-form
management-summary-header
management-data-row
management-detail-drawer
panel-mode
side-detail-card
detail-list
management-editor-card
management-editor-item-card
management-editor-form
```

드로어 셸은 `components.css`, 하위 항목 편집은 `management-page.css`가 소유한다.

## 하위 항목 편집

상태:

```text
미선택: management-editor-empty
선택: management-editor-body
선택 항목: is-selected
비활성: is-inactive
드래그: is-dragging
드롭 위치: is-drop-before / is-drop-after
```

- 넓은 폭은 목록과 설정 2열, 중간 폭은 1열로 전환한다.
- 정렬 저장은 ID 순서를 한 번만 전송한다.
- 항목 이름과 상태 배지는 줄바꿈 또는 말줄임으로 충돌을 막는다.

## 페이지 전용 허용

- 실제 데이터 열 grid
- 도메인 고유 필드 배치
- 모바일 노출 순서
- 공통 조합으로 표현할 수 없는 최소 예외

카드·선택·요약·드로어·정렬 상태를 페이지 CSS에 다시 작성하지 않는다.
