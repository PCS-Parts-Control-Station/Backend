# Dashboard DB Rules

## 목적

대시보드가 기존 입출고·관리번호·검수 데이터에서 운영 지표를 조회하는 SQL 계약을 정의한다. 신규 상태를 저장하지 않는다.

## 사용 테이블

| 영역 | 테이블 |
|---|---|
| 입출고 | `tb_stock_document`, `tb_stock_movement` |
| 현재 상태 | `tb_pc_part_unit`, `tb_pc_part`, `tb_part_category` |
| 검수 | `tb_inspection` |

회사·거래처 등 출력 보조 테이블은 필요한 페이지 대상에만 조인한다.

## 공통 조건

- 모든 쿼리는 `company_id = #{companyId}`를 포함한다.
- 회사 활성 여부는 공통 `WorkspaceMapper`로 먼저 검증한다.
- 날짜는 `created_at >= start AND created_at < end` 반열린 구간을 사용한다.
- `DATE(column)`으로 인덱스 컬럼을 감싸지 않는다.
- 현재 재고 모수는 활성 `unit_status=IN_STOCK` unit이다.
- 취소된 원본 movement는 `canceled_movement_id IS NULL` 조건으로 수량에서 제외한다.

## 상단 집계

입고·출고:

- `movement_type`과 `movement_status=COMPLETED`
- 오늘 시작 이상, 다음 날 시작 미만
- `SUM(quantity)`

현재 unit:

- 대기: `inspection_status=WAITING`
- 가능: `inspection_status=COMPLETED`, `sales_status=AVAILABLE`
- 보류·불가: 현재 `sales_status`

오늘 불합격:

- `inspected_at` 오늘 범위
- `result=FAIL OR grade=DEFECTIVE`

## 재고 비율

- 모수는 활성 `IN_STOCK` unit 수다.
- 상태별 비율은 `FLOOR(quantity * 100 / total)`을 사용한다.
- 모수가 0이면 모든 비율은 0이다.
- 판매 가능은 반드시 검수 완료 조건을 포함한다.

## 우선 처리

`tb_pc_part_unit`을 `part_id`로 묶고 품목·분류를 출력한다.

우선순위:

1. 검수 대기
2. 판매 보류
3. 판매 불가

각 그룹은 수량 내림차순, 품목명, `part_id`로 안정 정렬한다. 결합 결과는 최대 20건이다.

## 최근 처리

입출고:

- 완료 전표와 취소되지 않은 movement
- 첫 품목명, 여러 품목이면 `외 N종`
- 전표 총수량과 생성 시각

검수:

- `INITIAL`, `CORRECTION`, `REINSPECTION`
- 같은 입고 전표·유형·처리 시각의 unit을 묶어 표시
- 처리 시각은 `inspected_at`

두 결과를 `UNION ALL`, `processed_at DESC`와 안정적인 ID 순서로 정렬해 최대 20건을 반환한다.

## 인덱스와 성능

기대 인덱스:

```text
idx_stock_movement_type_status_created
idx_stock_document_type_status_created
idx_pc_part_unit_company_status
idx_pc_part_unit_work_status
idx_inspection_result_date
idx_inspection_type_date
```

- 변경 시 `EXPLAIN` 또는 `EXPLAIN ANALYZE`로 인덱스와 조회 행을 확인한다.
- 출력 JOIN은 집계·페이지 대상 확정 후 적용한다.
- 병목이 생기면 최근 처리 분리 또는 캐시를 우선 검토한다.

## DB 통합 테스트 수용 기준

- `DashboardPersistenceIntegrationTest`
- 다른 회사와 취소 movement가 모든 집계에서 제외된다.
- 오늘 수량은 반열린 날짜 범위를 사용한다.
- 대기·판매 상태·우선 처리 품목/분류 집계가 정확하다.
- 우선 처리와 최근 처리 결과가 20건을 넘지 않는다.
- 판매 상태 비율의 0 모수와 내림 계산을 검증한다.
