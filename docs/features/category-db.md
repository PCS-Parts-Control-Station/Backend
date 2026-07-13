# Category DB Rules

## 목적

품목 분류 기능이 사용하는 `tb_part_category`와 분류별 사양 정의 테이블 구조를 검증한다.

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

- `UNIQUE(company_id, category_name)`으로 업체 안에서 분류명이 중복되지 않아야 한다.
- `UNIQUE(company_id, category_id)`로 다른 테이블에서 업체 범위 FK를 걸 수 있어야 한다.
- 품목 분류는 사용/중지 개념을 두지 않으므로 `active` 컬럼을 사용하지 않는다.
- `tb_part_spec_definition`은 `uk_part_spec_definition_company_category_key`로 같은 분류 안의 사양 키 중복을 막는다.
- `tb_part_spec_definition.input_type`은 `TEXT`, `NUMBER`, `SELECT`, `BOOLEAN`만 허용한다.
- `tb_part_spec_option`은 `uk_part_spec_option_definition_value`로 같은 사양 항목 안의 선택지 값 중복을 막는다.
- `tb_part_spec_value`는 `UNIQUE(part_id, spec_definition_id)`로 품목 마스터별 사양값을 하나만 저장한다.

## 검증 시나리오

- 분류 목록은 `updated_at DESC, category_id DESC`로 정렬하고 `idx_part_category_company_list`를 기준으로 검증한다.
- 목록 count는 출력용 품목 집계 JOIN 없이 분류 검색 조건만 사용한다.

- 업체별로 같은 분류명을 사용할 수 있다.
- 같은 업체 안에서는 같은 분류명을 중복 등록할 수 없다.
- 품목 분류 생성 시 사양 정의와 선택지를 같은 트랜잭션에서 저장한다.
- `SELECT` 사양 항목은 선택지 테이블에 1개 이상 저장되어야 한다.
- 연결된 품목이 없는 분류 행은 삭제할 수 있다.
- 실제 서비스에서는 삭제 전 `tb_pc_part` 연결 수를 확인하고, 연결된 품목이 있으면 `CATEGORY_IN_USE`로 실패해야 한다.
- 분류 삭제 또는 사양 항목 교체 시 `tb_part_spec_value` -> `tb_part_spec_option` -> `tb_part_spec_definition` 순서로 하위 데이터를 먼저 정리해야 한다.

## DB 통합 테스트 기준

- 실제 MariaDB에서 `tb_part_category` 등록, 수정, 삭제 SQL이 동작해야 한다.
- `UNIQUE(company_id, category_name)` 제약으로 같은 업체의 중복 분류명이 막혀야 한다.
- 다른 업체는 같은 분류명을 사용할 수 있어야 한다.
- 목록 검색 SQL은 이름/설명 keyword, page, size 조건을 처리해야 한다.
- 목록과 상세 조회의 `partCount`는 `tb_pc_part` 기준으로 정확히 집계되어야 한다.
- 사양 정의는 `sort_order ASC, spec_definition_id ASC` 순서로 조회되어야 한다.
- 선택지는 `spec_definition_id ASC, sort_order ASC, option_id ASC` 순서로 조회되어야 한다.
- 분류 삭제 시 사양값, 선택지, 사양 정의, 분류 순서로 삭제되어 FK 오류가 없어야 한다.
- 연결 품목이 있는 분류는 서비스 계층에서 삭제가 차단되어야 한다.
- 조회와 삭제는 항상 `company_id` 범위를 지켜 다른 업체 데이터가 섞이지 않아야 한다.
