# PCS Frontend JS Rules

정적 HTML 화면에서 JS를 작성할 때의 공통 기준이다.

## 기본 원칙

- 화면은 서버 Model을 받지 않는다.
- HTML은 정적 파일로 두고, JS가 REST API를 호출한다.
- 인증이 필요한 API는 `docs/ai/pcs-auth-client-rules.md` 기준으로 `pcs-api.js`를 사용한다.
- 페이징 목록은 `docs/ai/pcs-pagination-rules.md` 기준으로 `pcs-pagination.js`를 사용한다.
- 화면별 JS는 해당 화면의 렌더링과 이벤트 연결만 담당한다.

## 스크립트 로딩 순서

인증 API와 페이징을 모두 쓰는 화면:

```html
<script src="/js/pcs-api.js"></script>
<script src="/js/pcs-pagination.js"></script>
<script src="/js/partners.js"></script>
```

순서 기준:

- `pcs-api.js`가 먼저 로드되어야 `window.PcsApi`를 사용할 수 있다.
- `pcs-pagination.js`가 먼저 로드되어야 `window.PcsPagination`을 사용할 수 있다.
- 화면별 JS는 항상 공통 JS 뒤에 둔다.

## API 호출

인증이 필요한 API 호출의 상세 기준은 `docs/ai/pcs-auth-client-rules.md`를 따른다.

사용:

```js
const data = await window.PcsApi.getData(url, {
    authRedirect: true,
    loginCompanyCode: companyCode
});
```

금지:

```js
const response = await fetch(url);
const json = await response.json();
```

단, 공개 페이지나 로그인 요청처럼 인증 공통 처리가 필요 없는 경우에는 화면 목적에 맞게 직접 호출할 수 있다.

## 페이징 목록

페이징 query, 응답 정규화, 이전/다음 버튼, 스크롤 보존 기준은 `docs/ai/pcs-pagination-rules.md`를 따른다.

## DOM 렌더링

- API 응답을 받은 뒤 필요한 행만 다시 그린다.
- 문자열 조합으로 큰 HTML을 만들기보다 `document.createElement()`를 우선한다.
- 사용자 입력값을 `innerHTML`에 직접 넣지 않는다.
- 빈 목록, 로딩, 오류 상태를 모두 고려한다.

## 폼 기준

- 저장 API가 아직 없으면 화면에서 저장되는 것처럼 보이게 만들지 않는다.
- 브라우저 자동완성이 업무 입력을 방해하면 해당 폼이나 입력에 `autocomplete="off"` 또는 목적에 맞는 값을 명시한다.
- 필수 입력과 선택 입력은 화면에서 구분한다.
