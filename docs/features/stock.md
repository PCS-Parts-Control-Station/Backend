# Stock Feature

## 목적

입고/출고 전표, 품목별 재고 변화 라인, 개별 부품 입출고 매핑, 입출고 취소를 담당한다.

## 패키지

```text
com.pcs.domain.stock
```

## API

| Method | API | 설명 |
|---|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` | 입고 전표 등록 |
| GET | `/api/workspaces/{companyCode}/stock/outbound-candidates` | 출고 가능한 관리번호 목록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` | 출고 전표 등록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` | 입출고 전표 취소 |
| GET | `/api/workspaces/{companyCode}/stock/documents` | 입출고 전표 목록 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` | 입출고 전표 상세 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}/movements` | 전표의 품목별 재고 변화 라인 |
| GET | `/api/workspaces/{companyCode}/stock/movements` | 입출고 재고 변화 라인 목록 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}` | 입출고 재고 변화 라인 상세 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}/units` | 라인에 포함된 개별 부품 목록 |

## 전표 목록

`GET /api/workspaces/{companyCode}/stock/documents`

Query:

| 이름 | 설명 |
|---|---|
| `documentType` | `INBOUND`, `OUTBOUND` |
| `keyword` | 전표 번호, 거래처명, 품목명, 모델명, 품목코드 검색 |
| `partnerId` | 거래처 필터 |
| `documentStatus` | `COMPLETED`, `CANCELED` |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | 기존 단순 목록 호환용 size 별칭 |

응답은 `PageResultDto<SearchStockDocumentResponse, SearchStockDocumentSummaryResponse>` 구조를 사용한다.

목록 정렬은 `document_id DESC` 기준이다. 전표 번호는 긴 랜덤 식별자를 포함하므로 정렬 기준으로 쓰지 않는다.

요약 필드:

| 이름 | 설명 |
|---|---|
| `totalCount` | 조회 조건에 맞는 전표 수 |
| `totalQuantity` | 조회 조건에 맞는 원본 movement 수량 합계 |
| `waitingQuantity` | `IN_STOCK`, `WAITING`, `active=true` 개별 부품 수 |
| `canceledCount` | 취소 전표 수 |

## 전표 상세

`GET /api/workspaces/{companyCode}/stock/documents/{documentId}`

상세 응답은 전표 헤더, 품목별 재고 변화 라인, 라인별 개별 부품 목록을 한 번에 내려준다.

주요 필드:

| 이름 | 설명 |
|---|---|
| `documentId` | 내부 식별자 |
| `documentNo` | 사용자 확인용 전표 번호 |
| `documentType` | `INBOUND`, `OUTBOUND` |
| `documentStatus` | `COMPLETED`, `CANCELED` |
| `partnerId`, `partnerName` | 거래처 정보 |
| `reason` | 전표 사유 |
| `processedByName` | 처리자 이름 |
| `lineCount`, `totalQuantity` | 라인 수와 총 수량 |
| `cancelable` | 현재 취소 가능 여부 |
| `cancelBlockedReason` | 취소 불가 사유 |
| `lines` | 품목별 movement 목록 |
| `lines[].units` | movement에 포함된 개별 부품 목록 |

## 입고 등록 화면

```text
src/main/resources/static/inbound-register.html
src/main/resources/static/css/pages/inbound.css
src/main/resources/static/css/pages/inbound-register.css
src/main/resources/static/js/inbound-register.js
```

입고 등록 화면은 거래처와 입고 사유를 입력한 뒤, 품목을 검색해 입고 품목으로 추가하고 전표를 저장한다.

화면 흐름:

1. 전표 기본 정보 입력
2. 품목 검색과 품목 분류 필터
3. 선택한 품목에 수량과 품목 사유 입력
4. 입고 품목 목록 검토
5. 저장 후 관리번호 생성

화면 문구 기준:

- 사용자 화면에서는 `품목 검색`, `입고 품목`, `품목 추가`, `품목 사유`를 사용한다.
- DB와 API 설명에서는 기존 `stock movement`, `line` 용어를 사용할 수 있다.
- 거래처는 긴 셀렉트 박스보다 검색 모달에서 선택하는 방식을 우선한다.
- 거래처 선택 버튼은 왼쪽에 `선택`, 오른쪽에 현재 선택 상태 또는 `거래처 선택`을 표시한다.
- 품목 분류는 배지보다 일반 텍스트에 가깝게 표시해 목록 가독성을 우선한다.
- 품목 추가 후에는 선택한 품목, 수량, 품목 사유 입력 상태를 초기화한다.

## 전표 통합 조회 화면

```text
src/main/resources/static/documents.html
src/main/resources/static/css/pages/documents.css
src/main/resources/static/js/documents.js
```

전표 통합 조회는 입고 전표와 출고 전표를 한 화면에서 조회하고 취소하는 관리 화면이다. 기존 `/w/{companyCode}/inbound`, `/w/{companyCode}/outbound` 경로는 전표 통합 조회로 이동하며, `documentType` 조건을 붙여 각각 입고 또는 출고 전표를 먼저 보여준다.

화면 기준:

- 상단에는 검색, 필터, 요약 정보를 간결하게 배치한다.
- 거래처 조건은 검색 모달에서 선택한다.
- 전표 목록은 구분, 전표번호, 거래처/내용, 수량, 상태, 처리일을 한 행에서 비교할 수 있게 표시한다.
- 전표 행 전체를 클릭해 상세를 연다.
- 선택된 전표 행은 배경색과 왼쪽 강조선으로 구분한다.
- 전표 상세는 오른쪽 논블로킹 슬라이드 패널로 연다.
- 상세 슬라이드는 배경 오버레이를 사용하지 않는다.
- 상세 슬라이드가 열린 상태에서도 다른 전표 행을 바로 클릭할 수 있고, 이때 패널 내용만 교체한다.
- 전표 행과 패널 내부를 제외한 영역을 클릭하면 패널을 닫는다.
- 닫기는 `닫기` 버튼, `Escape` 키, 오른쪽 패널 밖 클릭을 지원한다.
- 취소 처리는 상세 패널의 하단 고정 버튼에서 시작하고, 확인 모달에서 최종 실행한다.
- 상세 패널의 `부품 관리` 버튼은 `/w/{companyCode}/part-units?documentId={documentId}&documentNo={documentNo}&partState={partState}`로 이동한다. 입고 전표는 `partState=HELD`, 출고 전표는 `partState=OUTBOUND`를 사용한다.

입고/출고 전표 상세는 품목별 상세 행을 길게 펼치기보다 품목별 수량 요약을 우선 보여준다. 관리번호 전체 목록은 상세 조회나 확장 영역에서 확인한다.

## 출고 등록 화면

출고 등록 화면은 고객 거래처와 출고 사유를 입력한 뒤, 출고 가능한 관리번호를 검색해 출고 부품에 추가하고 전표를 저장한다.

화면 흐름:

1. 전표 기본 정보 입력
2. 출고 가능 관리번호 검색
3. 품목 묶음별 관리번호 선택
4. 출고 부품 목록 검토
5. 저장 후 재고 차감과 이력 저장

화면 문구 기준:

- 사용자 화면에서는 `출고 부품 검색`, `출고 부품`, `관리번호 선택`, `출고 사유`를 사용한다.
- 출고 등록은 품목 수량만 입력하지 않고 실제 출고할 `관리번호`를 선택한다.
- 관리번호 목록은 품목 묶음을 먼저 보여주고, 묶음 안에서 개별 관리번호를 선택한다.
- 출고 부품 목록은 품목별 수량과 선택된 관리번호를 함께 보여준다.
- 부품 상세의 `출고하러 가기`에서 `/w/{companyCode}/outbound/new?unitId={관리번호ID}&partId={품목ID}&categoryId={분류ID}&keyword={관리번호}`로 진입하면 해당 관리번호를 출고 부품 목록에 자동 선택하고, 사용자가 거래처를 먼저 고를 수 있도록 거래처 선택 영역에 포커스를 둔다.

출고 대상 조회:

`GET /api/workspaces/{companyCode}/stock/outbound-candidates`

Query:

| 이름 | 설명 |
|---|---|
| `keyword` | 관리번호, 품목명, 모델명, 품목코드 검색 |
| `categoryId` | 품목 분류 필터 |
| `partId` | 특정 품목 필터 |
| `grade` | `A`, `B`, `C` 등급 필터 |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | 기존 단순 목록 호환용 size 별칭 |

출고 대상 조건:

- `unit_status = IN_STOCK`
- `inspection_status = COMPLETED`
- `sales_status = AVAILABLE`
- `grade != DEFECTIVE`
- `active = true`

출고 등록 요청:

```json
{
  "partnerId": 2,
  "reason": "판매 출고",
  "lines": [
    {
      "partId": 10,
      "unitIds": [101, 102],
      "reason": "CPU 출고"
    }
  ]
}
```

출고 전표 번호는 서버가 `OUT-YYYYMMDD-RANDOM16` 형식으로 자동 발급한다.

## 주요 규칙

- `tb_stock_document`는 거래처와 연결된 입출고 전표 헤더다.
- 입고 전표 번호는 서버가 `IN-YYYYMMDD-RANDOM16` 형식으로 자동 발급하고, 내부 정렬은 `document_id`를 사용한다.
- 출고 전표 번호는 서버가 `OUT-YYYYMMDD-RANDOM16` 형식으로 자동 발급하고, 내부 정렬은 `document_id`를 사용한다.
- `tb_stock_movement`는 전표 안의 품목별 재고 변화 라인이다.
- `tb_stock_movement_unit`은 재고 변화 라인에 포함된 개별 부품 목록이다.
- 입출고 원본은 수정/삭제하지 않고 취소 이력으로 처리한다.
- 출고 시 검수 완료, 불량 아님, 판매 가능, 재고 보유 상태를 검증한다.
- 관리번호 단위 통합 조회 화면은 `docs/features/part-unit.md`를 따르며, 이 문서는 입출고 상태 변경과 이력 저장만 담당한다.

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

출고 전표 취소 가능 조건:

- 전표가 `CANCELED` 상태가 아니어야 한다.
- 원본 출고 movement의 개별 부품이 모두 `unit_status = OUTBOUND`이어야 한다.
- 원본 출고 movement의 개별 부품이 모두 `active = true`여야 한다.

출고 전표 취소 처리:

- 원본 document의 `document_status`를 `CANCELED`로 변경한다.
- 원본 movement의 `movement_status`를 `CANCELED`로 변경한다.
- 원본 movement마다 `OUTBOUND_CANCEL` movement를 추가한다.
- 취소 movement의 `before_quantity`, `after_quantity`를 저장한다.
- 원본 movement에 연결된 개별 부품은 취소 movement에도 매핑한다.
- 취소 movement unit 이력은 `before_unit_status = OUTBOUND`, `after_unit_status = IN_STOCK`으로 저장한다.
- 개별 부품은 `unit_status = IN_STOCK`으로 되돌린다.
- `tb_part_stock.quantity`는 취소 수량만큼 증가한다.

## 하네스 포인트

- 재고 변경과 이력 저장은 같은 트랜잭션이어야 한다.
- `beforeQuantity`와 `afterQuantity`를 저장해야 한다.
- 출고 재고 차감에는 DB 동시성 전략이 필요하다.
- `tb_part_stock.quantity`와 `IN_STOCK` unit 수량 정합성을 검증해야 한다.
