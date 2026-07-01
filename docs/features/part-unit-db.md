# Part Unit DB Rules

## 목적

부품 관리 화면의 관리번호 목록과 상세 조회가 사용하는 DB 조회 기준을 정의한다.

입고·출고·취소로 개별 부품과 재고 수량을 변경하는 정합성은 `docs/features/stock-db.md`가 담당한다. 검수 저장과 상태 변경 이력 정합성은 `docs/features/inspection-db.md`가 담당한다. 이 문서는 상태 변경을 다루지 않는다.

## 사용 테이블

```text
tb_pc_part_unit
tb_pc_part
tb_part_category
tb_stock_movement_unit
tb_stock_movement
tb_stock_document
tb_inspection
tb_member
```

`tb_part_stock`은 품목 단위 현재 재고 집계이며, 관리번호 목록의 기준 수량으로 사용하지 않는다. 품목 목록 재고 집계 기준은 `docs/features/part-db.md`를 따른다.

## 핵심 컬럼

- 개별 부품: `company_id`, `unit_id`, `part_id`, `internal_serial_no`, `manufacturer_serial_no`, `unit_status`, `inspection_status`, `grade`, `sales_status`, `active`, `updated_at`
- 품목: `company_id`, `part_id`, `category_id`, `part_name`, `model_name`, `manufacturer`, `part_code`
- 분류: `company_id`, `category_id`, `category_name`
- 입출고 이력: `movement_id`, `document_id`, `movement_type`, `movement_status`, `processed_by`, `created_at`
- 입출고 이력 매핑: `movement_id`, `unit_id`, `before_unit_status`, `after_unit_status`
- 검수 이력: `inspection_id`, `unit_id`, `inspection_type`, `result`, `grade`, `sales_status`, `inspected_by`, `inspected_at`

## 목록 조회 SQL 기준

- 목록의 기준 테이블은 `tb_pc_part_unit`이다.
- `tb_pc_part`와 `tb_part_category`를 조인해 품목명, 모델명, 제조사, 품목코드, 분류명을 함께 조회한다.
- `company_id`는 `tb_pc_part_unit`, `tb_pc_part`, `tb_part_category` 조인 조건에 모두 포함한다.
- 기본 조건은 `tb_pc_part_unit.active = true`이다.
- 검색어는 관리번호, 제조사 시리얼, 품목명, 모델명, 제조사, 품목코드, 분류명에 적용한다.
- `categoryId`는 `tb_pc_part.category_id` 기준으로 필터한다.
- `partState` 조건은 `docs/features/part-unit.md`의 목록 검색 표를 따른다.
- 목록 정렬은 `tb_pc_part_unit.updated_at DESC, tb_pc_part_unit.unit_id DESC`이다.
- summary는 목록 검색과 같은 where 조건으로 계산하고, `total_count`를 `PageResultDto.totalElements`의 원천으로 사용한다.
- summary의 `held_count`는 `unit_status = IN_STOCK` 전체가 아니라 `waiting_count + sales_available_count + sales_unavailable_count`와 같은 업무상 보유 기준이다. 검수완료 후 `sales_status = HOLD`인 판매보류 부품은 별도 참고 통계로만 집계한다.
- 별도 `countPartUnits` 쿼리를 두지 않는다. 같은 where 조건의 `COUNT(*)`를 summary와 중복 실행하지 않는다.
- 목록 SQL은 `unit_id` 페이지만 먼저 `ORDER BY updated_at DESC, unit_id DESC LIMIT/OFFSET`으로 확정하고, 확정된 관리번호에 대해서만 상세 컬럼과 최근 이력 컬럼을 조회한다.
- 기본 목록 정렬은 `idx_pc_part_unit_list_default (company_id, active, updated_at DESC, unit_id DESC)` 인덱스가 받쳐야 한다.
- `partState=WAITING` 목록 정렬은 `idx_pc_part_unit_list_inspection (company_id, active, inspection_status, updated_at DESC, unit_id DESC)` 인덱스가 받쳐야 한다.
- `partState=OUTBOUND` 목록 정렬은 `idx_pc_part_unit_list_unit_status (company_id, active, unit_status, updated_at DESC, unit_id DESC)` 인덱스가 받쳐야 한다.

