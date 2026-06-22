# History Feature

## 목적

개별 부품 타임라인, 입출고 전표 이력, 재고 변화 이력, 검수 이력, 상태 변경 이력을 조회한다.

검수 관리 화면에서 사용하는 전표 기준 검수 이력 조회는 검수 도메인 전용 기능으로 `docs/features/inspection-history.md`를 따른다.

## 패키지

```text
com.pcs.domain.history
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/history/units/{unitId}/timeline` | 개별 부품 전체 타임라인 |
| GET | `/api/workspaces/{companyCode}/history/stock-documents` | 입출고 전표 이력 |
| GET | `/api/workspaces/{companyCode}/history/stock-movements` | 입출고/취소 재고 변화 이력 |
| GET | `/api/workspaces/{companyCode}/history/inspections` | 검수/정정/재검수 이력 |
| GET | `/api/workspaces/{companyCode}/history/status-changes` | 상태 변경 이력 |

## 주요 규칙

- 이력 API는 read-only다.
- 원본 이력을 수정하거나 삭제하지 않는다.
- 타임라인은 입출고, 검수, 상태 변경 이력을 시간순으로 합쳐 보여준다.
- 기간, 거래처, 부품, 개별 부품, 처리자 필터를 지원한다.

## 하네스 포인트

- 이력 목록에는 기간 필터와 페이징이 있어야 한다.
- 반복 쿼리보다 JOIN 또는 명확한 SQL 집계를 우선한다.
- 이력 조회는 Java/JS 후처리보다 SQL 조건으로 필터링한다.
