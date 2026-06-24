# Dashboard Feature

## 목적

운영자가 첫 진입 시 오늘 처리량, 대기 작업, 현재 재고 상태, 최근 처리 흐름을 한 화면에서 확인하고 관련 업무 화면으로 이동할 수 있게 한다.

운영 현황은 조회 중심 화면이다. 등록, 수정, 취소 같은 업무 처리는 각 도메인 화면에서 수행한다.

## 패키지

```text
com.pcs.domain.dashboard
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard` | 운영 현황 통합 조회 |

초기 구현은 화면 진입 성능과 프론트 상태 관리를 단순하게 유지하기 위해 단일 API로 제공한다.

집계가 무거워지거나 화면 섹션별 캐시 정책이 달라지면 다음 API로 분리할 수 있다.

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard/summary` | 상단 요약 지표 |
| GET | `/api/workspaces/{companyCode}/dashboard/todos` | 우선 처리 목록 |
| GET | `/api/workspaces/{companyCode}/dashboard/statistics` | 재고 상태 통계 |

## 응답 구조

```json
{
  "summary": {
    "todayInboundQuantity": 0,
    "todayOutboundQuantity": 0,
    "waitingInspectionQuantity": 0,
    "availableQuantity": 0,
    "holdQuantity": 0,
    "unavailableQuantity": 0,
    "todayDefectiveInspectionCount": 0
  },
  "todos": [
    {
      "type": "INSPECTION_WAITING",
      "label": "검수 대기",
      "title": "RAM DDR4 16GB 외 1종",
      "count": 10,
      "route": "inspection"
    }
  ],
  "stockStatus": {
    "availableQuantity": 0,
    "holdQuantity": 0,
    "unavailableQuantity": 0,
    "availableRatio": 0,
    "holdRatio": 0,
    "unavailableRatio": 0
  },
  "recentActivities": [
    {
      "type": "INBOUND",
      "label": "입고",
      "documentNo": "IN-20260622-0001",
      "title": "RAM DDR4 16GB",
      "quantity": 10,
      "processedAt": "2026-06-22 10:30",
      "route": "inbound"
    }
  ]
}
```

## 집계 기준

- 오늘 입고 수량: 완료된 입고 전표의 재고 이동 수량 합계
- 오늘 출고 수량: 완료된 출고 전표의 재고 이동 수량 합계
- 입출고 수량 집계에서는 취소된 이동을 제외한다. 즉 `canceled_movement_id IS NULL`인 이동만 집계한다.
- 검수 대기 수량: 활성 개별 부품 중 `inspection_status = WAITING` 수량
- 판매 가능 수량: 현재 재고(`unit_status = IN_STOCK`)인 활성 개별 부품 중 `inspection_status = COMPLETED`, `sales_status = AVAILABLE` 수량
- 판매 보류 수량: 현재 재고(`unit_status = IN_STOCK`)인 활성 개별 부품 중 `sales_status = HOLD` 수량
- 판매 불가 수량: 현재 재고(`unit_status = IN_STOCK`)인 활성 개별 부품 중 `sales_status = UNAVAILABLE` 수량
- 오늘 불합격 검수 건수: 오늘 처리된 검수 이력 중 `result = FAIL` 또는 불량 등급 건수
- 최근 처리 흐름: 최근 입고 전표, 출고 전표, 검수 이력을 처리일 기준 내림차순으로 조회한다.
- 최근 검수 이력은 같은 입고 전표, 검수 유형, 처리 시각으로 묶어서 표시한다.

오늘 기준은 서버의 업무 기준 날짜 범위를 사용한다. 단순히 DB `DATE()` 함수에 의존하지 말고 시작 일시와 종료 일시를 조건으로 전달한다.

## 주요 지표

- 검수 대기 개별 부품 수
- 출고 차단 개별 부품 수
- 오늘 입고 수량
- 오늘 출고 수량
- 안전 재고 이하 부품 수
- 품목 분류별 재고 가치
- 최근 많이 출고된 부품 TOP
- 검수 불합격률
- 판매 가능 재고 비율

## 화면 구성

상단 영역:

- 제목: `운영 현황`
- 설명은 한 줄만 둔다.
- 주요 이동 버튼은 `입고 등록`을 우선 배치한다.
- `검수 관리`, `출고 등록`, `이력 조회`는 보조 버튼 또는 링크로 둔다.

요약 지표:

- 큰 카드 여러 개를 과도하게 늘리지 않는다.
- 기본 카드 4개를 우선 사용한다.
- 권장 카드: `오늘 입고`, `오늘 출고`, `검수 대기`, `현재 판매 가능`
- 보류/판매 불가/불합격은 보조 섹션에서 보여준다.

본문 섹션:

- 우선 처리: 검수 대기, 출고 보류, 출고 불가, 오늘 불합격 검수처럼 사용자가 바로 처리해야 하는 항목
- 재고 상태: 판매 가능, 보류, 판매 불가 수량과 비율
- 최근 처리: 최근 입고, 출고, 검수 기록

운영 현황 화면에는 단계형 보조 패널을 두지 않는다. 이 화면은 프로세스 입력 화면이 아니라 조회 허브이므로, 화면 전체 폭을 사용해 지표와 목록의 가독성을 우선한다.

## 화면 구성 설계

운영 현황은 사용자가 직접 데이터를 입력하는 화면이 아니라 현재 상태를 빠르게 판단하는 화면이다. 따라서 화면은 “요약 → 처리 필요 항목 → 상세 흐름” 순서로 구성한다.

### 1. 헤더

역할:

- 현재 화면이 운영 상태를 보는 화면임을 알려준다.
- 주요 업무 화면으로 빠르게 이동한다.

구성:

- 좌측: `운영 현황` 제목과 한 줄 설명
- 우측 버튼:
  - `입고 등록`: 주요 버튼
  - `출고 등록`: 보조 버튼
  - `검수 관리`: 보조 버튼

`이력 조회`는 헤더의 주요 버튼으로 두지 않는다. 최근 처리 섹션에서 자연스럽게 연결하는 편이 화면 목적에 맞다.

### 2. 상단 요약 지표

역할:

- 오늘 업무량과 현재 처리 대기 상태를 바로 보여준다.

카드 구성:

| 카드 | 표시 값 | 기준 |
|---|---|---|
| 오늘 입고 | `todayInboundQuantity` | 오늘 완료된 입고 수량 |
| 오늘 출고 | `todayOutboundQuantity` | 오늘 완료된 출고 수량 |
| 검수 대기 | `waitingInspectionQuantity` | 현재 검수 대기 개별 부품 수 |
| 현재 판매 가능 | `availableQuantity` | 현재 출고 가능한 개별 부품 수 |

카드는 4개를 기본으로 하고 데스크톱에서는 2행 2열로 배치한다. 보류, 판매 불가, 불합격은 상단 카드로 올리면 화면이 복잡해지므로 재고 비율 또는 우선 처리 섹션에서 보조 정보로 보여준다.

### 3. 우선 처리

역할:

- 운영자가 지금 먼저 확인할 항목을 보여준다.

표시 기준:

- 검수 대기 품목
- 출고 보류 품목
- 출고 불가 품목

표시 방식:

- 최대 20개를 조회하고 화면에는 5개씩 표시한다.
- 이전/다음 버튼으로 페이지를 이동한다.
- 항목 유형 배지, 품목명, 수량을 한 줄에 배치
- 행 전체 클릭으로 관련 화면 이동
- 검수 대기는 `검수 관리`, 보류/불가는 `출고 관리` 또는 재고 관련 화면으로 이동

우선 처리 항목이 없으면 빈 카드 대신 간결한 문구만 표시한다.

### 4. 재고 상태

역할:

- 현재 재고가 출고 가능한 상태인지 비율로 파악한다.

구성:

- 판매 가능
- 판매 보류
- 판매 불가

재고 상태는 도넛 차트와 범례로 표시한다. 차트 중앙에는 총 재고 수량을 표시하고, 범례에는 상태별 수량과 비율을 함께 보여준다.

색상은 모두 같은 파란 계열로 두지 않는다. 판매 가능, 판매 보류, 판매 불가는 서로 구분되는 색을 사용하되, 불필요하게 강한 경고색으로 화면을 지배하지 않게 한다.

차트는 화면 진입 시 1.1초 정도의 완만한 채움 애니메이션을 사용할 수 있다. 애니메이션은 운영 판단을 방해하지 않도록 한 번만 실행한다.

### 5. 최근 처리

역할:

- 입고, 출고, 검수 흐름이 최근에 정상적으로 발생하고 있는지 확인한다.

구성:

- 입고
- 출고
- 최초 검수
- 정정
- 재검수

표시 방식:

- 최대 20개를 조회하고 화면에는 5개씩 표시한다.
- 이전/다음 버튼으로 페이지를 이동한다.
- 처리 유형 배지, 품목 요약, 전표번호, 수량, 처리일 표시
- 행 전체 클릭으로 관련 이력 또는 관리 화면 이동

### 6. 상태별 화면 처리

로딩:

- 상단 요약 값은 `0` 또는 흐린 상태로 시작한다.
- 각 섹션은 “불러오는 중” 문구를 사용한다.

빈 결과:

- 우선 처리: `현재 우선 처리 항목이 없습니다.`
- 최근 처리: `최근 처리 내역이 없습니다.`
- 숫자 지표는 모두 `0`으로 표시한다.

오류:

- 화면 상단에 한 줄 오류 메시지를 표시한다.
- 각 섹션은 빈 상태로 되돌린다.
- 인증 오류와 워크스페이스 오류는 공통 API 유틸의 리다이렉트 정책을 따른다.

### 7. 반응형 기준

데스크톱:

- 상단은 `요약 카드 2행 2열`과 `재고 비율`을 좌우 배치
- 하단은 `처리 필요 TOP`과 `최근 처리`를 좌우 배치

태블릿:

- 상단과 하단 섹션은 세로 배치
- 요약 카드는 2열 유지

모바일:

- 요약 카드 1열
- 최근 처리 목록은 카드형 한 줄 흐름으로 표시
- 헤더 버튼은 세로 배치 또는 1열 배치

## DB 집계 기준 설계

대시보드는 신규 상태를 저장하지 않는다. 모든 값은 기존 입출고, 개별 부품, 검수 테이블에서 조회 시점에 집계한다.

### 공통 조건

- 모든 쿼리는 `company_id = #{companyId}` 조건을 포함한다.
- 회사 활성 상태는 `tb_company.active = TRUE`로 먼저 확인한다.
- 날짜 조건은 `DATE(column)` 변환 대신 `created_at >= start`와 `created_at < end` 범위 조건을 사용한다.
- 현재 재고 수량은 `tb_pc_part_unit.active = TRUE`와 `unit_status = IN_STOCK` 기준이다.
- 취소된 재고 이동은 `tb_stock_movement.canceled_movement_id IS NULL` 조건으로 제외한다.