## 최근 이력 조회 기준

- 최근 입출고 이력은 `tb_stock_movement_unit -> tb_stock_movement -> tb_stock_document` 순서로 조회한다.
- 최근 입출고 이력 정렬은 `tb_stock_movement.created_at DESC, tb_stock_movement.movement_id DESC`이다.
- 최근 검수 이력은 `tb_inspection`에서 조회한다.
- 최근 검수 이력 정렬은 `tb_inspection.inspected_at DESC, tb_inspection.inspection_id DESC`이다.
- 목록의 최근 처리 표시값은 최근 입출고 이력과 최근 검수 이력 중 더 최근인 값을 사용한다.
- 상세의 이력 목록은 각 10건 이내로 제한한다.

## 제약 조건 참조

개별 부품 테이블 자체의 제약은 `docs/sql/pcs-schema-ddl.sql`의 `tb_pc_part_unit` 기준을 따른다.

대표 제약:

```text
uk_pc_part_unit_internal_serial
uk_pc_part_unit_manufacturer_serial
uk_pc_part_unit_company_unit_id
uk_pc_part_unit_company_part_unit_id
idx_pc_part_unit_list_default
idx_pc_part_unit_list_inspection
idx_pc_part_unit_list_unit_status
idx_pc_part_unit_company_status
idx_pc_part_unit_work_status
```

이미 생성된 DB에는 `docs/sql/pcs-part-unit-list-index-alter.sql`의 세 목록 인덱스를 적용한다. 대상 DB에 인덱스가 이미 존재하면 같은 alter를 재실행하지 않는다.

## 실패 시나리오

- 다른 회사의 관리번호가 목록 또는 상세에 섞이면 실패한다.
- 존재하지 않는 `unitId` 또는 다른 회사의 `unitId` 상세 조회는 실패한다.
- `partState`가 허용된 값이 아니면 요청 값 오류로 실패한다.
- 판매상태를 필터로 받거나 SQL where에 판매상태 검색 조건을 추가하면 실패한다.
- summary가 목록과 다른 조건으로 계산되면 실패한다.

## DB Integration Test Coverage

- Integration test: `src/integrationTest/java/com/pcs/domain/part/PartPersistenceIntegrationTest.java`
- Schema fixture: `src/integrationTest/resources/pcs-category-part-test-schema.sql`
- Required checks:
  - 관리번호 목록 검색은 `tb_pc_part_unit` 기준으로 페이징된다.
  - keyword와 categoryId 조건으로 다른 관리번호가 제외된다.
  - `partState=WAITING`은 검수대기 관리번호만 반환한다.
  - `partState=A`는 검수완료 A등급 관리번호만 반환한다.
  - `partState=OUTBOUND`은 출고 상태 관리번호만 반환한다.
  - 판매상태는 검색 조건에 없고, 응답 필드로만 내려온다.
  - summary의 `totalCount`, `heldCount`, `waitingCount`, `salesAvailableCount`, `salesHoldCount`, `salesUnavailableCount`, `gradeACount`, `gradeBCount`, `gradeCCount`, `defectiveCount`, `outboundCount`, `outboundAvailableCount`는 목록 where 조건과 같은 기준으로 계산된다.
  - `heldCount`는 `waitingCount + salesAvailableCount + salesUnavailableCount`와 같은 값이어야 한다.
  - 출고 통계인 `outboundCount`를 제외한 화면 통계는 `unit_status = IN_STOCK`인 보유 부품만 집계한다. 단, `salesHoldCount`는 보유 중인 참고 통계지만 `heldCount`에는 포함하지 않는다.
  - 페이징된 목록은 `updated_at DESC, unit_id DESC` 순서를 유지하고, summary의 `totalCount`는 현재 페이지 크기가 아니라 전체 조건 건수를 반환한다.
  - 기본, 검수상태, 출고상태 목록 인덱스가 DDL과 통합 테스트 fixture에 모두 존재한다.
  - 상세 조회는 같은 회사 관리번호만 반환하고, 다른 회사 관리번호는 `PART_UNIT_NOT_FOUND`로 실패한다.
