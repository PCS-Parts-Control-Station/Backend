# PCS Navigation State Guide

목록 화면에서 다른 화면으로 이동했다가 브라우저 뒤로가기로 돌아왔을 때 검색 조건, 페이지, 선택된 상세, 스크롤 위치를 복원해야 하는 경우에만 사용하는 짧은 가이드다.

이 기능이 필요하지 않은 단순 등록 화면, 단일 상세 화면, 일회성 모달에는 적용하지 않는다.

## 먼저 읽을 파일

이전 상태 기억이 필요한 목록 화면을 구현하거나 수정할 때는 아래 파일을 함께 읽는다.

- `docs/ai/pcs-navigation-state-guide.md`
- `docs/ai/pcs-frontend-js-rules.md`
- `src/main/resources/static/js/pcs-navigation-state.js`
- 적용 예시:
  - `src/main/resources/static/js/parts.js`
  - `src/main/resources/static/js/categories.js`
  - `src/main/resources/static/js/part-units.js`

새로 `sessionStorage`, `localStorage`, 화면별 복원 유틸을 만들지 않는다.

## 기준

- 새 저장소, `sessionStorage`, `localStorage`, 화면별 전용 복원 유틸을 만들지 않는다.
- 공통 `src/main/resources/static/js/pcs-navigation-state.js`의 `window.PcsNavigationState`를 사용한다.
- 검색 조건, 페이지, 선택 ID는 URL query에 둔다.
- 스크롤 위치는 `history.state`에 둔다.
- 등록/수정 중인 입력값, 임시 모달 상태는 복원하지 않는다.
- 화면별 JS에는 어떤 값을 저장할지와 복원 후 어떤 API를 다시 호출할지만 둔다.

## 로드 순서

```html
<script src="/js/pcs-common.js"></script>
<script src="/js/pcs-navigation-state.js"></script>
<script src="/js/{page}.js"></script>
```

`pcs-navigation-state.js`는 화면별 JS보다 먼저 로드해야 한다.

## 기본 흐름

```js
const navigationState = window.PcsNavigationState?.createUrlStateController({
    namespace: "page-name",
    managedKeys: ["keyword", "page", "selectedId"],
    defaults: {
        keyword: "",
        page: "0",
        selectedId: ""
    }
});

const syncNavigationState = (overrides = {}) => {
    navigationState?.write({
        ...window.PcsNavigationState.captureFormState(filterForm, {
            fields: ["keyword"]
        }),
        page: String(currentPage),
        selectedId: selectedId || "",
        ...overrides
    });
};

const restored = navigationState?.read() || {};
window.PcsNavigationState.applyFormState(filterForm, restored, {
    fields: ["keyword"]
});
currentPage = window.PcsNavigationState.numberParam(restored.page, 0);
```

목록 조회 후 `selectedId`가 있으면 해당 상세를 다시 열고, 마지막에 `navigationState.restoreScroll()`을 호출한다. 페이지를 떠날 때 스크롤을 저장하려면 `navigationState.bindScrollCapture()`를 초기화 시점에 호출한다.

## 이미 적용된 예시

- `src/main/resources/static/js/part-units.js`: `keyword`, `documentId`, `categoryId`, `partState`, `page`, `unitId`
- `src/main/resources/static/js/parts.js`: `keyword`, `categoryId`, `page`, `partId`
- `src/main/resources/static/js/categories.js`: `keyword`, `page`, `categoryId`

## 딥링크와 구분

`PcsNavigationState`는 같은 목록 화면으로 돌아왔을 때 이전 상태를 복원하는 기능이다.

다른 화면에서 특정 대상을 지정해 들어오는 기능은 URL query 딥링크로 처리한다. 예를 들어 부품관리에서 검수 이력으로 이동할 때 `documentId`, `partId`, `unitId`, `inspectionId`를 넘기고 검수 이력 화면이 해당 전표와 관리번호 상세를 선택하는 방식은 딥링크 복원이다.
