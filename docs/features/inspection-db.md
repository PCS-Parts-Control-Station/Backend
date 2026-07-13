# Inspection DB Feature

## 목적

검수, 검수 정정, 재검수, 검수 템플릿 관리가 사용하는 DB 구조와 기본 정합성 규칙을 검증한다.

이 문서는 화면 시나리오 문서가 아니다. 검수 도메인의 테이블, 컬럼, 제약 조건, 저장 규칙을 확인하기 위한 DB 기준 문서다.

## 사용 테이블

```text
tb_inspection_template
tb_inspection_template_item
tb_inspection_template_item_option
tb_inspection
tb_inspection_item_result
tb_part_status_history
tb_pc_part_unit
tb_part_category
tb_member
tb_company
```

`tb_part_category`, `tb_member`, `tb_company`는 회사 범위, 카테고리, 작업자 검증에 사용한다.

`tb_pc_part_unit`은 검수 후 개별 부품 상태 갱신 대상이다.

## 조회 대상 컬럼

`tb_inspection_template`:

- `template_id`
- `company_id`
- `category_id`
- `template_name`
- `version`
- `active`
- `created_by`
- `created_at`
- `updated_at`

`tb_inspection_template_item`:

- `item_id`
- `template_id`
- `item_group`
- `item_name`
- `input_type`
- `required`
- `sort_order`
- `grade_impact`
- `fail_policy`
- `active`

`tb_inspection_template_item_option`:

- `option_id`
- `item_id`
- `option_label`
- `option_value`
- `sort_order`
- `active`

`tb_inspection`:

- `inspection_id`
- `company_id`
- `unit_id`
- `template_id`
- `inspected_by`
- `inspection_type`
- `original_inspection_id`
- `sales_status`
- `result`
- `grade`
- `memo`
- `inspected_at`
- `created_at`

`tb_inspection_item_result`:

- `item_result_id`
- `inspection_id`
- `item_id`
- `item_name_snapshot`
- `result`
- `value_text`
- `value_number`
- `selected_option_id`
- `selected_option_label_snapshot`
- `selected_option_value_snapshot`
- `memo`

## 저장 / 수정 대상 컬럼

검수 템플릿 생성 시 저장한다.

- `company_id`
- `category_id`
- `template_name`
- `version`
- `active`
- `created_by`
- `created_at`
- `updated_at`

검수 템플릿 기본 정보 수정 시 갱신한다.

- `category_id`
- `template_name`
- `version`
- `active`
- `updated_at`

검수 템플릿 사용 여부 변경 시 갱신한다.

- `active`
- `updated_at`

검수 항목 생성/수정 시 저장 또는 갱신한다.

- `template_id`
- `item_group`
- `item_name`
- `input_type`
- `required`
- `sort_order`
- `grade_impact`
- `fail_policy`
- `active`

검수 선택지 생성/수정 시 저장 또는 갱신한다.

- `item_id`
- `option_label`
- `option_value`
- `sort_order`
- `active`

검수 등록, 정정, 재검수 시 저장한다.

- `company_id`
- `unit_id`
- `template_id`
- `inspected_by`
- `inspection_type`
- `original_inspection_id`
- `sales_status`
- `result`
- `grade`
- `memo`
- `inspected_at`
- `created_at`

검수 항목 결과 저장 시 저장한다.

- `inspection_id`
- `item_id`
- `item_name_snapshot`
- `result`
- `value_text`
- `value_number`
- `selected_option_id`
- `selected_option_label_snapshot`
- `selected_option_value_snapshot`
- `memo`

검수 후 개별 부품 상태 변경 시 `tb_pc_part_unit`에서 갱신한다.

- `inspection_status`
- `grade`
- `sales_status`
- `updated_at`

검수 후 상태 변경 이력은 `tb_part_status_history`에 저장한다.

- `company_id`
- `unit_id`
- `changed_by`
- `from_inspection_status`
- `to_inspection_status`
- `from_grade`
- `to_grade`
- `from_sales_status`
- `to_sales_status`
- `reason`
- `created_at`

## 제약 조건

