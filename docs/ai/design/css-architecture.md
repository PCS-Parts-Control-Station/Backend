# CSS Architecture

PCS CSS 파일과 cascade layer 소유권의 원본이다.

## 구조와 소유권

```text
static/css/
  core/
    tokens.css
    base.css
  layouts/
    workspace.css
  components/
    components.css
    management-page.css
    workflow.css
    feedback.css
  pages/
    {page}.css
```

| 파일 | 책임 |
|---|---|
| `tokens.css` | 토큰 실제 값과 layer 순서 |
| `base.css` | box sizing, 폰트, 기본 요소 |
| `workspace.css` | 업무 레이아웃, 사이드바, 헤더 |
| `components.css` | 버튼, 입력, 카드, 표, 배지, 모달, 드로어 셸 |
| `management-page.css` | 관리형 편집·선택·정렬 상태 |
| `workflow.css` | 업무 흐름 표현 |
| `feedback.css` | 토스트와 공통 피드백 |
| `pages/{page}.css` | 해당 페이지의 데이터 배치와 예외 |

권한별 CSS와 `admin.css` 같은 업무 화면 단일 파일은 만들지 않는다.

## Cascade layer

layer 순서는 `tokens.css` 한 곳에서만 선언한다.

```css
@layer foundation, layout, components, workflow, page;
```

- 각 파일은 자기 layer 안에만 규칙을 둔다.
- 일반 규칙을 layer 밖에 두지 않는다.
- 선택자 강도를 불필요하게 높이지 않는다.
- `[hidden]` 계약처럼 불가피한 경우 외에는 `!important`를 사용하지 않는다.

## 로딩 순서

업무 화면:

```html
<link rel="stylesheet" href="/css/core/tokens.css">
<link rel="stylesheet" href="/css/core/base.css">
<link rel="stylesheet" href="/css/layouts/workspace.css">
<link rel="stylesheet" href="/css/components/components.css">
<!-- 필요한 component CSS -->
<link rel="stylesheet" href="/css/pages/{page}.css">
```

공개 화면은 `workspace.css`를 로드하지 않는다. 모든 body에는 `page-{page}` 범위 class를 둔다.

## 페이지 CSS 허용 범위

- 실제 데이터 열 수에 따른 grid
- 도메인에만 존재하는 필드 묶음
- 모바일에서 숨길 열과 페이지 고유 노출 순서
- 공통 계약으로 표현할 수 없는 페이지 상태

공통 CSS가 소유하는 내용:

- 버튼, 입력, 카드, 배지, 검색, 요약, 모달, 드로어 기본 모양
- hover, focus, selected, inactive, dragging 상태
- 드로어 위치·폭·열림·스크롤·액션 영역
- 여러 화면에 동일하게 적용되는 컴포넌트 내부 반응형

모든 HTML은 대응하는 `pages/{page}.css`를 가진다. 비어 있거나 `@layer page {}`만 있어도 된다.

## 드로어와 스크롤

- 공통 셸은 `right-side-drawer`, `right-side-drawer-panel`을 사용한다.
- 긴 본문은 `drawer-scroll-body`, 긴 반복 목록은 `right-side-scroll-list`에만 스크롤을 둔다.
- 드로어 루트와 패널 자체에 별도 세로 스크롤을 만들지 않는다.
- 하단 실행 영역은 `form-actions`를 사용한다.
- 동작 계약은 `side-drawer.md`를 따른다.

## 인라인 스타일

- 정적 색상, 폭, grid는 인라인으로 작성하지 않는다.
- API 값에 따른 진행률처럼 런타임 custom property 전달만 허용한다.

## 변경 절차

1. 대상 페이지와 로드하는 공통 CSS를 읽는다.
2. 같은 class, 상태, media query를 검색한다.
3. 기존 class → 공통 modifier → 공통 컴포넌트 → 페이지 예외 순서로 결정한다.
4. 수정한 페이지 CSS의 기존 중복도 함께 제거한다.
5. 대표 화면 2개 이상에서 충돌을 확인한다.

## 금지

- 페이지 CSS에서 공통 컴포넌트 전체 복사
- 공통 CSS에 페이지 전용 선택자 추가
- 정적 인라인 스타일과 우선순위 회피용 `!important`
- HTML마다 다른 공통 CSS 로딩 순서
- 페이지 전용 근거 없이 새 선언 추가
