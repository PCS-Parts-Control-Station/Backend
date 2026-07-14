# PCS Design System

PCS 화면의 시각 토큰과 공통 UI 원칙의 원본이다. 화면 구조는 `docs/ai/design/*.md`, 실제 CSS 값은 `static/css/core/tokens.css`를 따른다.

## 제품 방향

PCS는 관리번호 단위로 입고, 검수, 재고, 출고, 이력을 추적하는 국내 B2B 업무 시스템이다.

- 밝은 배경과 블루 중심의 차분한 SaaS 톤
- 운영 데이터와 다음 행동이 장식보다 우선
- 제목은 명확하게, 설명은 짧고 실무적으로 작성
- 상태는 빠르게 스캔할 수 있는 작은 배지로 표시
- 그림자는 약하게 쓰고 배경과 여백으로 영역을 구분

## 토큰 소유권

색상·글꼴·간격·그림자·radius의 실제 값은 `static/css/core/tokens.css`만 원본으로 한다. 문서와 페이지 CSS에 값을 복사하지 않는다.

주요 역할:

| 토큰 역할 | 사용 |
|---|---|
| page | 전체 배경 |
| surface / surface-soft | 카드·패널·보조 영역 |
| navy / ink / text | 제목·본문 |
| muted / subtle | 설명·placeholder |
| cyan | 주요 행동과 링크 |
| line / line-strong | 경계선과 입력 |
| green / orange / red / gray | 의미 있는 상태와 흐름 신호 |

기준:

- 기본 radius는 8px, 기본 컨트롤 높이는 48px이다.
- 강한 포인트는 블루 한 계열을 우선한다.
- 초록·주황·빨강은 상태, 위험, 현재 처리 단계처럼 의미가 있을 때만 쓴다.
- 과한 그라데이션, 형광색, 큰 그림자, 즉흥적인 radius를 사용하지 않는다.

## 타이포그래피

- 기본 폰트는 `Inter`, 시스템 UI, `Malgun Gothic` 순서다.
- 관리번호, 업체 코드, 내부 상태값은 공통 monospace 토큰을 사용한다.
- `letter-spacing`은 기본 0을 유지한다.
- 화면 라벨은 영어 도메인명보다 한국어 업무 용어를 우선한다.
- 용어 원본은 `docs/ai/pcs-terminology-rules.md`를 따른다.

## 공통 요소

### 버튼

- Primary: 저장, 생성, 확정, 검색처럼 화면의 핵심 행동
- Secondary: 취소, 초기화, 보조 이동
- Danger: 삭제, 취소 처리, 사용 중지처럼 되돌리기 어려운 행동
- 한 화면에서는 핵심 primary 행동 하나를 우선한다.
- 버튼 크기와 상태는 공통 `.btn` 계열을 사용하고 페이지 CSS에서 다시 정의하지 않는다.

### 입력

- input/select는 기본 컨트롤 높이를 사용한다.
- label은 짧고 필수/선택 여부를 명확히 한다.
- focus는 공통 primary outline을 사용한다.
- 브라우저 자동완성은 입력 목적에 맞게 명시한다.

### 카드와 패널

- 공통 surface, 얇은 border, 기본 radius, 작은 shadow를 사용한다.
- 페이지 섹션을 의미 없이 모두 카드로 감싸지 않는다.
- 카드 안에 같은 무게의 카드를 반복 중첩하지 않는다.

### 상태 배지와 코드 chip

- 상태는 `.badge` 계열의 작은 pill로 표시한다.
- 관리번호·업체 코드처럼 시스템 식별값은 `.code-chip` 또는 monospace 스타일을 사용한다.
- 상태 색 매핑은 공통 CSS와 해당 도메인 feature 문서를 따른다.
- 목록과 상세에서 같은 상태를 서로 다른 색으로 표현하지 않는다.

## 문구

- 사용자가 여기서 무엇을 확인하거나 처리하는지 먼저 말한다.
- 추상적인 마케팅 문구와 API·권한·URL 같은 구현 설명을 화면에 넣지 않는다.
- 설명은 한두 문장으로 제한하고 긴 정책은 문서에만 둔다.
- 공개 페이지의 소개 문구는 `design/public-pages.md`, 업무 용어는 `pcs-terminology-rules.md`를 따른다.

## 접근성

- 의미 있는 섹션은 제목과 `aria-labelledby`를 연결한다.
- 아이콘 전용 버튼에는 목적을 설명하는 `aria-label`을 둔다.
- 상태를 색상만으로 구분하지 않는다.
- 자동 움직임은 중지 가능해야 하고 `prefers-reduced-motion: reduce`를 지원한다.
- 드로어와 모달의 focus·Escape 기준은 각 소유 문서를 따른다.

## 로고와 favicon

공통 로고:

```text
src/main/resources/static/images/parts-control-station-icon.svg
```

- 모든 정적 HTML은 `/images/parts-control-station-icon.svg` favicon을 사용한다.
- `/favicon.ico`도 같은 로고로 연결한다.
- 로고와 업무 아이콘은 공통 크기 체계에 맞추고 페이지 CSS로 개별 보정하지 않는다.

## 화면 유형 문서

| 유형 | 문서 |
|---|---|
| 공개·진입 | `design/public-pages.md` |
| 업무 골격 | `design/workspace-layout.md` |
| 반응형 | `design/responsive-layout.md` |
| 관리형 화면 | `design/management-page.md` |
| 검색·목록 | `design/data-table.md` |
| 등록·수정 폼 | `design/form-panel.md` |
| 오른쪽 드로어 | `design/side-drawer.md` |
| 모달·토스트 | `design/modal-dialog.md` |
| 업무 흐름 패널 | `design/workflow-panel.md` |
| 단계형 입력 | `design/operation-flow.md` |
| 대시보드·상세·이력 | 해당 디자인 문서 |

## 변경 완료 기준

1. `design-md-rules.md`와 `design/css-architecture.md`에서 소유 위치를 확인한다.
2. 공통 class와 modifier로 표현할 수 있는지 검색한다.
3. 페이지 문서와 CSS에는 도메인 필드·열·상태로 인한 최소 예외만 남긴다.
4. 공통 변경은 같은 유형 대표 화면 2개 이상에서 확인한다.
5. 데스크톱과 모바일에서 텍스트, focus, 스크롤이 깨지지 않는지 확인한다.
