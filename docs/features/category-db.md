# Category DB Rules

## 목적

카테고리 기능이 사용하는 `tb_part_category`와 카테고리별 스펙 정의 테이블 구조를 검증한다.

## 대상 테이블

- `tb_part_category`
- `tb_part_spec_definition`
- `tb_part_spec_option`
- `tb_part_spec_value`
- `tb_pc_part`

## 필수 컬럼

`tb_part_category`

- `company_id`
- `category_name`
- `description`
- `created_by`
- `created_at`
- `updated_at`

`tb_part_spec_definition`

- `company_id`
- `category_id`
- `spec_key`
- `spec_name`
- `input_type`
- `unit`
- `required`
- `searchable`
- `sort_order`
- `active`
- `created_by`
- `created_at`
- `updated_at`

`tb_part_spec_option`

- `spec_definition_id`
- `option_label`
- `option_value`
- `sort_order`
- `active`

`tb_part_spec_value`

- `company_id`
- `part_id`
- `spec_definition_id`
- `value_text`
- `value_number`
- `value_boolean`
- `selected_option_id`
- `selected_option_label_snapshot`
- `selected_option_value_snapshot`
- `created_at`
- `updated_at`

## 제약

- `UNIQUE(company_id, category_name)`으로 업체 안에서 카테고리명이 중복되지 않아야 한다.
- `UNIQUE(company_id, category_id)`로 다른 테이블에서 업체 범위 FK를 걸 수 있어야 한다.
- 카테고리는 사용/중지 개념을 두지 않으므로 `active` 컬럼을 사용하지 않는다.
- `tb_part_spec_definition`은 `uk_part_spec_definition_company_category_key`로 같은 카테고리 안의 스펙 키 중복을 막는다.
- `tb_part_spec_definition.input_type`은 `TEXT`, `NUMBER`, `SELECT`, `BOOLEAN`만 허용한다.
- `tb_part_spec_option`은 `uk_part_spec_option_definition_value`로 같은 스펙 항목 안의 선택지 값 중복을 막는다.
- `tb_part_spec_value`는 `UNIQUE(part_id, spec_definition_id)`로 부품 마스터별 스펙 값을 하나만 저장한다.

## 검증 시나리오

- 업체별로 같은 카테고리명을 사용할 수 있다.
- 같은 업체 안에서는 같은 카테고리명을 중복 등록할 수 없다.
- 카테고리 생성 시 스펙 정의와 선택지를 같은 트랜잭션에서 저장한다.
- `SELECT` 스펙 항목은 선택지 테이블에 1개 이상 저장되어야 한다.
- 연결된 부품이 없는 카테고리 행은 삭제할 수 있다.
- 실제 서비스에서는 삭제 전 `tb_pc_part` 연결 수를 확인하고, 연결된 부품이 있으면 `CATEGORY_IN_USE`로 실패해야 한다.
