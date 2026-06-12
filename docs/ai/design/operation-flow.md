# Operation Flow Design

전표 등록처럼 업무 처리를 순서대로 입력하고 저장하는 화면 기준이다.

이 문서는 목록/검색 화면이 아니라, 사용자가 하나의 업무 전표나 처리 결과를 생성하는 화면을 다룬다.

## 적용 대상

- `/w/{companyCode}/inbound/new`
- 출고 등록 화면이 별도 전표 생성 흐름으로 확장되는 경우
- 검수 등록처럼 단계별 입력과 최종 저장이 필요한 화면

## 적용 제외

- 입고 전표 목록처럼 검색과 목록이 중심인 화면
  - `docs/ai/design/data-table.md`
- 오른쪽 업무 흐름 안내 패널만 수정하는 작업
  - `docs/ai/design/workflow-panel.md`
- 단순 오른쪽 등록/수정 폼
  - `docs/ai/design/form-panel.md`

## 기본 구조

CSS 기준:

```text
admin.css
workflow.css
inbound.css
pcs-toast.css
```

기준:

- 업무 화면 공통 레이아웃은 `admin.css`를 사용한다.
- 오른쪽 업무 흐름 패널은 `workflow.css`를 사용한다.
- 전표 등록의 본문 단계, 품목 검색, 라인 목록, 빠른 등록 모달은 `inbound.css` 기준을 따른다.
- 저장/오류 피드백에 토스트를 쓰면 `pcs-toast.css`를 함께 로드한다.

```text
workspace-layout
- workspace-main
  - workspace-header
  - content-grid
    - content-main
      - form.operation-flow-form
        - table-card.operation-step-card
        - table-card.operation-step-card
        - table-card.operation-step-card
        - table-card.operation-step-card
    - side-panel
      - panel-card.process-panel
      - panel-card.muted-panel
```

기준:

- 본문은 `operation-flow-form` 안에 단계별 `operation-step-card`를 세로로 쌓는다.
- 오른쪽 패널은 입력 폼이 아니라 현재 업무 흐름과 저장 후 처리 기준을 보여준다.
- 각 단계는 `table-card`를 재사용하되, 실제 테이블이 아니라 업무 입력 섹션으로 쓸 수 있다.
- 저장 버튼은 헤더 우측과 마지막 저장 섹션에 둘 수 있다.
- 저장 전 확인이 필요한 작업은 `modal-dialog.md`의 확인 모달을 사용한다.

## 헤더

입력 화면 헤더는 사용자가 현재 새 업무를 작성 중임을 분명히 보여준다.

구조:

```text
workspace-header
- menu-toggle
- page-title-row
  - page-icon
  - page-kicker
  - h1
  - page-description
- header-actions
  - 목록으로 돌아가기
  - 저장
```

입고 등록 예:

```text
재고 입출고 관리
입고 등록
거래처, 입고 사유, 부품 라인을 입력해 입고 전표를 생성합니다.
[전표 목록] [입고 저장]
```

기준:

- `page-icon`은 해당 업무 성격을 나타내는 선형 아이콘을 사용한다.
- 보조 버튼은 목록 복귀나 취소 성격으로 둔다.
- primary 버튼은 최종 저장을 가리킨다.

## Operation Flow Form

`operation-flow-form`은 업무 입력 단계를 담는 세로 흐름이다.

```text
operation-flow-form
- operation-step-card: 전표 기본 정보
- operation-step-card: 품목 검색
- operation-step-card: 부품 라인
- operation-step-card: 저장 후 처리
```

기준:

- 섹션 간 간격은 18px 전후로 유지한다.
- 각 섹션 제목 앞에는 `section-step`을 붙여 입력 순서를 보여준다.
- `section-step`은 작은 원형 번호로 표시하고, 강한 장식으로 만들지 않는다.
- 섹션 설명은 한 문장 정도로 짧게 쓴다.
- 입력이 없는 빈 상태는 dashed border와 짧은 안내 문구로 표현한다.

## 기본 정보 섹션

전표 기본 정보는 저장 전 반드시 필요한 최소 입력만 둔다.

입고 등록 기준:

```text
거래처
입고 사유
```

구조:

```text
table-card.operation-step-card
- table-header
  - section-step
  - 제목
  - 짧은 설명
  - 상태 배지
- register-fields.basic-fields
  - 거래처 select
  - 사유 input
  - field-message
```

기준:

- 전표번호처럼 서버가 자동 발급하는 값은 입력 필드로 만들지 않는다.
- 거래처는 선택 목록으로 제공한다.
- 거래처 로딩/오류 안내는 `field-message`로 표시한다.
- 필수 입력은 1단계에 몰아서 사용자가 바로 이해하게 한다.

