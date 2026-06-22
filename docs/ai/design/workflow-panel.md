# Workflow Panel Design

입고 등록, 검수 등록, 출고 등록처럼 사용자가 순서대로 처리하는 업무 화면의 오른쪽 업무 흐름 보조 패널 기준이다.

목록 조회가 중심인 관리 화면의 상세 조회는 이 문서의 workflow panel이 아니라 `상세 슬라이드 패널` 기준을 따른다.

## 적용 대상

- `/w/{companyCode}/inbound/new`
- `/w/{companyCode}/inspection`
- `/w/{companyCode}/outbound/new`

입고 관리, 출고 관리, 이력 화면은 조회 중심 화면이므로 오른쪽 업무 흐름 보조 패널을 기본으로 두지 않는다. 목록은 본문 전체 너비를 우선 사용하고, 상세는 필요할 때 오른쪽 슬라이드 패널로 연다.

## 목적

사용자가 현재 화면이 PCS 업무 흐름 중 어느 단계인지 바로 이해하도록 돕는다.

이 패널은 입력 폼이나 상세 조회 영역이 아니다. 등록/처리 화면 오른쪽에서 현재 업무 위치와 다음 업무 흐름을 설명하는 보조 패널이다.

## 기본 흐름

PCS 재고 업무의 기본 흐름은 아래 순서를 따른다.

```text
입고
-> 검수
-> 출고
-> 이력
```

업무별 active 단계:

```text
입고 업무: 입고 active
검수 업무: 검수 active
출고 업무: 출고 active
이력 업무: 필요할 때만 이력 active
```

## 기본 구조

CSS 기준:

```text
workflow.css
```

기준:

- `process-panel`, `workflow-list`, `workflow-step`, `process-dot`, `sub-process-list` 시각 구조는 `components/workflow.css`를 따른다.
- 오른쪽 패널 카드 자체의 기본 여백과 표면은 `components/components.css`의 `panel-card` 기준을 따른다.

```text
side-panel
- panel-card.process-panel
  - 제목
  - 짧은 설명
  - workflow-list
    - workflow-step.active
      - process-dot
      - 현재 단계 제목/설명
      - sub-process-list
    - workflow-step
    - workflow-step
    - workflow-step
- panel-card.muted-panel
  - 운영 규칙
```

HTML 예:

```html
<div class="panel-card process-panel">
    <h2>입고부터 출고까지</h2>
    <p>현재 화면은 전체 재고 흐름 중 입고 단계입니다.</p>

    <ol class="workflow-list">
        <li class="workflow-step active">
            <span class="process-dot" aria-hidden="true"></span>
            <div>
                <strong>입고 진행 중</strong>
                <p>거래처 입고 품목을 전표로 묶고 관리번호를 생성합니다.</p>
                <ol class="sub-process-list">
                    ...
                </ol>
            </div>
        </li>
    </ol>
</div>
```

## 표시 기준

- 현재 화면 단계만 `active`로 표시한다.
- active 단계는 초록 dot와 굵은 제목을 사용한다.
- active 단계에는 해당 업무의 세부 처리 단계를 펼쳐 보여준다.
- active가 아닌 단계는 회색 톤으로 축약한다.
- 전체 흐름은 세로 타임라인 형태로 보여준다.
- 타임라인 선은 얇은 `--line` 색상을 사용한다.
- 패널은 오른쪽 보조 영역이므로 본문 목록보다 강하게 튀면 안 된다.
- 목록 행 선택에 따른 상세 조회는 workflow panel 안에서 처리하지 않는다.
- 상세 조회가 필요한 관리 화면은 본문 전체 너비 목록과 오른쪽 상세 슬라이드 패널을 사용한다.

## Active Dot

active dot은 현재 진행 중인 업무 위치를 알려주는 작은 시각 신호다.

기준:

- 색상은 `--green`을 사용한다.
- 크기는 12~14px 수준을 유지한다.
- pulse 애니메이션은 느리고 작게 사용한다.
- 사용자의 시선을 과하게 끌 정도로 커지면 안 된다.
- `prefers-reduced-motion: reduce`에서는 애니메이션을 제거한다.

CSS 기준:

```css
.workflow-step.active .process-dot {
    background: var(--green);
    animation: pulseDot 2.4s ease-out infinite;
}

@media (prefers-reduced-motion: reduce) {
    .workflow-step.active .process-dot {
        animation: none;
    }
}
```

## 입고 단계 세부 흐름

입고 업무가 active인 화면은 아래 세부 흐름을 보여준다.

```text
1. 거래처 선택
2. 입고 품목 추가
3. 관리번호 생성
4. 검수 대기 전환
```

문구 기준:

```text
거래처 선택
공급 거래처를 입고 전표에 연결합니다.

입고 품목 추가
품목과 입고 수량을 입력합니다.

관리번호 생성
입고 수량만큼 개별 관리번호를 발급합니다.

검수 대기 전환
검수 대기, 판매 보류 상태로 시작합니다.
```

