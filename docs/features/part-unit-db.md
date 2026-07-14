# Part Unit DB Rules

## 목적

관리번호 목록·상세 조회의 SQL, 집계, 성능 계약을 정의한다. 상태 변경 정합성은 `stock-db.md`, `inspection-db.md`가 담당한다.

## 테이블

| 역할 | 테이블 |
|---|---|
| 기준 | `tb_pc_part_unit` |
| 품목·분류 | `tb_pc_part`, `tb_part_category` |
| 입출고 이력 | `tb_stock_movement_unit`, `tb_stock_movement`, `tb_stock_document` |
| 검수 이력 | `tb_inspection` |
| 처리자 | `tb_member` |

`tb_part_stock`은 품목 집계용이며 관리번호 목록 수량의 원천이 아니다.

## 목록 SQL

- unit, part, category 조인에 company_id를 포함한다.
- 기본은 unit active=true이며 partState=CANCELED만 active=false 취소 unit을 조회한다.
- keyword, partId, documentId, categoryId, partState를 `part-unit.md`와 동일하게 적용한다.
- salesStatus 단독 검색 조건은 받지 않는다.
- 정렬은 `updated_at DESC, unit_id DESC`다.

페이지 처리:

1. 조건과 정렬로 unit_id 페이지를 LIMIT/OFFSET으로 확정한다.
2. 확정된 ID에만 품목·분류·최근 이력을 조인한다.
3. 전체 후보에 최근 이력 상관 서브쿼리를 실행하지 않는다.

## Summary

- totalCount는 partState까지 포함한 목록 where를 사용한다.
- 다른 통계는 partState만 제외하고 나머지 조건을 유지한다.
- 같은 total count를 위한 별도 countPartUnits 쿼리를 추가하지 않는다.
- heldCount는 waiting + sales available + sales unavailable + sales hold다.
- 출고 외 상태·등급 통계는 IN_STOCK만 집계한다.
- 공통 판매 보류·불가 조건은 `mapper/global/PartUnitConditionSql.xml`을 사용한다.

## 최근 이력

입출고:

- movement unit → movement → document 순서
- `created_at DESC, movement_id DESC`
- 최신 movement ID를 한 번 결정하고 같은 JOIN에서 번호·유형·시각을 가져온다.

검수:

- `inspected_at DESC, inspection_id DESC`
- 최신 inspection ID를 한 번 결정하고 같은 JOIN에서 유형·시각을 가져온다.

최근 처리 값은 두 시각 중 최신을 사용한다. 상세 이력은 종류별 최대 10건이다.

## 인덱스

```text
idx_pc_part_unit_list_default
idx_pc_part_unit_list_inspection
idx_pc_part_unit_list_unit_status
idx_pc_part_unit_company_status
idx_pc_part_unit_work_status
```

실제 정의는 DDL이 원본이다. 목록 SQL 변경 시 `EXPLAIN`으로 정렬·필터 인덱스와 페이지 이후 JOIN을 확인한다.

## 실패 조건

- 다른 회사 unit이 목록·상세에 섞임
- 없는 또는 다른 회사 unit 상세 반환
- 허용되지 않은 partState
- salesStatus 검색 조건 추가
- summary와 목록의 공통 조건 불일치
- CANCELED 조회에 active=true 기본 조건이 남음

## DB 통합 테스트 수용 기준

- `PartPersistenceIntegrationTest`
- keyword, partId, documentId, categoryId가 목록과 summary에 동일하게 적용된다.
- 모든 partState가 feature 표의 조건과 일치한다.
- CANCELED는 active=false 취소 unit만 반환한다.
- 판매 상태는 응답에만 있고 검색 조건에는 없다.
- summary 전체 필드와 held 합계가 정확하다.
- 페이지 정렬과 전체 totalCount가 유지된다.
- 최근 이벤트가 movement 유형별 라벨 또는 검수로 정확히 선택된다.
- 기본·검수·출고 목록 인덱스가 DDL과 fixture에 존재한다.
- 다른 회사 상세는 `PART_UNIT_NOT_FOUND`다.
