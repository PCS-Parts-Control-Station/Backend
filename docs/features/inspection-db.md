# Inspection DB Rules

## 목적

검수 저장, 이력 조회, 템플릿 관리의 DB 동작과 정합성을 정의한다. 물리 컬럼과 제약의 전체 원본은 `docs/sql/pcs-schema-ddl.sql`이다.

## 테이블 역할

| 테이블 | 역할 |
|---|---|
| `tb_inspection_template` | 회사·분류별 템플릿 버전 |
| `tb_inspection_template_item` | 입력 항목과 정렬·판정 설정 |
| `tb_inspection_template_item_option` | SELECT 선택지 |
| `tb_inspection` | 관리번호 단위 최초·정정·재검수 이력 |
| `tb_inspection_item_result` | 항목 결과와 snapshot |
| `tb_pc_part_unit` | 최신 검수 상태·등급·판매 상태 |
| `tb_part_status_history` | 상태 전후 이력 |

category/member/company는 소속과 처리자 검증에 사용한다.

## 핵심 제약

```text
uk_inspection_template_version
chk_inspection_template_version
chk_inspection_template_item_sort_order
uk_inspection_template_item_option_value
chk_inspection_template_item_option_sort_order
chk_inspection_original
idx_inspection_company_date
idx_inspection_company_unit_date
idx_inspection_company_original
```

- 물리 FK는 사용하지 않으며 Service와 테스트가 소속 정합성을 검증한다.
- 상세 제약 정의는 DDL을 검색한다.

## 템플릿 조회·저장

- 모든 조회·변경은 company_id를 포함한다.
- categoryId는 같은 회사 소속이어야 한다.
- 회사 안에서 categoryId, templateName, version 조합은 중복될 수 없다.
- version은 1 이상, item/option sortOrder는 0 이상이다.
- SELECT 항목만 option을 가진다.
- 같은 item 안에서 optionValue는 중복될 수 없다.
- optionValue가 없으면 optionLabel을 저장 코드로 사용한다.
- inactive 템플릿·항목·선택지는 신규 검수에서 제외하되 과거 snapshot을 바꾸지 않는다.

목록:

- keyword는 templateName과 categoryName에 적용한다.
- categoryId와 active를 필터한다.
- `updated_at DESC, template_id DESC`로 정렬한다.
- item/option count는 목록 검색 조건 전체 기준 summary에 집계한다.
- page/size는 공통 페이징 계약을 따른다.

## 검수 저장

- INITIAL은 originalInspectionId가 없어야 한다.
- CORRECTION/REINSPECTION은 최초 chain ID가 있어야 한다.
- 요청 시각이 아니라 서버 현재 시각을 inspectedAt에 저장한다.
- `grade=DEFECTIVE`와 `salesStatus=UNAVAILABLE`을 함께 보장한다.
- inspection과 item result를 추가한 뒤 unit의 최신 상태를 갱신한다.
- 상태 변경 전후를 status history에 저장한다.
- 항목명과 선택 option label/value snapshot을 저장한다.
- inspection, item result, unit, history 변경은 하나의 트랜잭션이다.

## 이력 조회

- 모든 조회는 company_id를 포함한다.
- documentId 전표 집계와 unit 단위 row 목록을 별도 SQL·DTO로 처리한다.
- 전표 집계 결과에 LIMIT/OFFSET을 적용한다.
- 관리번호 이력은 `inspected_at DESC, inspection_id DESC`로 정렬한다.
- 전표·관리번호·품목·유형·결과·등급·기간 조건은 SQL에 적용한다.
- 페이지 ID 또는 집계 대상을 먼저 확정한 뒤 출력 JOIN을 수행한다.
- SQL 변경 시 `EXPLAIN`으로 인덱스, filesort, temporary table을 확인한다.

## 실패와 롤백

- 다른 회사의 category, template, item, option, unit, inspection 접근은 실패한다.
- SELECT가 아닌 item의 option 저장은 실패한다.
- INITIAL/original 조합과 CORRECTION·REINSPECTION/original 조합이 잘못되면 실패한다.
- item result 또는 상태 이력 저장 실패 시 앞선 모든 변경을 롤백한다.
- 일괄 검수 중 한 관리번호가 실패하면 전체를 롤백한다.

## 단위/API 테스트 연결

- template 기본값, 소속, active, 정렬은 `InspectionTemplateServiceTest`
- 검수 저장과 이력 조회는 `InspectionServiceTest`
- REST validation과 필터는 inspection API 테스트
- 공통 테스트 정책은 `pcs-test-strategy.md`를 따른다.

## DB 통합 테스트 수용 기준

- `InspectionPersistenceIntegrationTest`
- `InspectionOperationsPersistenceIntegrationTest`
- `InspectionTemplatePersistenceIntegrationTest`
- 회사 A가 회사 B의 템플릿·unit·이력을 조회·변경할 수 없다.
- 최초 검수는 row·snapshot·unit 상태·status history를 함께 저장한다.
- 정정·재검수는 기존 row를 보존하고 최초 chain ID를 유지한다.
- 중간 실패와 일괄 실패는 전체 rollback된다.
- unit 최신 상태는 마지막 검수 이력과 일치한다.
- 템플릿·항목·선택지 중첩 저장과 버전 제약을 검증한다.