## 검색 후 선택 섹션

업무 중 필요한 기준 데이터를 검색해 선택하는 영역은 본문 안에서 처리한다.

입고 등록 기준:

```text
품목 검색
- 검색어
- 분류
- 검색 버튼
- 검색 결과
- 선택한 부품
- 수량
- 라인 사유
- 라인 추가
```

구조:

```text
part-search-panel
- part-search-form
- part-search-results
  - part-result-head
  - part-result-row
  - part-search-message
- selected-part-panel
```

기준:

- 검색 조건은 상단에 한 줄로 두되, 좁아지면 1열로 전환한다.
- 검색 결과는 내부 스크롤을 허용하고 헤더를 유지한다.
- 선택된 행은 옅은 블루 배경과 선택 pill로 표시한다.
- 선택한 부품 영역은 `selected-part-panel`로 별도 강조한다.
- 선택한 부품, 수량, 라인 사유, 라인 추가 버튼이 한눈에 이어져야 한다.

## 라인 목록 섹션

업무 전표에 추가된 라인은 별도 목록 섹션에서 검토한다.

입고 등록 기준:

```text
부품 라인
- 라인 수
- 추가된 라인 목록
- 수량/사유 수정
- 라인 삭제
```

구조:

```text
table-card.operation-step-card
- table-header
  - section-step
  - 제목
  - 설명
  - line-count
- line-entry-list
  - line-empty-state
  - line-entry
```

기준:

- 라인이 없을 때는 `line-empty-state`를 보여준다.
- 라인 수는 제목 오른쪽의 작고 가벼운 텍스트로 둔다.
- 각 라인은 독립된 항목처럼 보이되 카드 중첩이 과해지지 않게 한다.
- 수량과 사유 수정은 같은 화면에서 가능하게 한다.

## 저장 섹션

마지막 섹션은 저장 후 어떤 일이 생기는지 짧게 확인시킨다.

구조:

```text
submit-panel
- 제목
- 저장 후 처리 설명
- submit-message
- form-actions
  - 취소
  - 저장
```

기준:

- 저장 후 생성되는 전표, 재고 변화, 개별 부품 상태를 짧게 설명한다.
- 성공/실패 메시지는 `submit-message` 또는 토스트를 사용한다.
- 브라우저 `alert()`는 사용하지 않는다.

## 오른쪽 흐름 패널

등록 화면의 오른쪽 `side-panel`은 `workflow-panel.md` 기준을 따른다.

입고 등록에서는 아래 세부 흐름을 active 단계 안에 둔다.

```text
1. 기본 정보 입력
2. 품목 검색
3. 라인 검토
4. 검수 대기
```

기준:

- 본문 입력과 같은 내용을 길게 반복하지 않는다.
- 현재 작성 내용이 저장 후 어떤 도메인 데이터로 바뀌는지 알려준다.
- 보조 규칙은 `muted-panel`에 3~4개 이하로 둔다.

## 빠른 등록 모달

업무 중 필요한 기준 데이터를 간단히 추가해야 하면 모달을 사용할 수 있다.

입고 등록의 빠른 품목 등록 예:

```text
새 품목 등록
- 분류
- 제조사
- 품목명
- 제조사 모델명
- 안전 재고
[취소] [등록 후 선택]
```

기준:

- 현재 입력 중인 전표 내용을 잃지 않게 모달로 처리한다.
- 입력 범위는 빠른 등록에 필요한 최소 항목으로 제한한다.
- 상세 입력은 해당 관리 화면에서 보강한다.
- 모달 구조와 피드백은 `modal-dialog.md`를 따른다.

## 반응형 기준

세부 breakpoint는 `responsive-layout.md`를 따른다.

추가 기준:

- `register-fields`, `part-search-form`, `selected-part-panel`은 좁은 화면에서 1열로 전환한다.
- 검색 결과 테이블은 중간 폭에서 내부 스크롤을 허용할 수 있다.
- 저장 버튼은 모바일에서 줄바꿈되어도 높이가 안정적으로 유지되어야 한다.

## 금지

- 전표 작성 화면을 단순 목록 테이블처럼 만들지 않는다.
- 오른쪽 패널에 실제 입력 필드를 많이 넣지 않는다.
- 저장 후 생성되는 상태 변화를 설명 없이 숨기지 않는다.
- 빠른 등록 모달에 전체 품목 상세 입력을 모두 넣지 않는다.
- 품목코드는 빠른 등록 모달에서 입력받지 않고 서버 자동 생성 기준을 따른다.
- 저장 성공을 임시 화면 데이터로만 처리하지 않는다.
