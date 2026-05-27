# PCS Pagination Rules

목록 API와 정적 JS 화면에서 같은 페이징 구조를 쓰기 위한 기준이다.

## Backend

목록 API 응답은 `ApiResultDto<PageResultDto<T, S>>`를 기본으로 한다.

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "요청이 정상 처리되었습니다.",
  "data": {
    "content": [],
    "page": 0,
    "size": 20,
    "totalElements": 0,
    "totalPages": 0,
    "hasPrevious": false,
    "hasNext": false,
    "summary": null
  }
}
```

기준:

- `page`는 0부터 시작한다.
- `size` 기본값은 20이다.
- `size` 최대값은 100이다.
- 실제 목록 배열 필드명은 `content`를 사용한다.
- 목록 화면에 요약 숫자가 필요하면 `summary`에 넣는다.
- 기존 단순 선택 목록 호환이 필요하면 `limit`을 `size` 별칭으로 받을 수 있다.
- SQL은 `COUNT(*)`와 `LIMIT/OFFSET`을 분리해서 처리한다.
- 정렬 기준은 API마다 명확히 고정한다.

## Frontend

정적 업무 화면에서 페이징 API를 호출할 때는 `/js/pcs-pagination.js`를 사용한다.

HTML:

```html
<script src="/js/pcs-api.js"></script>
<script src="/js/pcs-pagination.js"></script>
<script src="/js/{page}.js"></script>
```

JS:

```js
const params = PcsPagination.buildParams({
    page,
    size: 20,
    form: filterForm
});

const data = await PcsApi.getData(`/api/workspaces/${companyCode}/parts?${params.toString()}`);
const pageData = PcsPagination.normalizePageData(data, 20);

PcsPagination.updateControls({
    pageData,
    container: pagination,
    info: pageInfo,
    prevButton,
    nextButton
});
```

기준:

- 직접 `new URLSearchParams()`를 반복 작성하지 않는다.
- 직접 `page + 1 / totalPages` 문구를 반복 작성하지 않는다.
- 이전/다음 버튼 disabled 처리는 `PcsPagination.updateControls()`를 사용한다.
- 페이지 이동으로 목록 높이가 바뀌어도 사용자가 보던 위치를 유지해야 하면 `PcsPagination.withPreservedScroll()`을 사용한다.
- 검색 버튼으로 새 조건을 조회할 때는 `page = 0`부터 다시 조회한다.
- 다음 페이지는 `currentPage + 1`, 이전 페이지는 `currentPage - 1`로 이동하되 `currentPage > 0`일 때만 이전 이동한다.

## 화면 표시

- 페이지 정보는 테이블 하단에 둔다.
- 문구는 `현재 페이지 / 전체 페이지 · 총 N건` 형식을 사용한다.
- 페이지가 1개 이하이면 페이지 이동 영역은 숨긴다.
- 페이징 버튼은 `이전`, `다음`을 기본으로 한다.
