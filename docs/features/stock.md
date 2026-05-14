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

## 주요 규칙

- `tb_stock_document`는 거래처와 연결된 입출고 전표 헤더다.
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

## 하네스 포인트

- 재고 변경과 이력 저장은 같은 트랜잭션이어야 한다.
- `beforeQuantity`와 `afterQuantity`를 저장해야 한다.
- 출고 재고 차감에는 DB 동시성 전략이 필요하다.
- `tb_part_stock.quantity`와 `IN_STOCK` unit 수량 정합성을 검증해야 한다.
