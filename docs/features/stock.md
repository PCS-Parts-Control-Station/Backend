# Stock Feature

## 목적

입고·출고 전표, 품목별 movement, 개별 관리번호 매핑, 취소와 현재 재고 변경을 담당한다.

## 패키지

```text
com.pcs.domain.stock
```

## API

| Method | API |
|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` |
| GET | `/api/workspaces/{companyCode}/stock/outbound-candidates` |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` |
| GET | `/api/workspaces/{companyCode}/stock/documents` |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` |

movement와 movement unit은 전표 처리·취소 및 전표 상세 응답을 위한 내부 저장 모델이다. 별도 movement 조회 API는 현재 제공하지 않는다.

## 전표 목록

조건:

```text
documentType, keyword, partnerId, documentStatus,
dateFrom, dateTo, page, size, limit
```

- dateTo는 다음 날 00:00 미만 반열린 범위로 처리한다.
- 정렬은 `document_id DESC`다.
- 응답은 `PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse>`다.
- summary는 totalCount, totalQuantity, waitingQuantity, canceledCount를 제공한다.
- totalQuantity는 검색 조건에 맞는 원본 movement 수량이며 취소 movement를 중복 합산하지 않는다.

## 전표 상세

전표 header와 line, line별 unit을 한 응답에 제공한다.

주요 필드:

```text
documentId, documentNo, documentType, documentStatus
partnerId, partnerName, reason, processedByName
lineCount, totalQuantity, cancelable, cancelBlockedReason
lines[].units[]
```

취소 가능 여부와 불가 사유는 서버가 계산한다.

## 입고

화면:

```text
static/inbound-register.html
static/css/pages/inbound-register.css
static/js/inbound-register.js
```

흐름은 `design/operation-flow.md`를 따른다.

1. 공급 거래처와 입고 사유
2. 분류·품목 검색
3. 품목별 수량·사유
4. 라인 검토
5. 저장 후 수량만큼 관리번호 생성

- 전표 번호는 `IN-YYYYMMDD-RANDOM16`으로 서버가 발급한다.
- 새 unit은 재고 보유, 검수 대기, 판매 보류로 시작한다.
- 빠른 품목 등록은 현재 전표 입력을 유지하는 최소 모달로 제공할 수 있다.

화면 상태 복원:

- 공통 `PcsNavigationState`를 사용해 `keyword`, `partnerId`, `documentType`, `documentStatus`, `dateFrom`, `dateTo`, `page`, 선택된 `documentId`를 URL query에 저장한다.
- 전표 상세의 검수 또는 부품 관리 화면으로 이동했다가 브라우저 뒤로가기로 돌아오면 검색 조건, 페이지, 선택된 상세 슬라이드, 가능한 스크롤 위치를 복원한다.
- 다른 화면에서 전달한 `documentNo` 딥링크는 최초 검색어로 적용하고, 사용자가 검색 조건을 변경하거나 초기화하면 URL에서 제거한다.
- 스크롤 위치는 공통 유틸의 `history.state`에 저장하며 별도 `sessionStorage`, `localStorage`, 화면 전용 복원 저장소를 만들지 않는다.

입고/출고 전표 상세는 품목별 상세 행을 길게 펼치기보다 품목별 수량 요약을 우선 보여준다. 관리번호 전체 목록은 상세 조회나 확장 영역에서 확인한다.

## 출고

출고 등록은 고객 거래처를 선택하고 실제 관리번호를 고른다. 품목 수량만 입력하지 않는다.

출고 후보 조건:

```text
active=true
unit_status=IN_STOCK
inspection_status=COMPLETED
sales_status=AVAILABLE
grade!=DEFECTIVE
```

검색 조건은 keyword, categoryId, partId, grade, page/size/limit다.

요청:

```json
{
  "partnerId": 2,
  "reason": "판매 출고",
  "lines": [{"partId": 10, "unitIds": [101, 102], "reason": "CPU 출고"}]
}
```

- 전표 번호는 `OUT-YYYYMMDD-RANDOM16`으로 서버가 발급한다.
- 부품 상세 딥링크의 unitId, partId, categoryId, keyword를 초기 선택에 사용한다.

## 전표 통합 조회 화면

```text
static/documents.html
static/css/pages/documents.css
static/js/documents.js
```

- `/inbound`, `/outbound` 목록 경로는 documentType 조건과 함께 이 화면으로 연결한다.
- 검색·목록은 `design/data-table.md`, 상세는 `design/side-drawer.md`를 따른다.
- 취소는 상세 하단에서 시작하고 확인 모달에서 최종 실행한다.
- 부품 관리 이동은 documentId/documentNo와 다음 partState를 전달한다.

| 전표 | partState |
|---|---|
| 완료 입고 | HELD |
| 완료 출고 | OUTBOUND |
| 취소 입고 | CANCELED |
| 취소 출고 | HELD |

## 저장 모델

- document: 거래처와 연결된 전표 header
- movement: 전표의 품목별 재고 변화
- movement unit: movement에 포함된 관리번호와 상태 전후
- 원본은 수정·삭제하지 않고 취소 이력을 추가한다.
- 관리번호 통합 조회는 `part-unit.md`가 담당한다.

## 취소

공통:

```text
원본 document.status = CANCELED
원본 movement.status = CANCELED
반대 movement.status = COMPLETED
반대 movement.canceledMovementId = 원본 movementId
```

입고 취소 가능:

- 아직 취소되지 않음
- 모든 unit이 active, IN_STOCK, inspection WAITING, sales HOLD

입고 취소 결과:

- INBOUND_CANCEL movement와 unit 이력 추가
- unit IN_STOCK → CANCELED, active=false
- part stock 감소

출고 취소 가능:

- 아직 취소되지 않음
- 모든 unit이 active, OUTBOUND

출고 취소 결과:

- OUTBOUND_CANCEL movement와 unit 이력 추가
- unit OUTBOUND → IN_STOCK
- part stock 증가

모든 취소 movement는 before/after quantity와 unit 상태 전후를 저장한다.

## 트랜잭션과 동시성

- 전표, movement, unit mapping, unit 상태, part stock은 한 Facade 트랜잭션이다.
- 출고 재고 차감에는 DB 동시성 전략이 필요하다.
- 완료 시 `tb_part_stock.quantity`와 활성 IN_STOCK unit 수가 일치해야 한다.
- DB 계약은 `stock-db.md`를 따른다.

## 테스트 수용 기준

- `StockServiceTest`, `StockFacadeTest`, `StockApiControllerTest`
- 입고·출고·취소 상태, 중복 unit, 재고 부족을 검증한다.
- 목록 필터, summary, 등록 validation을 검증한다.
- STAFF 입고·출고 권한 차단을 검증한다.
- 중간 실패에서 모든 변경이 롤백된다.