### 상단 요약 집계

`todayInboundQuantity`:

- 테이블: `tb_stock_movement`
- 조건:
  - `movement_type = INBOUND`
  - `movement_status = COMPLETED`
  - `canceled_movement_id IS NULL`
  - `created_at >= todayStart`
  - `created_at < tomorrowStart`
- 값: `SUM(quantity)`

`todayOutboundQuantity`:

- 테이블: `tb_stock_movement`
- 조건:
  - `movement_type = OUTBOUND`
  - `movement_status = COMPLETED`
  - `canceled_movement_id IS NULL`
  - `created_at >= todayStart`
  - `created_at < tomorrowStart`
- 값: `SUM(quantity)`

`waitingInspectionQuantity`:

- 테이블: `tb_pc_part_unit`
- 조건:
  - `active = TRUE`
  - `unit_status = IN_STOCK`
  - `inspection_status = WAITING`
- 값: `COUNT(*)`

`availableQuantity`:

- 테이블: `tb_pc_part_unit`
- 조건:
  - `active = TRUE`
  - `unit_status = IN_STOCK`
  - `inspection_status = COMPLETED`
  - `sales_status = AVAILABLE`
- 값: `COUNT(*)`

`holdQuantity`:

- 테이블: `tb_pc_part_unit`
- 조건:
  - `active = TRUE`
  - `unit_status = IN_STOCK`
  - `sales_status = HOLD`
