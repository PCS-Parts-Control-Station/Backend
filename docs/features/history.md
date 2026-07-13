# History Feature

## 목적

검수 이력 화면에서 사용하는 현재 구현 기준의 조회 흐름을 정리한다. 입출고 전표 조회는 `docs/features/stock.md`의 전표 통합 조회로 통합한다.

현재 별도 `history` 도메인 API는 두지 않는다. 이력 화면은 재고 도메인과 검수 도메인의 조회 API를 조합해 구성한다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` | 검수 이력 전표 목록 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록. `documentId`, `unitId`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |

검수 이력 화면과 전표 기준 검수 이력 조회 규칙은 `docs/features/inspection-history.md`를 따른다.

## 화면

검수 이력:

```text
src/main/resources/static/history-inspection.html
src/main/resources/static/css/history-inspection.css
src/main/resources/static/js/history-inspection.js
```

## 검수 이력 화면

검수 이력 화면은 전표 기준 목록에서 시작해 관리번호 단위 상세 이력으로 내려간다.

화면 기준:

- 상단에는 기간, 이력 유형, 검색어 필터를 배치한다.
- 전표 목록은 전표 기준 집계 결과를 보여준다.
- 전표를 선택하면 전표 상세 영역에 품목 묶음과 관리번호 목록을 표시한다.
- 품목 묶음은 왼쪽, 관리번호 목록은 오른쪽에 배치한다.
- 관리번호 행을 클릭하면 오른쪽 상세 슬라이드 패널에서 검수 이력 타임라인과 항목별 결과를 확인한다.
- 관리번호 행과 패널 내부를 제외한 영역을 클릭하면 상세 슬라이드 패널을 닫는다.

검수 이력 화면은 `GET /inspections/history-documents`, `GET /inspections?documentId=...`, `GET /inspections/{inspectionId}`를 사용한다. 다른 화면에서 `documentId`, `partId`, `unitId`, `inspectionId` query로 진입하면 전표, 품목 묶음, 관리번호, 상세 패널 선택 상태를 복원한다. 별도 `/history/inspections` API를 호출하지 않는다.

## 주요 규칙

- 이력 화면은 조회 중심 화면이다.
- 조회 상세는 모달보다 오른쪽 논블로킹 슬라이드 패널을 우선한다.
- 슬라이드 패널은 목록 조작을 막지 않는다.
- 슬라이드 패널은 배경 오버레이를 사용하지 않고, 행 또는 패널 내부가 아닌 영역을 클릭하면 닫는다.
- 검수 원본 이력은 수정/삭제하지 않고 정정, 재검수 같은 별도 이력으로 보존한다.
- 검수 이력의 실제 row는 관리번호 단위 `tb_inspection` 기록이며, 전표 목록은 `documentId` 기준 집계 결과다.

## 하네스 포인트

- 검수 이력은 현재 `inspection` 도메인 API 기준으로 검증한다.
- 구현되지 않은 `/history/*` API를 하네스 기준으로 삼지 않는다.
- 전표 목록에는 기간 필터와 페이징이 있어야 한다.
- 반복 쿼리보다 JOIN 또는 명확한 SQL 집계를 우선한다.
- 이력 조회 조건은 가능하면 SQL 조건으로 필터링한다.
