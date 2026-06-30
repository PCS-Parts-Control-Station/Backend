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
- 목록 페이징은 `COUNT(*)`와 `LIMIT/OFFSET`을 분리한다.
- summary는 목록 검색과 같은 where 조건으로 계산한다.

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
idx_pc_part_unit_company_status
idx_pc_part_unit_work_status
```

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
  - summary의 `totalCount`, `waitingCount`, `outboundAvailableCount`는 목록 where 조건과 같은 기준으로 계산된다.
  - 상세 조회는 같은 회사 관리번호만 반환하고, 다른 회사 관리번호는 `PART_UNIT_NOT_FOUND`로 실패한다.
