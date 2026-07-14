# Design MD Rules

디자인 규칙을 한 문서에만 두기 위한 소유권 기준이다.

## 우선순위

```text
pcs-design-system.md
-> design-md-rules.md
-> design/*.md 화면 유형·컴포넌트
-> features/*.md 페이지 전용 계약
```

상위 문서와 충돌하면 상위 기준을 우선한다. 예외가 필요하면 하위 문서에 복사하지 말고 원본을 수정할지 먼저 판단한다.

## 규칙 소유권

| 내용 | 소유 문서 |
|---|---|
| 색·폰트·radius·그림자·버튼·입력·배지 | `pcs-design-system.md` |
| CSS 파일·layer·페이지 예외 | `css-architecture.md` |
| 사이드바·헤더·업무 본문 골격 | `workspace-layout.md` |
| breakpoint와 폭별 전환 | `responsive-layout.md` |
| 검색·필터·요약·목록 행 | `data-table.md` |
| 관리형 화면 조합 | `management-page.md` |
| 등록·수정 폼 내용 | `form-panel.md` |
| 오른쪽 드로어 셸·동작·스크롤 | `side-drawer.md` |
| `<dialog>`·확인·입력 모달·토스트 | `modal-dialog.md` |
| 업무 흐름 안내 | `workflow-panel.md` |
| 단계별 입력과 저장 | `operation-flow.md` |
| 대시보드·상세·타임라인 | 해당 유형 문서 |

## 페이지 문서에 남길 내용

- API, 필드, 상태, 권한, 저장 규칙
- 사용하는 공통 화면 유형의 조합
- 데이터 열 수와 도메인별 정보 우선순위
- 공통 규칙으로 표현할 수 없는 업무상 예외와 이유

남기지 않는 내용:

- 공통 색상·크기·CSS 선언
- 검색 카드·드로어·모달의 공통 구조
- 다른 화면에도 적용되는 반응형 규칙
- 공통 class 전체 설명

참조 형식:

```text
화면 구성은 `docs/ai/design/management-page.md`를 따른다.
이 문서는 품목 분류의 열과 입력 계약만 정의한다.
```

## 변경 위치 판단

1. 기존 원본 문서와 공통 CSS를 검색한다.
2. 기존 class로 해결한다.
3. 부족하면 의미 기반 공통 modifier를 추가한다.
4. 다른 화면에서도 같은 의미면 공통 컴포넌트로 올린다.
5. 데이터·업무 계약 때문에 다른 최소 차이만 페이지에 둔다.

현재 한 화면에서만 사용한다는 이유는 페이지 전용 근거가 아니다. 반대로 선언값이 비슷하다는 이유만으로 의미가 다른 컴포넌트를 합치지 않는다.

## 이름 규칙

- CSS class는 `management-data-row`, `document-detail-drawer`처럼 역할을 사용한다.
- 페이지·도메인 이름은 JS 식별용 `data-*`에 사용할 수 있다.
- `partner-table`, `inbound-row`처럼 재사용 가능한 모양에 도메인 이름을 붙이지 않는다.

## 새 디자인 문서

기존 문서 조합으로 설명할 수 없고 두 화면 이상에서 독립적으로 재사용할 유형일 때만 만든다.

새 문서를 만들면 다음을 갱신한다.

- `docs/ai/pcs-design-system.md`
- `docs/ai/AI_INDEX.md`
- 필요하면 `css-architecture.md`의 소유권 표

## 완료 확인

- 같은 규칙을 설명하는 다른 문서를 참조 문장으로 바꿨는가?
- 변경된 class를 사용하는 화면을 검색했는가?
- 대표 화면 2개 이상과 모바일 폭을 확인했는가?
- 페이지 CSS에 공통 선언이 남아 있지 않은가?
- `processResources` 또는 관련 최소 검증을 수행했는가?
