# PCS Pagination Rules

목록 API와 정적 JS 화면에서 같은 페이징 구조를 쓰기 위한 기준이다.

## Backend

공통 응답 형식은 `docs/ai/pcs-backend-common-rules.md`를 따른다.  
목록 API의 `data`는 `PageResultDto<T, S>` 구조를 기본으로 한다.

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
- 화면 JS는 목록마다 명시적인 `PAGE_SIZE`를 정하고 API에 `size`를 보낸다.
- 서버 fallback 기본값은 기능별로 다를 수 있으나, 별도 기준이 없으면 10을 사용한다.
- `size` 최대값은 100이다.
- 실제 목록 배열 필드명은 `content`를 사용한다.
- 목록 화면에 요약 숫자가 필요하면 `summary`에 넣는다.
- 기존 단순 선택 목록 호환이 필요하면 `limit`을 `size` 별칭으로 받을 수 있다.
- SQL은 `COUNT(*)`와 `LIMIT/OFFSET`을 분리해서 처리한다.
- 정렬 기준은 API마다 명확히 고정한다.
- `page`, `size`, `limit`, `offset` 계산은 `com.pcs.global.pagination.PageQuery`를 사용한다.
- Service별 `normalizePage`, `normalizeSize`를 새로 만들지 않는다.
- 비정상적으로 큰 `page` 값으로 offset 정수 오버플로가 발생하면 안 된다.

대용량 이력 목록 기준:

- 입출고 전표, 검수 이력, 상태 변경 이력처럼 계속 누적되는 API는 기본 목록에서는 기간 필터를 제공한다.
- 운영 데이터가 커질 수 있는 API를 새로 만들 때는 `LIMIT/OFFSET`만 전제로 설계하지 않는다.
- 깊은 페이지 탐색이 필요한 이력 API는 `cursor`, `lastId`, `lastCreatedAt` 같은 no-offset 페이징을 별도 API 계약으로 검토한다.
- 관리형 마스터 목록(품목, 품목 분류, 거래처, 사용자)은 검색 조건과 page size 제한이 있는 현재 `PageResultDto` 구조를 기본으로 유지할 수 있다.

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
const PAGE_SIZE = 10;

const params = PcsPagination.buildParams({
    page,
    size: PAGE_SIZE,
    form: filterForm
});

const data = await PcsApi.getData(`/api/workspaces/${companyCode}/parts?${params.toString()}`);
const pageData = PcsPagination.normalizePageData(data, PAGE_SIZE);

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
- 화면별 JS에는 `const PAGE_SIZE = N`을 명시하고, `buildParams`와 `normalizePageData`에 같은 값을 넘긴다.
- 검색 버튼으로 새 조건을 조회할 때는 `page = 0`부터 다시 조회한다.
- 다음 페이지는 `currentPage + 1`, 이전 페이지는 `currentPage - 1`로 이동하되 `currentPage > 0`일 때만 이전 이동한다.

## 화면 표시

- 페이지 정보는 테이블 하단에 둔다.
- 문구는 `현재 페이지 / 전체 페이지 · 총 N건` 형식을 사용한다.
- 페이지가 1개 이하이면 페이지 이동 영역은 숨긴다.
- 페이징 버튼은 `이전`, `다음`을 기본으로 한다.