- 값: `COUNT(*)`

`unavailableQuantity`:

- 테이블: `tb_pc_part_unit`
- 조건:
  - `active = TRUE`
  - `unit_status = IN_STOCK`
  - `sales_status = UNAVAILABLE`
- 값: `COUNT(*)`

`todayDefectiveInspectionCount`:

- 테이블: `tb_inspection`
- 조건:
  - `inspected_at >= todayStart`
  - `inspected_at < tomorrowStart`
  - `result = FAIL OR grade = DEFECTIVE`
- 값: `COUNT(*)`

### 재고 상태 비율

기준 모수:

- `tb_pc_part_unit`
- `active = TRUE`
- `unit_status = IN_STOCK`

비율 계산:

- `availableRatio = FLOOR(availableQuantity * 100 / totalQuantity)`
- `holdRatio = FLOOR(holdQuantity * 100 / totalQuantity)`
- `unavailableRatio = FLOOR(unavailableQuantity * 100 / totalQuantity)`
- `totalQuantity = 0`이면 모든 비율은 `0`

주의:

- 반올림을 사용하면 세 항목 합이 100을 초과할 수 있으므로 `FLOOR`를 사용한다.
- 판매 가능은 `inspection_status = COMPLETED` 조건을 포함한다. 검수 전 부품이 `sales_status = AVAILABLE`로 잘못 들어가더라도 판매 가능으로 집계하지 않는다.