```text
tb_inspection_template.uk_inspection_template_company_template_id
tb_inspection_template.uk_inspection_template_version
tb_inspection_template.chk_inspection_template_version
tb_inspection_template.idx_inspection_template_company_category
tb_inspection_template_item.uk_inspection_template_item_id
tb_inspection_template_item.chk_inspection_template_item_sort_order
tb_inspection_template_item.idx_inspection_template_item_template_sort
tb_inspection_template_item_option.uk_inspection_template_item_option_value
tb_inspection_template_item_option.chk_inspection_template_item_option_sort_order
tb_inspection_template_item_option.idx_inspection_template_item_option_item_sort
tb_inspection.uk_inspection_company_inspection_id
tb_inspection.chk_inspection_original
tb_inspection.idx_inspection_company_unit_date
tb_inspection.idx_inspection_company_template
tb_inspection.idx_inspection_company_original
tb_inspection_item_result.idx_inspection_item_result_inspection
tb_inspection_item_result.idx_inspection_item_result_item
tb_inspection_item_result.idx_inspection_item_result_selected_option
```

물리 FK는 사용하지 않는다. 관계 정합성은 Service와 하네스에서 검증한다.

## 목록 조회 기준

검수 템플릿 목록:

- 모든 조회는 `company_id` 조건을 반드시 포함한다.
- `keyword`는 `template_name`, `category_name`에 부분 일치 검색한다.
- `categoryId`는 `category_id`와 정확히 일치한다.
- `active`가 없으면 사용 중/중지 템플릿을 모두 조회한다.
- 목록은 `updated_at DESC, template_id DESC` 순서로 정렬한다.
- 항목 수는 `tb_inspection_template_item` 기준으로 계산한다.
- 선택지 수는 `tb_inspection_template_item_option` 기준으로 계산한다.
- 페이징 query와 응답 기준은 `docs/ai/pcs-pagination-rules.md`를 따른다.

검수 이력 목록:

- 모든 조회는 `company_id` 조건을 반드시 포함한다.
- 관리번호, 부품, 전표, 검수 유형, 결과, 등급, 기간 조건으로 검색할 수 있어야 한다.
- 전표 기준 이력은 `documentId`, 개별 관리번호 기준 이력은 `unitId` 조건으로 조회한다.
- 목록은 `inspected_at DESC, inspection_id DESC` 순서로 정렬한다.
- 검수 이력 화면에서 전표 단위 목록을 보여주더라도 실제 검수 이력 row는 `tb_inspection`의 관리번호 단위 기록이다.
- 전표 단위 요약은 `documentId` 기준 집계 결과이며, 개별 이력 추적은 항상 `unitId`와 `inspection_id` 기준으로 내려간다.
- 전표 단위 페이징은 `tb_inspection` row 페이징과 혼동하지 않도록 별도 집계 쿼리와 별도 응답 DTO를 사용한다.
- 전표 단위 이력 목록은 집계 결과에 `LIMIT`, `OFFSET`을 적용해 서버 페이징한다.
- 검수 이력 화면의 품목 묶음 구성을 위해 이력 목록 또는 전표 상세 조회 응답에는 품목명, 모델명, 품목 분류명 또는 카테고리명을 포함한다.
- 전표 선택 후 품목 묶음과 관리번호 목록은 `documentId`로 조회한 관리번호 단위 이력 row를 클라이언트에서 묶어 표시한다.
- 전체 검수 이력의 기간 정렬은 `idx_inspection_company_date (company_id, inspected_at DESC, inspection_id DESC)`를 기준으로 검증한다.
- 관리번호별 최근 검수는 `idx_inspection_company_unit_date`를 사용한다.
- 목록 SQL 변경 시 MariaDB `EXPLAIN` 또는 `EXPLAIN ANALYZE`로 사용 인덱스, 실제 조회 행, filesort와 temporary table 여부를 확인한다.

## 정합성 기준

- 템플릿 생성/수정 시 `category_id`는 같은 `company_id`의 카테고리여야 한다.
- 같은 회사 안에서 `category_id`, `template_name`, `version` 조합은 중복될 수 없다.
- 템플릿 `version`은 1 이상이어야 한다.
- 항목 `sort_order`는 0 이상이어야 한다.
- 선택지 `sort_order`는 0 이상이어야 한다.
- 같은 항목 안에서 `option_value`는 중복될 수 없다.
- `option_value`가 없으면 서버는 `option_label`을 저장한다.
- `input_type = SELECT`인 항목만 선택지를 가질 수 있다.
- `active = false`인 템플릿, 항목, 선택지는 신규 검수 입력에서 제외한다.
- 사용 중지된 템플릿, 항목, 선택지는 과거 검수 이력과 snapshot을 변경하지 않는다.

## 검수 저장 기준

