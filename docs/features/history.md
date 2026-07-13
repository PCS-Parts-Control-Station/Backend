# History Feature

## 목적

입출고 이력 화면과 검수 이력 화면에서 사용하는 현재 구현 기준의 조회 흐름을 정리한다.

현재 별도 `history` 도메인 API는 두지 않는다. 이력 화면은 재고 도메인과 검수 도메인의 조회 API를 조합해 구성한다.

## 패키지

```text
com.pcs.domain.stock
com.pcs.domain.inspection
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/stock/documents` | 입출고 전표 목록. `documentType`, `keyword`, `partnerId`, `documentStatus`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` | 입출고 전표 상세 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}/movements` | 전표의 품목별 재고 변화 라인 |
| GET | `/api/workspaces/{companyCode}/stock/movements` | 입출고 재고 변화 라인 목록 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}` | 입출고 재고 변화 라인 상세 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}/units` | 라인에 포함된 개별 부품 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` | 검수 이력 전표 목록 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록. `documentId`, `unitId`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |

입출고 이력 상세 규칙은 `docs/features/stock.md`를 따른다.

검수 이력 화면과 전표 기준 검수 이력 조회 규칙은 `docs/features/inspection-history.md`를 따른다.

## 화면

입출고 이력:

```text
src/main/resources/static/history-stock.html
src/main/resources/static/css/history-stock.css
src/main/resources/static/js/history-stock.js
```

검수 이력:

```text
src/main/resources/static/history-inspection.html
src/main/resources/static/css/history-inspection.css
src/main/resources/static/js/history-inspection.js
```

## 입출고 이력 화면

입출고 이력 화면은 입고와 출고 전표를 한 화면에서 조회한다.

화면 기준:

- 상단에는 기간, 구분, 상태, 검색어 필터를 배치한다.
- 전표 목록은 전표 번호, 구분, 거래처, 내용, 수량, 상태, 처리일을 비교할 수 있게 표시한다.
- 전표 행 전체를 클릭하면 오른쪽 상세 슬라이드 패널을 연다.
- 상세 슬라이드 패널은 배경 오버레이를 사용하지 않고, 열린 상태에서도 다른 전표 행을 바로 클릭할 수 있다.
- 전표 행과 패널 내부를 제외한 영역을 클릭하면 상세 슬라이드 패널을 닫는다.
- 전표 상세는 품목 요약을 우선 보여주고, 개별 관리번호 목록은 기본 접힘 상태로 둔다.
- 개별 관리번호 목록은 품목별로 한 번 더 구분해 긴 목록의 가독성을 유지한다.
- 상세 패널의 `부품 관리` 버튼은 `/w/{companyCode}/part-units?documentId={documentId}&documentNo={documentNo}&partState={partState}`로 이동한다. 입고 전표는 `partState=HELD`, 출고 전표는 `partState=OUTBOUND`를 사용한다. 취소된 입고 전표는 `partState=CANCELED`, 취소된 출고 전표는 재고 복원 상태 기준으로 `partState=HELD`를 사용한다.

입출고 이력 화면은 `GET /stock/documents`와 `GET /stock/documents/{documentId}`를 사용한다. 별도 `/history/stock-documents` API를 호출하지 않는다.

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
- 입출고 원본 전표와 검수 원본 이력은 수정/삭제하지 않고 취소, 정정, 재검수 같은 별도 이력으로 보존한다.
- 입출고 전표 목록과 요약은 취소 movement를 원본 수량 집계에 포함하지 않는다.
- 검수 이력의 실제 row는 관리번호 단위 `tb_inspection` 기록이며, 전표 목록은 `documentId` 기준 집계 결과다.

## 하네스 포인트

- 입출고 이력은 현재 `stock` 도메인 API 기준으로 검증한다.
- 검수 이력은 현재 `inspection` 도메인 API 기준으로 검증한다.
- 구현되지 않은 `/history/*` API를 하네스 기준으로 삼지 않는다.
- 전표 목록에는 기간 필터와 페이징이 있어야 한다.
- 반복 쿼리보다 JOIN 또는 명확한 SQL 집계를 우선한다.
- 이력 조회 조건은 가능하면 SQL 조건으로 필터링한다.
