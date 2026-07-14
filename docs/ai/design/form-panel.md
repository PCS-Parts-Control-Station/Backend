# Form Panel Design

관리형 화면의 등록·수정 폼 내용 기준이다. 드로어 셸·모드·닫기·스크롤은 `side-drawer.md`를 따른다.

## 적용

- 품목·분류·거래처·사용자 등록/수정
- 검수 템플릿 기본 정보
- 짧은 설정 변경

제외:

- 공개 페이지 전체 폼: `public-pages.md`
- 전표·검수 단계형 입력: `operation-flow.md`
- 일시적인 보조 입력: `modal-dialog.md`

## 구조

```text
panel-mode create/edit
- panel-title-bar
- drawer-scroll-body
  - form fields
  - field message
- form-actions
```

- 목록을 보면서 처리할 핵심 입력만 둔다.
- 긴 업무는 별도 페이지로 분리한다.
- 반복 하위 항목이 길면 모달이나 전용 편집 영역을 사용한다.
- 상세 모드는 `side-detail-card`, `detail-list`를 사용한다.

## 필드

- 필드는 기본적으로 세로 배치한다.
- label은 짧고 필수·선택 여부를 구분한다.
- input/select/textarea 스타일은 디자인 시스템을 따른다.
- 서버 자동 생성 값은 입력받지 않는다.
- 저장 API가 없으면 저장되는 것처럼 보이게 만들지 않는다.

분류에 따라 입력 항목이 달라지는 품목 상세입력처럼 보조 필드가 많으면 기본 폼에는 요약 버튼만 두고 모달에서 입력한다.

## 선택 입력 접기

필수 입력을 방해하는 선택 필드는 `details`로 접을 수 있다.

```text
optional-field-group
- optional-field-label
- details.optional-fields
  - summary
  - optional-fields-body
```

- summary에는 선택 필드 종류만 짧게 표시한다.
- 등록 모드는 닫힘, 기존 값을 확인해야 하는 수정 모드는 열림으로 시작할 수 있다.
- 각 선택 필드에는 작은 `선택` 표시를 사용할 수 있다.

## Boolean 설정

- 단순 boolean은 checkbox 기반 switch row를 사용한다.
- 문구는 명령보다 현재 상태를 설명한다.
- 너무 많은 switch를 한 폼에 넣지 않는다.
- 도메인에 active가 없으면 화면에도 만들지 않는다.

## 저장 상태와 피드백

- 저장 중 입력과 버튼을 비활성화해 중복 제출을 막는다.
- 성공 후 API 응답 기준으로 목록·요약·선택 상세를 갱신한다.
- 실패 시 성공 상태로 바꾸지 않고 공통 오류 피드백을 표시한다.
- 토스트는 `pcs-frontend-js-rules.md`, 확인은 `modal-dialog.md`를 따른다.

## Form actions

- primary: 저장·생성·적용
- secondary: 초기화·취소
- destructive action은 일반 저장과 섞지 않는다.
- 액션 영역은 드로어 하단 `form-actions`에 유지한다.

## 운영 메모

입력 판단에 꼭 필요한 도메인 규칙 3~4개만 보조 영역에 둘 수 있다. 기능 설명이나 문서 전체를 화면에 옮기지 않는다.

## 금지

- 공통 드로어 구조 재정의
- 모든 필드를 한 줄에 강제
- 긴 도움말과 무관한 설정 혼합
- 복잡한 업무 흐름을 단순 폼 패널에 수용
