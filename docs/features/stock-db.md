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

## 정합성 기준

- 입고, 출고, 취소는 전표·재고 변화·개별 관리번호·현재 재고를 같은 트랜잭션에서 변경한다.
- 모든 조회와 변경은 `company_id` 범위를 유지한다.
- 입고와 출고 전표번호는 중복될 수 없다.
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
