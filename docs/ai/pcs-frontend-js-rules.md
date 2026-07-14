# PCS Frontend JS Rules

정적 HTML 화면의 JavaScript 공통 계약입니다. 인증 호출은 [Auth Client Rules](pcs-auth-client-rules.md), paging은 [Pagination Rules](pcs-pagination-rules.md), 목록 상태 복원은 [Navigation State Guide](pcs-navigation-state-guide.md)를 따릅니다.

## 기본 원칙

- HTML은 정적 파일이며 화면 JS가 REST API로 데이터를 가져옵니다.
- 화면별 JS는 해당 화면의 API URL, 렌더링, 이벤트 연결만 담당합니다.
- 인증·업체 코드·날짜·toast·paging·drawer 동작을 화면별로 다시 구현하지 않습니다.
- 데이터 변경 성공 전에는 화면을 성공 상태로 먼저 바꾸지 않습니다.

## 로드 순서

필요한 파일만 다음 순서로 로드합니다.

```html
<script src="/js/pcs-api.js"></script>
<script src="/js/pcs-pagination.js"></script>
<script src="/js/pcs-ui.js"></script>
<script src="/js/pcs-common.js"></script>
<script src="/js/pcs-navigation-state.js"></script>
<script src="/js/{page}.js"></script>
```

- `pcs-api.js`는 인증 API 호출보다 먼저 둡니다.
- `pcs-pagination.js`는 paging 화면에서만 포함합니다.
- `pcs-ui.js`는 feedback을 쓰는 화면에서 `pcs-common.js`보다 먼저 둡니다.
- `pcs-navigation-state.js`는 목록 상태 복원이 필요한 화면에서만 포함합니다.
- 화면별 JS는 항상 마지막에 둡니다.

## 공통 API

| 목적 | API |
|---|---|
| 업체 코드·링크 | `PcsWorkspace.getCompanyCode()`, `updateWorkspaceLinks()` |
| 날짜·숫자 표시 | `PcsFormat.date()`, `PcsFormat.number()` |
| HTML escape | `PcsHtml.escape()` |
| toast | `PcsFeedback.toast()` 또는 `PcsUi.toast()` |
| 저장 중 잠금 | `PcsForm.setSaving()` |
| table 상태·cell | `PcsTable.clearRows()`, `textCell()`, `emptyRow()` |
| drawer 닫기 | `PcsDrawer.bindDismiss()` |
| URL 기반 목록 상태 | `PcsNavigationState.createUrlStateController()` |

공통 함수로 처리할 수 없는 화면별 후처리만 얇은 wrapper로 추가합니다.

## API 호출

인증 API는 `PcsApi`를 사용합니다.

```js
const data = await window.PcsApi.getData(url, {
    authRedirect: true,
    loginCompanyCode: companyCode
});
```

인증이 필요한 화면에서 직접 `fetch()`로 토큰·재발급·오류 계약을 재구현하지 않습니다. 공개 로그인·가입처럼 인증 공통 처리가 불필요한 요청만 직접 호출할 수 있습니다.

## 관리 화면 흐름

품목, 분류, 거래처, 사용자 같은 목록·등록·수정 화면은 다음 흐름을 공유합니다.

1. `PcsWorkspace`로 업체 코드를 확인합니다.
2. 목록은 loading/empty/error 상태를 명시합니다.
3. 행 선택 시 상세 또는 편집 drawer를 엽니다.
4. 저장 중에는 `PcsForm.setSaving()`으로 중복 제출을 막습니다.
5. 성공 시 실제 응답으로 목록·선택·요약을 갱신하고 toast를 표시합니다.
6. 실패 시 이전 화면 상태를 유지하고 오류 toast를 표시합니다.

drawer의 외부 클릭, Escape, 행 전환 규칙은 [Side Drawer](design/side-drawer.md)가 소유합니다. 화면별 예외만 기능 또는 디자인 문서에 기록합니다.

## DOM과 보안

- 필요한 영역만 다시 렌더링합니다.
- 데이터 기반 요소는 `document.createElement()`와 `textContent`를 우선합니다.
- 사용자·API 문자열을 `innerHTML`에 직접 넣지 않습니다.
- 문자열 템플릿이 꼭 필요하면 공통 escape를 적용합니다.
- access token을 `localStorage`에 저장하지 않습니다.
- inline script, 외부 이미지·폰트 추가는 CSP 정책과 함께 검토합니다.
- `alert()` 대신 공통 toast를 사용합니다.

## 입력과 상태

- required와 optional 입력을 화면에서 구분합니다.
- 업무 입력을 방해하는 브라우저 자동완성은 적절한 `autocomplete` 값으로 제어합니다.
- 저장 중 관련 입력과 버튼을 비활성화합니다.
- 저장 성공 후에만 form, 목록, 선택 상태를 갱신합니다.
- 목록 화면의 query, page, 선택 행, scroll 복원은 `PcsNavigationState`를 사용합니다.

## 완료 기준

- 공통 JS 로드 순서와 API를 재사용합니다.
- 인증 API를 `PcsApi`로 호출합니다.
- loading/empty/error/success 상태가 구분됩니다.
- XSS 위험이 있는 HTML 조립과 로컬 토큰 저장이 없습니다.
- 저장 중 중복 제출이 차단되고 실패 상태가 보존됩니다.
