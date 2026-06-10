# Part DB Rules

## 기준 테이블

```text
tb_pc_part
tb_part_stock
tb_part_spec_definition
tb_part_spec_option
tb_part_spec_value
tb_pc_part_unit
```

## 품목 마스터 저장

- 품목 마스터는 `tb_pc_part`에 저장한다.
- `company_id`, `category_id`, `part_name`, `manufacturer`, `model_name`, `part_code`, `estimated_price`, `safe_quantity`는 등록/수정 흐름에서 관리한다.
- `part_code`는 화면에서 받지 않고 서버에서 생성한다.
- `part_code`는 `UNIQUE(company_id, part_code)` 제약을 만족해야 한다.
- 품목 목록의 현재 재고는 `tb_part_stock.quantity`를 `LEFT JOIN`해서 조회한다.

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
