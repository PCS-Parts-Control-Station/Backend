# Dashboard Feature

## 목적

업무 대시보드에서 필요한 요약 지표, 우선 처리 목록, 운영 통계를 조회한다.

## 패키지

```text
com.pcs.domain.dashboard
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard/summary` | 대시보드 요약 |
| GET | `/api/workspaces/{companyCode}/dashboard/todos` | 우선 처리 목록 |
| GET | `/api/workspaces/{companyCode}/dashboard/statistics` | 운영 통계 |

## 주요 지표

- 검수 대기 개별 부품 수
- 출고 차단 개별 부품 수
- 오늘 입고 수량
- 오늘 출고 수량
- 안전 재고 이하 부품 수
- 카테고리별 재고 가치
- 최근 많이 출고된 부품 TOP
- 검수 불합격률
- 판매 가능 재고 비율

## 하네스 포인트

- 대시보드 집계는 SQL에서 처리한다.
- 기간별 통계에는 날짜 조건이 있어야 한다.
- TOP 조회에는 `ORDER BY`와 `LIMIT`이 있어야 한다.
