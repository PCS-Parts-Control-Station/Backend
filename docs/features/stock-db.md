# Stock DB Rules

## 목적

입고, 출고, 취소, 현재 재고 변경이 사용하는 DB 구조와 이력 정합성을 검증한다.

## 사용 테이블

```text
tb_stock_document
tb_stock_movement
tb_stock_movement_unit
tb_part_stock
tb_pc_part_unit
tb_pc_part
tb_trade_partner
tb_member
tb_company
```

## 핵심 컬럼

- 전표: `company_id`, `partner_id`, `document_no`, `document_type`, `document_status`, `processed_by`
- 재고 변화: `company_id`, `document_id`, `part_id`, `movement_type`, `movement_status`, `canceled_movement_id`, `quantity`, `before_quantity`, `after_quantity`
- 개별 품목: `movement_id`, `unit_id`, `before_unit_status`, `after_unit_status`
- 현재 재고: `company_id`, `part_id`, `quantity`

## 제약 조건

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

## 목록 조회와 인덱스 기준

- 전표 목록은 `company_id`를 선두 조건으로 사용하고 `document_id DESC`로 안정적으로 정렬한다.
- 날짜 조건은 `created_at >= 시작일 00:00`, `created_at < 종료일 다음 날 00:00`의 반열린 구간으로 조회한다.
- `DATE(created_at)`처럼 날짜 컬럼을 함수로 감싸지 않는다.
- 전표 목록은 페이지 대상 `document_id`를 먼저 확정하고, 해당 전표에 대해서만 movement, 품목, 처리자 정보를 집계한다.
- 전표 count 쿼리는 출력용 JOIN을 제거하고 검색에 필요한 관계만 `EXISTS`로 확인한다.
- 날짜 범위는 `idx_stock_document_company_created`, 현재 movement 조회는 `idx_stock_movement_company_document_current` 인덱스를 기준으로 검증한다.
- 인덱스 사용 여부는 MariaDB `EXPLAIN` 또는 `EXPLAIN ANALYZE`로 확인한다.

## 정합성 기준

- 입고, 출고, 취소는 전표·재고 변화·개별 관리번호·현재 재고를 같은 트랜잭션에서 변경한다.
- 모든 조회와 변경은 `company_id` 범위를 유지한다.
- 입고와 출고 전표 번호는 중복될 수 없다.
- 수량은 0보다 커야 하고 `before_quantity`, `after_quantity`는 이동 유형의 증감 방향과 일치해야 한다.
- 취소는 원본 이력을 수정하지 않고 취소 전표와 반대 방향 재고 변화 이력을 추가한다.
- 출고 대상 관리번호는 재고 보유, 검수 완료, 판매 가능 상태여야 한다.
- `tb_part_stock.quantity`는 재고 상태인 개별 관리번호 수와 일치해야 한다.

## 실패 시나리오

- 다른 회사의 거래처, 품목, 관리번호를 사용하면 실패한다.
- 이미 취소된 전표를 다시 취소하면 실패한다.
- 재고보다 많은 수량을 출고하면 실패한다.
- 동일 관리번호를 같은 이동에 중복 포함하면 실패한다.
- 검수 미완료, 불량, 판매 불가 관리번호를 출고하면 실패한다.

## 하네스 기준

`-RunDb`에서 `stock`이 선택되면 공통 `checkdb`와 이 문서의 테이블·컬럼·제약 조건을 함께 검사한다.

## DB Integration Test Coverage

- Integration test: `src/integrationTest/java/com/pcs/domain/stock/StockPersistenceIntegrationTest.java`
- Schema fixture: `src/integrationTest/resources/pcs-category-part-test-schema.sql`
- Required checks:
  - 회사 A 범위에서 회사 B의 거래처, 품목, 관리번호, 전표를 조회하거나 변경할 수 없다.
  - 입고는 전표, movement, 현재 재고, 개별 관리번호를 한 트랜잭션에 저장한다.
  - 검수 완료된 판매 가능 관리번호만 출고할 수 있고, 출고 후 재고와 `unit_status`가 함께 변경된다.
  - 출고 취소는 원본 movement를 `CANCELED`로 바꾸고 반대 movement를 추가한 뒤 관리번호와 재고를 복구한다.
  - 처리 중 오류가 발생하면 앞서 저장한 전표, movement, 재고, 관리번호가 전부 rollback된다.
  - 각 완료 시점의 `tb_part_stock.quantity`와 활성 `IN_STOCK` 관리번호 수가 일치한다.
