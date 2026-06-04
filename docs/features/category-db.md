# Category DB Rules

## 목적

카테고리 기능이 사용하는 `tb_part_category` 구조와 기본 DB 동작을 검증한다.

## 대상 테이블

- `tb_part_category`
- `tb_pc_part`

## 필수 컬럼

`tb_part_category`

- `company_id`
- `category_name`
- `description`
- `created_by`
- `created_at`
- `updated_at`

## 제약

- `UNIQUE(company_id, category_name)`으로 업체 안에서 카테고리명이 중복되지 않아야 한다.
- `UNIQUE(company_id, category_id)`로 다른 테이블에서 업체 범위 FK를 걸 수 있어야 한다.
- 카테고리는 사용/중지 개념을 두지 않으므로 `active` 컬럼을 사용하지 않는다.

## 검증 시나리오

- 업체별로 같은 카테고리명을 사용할 수 있다.
- 같은 업체 안에서는 같은 카테고리명을 중복 등록할 수 없다.
- 연결된 부품이 없는 카테고리 행은 삭제할 수 있다.
- 실제 서비스에서는 삭제 전 `tb_pc_part` 연결 수를 확인하고, 연결된 부품이 있으면 `CATEGORY_IN_USE`로 실패해야 한다.
