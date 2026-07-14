# Workflow Panel Design

입고·검수·출고 등록 화면 오른쪽의 업무 흐름 안내 패널 기준이다. 입력 폼이나 상세 드로어가 아니다.

## 적용

- `/w/{companyCode}/inbound/new`
- `/w/{companyCode}/inspection`
- `/w/{companyCode}/outbound/new`

조회 중심 전표·이력·관리 화면에는 사용하지 않는다.

## 기본 흐름

```text
입고 -> 검수 -> 출고 -> 이력
```

현재 화면 단계 하나만 active로 표시하고 그 단계의 세부 순서를 펼친다.

## 구조

```text
side-panel
- panel-card.process-panel
  - 제목과 짧은 설명
  - workflow-list
    - workflow-step.active
      - process-dot
      - 현재 단계
      - sub-process-list
    - 축약된 나머지 단계
```

- 표면은 공통 `panel-card`, 흐름 표현은 `workflow.css`가 소유한다.
- active는 의미 있는 초록 신호와 굵은 제목을 사용한다.
- 애니메이션은 작고 느리게 사용하며 reduced motion에서는 제거한다.
- 본문 입력과 같은 설명을 반복하지 않는다.

## 단계별 세부 흐름

입고:

```text
거래처 선택 -> 입고 품목 추가 -> 관리번호 생성 -> 검수 대기
```

검수:

```text
검수 대상 선택 -> 항목 결과 입력 -> 등급 확정 -> 판매 상태 반영
```

출고:

```text
거래처 선택 -> 판매 가능 관리번호 선택 -> 전표 생성 -> 재고·이력 저장
```

세부 문구와 상태는 각 feature 문서를 원본으로 한다.

## 보조 규칙

workflow 자체가 안내 역할을 하므로 별도 규칙 카드를 기본으로 추가하지 않는다. 꼭 필요하면 입력 판단에 필요한 규칙 3개 이하만 보조 영역에 둔다.

## 반응형

- 넓은 화면은 본문 오른쪽에 둔다.
- 1180px 이하에서 본문 아래로 이동한다.
- 내용이 길어 독립 스크롤이 생기지 않게 한다.
- 자세한 전환은 `responsive-layout.md`를 따른다.

## 금지

- 등록·수정 입력 또는 목록 상세 수용
- active 단계 여러 개 표시
- 모든 단계 동일 강조
- 긴 설명과 큰 pulse 애니메이션
