# CSS Architecture

PCS 화면 CSS의 파일 소유권과 cascade layer 기준이다.

## 기본 원칙

- 권한별 CSS를 만들지 않는다. OWNER, ADMIN, STAFF는 같은 디자인 체계를 사용한다.
- 모든 HTML은 공통 CSS와 자신의 페이지 CSS를 함께 로드한다.
- 페이지 CSS에는 해당 페이지에서만 쓰는 예외만 둔다.
- 두 화면 이상에서 구조와 역할이 같은 스타일은 반드시 공통 CSS로 이동한다.
- 현재 한 화면에서만 사용해도 역할이 일반화될 수 있는 컴포넌트와 상태 스타일은 공통 CSS가 소유한다.
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
    management-page.css
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
- `components/management-page.css`: 관리형 화면의 요약, 하위 항목 편집, 선택·정렬 상태
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
<!-- 관리형 화면은 management-page.css, 필요한 경우 workflow.css, feedback.css -->
<link rel="stylesheet" href="/css/pages/{page}.css">
```

공개 화면은 `layouts/workspace.css`를 로드하지 않는다.

모든 body에는 범위 클래스를 둔다.

```html
<body class="workspace-page page-partners">
```

## 페이지 CSS 기준

- 모든 HTML에는 같은 이름의 `pages/{page}.css`가 존재해야 한다.
- 페이지 CSS는 비어 있거나 `@layer page {}`만 있어도 된다. 페이지별 선언을 채우는 것이 목적이 아니다.
- 페이지 전용 규칙은 가능한 경우 `.page-{page}` 아래로 범위를 제한한다.
- 공통 `.btn`, `.field`, `.panel-card`, `.data-row`를 페이지 CSS에서 다시 정의하지 않는다.
- 공통 컴포넌트의 실제 페이지 차이만 modifier 또는 페이지 범위 선택자로 보정한다.
- 반응형 전체 골격은 layout이, 컴포넌트 내부 전환은 components가, 한 페이지의 예외만 page가 담당한다.

페이지 CSS에 남길 수 있는 규칙:

- 해당 목록의 실제 열 수에 따른 `grid-template-columns`
- 특정 도메인에만 존재하는 필드 묶음의 배치
- 모바일에서 숨길 데이터 열과 페이지 고유 노출 순서
- 공통 컴포넌트 계약으로 표현할 수 없는 페이지 상태

공통 CSS로 이동해야 하는 규칙:

- 카드, 버튼, 배지, 검색 폼, 요약, 패널, 모달의 기본 모양
- hover, focus, selected, inactive, dragging 같은 재사용 상태
- 두 열에서 한 열로 바뀌는 컴포넌트 내부 반응형
- 다른 데이터로 바꿔도 동일하게 성립하는 목록·편집·상세 구조

## 페이지 CSS 수정 절차

페이지 CSS를 건드리는 모든 작업은 아래 순서를 따른다.

1. 대상 페이지 CSS 전체와 연결된 공통 CSS를 읽는다.
2. 추가하려는 선언과 비슷한 class, 상태, media query를 공통 CSS에서 검색한다.
3. 기존 공통 class 사용으로 해결한다.
4. 부족하면 역할 기반 공통 modifier 또는 공통 컴포넌트를 추가한다.
5. 공통화할 수 없는 최소 차이만 페이지 CSS에 작성한다.
6. 대상 페이지 CSS의 기존 선언도 같은 기준으로 검토해 공통으로 이동하거나 삭제한다.
7. 같은 화면 유형의 대표 페이지를 최소 2개 실행해 공통 변경의 충돌 여부를 확인한다.

페이지 CSS가 늘어났다면 완료 전에 각 추가 블록이 페이지 전용이어야 하는 이유를 다시 검토한다. 공통화 가능한 블록이 하나라도 있으면 작업은 완료되지 않은 것으로 본다.

다음 질문에 모두 `예`여야 페이지 CSS에 남길 수 있다.

```text
이 규칙은 데이터나 업무 계약 때문에 이 페이지에서만 달라지는가?
기존 공통 class와 modifier로 표현할 수 없는가?
다른 도메인명으로 바꾸면 의미가 사라지는가?
선언 범위가 필요한 최소 크기인가?
```

## 인라인 스타일

- 정적인 색상, 폭, grid 설정은 인라인으로 작성하지 않는다.
- API 응답에 따라 달라지는 진행률처럼 런타임 값 전달에는 CSS custom property 인라인 값을 허용한다.
- 정적 값은 class와 페이지 CSS로 이동한다.

## 새 페이지 추가

1. 비어 있어도 되는 `pages/{page}.css`를 만든다.
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
- 현재 사용 화면이 하나라는 이유만으로 일반화 가능한 컴포넌트를 페이지 CSS에 작성
- 공통 class를 페이지 범위 선택자로 복사해 전체 모양을 다시 정의
- 페이지 CSS 수정 시 기존 중복 선언 검토 없이 새 선언만 추가
