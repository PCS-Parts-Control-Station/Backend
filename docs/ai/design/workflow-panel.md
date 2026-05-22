# Workflow Panel Design

입고, 검수, 출고, 이력 화면의 오른쪽 업무 흐름 보조 패널 기준이다.

## 적용 대상

- `/w/{companyCode}/inbound`
- `/w/{companyCode}/inspection`
- `/w/{companyCode}/outbound`
- `/w/{companyCode}/history`

## 목적

사용자가 현재 화면이 PCS 업무 흐름 중 어느 단계인지 바로 이해하도록 돕는다.

이 패널은 입력 폼이 아니다. 목록 화면 오른쪽에서 현재 업무 위치와 다음 업무 흐름을 설명하는 보조 패널이다.

## 기본 흐름

PCS 재고 업무의 기본 흐름은 아래 순서를 따른다.

```text
입고
-> 검수
-> 출고
-> 이력
```

화면별 active 단계:

```text
입고 화면: 입고 active
검수 화면: 검수 active
출고 화면: 출고 active
이력 화면: 이력 active
```

## 기본 구조

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
                <p>거래처 입고 부품을 전표로 묶고 관리번호를 생성합니다.</p>
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

## 입고 화면 세부 단계

입고 화면의 active 단계는 아래 세부 흐름을 보여준다.

```text
1. 거래처 선택
2. 부품 라인 추가
3. 관리번호 생성
4. 검수 대기 전환
```

문구 기준:

```text
거래처 선택
공급 거래처를 입고 전표에 연결합니다.

부품 라인 추가
부품 종류와 입고 수량을 입력합니다.

관리번호 생성
입고 수량만큼 개별 관리번호를 발급합니다.

검수 대기 전환
검수 대기, 판매 보류 상태로 시작합니다.
```

## 검수 화면 세부 단계

검수 화면의 active 단계는 아래 세부 흐름을 사용한다.

```text
1. 검수 대상 선택
2. 항목별 결과 입력
3. 등급 확정
4. 판매 상태 반영
```

## 출고 화면 세부 단계

출고 화면의 active 단계는 아래 세부 흐름을 사용한다.

```text
1. 출고 거래처 선택
2. 판매 가능 부품 선택
3. 출고 전표 생성
4. 재고 차감 및 이력 저장
```

## 이력 화면 세부 단계

이력 화면은 특정 처리 단계보다 추적 흐름을 보여준다.

```text
1. 기간/대상 검색
2. 전표/상태 변경 확인
3. 개별 관리번호 이력 추적
4. 정정/취소 사유 확인
```

## 보조 규칙 패널

workflow panel 아래에는 화면별 운영 규칙을 `muted-panel`로 둘 수 있다.

입고 화면 예:

```text
입고 완료 시 수량만큼 관리번호를 생성
개별 부품은 검수 대기, 판매 보류로 시작
입고 오류는 원본 수정 대신 취소 전표로 보존
```

기준:

- 목록은 3~4개 이하로 유지한다.
- 기능 설명보다 운영 판단에 필요한 규칙을 적는다.
- 등록 입력 필드와 섞지 않는다.

## 금지

- workflow panel 안에 등록/수정 입력 폼을 넣지 않는다.
- active 단계를 여러 개 표시하지 않는다.
- 모든 단계를 같은 강조도로 보여주지 않는다.
- pulse 애니메이션을 크거나 빠르게 만들지 않는다.
- 안내 문구를 길게 늘려 오른쪽 패널을 설명서처럼 만들지 않는다.
