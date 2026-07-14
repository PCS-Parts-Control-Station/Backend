# Side Drawer Design

목록 맥락을 유지한 채 등록·상세·수정을 처리하는 오른쪽 드로어의 원본 규칙이다.

`<dialog>` 기반 모달은 `modal-dialog.md`, 고정 업무 흐름 안내는 `workflow-panel.md`를 따른다.

## 유형

| 유형 | 용도 | 외부 클릭 |
|---|---|---|
| management drawer | 등록·상세·수정 | 닫음. 다른 행 클릭은 내용 교체 |
| detail drawer | 전표·관리번호·이력 조회 | 닫음. 다른 행 클릭은 내용 교체 |

모든 업무 드로어는 위 동작을 통일한다. 위험 작업은 드로어에서 즉시 실행하지 않고 확인 모달을 거친다.

## 공통 구조

```text
aside.right-side-drawer.[type]
- .right-side-drawer-panel
  - .panel-title-bar
  - .drawer-scroll-body
    - .right-side-scroll-list 선택
  - .form-actions 선택
```

- 배경 오버레이와 `aria-modal`을 사용하지 않는다.
- 드로어가 열려도 본문 스크롤과 다른 목록 행 선택을 막지 않는다.
- 패널 배경은 불투명 surface를 사용한다.

## 열기와 닫기

- 헤더 등록 버튼은 management drawer의 등록 모드를 연다.
- 목록 행 클릭 또는 Enter/Space는 상세 모드를 연다.
- 열린 상태에서 다른 행을 선택하면 닫지 않고 내용과 선택 표시만 교체한다.
- 닫기 버튼, `Escape`, 행과 패널 밖 클릭으로 닫는다.
- 닫을 때는 드로어를 연 버튼이나 마지막 선택 행으로 focus를 돌려준다.
- 저장 중에는 닫기와 중복 제출을 막는다.

열림 상태는 공통 `PcsDrawer.setOpen()`으로 변경하고, outside-click/Escape 닫기는 `PcsDrawer.bindDismiss()`를 사용한다. 화면별로 같은 로직을 다시 만들지 않는다.

## Management 모드

```text
create: 새 항목 등록
detail: 선택 대상 요약과 주요 정보
edit: 선택 대상 수정
```

- 같은 패널 안에서 `panel-mode`와 `hidden`으로 전환한다.
- 최초 진입은 닫힘 상태다.
- 수정 취소는 detail, 새 항목은 create로 전환한다.
- 하단 주요 실행은 `form-actions`에 둔다.

## Detail 내용

- 대표 식별값과 상태를 상단에 둔다.
- 메타 정보는 `detail-list`, 긴 반복 항목은 `right-side-scroll-list`를 사용한다.
- 관리번호와 전표 번호는 monospace로 표시한다.
- 상세 하단에는 현재 대상과 직접 연결되는 이동 또는 확인 행동만 둔다.

## 스크롤

- 드로어와 패널 자체는 스크롤 컨테이너가 아니다.
- 제목과 하단 액션은 고정하고 `drawer-scroll-body`만 세로 스크롤한다.
- 라인·사양·타임라인 목록이 길면 내부 `right-side-scroll-list` 하나만 스크롤한다.
- 드로어 본문과 내부 목록에 이중 스크롤을 만들지 않는다.

## 크기와 반응형

- 데스크톱은 420~520px 범위를 우선한다.
- 태블릿은 viewport의 60~70% 범위를 사용할 수 있다.
- 모바일은 좌우 inset을 유지한 거의 전체 폭으로 표시한다.
- 폭과 위치는 공통 CSS가 소유하며 페이지 CSS에서 재정의하지 않는다.
- breakpoint는 `responsive-layout.md`를 따른다.

## 접근성

- `aside`에 목적을 설명하는 label을 제공한다.
- 닫기 버튼에는 `aria-label="닫기"`를 둔다.
- 선택 행은 `is-selected`와 적절한 상태 속성을 함께 사용한다.
- focus를 강제로 드로어로 옮기지 않되 키보드로 모든 동작에 접근할 수 있어야 한다.

## 금지

- 반투명 오버레이로 목록 조작 차단
- 드로어 유형마다 다른 외부 클릭 정책
- 패널 자체 스크롤과 이중 스크롤
- 페이지 CSS에서 위치·폭·그림자·transform 복제
- 위험 작업을 확인 없이 즉시 실행
