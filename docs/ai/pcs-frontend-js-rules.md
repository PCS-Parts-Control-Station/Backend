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
<script src="/js/pcs-ui.js"></script>
<script src="/js/pcs-common.js"></script>
<script src="/js/partners.js"></script>
```

토스트 피드백을 쓰는 화면:

```html
<link rel="stylesheet" href="/css/components/feedback.css">
<script src="/js/pcs-ui.js"></script>
```

순서 기준:

- `pcs-api.js`가 먼저 로드되어야 `window.PcsApi`를 사용할 수 있다.
- `pcs-pagination.js`가 먼저 로드되어야 `window.PcsPagination`을 사용할 수 있다.
- `pcs-ui.js`가 먼저 로드되어야 `window.PcsUi.toast()`를 사용할 수 있다.
- `pcs-common.js`는 `pcs-ui.js` 뒤, 화면별 JS 앞에 둔다.
- 화면별 JS는 항상 공통 JS 뒤에 둔다.

## 공통 JS 사용

화면별 JS에서 아래 기능을 다시 만들지 않는다.

```js
window.PcsWorkspace.getCompanyCode()
window.PcsWorkspace.updateWorkspaceLinks(companyCode)
window.PcsFormat.date(value)
window.PcsFormat.number(value)
window.PcsFormat.money(value)
window.PcsFeedback.toast(message, type)
window.PcsForm.setSaving(form, isSaving)
window.PcsTable.clearRows(table)
window.PcsTable.textCell(label, text, tagName)
window.PcsTable.emptyRow(table, options)
window.PcsDrawer.bindOutsideClose(options)
```

기준:

- 업체 코드 추출 정규식은 화면별 JS에 반복 작성하지 않는다.
- 날짜/숫자/금액 포맷은 `PcsFormat`을 사용한다.
- 저장 중 폼 비활성화는 `PcsForm.setSaving()`을 사용한다.
- 빈 목록/로딩/오류 행은 `PcsTable.emptyRow()`를 우선 사용한다.
- 관리형 작업 드로어의 외부 클릭 닫기는 `PcsDrawer.bindOutsideClose()`를 사용한다.
- 다른 목록 행, 드로어를 여는 버튼, 연결된 모달처럼 닫기에서 제외할 요소는 `keepOpenSelector`로 지정한다.
- 화면별 JS는 도메인별 렌더링, 이벤트 연결, API URL 조립에 집중한다.

## 관리형 페이지 JS 기준

품목 관리, 품목 분류, 거래처 관리, 사용자 관리처럼 검색/목록/등록/수정 패널을 함께 쓰는 화면은 같은 JS 흐름을 따른다.

기준:

- 업체 코드 추출은 `window.PcsWorkspace.getCompanyCode()`를 사용한다.
- 날짜/숫자 포맷은 `window.PcsFormat`을 사용한다.
- 토스트는 `window.PcsFeedback.toast()`를 사용한다.
- 저장 중 폼 상태는 `window.PcsForm.setSaving()`을 사용한다.
- 빈 목록, 로딩, 오류 행은 `window.PcsTable.emptyRow()`를 사용한다.
- 텍스트 셀 생성은 `window.PcsTable.textCell()`을 우선 사용한다.
- 관리형 작업 드로어의 외부 클릭 처리는 `window.PcsDrawer.bindOutsideClose()`를 사용한다.
- 화면별 JS에는 해당 화면의 API URL, 폼 값 읽기, 행 렌더링, 이벤트 연결만 남긴다.

금지:

```js
const getCompanyCode = () => { ... };
const showToast = (message, type) => { window.PcsUi.toast(...); };
const setFormSaving = (form, isSaving) => { form.querySelectorAll(...); };
```

허용:

```js
const getCompanyCode = window.PcsWorkspace.getCompanyCode;
const showToast = window.PcsFeedback.toast;
const setFormSaving = window.PcsForm.setSaving;
const setEmptyMessage = (message) => window.PcsTable.emptyRow(table, { message });
```

공통 함수 사용 후 특정 화면만 후처리가 필요하면 얇은 래퍼만 둔다.

```js
const setFormSaving = (form, isSaving, text = "저장 중") => {
    window.PcsForm.setSaving(form, isSaving, text);
    if (!isSaving && form === editForm) {
        renderEditSpecs();
    }
};
```

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
- 등록/수정 API 호출 중에는 해당 폼의 입력과 버튼을 비활성화해 중복 제출을 막는다.
- 성공/실패 피드백은 브라우저 `alert()`가 아니라 `window.PcsUi.toast()`를 사용한다.
- 저장 성공 후에는 현재 화면의 목록, 선택값, 요약, 상세 패널을 실제 API 응답 기준으로 갱신한다.
- 저장 실패 시에는 화면을 임의 성공 상태로 바꾸지 않고 오류 토스트를 보여준다.

사용:

```js
window.PcsUi.toast({
    message: "저장했습니다.",
    type: "success"
});
```

금지:

```js
alert("저장되었습니다.");
```