### 우선 처리 집계

검수 대기:

- 테이블: `tb_pc_part_unit`, `tb_pc_part`
- 그룹: `part_id`
- 조건:
  - `unit_status = IN_STOCK`
  - `inspection_status = WAITING`
  - `active = TRUE`
- 정렬: 수량 내림차순, 품목명 오름차순

판매 보류:

- 테이블: `tb_pc_part_unit`, `tb_pc_part`
- 그룹: `part_id`
- 조건:
  - `unit_status = IN_STOCK`
  - `sales_status = HOLD`
  - `active = TRUE`
- 정렬: 수량 내림차순, 품목명 오름차순

판매 불가:

- 테이블: `tb_pc_part_unit`, `tb_pc_part`
- 그룹: `part_id`
- 조건:
  - `unit_status = IN_STOCK`
  - `sales_status = UNAVAILABLE`
  - `active = TRUE`
- 정렬: 수량 내림차순, 품목명 오름차순

전체 결과는 업무 우선순위 순서로 정렬한다.

1. 검수 대기
2. 출고 보류
3. 출고 불가

최종 표시 개수는 최대 6개로 제한한다.

### 최근 처리 집계

입출고 처리:

- 테이블: `tb_stock_document`, `tb_stock_movement`, `tb_pc_part`
- 조건:
  - `tb_stock_document.document_status = COMPLETED`
  - `tb_stock_movement.canceled_movement_id IS NULL`
- 품목 요약:
  - 첫 번째 품목명
  - 라인이 2개 이상이면 `외 N종`
- 수량: `SUM(tb_stock_movement.quantity)`
- 처리일: `tb_stock_document.created_at`

검수 처리:

- 테이블: `tb_inspection`, `tb_pc_part_unit`, `tb_pc_part`
- 유형:
  - `INITIAL`: 검수
  - `CORRECTION`: 정정
  - `REINSPECTION`: 재검수
- 수량: 같은 입고 전표, 검수 유형, 처리일에 속한 검수 이력 건수
- 처리일: `tb_inspection.inspected_at`
- 전표번호는 해당 관리번호와 연결된 입고 전표를 보조 조회한다.
- 여러 품목이 같은 검수 이벤트에 포함되면 첫 품목명과 `외 N종`으로 요약한다.

최종 정렬:

- 입출고 처리와 검수 처리를 `UNION ALL`로 합친다.
- `processed_at DESC`
- 최대 5개

### 인덱스 사용 기대

대시보드 집계는 다음 인덱스를 우선 사용해야 한다.

- `tb_stock_movement.idx_stock_movement_type_status_created`
- `tb_stock_document.idx_stock_document_type_status_created`
- `tb_pc_part_unit.idx_pc_part_unit_company_status`
- `tb_pc_part_unit.idx_pc_part_unit_work_status`
- `tb_inspection.idx_inspection_result_date`
- `tb_inspection.idx_inspection_type_date`

조회 속도가 느려지면 가장 먼저 최근 처리 집계를 분리하거나 캐시하는 방식을 검토한다.

## 프론트 구현 기준

- `dashboard.html`의 하드코딩된 운영 수치는 제거한다.
- `dashboard.html`에서 `dashboard.js`를 로드한다.
- `dashboard.js`는 `GET /api/workspaces/{companyCode}/dashboard`를 호출한다.
- 로딩, 빈 결과, 오류 상태를 화면 섹션별로 표시한다.
- API 응답이 비어 있으면 숫자는 0으로 표시한다.
- 각 카드와 우선 처리 항목은 관련 화면으로 이동할 수 있어야 한다.
- 화면 진입 시 사용자가 가장 먼저 보는 영역은 요약 지표와 우선 처리 목록이어야 한다.
- 모바일에서는 요약 카드가 1열 또는 2열로 접히고, 최근 처리 목록은 카드형으로 전환한다.

## 하네스 포인트

- 회사가 활성 상태인지 검증한다.
- 요청한 대시보드 데이터가 해당 회사 소속 데이터만 집계하는지 검증한다.
- 대시보드 집계는 SQL에서 처리한다. 전체 목록 조회 후 Java에서 필터링하지 않는다.
- 오늘 기준 집계에는 시작 일시와 종료 일시 조건이 있어야 한다.
- 최근 처리 목록에는 `ORDER BY`와 `LIMIT`이 있어야 한다.
- 취소된 입출고 이동은 수량 집계에서 제외한다.
- 프론트 화면에 운영 수치를 하드코딩하지 않는다.
