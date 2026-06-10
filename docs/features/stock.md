# Stock Feature

## 목적

입고/출고 전표, 부품별 재고 변화 라인, 개별 부품 입출고 매핑, 입출고 취소를 담당한다.

## 패키지

```text
com.pcs.domain.stock
```

## API

| Method | API | 설명 |
|---|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` | 입고 전표 등록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` | 출고 전표 등록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` | 입출고 전표 취소 |
| GET | `/api/workspaces/{companyCode}/stock/documents` | 입출고 전표 목록 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` | 입출고 전표 상세 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}/movements` | 전표의 부품별 재고 변화 라인 |
| GET | `/api/workspaces/{companyCode}/stock/movements` | 입출고 재고 변화 라인 목록 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}` | 입출고 재고 변화 라인 상세 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}/units` | 라인에 포함된 개별 부품 목록 |

## 전표 목록

`GET /api/workspaces/{companyCode}/stock/documents`

Query:

| 이름 | 설명 |
|---|---|
| `documentType` | `INBOUND`, `OUTBOUND` |
| `keyword` | 전표번호, 거래처명, 품목명, 모델명, 품목코드 검색 |
| `partnerId` | 거래처 필터 |
| `documentStatus` | `COMPLETED`, `CANCELED` |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | 기존 단순 목록 호환용 size 별칭 |

응답은 `PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse>` 구조를 사용한다.

목록 정렬은 `document_id DESC` 기준이다. 전표번호는 긴 랜덤 식별자를 포함하므로 정렬 기준으로 쓰지 않는다.

요약 필드:

| 이름 | 설명 |
|---|---|
| `totalCount` | 조회 조건에 맞는 전표 수 |
| `totalQuantity` | 조회 조건에 맞는 원본 movement 수량 합계 |
| `waitingQuantity` | `IN_STOCK`, `WAITING`, `active=true` 개별 부품 수 |
| `canceledCount` | 취소 전표 수 |

## 전표 상세

`GET /api/workspaces/{companyCode}/stock/documents/{documentId}`

상세 응답은 전표 헤더, 부품 라인, 라인별 개별 부품 목록을 한 번에 내려준다.

주요 필드:

| 이름 | 설명 |
|---|---|
| `documentId` | 내부 식별자 |
| `documentNo` | 사용자 확인용 전표번호 |
| `documentType` | `INBOUND`, `OUTBOUND` |
| `documentStatus` | `COMPLETED`, `CANCELED` |
| `partnerId`, `partnerName` | 거래처 정보 |
| `reason` | 전표 사유 |
| `processedByName` | 처리자 이름 |
| `lineCount`, `totalQuantity` | 라인 수와 총 수량 |
| `cancelable` | 현재 취소 가능 여부 |
| `cancelBlockedReason` | 취소 불가 사유 |
| `lines` | 부품별 movement 목록 |
| `lines[].units` | movement에 포함된 개별 부품 목록 |

## 주요 규칙

- `tb_stock_document`는 거래처와 연결된 입출고 전표 헤더다.
- 입고 전표번호는 서버가 `IN-YYYYMMDD-RANDOM16` 형식으로 자동 발급하고, 내부 정렬은 `document_id`를 사용한다.
- `tb_stock_movement`는 전표 안의 부품별 재고 변화 라인이다.
- `tb_stock_movement_unit`은 재고 변화 라인에 포함된 개별 부품 목록이다.
- 입출고 원본은 수정/삭제하지 않고 취소 이력으로 처리한다.
- 출고 시 검수 완료, 불량 아님, 판매 가능, 재고 보유 상태를 검증한다.

## 취소 규칙

```text
원본 document:
document_status = CANCELED

원본 movement:
movement_status = CANCELED

취소 movement:
movement_type = INBOUND_CANCEL 또는 OUTBOUND_CANCEL
movement_status = COMPLETED
canceled_movement_id = 원본 movement_id
```

입고 전표 취소 가능 조건:

- 전표가 `CANCELED` 상태가 아니어야 한다.
- 현재 입고 관리 화면에서는 `document_type = INBOUND` 전표만 취소한다.
- 원본 입고 movement의 개별 부품이 모두 `unit_status = IN_STOCK`이어야 한다.
- 원본 입고 movement의 개별 부품이 모두 `inspection_status = WAITING`이어야 한다.
- 원본 입고 movement의 개별 부품이 모두 `sales_status = HOLD`이어야 한다.
- 원본 입고 movement의 개별 부품이 모두 `active = true`여야 한다.

입고 전표 취소 처리:

- 원본 document의 `document_status`를 `CANCELED`로 변경한다.
- 원본 movement의 `movement_status`를 `CANCELED`로 변경한다.
- 원본 movement마다 `INBOUND_CANCEL` movement를 추가한다.
- 취소 movement의 `before_quantity`, `after_quantity`를 저장한다.
- 원본 movement에 연결된 개별 부품은 취소 movement에도 매핑한다.
- 취소 movement unit 이력은 `before_unit_status = IN_STOCK`, `after_unit_status = CANCELED`로 저장한다.
- 개별 부품은 `unit_status = CANCELED`, `active = false`로 변경한다.
- `tb_part_stock.quantity`는 취소 수량만큼 차감한다.

## 하네스 포인트

- 재고 변경과 이력 저장은 같은 트랜잭션이어야 한다.
- `beforeQuantity`와 `afterQuantity`를 저장해야 한다.
- 출고 재고 차감에는 DB 동시성 전략이 필요하다.
- `tb_part_stock.quantity`와 `IN_STOCK` unit 수량 정합성을 검증해야 한다.
