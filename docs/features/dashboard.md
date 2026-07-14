# Dashboard Feature

## 목적

운영자가 첫 진입에서 오늘 처리량, 대기 작업, 현재 재고 상태, 최근 흐름을 확인하고 관련 업무로 이동하게 한다. 조회 전용이며 데이터 변경은 각 도메인이 담당한다.

## 패키지

```text
com.pcs.domain.dashboard
```

## API

| Method | API |
|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard` |

초기 계약은 단일 API다. 집계 비용이나 캐시 정책이 달라질 때만 summary/todos/statistics API 분리를 검토한다.

## 응답

| 영역 | 필드 |
|---|---|
| `summary` | `todayInboundQuantity`, `todayOutboundQuantity`, `waitingInspectionQuantity`, `availableQuantity`, `holdQuantity`, `unavailableQuantity`, `todayDefectiveInspectionCount` |
| `todos[]` | `type`, `label`, `title`, `count`, `partId`, `categoryName`, `route`, `partState` |
| `stockStatus` | 상태별 수량과 `availableRatio`, `holdRatio`, `unavailableRatio` |
| `recentActivities[]` | `type`, `label`, `documentNo`, `title`, `quantity`, `processedAt`, `route` |

`todos`와 `recentActivities`는 API에서 각각 최대 20건을 반환하고 화면은 5건씩 이전/다음으로 표시한다.

## 지표 의미

| 지표 | 기준 |
|---|---|
| 오늘 입고·출고 | 오늘 완료된 원본 movement 수량. 취소 movement 제외 |
| 검수 대기 | 활성·재고 보유 unit 중 `inspectionStatus=WAITING` |
| 판매 가능 | 재고 보유·검수 완료·`salesStatus=AVAILABLE` |
| 판매 보류·불가 | 재고 보유 unit의 현재 sales status |
| 오늘 불합격 | 오늘 `result=FAIL` 또는 `grade=DEFECTIVE` 검수 |
| 최근 처리 | 완료 입출고와 검수 이력을 처리일 내림차순으로 결합 |

정확한 SQL, 날짜 범위, 취소 제외, 인덱스는 `dashboard-db.md`가 원본이다.

## 화면

화면 구조와 반응형은 `docs/ai/design/dashboard.md`를 따른다. 화면에는 다음 도메인 계약만 적용한다.

헤더:

- 제목 `운영 현황`
- primary `입고 등록`
- secondary `출고 등록`, `검수 관리`
- 이력 조회는 최근 처리 영역에서 연결

상단 요약:

- 오늘 입고
- 오늘 출고
- 검수 대기
- 현재 판매 가능

본문:

- 우선 처리: 검수 대기, 판매 보류, 판매 불가
- 재고 상태: 가능·보류·불가 수량과 비율
- 최근 처리: 입고, 출고, 최초 검수, 정정, 재검수

운영 현황은 조회 허브이므로 workflow 패널을 두지 않고 전체 폭을 사용한다.

## 이동 계약

- 검수 대기는 `partId`와 함께 검수 화면으로 이동한다.
- 판매 보류·불가는 `route=part-units`, `partState=STOCK_HOLD` 또는 `STOCK_UNAVAILABLE`을 사용한다.
- 최근 처리는 해당 전표 또는 검수 이력 화면으로 이동한다.
- 프론트가 `type`을 다시 해석하지 않도록 API가 `route`와 필요한 filter 값을 제공한다.

## 상태 화면

- 로딩: 숫자 0과 섹션별 불러오는 중
- 빈 결과: 우선 처리·최근 처리에 짧은 빈 문구
- 오류: 상단 오류와 빈 섹션, 인증·workspace 오류는 공통 API redirect
- 하드코딩된 운영 수치를 HTML에 두지 않는다.

## 프론트

- `dashboard.js`가 `GET /dashboard`를 한 번 호출한다.
- 모든 숫자와 목록은 API 응답으로 갱신한다.
- 차트는 응답 수량·비율을 사용하고 reduced motion을 지원한다.
- 모바일 목록은 카드형으로 전환한다.

## 권한·회사 범위

- 권한은 `pcs-permission-rules.md`를 따른다.
- URL과 인증 회사 범위를 검증한다.
- 다른 회사 데이터는 어떤 집계에도 포함하지 않는다.

## 테스트 수용 기준

- `DashboardServiceTest`, `DashboardFacadeTest`, `DashboardApiControllerTest`
- DB 계약은 `DashboardPersistenceIntegrationTest`와 `dashboard-db.md`를 따른다.
- workspace 불일치와 공통 응답을 검증한다.
- 취소 이동과 다른 회사 데이터를 제외한다.
- API 목록 상한 20건과 화면 5건 단위 표시 계약을 유지한다.
