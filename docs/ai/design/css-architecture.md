# CSS Architecture

PCS 화면 CSS의 파일 소유권과 cascade layer 기준이다.

## 기본 원칙

- 권한별 CSS를 만들지 않는다. OWNER, ADMIN, STAFF는 같은 디자인 체계를 사용한다.
- 모든 HTML은 공통 CSS와 자신의 페이지 CSS를 함께 로드한다.
- 페이지 CSS에는 해당 페이지에서만 쓰는 예외만 둔다.
- 두 화면 이상에서 구조와 역할이 같은 스타일은 공통 CSS로 이동한다.
- 단순히 선언값이 비슷하다는 이유만으로 서로 다른 컴포넌트를 합치지 않는다.
- `admin.css` 같은 전체 업무 화면 단일 파일을 다시 만들지 않는다.

## 파일 구조

```text
src/main/resources/static/css/
  core/
    tokens.css
    base.css
  layouts/
    workspace.css
  components/
    components.css
    workflow.css
    feedback.css
  pages/
    {page}.css
```

소유권:

- `core/tokens.css`: 색상, 글꼴, 간격과 공통 CSS 변수, layer 순서
- `core/base.css`: box sizing, 기본 글꼴, 기본 요소 초기화
- `layouts/workspace.css`: 사이드바, 헤더, 본문 폭, 공통 반응형 골격
- `components/components.css`: 버튼, 입력, 카드, 표, 배지, 모달, 페이징
- `components/workflow.css`: 입고·검수·출고에서 공유하는 업무 흐름 표현
- `components/feedback.css`: 토스트 등 공통 피드백
- `pages/{page}.css`: 그 HTML에서만 사용하는 배치와 상태

## Cascade Layer

layer 순서는 아래 한 곳에서만 선언한다.

```css
@layer foundation, layout, components, workflow, page;
```

각 파일은 자신의 layer 안에만 규칙을 둔다.

```css
@layer components {
    .btn { ... }
}

@layer page {
    .page-users .user-management-grid { ... }
}
```

- `page`가 공통 컴포넌트보다 우선하므로 선택자 강도를 불필요하게 높이지 않는다.
- `!important`를 사용하지 않는다. `[hidden]`의 표시 보장처럼 공통 계약상 반드시 필요한 경우만 예외다.
- layer 밖에 일반 스타일 규칙을 두지 않는다. layer 밖 규칙은 정상 선언에서 모든 layer보다 우선한다.

## HTML 로딩 순서

업무 화면:

```html
<link rel="stylesheet" href="/css/core/tokens.css">
<link rel="stylesheet" href="/css/core/base.css">
<link rel="stylesheet" href="/css/layouts/workspace.css">
<link rel="stylesheet" href="/css/components/components.css">
<!-- 필요한 경우 workflow.css, feedback.css -->
<link rel="stylesheet" href="/css/pages/{page}.css">
```

공개 화면은 `layouts/workspace.css`를 로드하지 않는다.

모든 body에는 범위 클래스를 둔다.

```html
<body class="workspace-page page-partners">
```

## 페이지 CSS 기준

- 모든 HTML에는 같은 이름의 `pages/{page}.css`가 존재해야 한다.
- 페이지 전용 규칙은 가능한 경우 `.page-{page}` 아래로 범위를 제한한다.
- 공통 `.btn`, `.field`, `.panel-card`, `.data-row`를 페이지 CSS에서 다시 정의하지 않는다.
- 공통 컴포넌트의 실제 페이지 차이만 modifier 또는 페이지 범위 선택자로 보정한다.
- 반응형 전체 골격은 layout이, 컴포넌트 내부 전환은 components가, 한 페이지의 예외만 page가 담당한다.

## 인라인 스타일

- 정적인 색상, 폭, grid 설정은 인라인으로 작성하지 않는다.
- API 응답에 따라 달라지는 진행률처럼 런타임 값 전달에는 CSS custom property 인라인 값을 허용한다.
- 정적 값은 class와 페이지 CSS로 이동한다.

## 새 페이지 추가

1. `pages/{page}.css`를 만든다.
2. body에 `page-{page}`와 화면 유형 클래스를 추가한다.
3. 공통 CSS를 표준 순서로 로드한다.
4. 필요한 페이지 예외만 `@layer page`에 작성한다.
5. 다른 페이지와 같은 구조를 새로 작성하지 말고 기존 공통 컴포넌트를 사용한다.

## 금지

- `admin.css` 재생성 또는 참조
- 페이지 CSS 없이 공통 CSS에 페이지 전용 선택자 추가
- 페이지 CSS에서 공통 컴포넌트 전체 복사
- 정적 인라인 스타일
- `!important`로 우선순위 문제 회피
- HTML마다 CSS 로딩 순서를 다르게 구성
