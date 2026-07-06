# Part DB Rules

## 기준 테이블

```text
tb_pc_part
tb_part_stock
tb_part_spec_definition
tb_part_spec_option
tb_part_spec_value
```

관리번호를 가진 실제 부품 조회 기준은 `docs/features/part-unit-db.md`가 담당한다.

## 품목 마스터 저장

- 품목 마스터는 `tb_pc_part`에 저장한다.
- `company_id`, `category_id`, `part_name`, `manufacturer`, `model_name`, `part_code`, `safe_quantity`는 등록/수정 흐름에서 관리한다.
- `part_code`는 화면에서 받지 않고 서버에서 생성한다.
- `part_code`는 `UNIQUE(company_id, part_code)` 제약을 만족해야 한다.
- 품목 목록의 현재 재고는 `tb_part_stock.quantity`를 `LEFT JOIN`해서 조회한다.
- 품목 목록 전체 건수는 `tb_pc_part` 기준으로 계산한다.
- 품목 목록 요약은 `partSearchWhere`와 같은 조건으로 집계한다.
- `total_stock`은 조회 조건 전체 품목의 `COALESCE(tb_part_stock.quantity, 0)` 합계다.
- `low_stock_count`는 조회 조건 전체 품목 중 `safe_quantity > 0`이고 현재 재고가 안전 재고보다 작은 품목 수다.

## 사양값 저장

- 분류별 사양 정의는 `tb_part_spec_definition`을 기준으로 한다.
- `SELECT` 사양의 선택지는 `tb_part_spec_option` 기준으로 검증한다.
- 실제 품목에 입력된 사양값은 `tb_part_spec_value`에 저장한다.
- 한 품목에는 같은 `spec_definition_id` 값을 한 번만 저장한다.
- 품목 수정 시 기존 `tb_part_spec_value`를 삭제한 뒤 현재 요청값을 다시 저장한다.
- 선택지 사양은 선택지 ID와 함께 label/value snapshot을 저장한다.

## 검증 포인트

- 존재하지 않는 분류 ID로 품목을 등록하거나 수정할 수 없다.
- 현재 분류에 속하지 않은 사양 항목은 저장할 수 없다.
- 필수 사양 항목은 값이 없으면 실패해야 한다.
- `NUMBER`, `SELECT`, `BOOLEAN`, `TEXT` 입력 방식에 맞는 컬럼에만 값을 저장한다.

## DB 통합 테스트 기준

- 실제 MariaDB에서 `tb_pc_part` 등록, 수정, 상세 조회 SQL이 동작해야 한다.
- `UNIQUE(company_id, part_code)` 제약으로 같은 업체의 중복 품목코드가 막혀야 한다.
- 다른 업체는 같은 품목코드를 사용할 수 있어야 한다.
- 품목 목록 검색 SQL은 `keyword`, `categoryId`, `active`, page, size 조건을 처리해야 한다.
- 기본 조회는 `active=true` 조건으로 동작해야 한다.
- `tb_part_stock.quantity`는 `currentStockQuantity`로 조회되어야 한다.
- summary의 `totalCount`, `totalStock`, `lowStockCount`는 목록 검색 조건과 같은 기준으로 계산되어야 한다.
- 상세 조회는 `tb_part_spec_value`와 `tb_part_spec_definition` 조인이 정상 동작해야 한다.
- `SELECT` 사양값 저장 시 선택지 label/value snapshot이 저장되어야 한다.
- 품목 수정 시 기존 사양값은 삭제되고 현재 요청 사양값만 남아야 한다.
- 조회와 수정은 항상 `company_id` 범위를 지켜 다른 업체 데이터가 섞이지 않아야 한다.