- 최초 검수는 `inspection_type = INITIAL`, `original_inspection_id = NULL`이어야 한다.
- 정정과 재검수는 `inspection_type IN ('CORRECTION', 'REINSPECTION')`, `original_inspection_id IS NOT NULL`이어야 한다.
- 최초 검수를 기준으로 정정/재검수를 생성하면 `original_inspection_id`는 기준 검수 ID여야 한다.
- 정정 또는 재검수 이력을 기준으로 다시 정정/재검수를 생성하면 기존 `original_inspection_id`를 유지해야 한다.
- `tb_inspection.chk_inspection_original` 제약을 만족해야 한다.
- 검수 요청 body에는 `inspectedAt`을 받지 않고, 서버가 현재 시각을 `inspected_at`에 저장한다.
- `grade = DEFECTIVE`이면 `sales_status = UNAVAILABLE`이어야 한다.
- 검수 저장 시 `tb_pc_part_unit.inspection_status = COMPLETED`로 갱신한다.
- 검수 저장 시 `tb_pc_part_unit.grade`, `tb_pc_part_unit.sales_status`를 검수 결과 기준으로 갱신한다.
- 개별 부품 상태 변경 전후 값은 `tb_part_status_history`에 저장한다.
- 검수 항목 결과는 `tb_inspection_item_result`에 저장한다.
- 항목명은 `item_name_snapshot`으로 저장한다.
- 선택지 결과는 `selected_option_id`, `selected_option_label_snapshot`, `selected_option_value_snapshot`으로 저장한다.

## 실패 시나리오

- 다른 회사의 템플릿, 항목, 선택지를 조회하거나 수정하면 실패한다.
- 다른 회사의 카테고리로 템플릿을 생성하거나 수정하면 실패한다.
- 같은 회사 안에서 같은 카테고리, 템플릿명, 버전 조합으로 저장하면 실패한다.
- `SELECT`가 아닌 항목에 선택지를 추가하면 실패한다.
- 같은 항목 안에서 선택지 저장 코드가 중복되면 실패한다.
- `INITIAL` 검수에 `original_inspection_id`가 있으면 실패한다.
- `CORRECTION`, `REINSPECTION` 검수에 `original_inspection_id`가 없으면 실패한다.
- `grade = DEFECTIVE`인데 `sales_status != UNAVAILABLE`이면 실패한다.

## 하네스 기준

실행 명령과 `-DbFeature inspection` 사용 기준은 `docs/ai/pcs-harness-rules.md`를 따른다.

검수 DB 검증 시에는 `inspection.md`, `inspection-history.md`, `inspection-template.md`, `inspection-db.md`, `checkdb.md` 기준을 함께 확인한다.

## JUnit 검증 기준

검수 도메인 서비스 테스트는 아래 기준을 포함해야 한다.

- 최초 검수 저장 시 `tb_inspection`, `tb_inspection_item_result`, `tb_pc_part_unit`, `tb_part_status_history` 저장/갱신 호출을 검증한다.
- 정정과 재검수 저장 시 `inspection_type`, `original_inspection_id`, `template_id`, `memo` 정규화 값을 검증한다.
- 검수 이력 목록 조회 시 필터, 기간, 페이징 정규화 값을 검증한다.
- 검수 이력 상세 조회 시 항목별 결과 조회 호출을 검증한다.
- 템플릿 항목 생성 시 `grade_impact = LOW`, `fail_policy = NONE` 기본값을 검증한다.
- 템플릿/항목/선택지 `active` 변경 시 소속 검증 후 변경 호출을 검증한다.
- 선택지 수정 시 `option_value`가 없으면 `option_label`을 저장 코드로 사용하는지 검증한다.

## DB Integration Test Coverage

- Integration tests: `InspectionPersistenceIntegrationTest`, `InspectionOperationsPersistenceIntegrationTest`, `InspectionTemplatePersistenceIntegrationTest`
- Schema fixtures: `pcs-category-part-test-schema.sql`, `pcs-operations-test-schema-extension.sql`
- Required checks:
  - 회사 A 범위에서 회사 B의 관리번호, 템플릿, 검수 이력을 조회하거나 변경할 수 없다.
  - 최초 검수는 검수 row와 항목 snapshot을 저장하고 관리번호 상태와 상태 이력을 같은 트랜잭션에서 변경한다.
  - 일괄 검수 중 하나가 실패하면 모든 검수와 상태 변경을 롤백한다.
  - 정정과 재검수는 기존 row를 수정하지 않고 새 row를 추가하며 최초 `original_inspection_id`를 유지한다.
  - 검수 항목 저장 또는 상태 변경 중 실패하면 검수 row, 항목 결과, 관리번호 상태, 상태 이력이 전부 rollback된다.
  - 검수 완료 후 `inspection_status`, `grade`, `sales_status`가 마지막 검수 이력과 일치한다.
  - 템플릿과 중첩 항목·선택지를 함께 저장하고 버전 제약을 검증한다.