## 검수 단계 세부 흐름

검수 업무가 active인 화면은 아래 세부 흐름을 사용한다.

```text
1. 검수 대상 선택
2. 항목별 결과 입력
3. 등급 확정
4. 판매 상태 반영
```

## 출고 단계 세부 흐름

출고 업무가 active인 화면은 아래 세부 흐름을 사용한다.

```text
1. 출고 거래처 선택
2. 판매 가능 부품 선택
3. 출고 전표 생성
4. 재고 차감 및 이력 저장
```

## 관리/이력 화면 기준

입고 관리, 출고 관리, 이력 화면은 등록/수정 업무가 아니라 조회 업무다. 따라서 오른쪽 업무 흐름 보조 패널을 기본으로 두지 않는다.

관리 화면 기본 구조:

```text
검색/필터
전표 목록 전체 너비
전표 상세 오른쪽 슬라이드 패널
확인/취소 모달
```

이력 화면 기본 구조:

```text
전표 단위 목록
전표 내 관리번호 이력
개별 이력 상세 슬라이드 패널
```

입고/출고 관리 화면은 전표 목록을 전체 너비로 보여주고, 전표 상세는 오른쪽 슬라이드 패널로 연다. 검수 이력 화면은 전표 단위 목록을 먼저 보여주고, 전표 선택 후 전표 상세 영역에서 품목 묶음과 관리번호별 검수 이력을 확인한다. 관리번호 상세는 오른쪽 슬라이드 패널로 열어 목록 흐름을 유지하고, 패널 내부만 스크롤한다.

## 보조 규칙 패널

workflow panel 아래에는 화면별 운영 규칙을 `muted-panel`로 둘 수 있다.

입고 운영 규칙 예:

```text
입고 완료 시 수량만큼 관리번호를 생성
개별 부품은 검수 대기, 판매 보류로 시작
입고 오류는 원본 수정 대신 취소 전표로 보존
```

기준:

- 목록은 3~4개 이하로 유지한다.
- 기능 설명보다 운영 판단에 필요한 규칙을 적는다.
- 등록 입력 필드와 섞지 않는다.

## 상세 슬라이드 패널

관리 화면에서 목록 행을 선택하면 오른쪽에서 상세 슬라이드 패널을 연다.

전표형 상세 모드 구조:

```text
aside.document-detail-drawer
- panel-card.document-detail-panel
  - panel-title-bar
    - 제목
    - 선택 안내 또는 전표 요약 문구
    - 닫기
  - document-detail-card
    - 전표번호
    - 상태 배지
  - detail-list
    - 거래처
    - 입고일
    - 처리자
    - 입고 사유
    - 취소 가능
  - document-line-section
    - section-title-row
    - document-line-list
  - form-actions
    - 목록 안내
    - 전표 취소
```

기준:

- 상세 슬라이드는 모달처럼 목록 조작을 막지 않는다.
- 배경 오버레이를 깔지 않는다.
- 패널이 열린 상태에서 다른 행을 클릭하면 패널을 닫지 않고 상세 내용만 교체한다.
- 닫기는 명시적인 `닫기` 버튼과 `Escape` 키를 지원한다.
- 패널 외부 클릭으로 닫지 않는다.
- 패널이 열린다고 포커스를 강제로 빼앗지 않는다. 닫을 때는 가능하면 마지막으로 선택했던 행 또는 버튼으로 포커스를 복귀한다.
- 전표번호와 관리번호 같은 긴 값은 monospace 계열로 표시한다.
- 상태는 배지로 표시한다.
- 상세 카드 안 상태 배지는 작은 pill 형태로 유지하고, 행 높이나 카드 높이에 맞춰 원형으로 커지지 않게 한다.
- 관련 항목 목록은 길어질 수 있으므로 내부 스크롤을 허용한다.
- 품목별 관리번호 목록은 접기/펼치기를 제공할 수 있다.
- 관리번호 옆에는 작은 복사 버튼을 둘 수 있다.
- 위험 작업은 오른쪽 패널에서 바로 실행하지 않고 확인 모달을 거친다.

전표 취소 액션:

- 취소 가능 여부와 불가 사유를 상세 모드에 먼저 표시한다.
- 취소 버튼은 취소 가능할 때만 활성화한다.
- 취소 확인과 결과 피드백은 `modal-dialog.md`와 `pcs-frontend-js-rules.md`를 따른다.

## 금지

- workflow panel 안에 등록/수정 입력 폼을 넣지 않는다.
- workflow panel 안에 관리 화면 상세 조회를 넣지 않는다.
- active 단계를 여러 개 표시하지 않는다.
- 모든 단계를 같은 강조도로 보여주지 않는다.
- pulse 애니메이션을 크거나 빠르게 만들지 않는다.
- 안내 문구를 길게 늘려 오른쪽 패널을 설명서처럼 만들지 않는다.
