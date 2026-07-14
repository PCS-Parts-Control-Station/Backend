# Stock DB Rules

## 목적

입고·출고·취소의 전표, movement, unit, 현재 재고 정합성과 조회 성능을 정의한다.

## 테이블 역할

| 테이블 | 역할 |
|---|---|
| `tb_stock_document` | 전표 header |
| `tb_stock_movement` | 품목별 수량 변화와 취소 연결 |
| `tb_stock_movement_unit` | movement와 관리번호, 상태 전후 |
| `tb_part_stock` | 품목별 현재 수량 |
| `tb_pc_part_unit` | 개별 부품 현재 상태 |

part, partner, member, company는 소속·출력·처리자 검증에 사용한다.

## 핵심 제약

```text
uk_stock_document_document_no
uk_stock_document_company_document_id
uk_stock_movement_company_movement_id
chk_stock_movement_quantity
chk_stock_movement_before_after
uk_stock_movement_unit
uk_part_stock_company_part
chk_part_stock_quantity
```

상세 컬럼과 정의는 DDL이 원본이다.

## 목록 조회

- 모든 조회는 company_id를 선두 조건으로 사용한다.
- document_id DESC로 안정 정렬한다.
- 날짜는 시작 이상, 종료 다음 날 미만의 반열린 범위다.
- 페이지 document_id를 먼저 확정한 뒤 movement·품목·처리자를 집계한다.
- count는 출력 JOIN을 제거하고 검색 관계는 EXISTS를 우선한다.
- `idx_stock_document_company_created`, `idx_stock_movement_company_document_current`를 기준으로 EXPLAIN한다.

## 저장 정합성

- 입고·출고·취소는 document, movement, mapping, unit, stock을 같은 트랜잭션에서 변경한다.
- 다른 회사의 partner, part, unit을 사용할 수 없다.
- documentNo는 중복될 수 없다.
- quantity는 양수이고 before/after는 movement 증감 방향과 일치한다.
- 동일 movement에 같은 unit을 중복 포함할 수 없다.
- 취소는 원본을 보존하고 반대 movement를 추가한다.
- 출고 unit은 재고 보유·검수 완료·판매 가능·불량 아님을 만족한다.
- 완료 시 part stock은 활성 IN_STOCK unit 수와 일치한다.

## 실패와 롤백

- 이미 취소된 전표 재취소
- 재고보다 많은 출고
- 검수 미완료·불량·판매 불가 unit 출고
- 다른 회사 데이터 사용
- movement 또는 unit 저장 중 오류

실패 시 앞서 저장한 document, movement, stock, unit 변경이 남지 않아야 한다.

## DB 통합 테스트 수용 기준

- `StockPersistenceIntegrationTest`, `StockOperationsPersistenceIntegrationTest`
- 회사 격리와 전표·movement·unit·stock 동시 저장을 검증한다.
- 판매 가능한 unit만 출고되고 상태·재고가 함께 변경된다.
- 출고 취소는 원본 취소와 반대 movement, unit·stock 복원을 검증한다.
- 입고 취소 unit은 CANCELED, active=false로 조회된다.
- 강제 실패가 전체 rollback된다.
- 현재 재고 음수 제약과 unit 수량 일치를 실제 MariaDB에서 검증한다.
