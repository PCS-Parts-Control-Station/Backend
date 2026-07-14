# Part Unit Feature

## 목적

관리번호 단위 실제 부품의 목록과 상세 상태를 조회한다. 상태를 변경하지 않는다.

- 품목 마스터: `part.md`
- 입출고 상태 변경: `stock.md`
- 검수 상태 변경: `inspection.md`

## 패키지와 API

Java 패키지는 기존 `com.pcs.domain.part`를 공유한다.

| Method | API |
|---|---|
| GET | `/api/workspaces/{companyCode}/part-units` |
| GET | `/api/workspaces/{companyCode}/part-units/{unitId}` |

## 목록 조건

| Query | 의미 |
|---|---|
| keyword | 관리번호, 제조사 시리얼, 품목명·코드·제조사·모델 |
| partId | 특정 품목 딥링크 |
| documentId | 전표에 포함된 관리번호 |
| categoryId | 품목 분류 |
| partState | 상단 통계 카드 상태 |
| page/size/limit | 0 시작, 기본 20, 최대 100, limit은 size 별칭 |

별도 `salesStatus`와 부품 상태 select는 제공하지 않는다. 화면의 통계 카드가 `partState` 필터다.

## partState

| 값 | 조건 |
|---|---|
| HELD | WAITING + 판매 가능 + 판매 불가 + 판매 보류 |
| WAITING | 활성 IN_STOCK, 검수 대기 |
| SALES_AVAILABLE | 활성 IN_STOCK, 검수 완료, 판매 가능, 불량 아님 |
| SALES_UNAVAILABLE | 활성 IN_STOCK, 검수 완료, 판매 불가 |
| SALES_HOLD | 활성 IN_STOCK, 검수 완료, 판매 보류 |
| STOCK_UNAVAILABLE | 활성 IN_STOCK, 판매 불가. dashboard 딥링크 |
| STOCK_HOLD | 활성 IN_STOCK, 판매 보류. dashboard 딥링크 |
| A / B / C | 활성 IN_STOCK, 검수 완료, 해당 등급 |
| DEFECTIVE | 활성 IN_STOCK, 검수 완료, 불량 |
| OUTBOUND | 활성, 출고 상태 |
| CANCELED | 입고 취소로 unitStatus=CANCELED, active=false |

`CANCELED`만 취소 이력 조회를 위해 기본 active 조건의 예외다.

## 목록 응답

`PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse>`를 사용한다.

주요 행 필드:

- unitId, 관리번호, 제조사 시리얼
- partId, 품목명·코드·제조사·모델
- categoryId, categoryName
- unitStatus, inspectionStatus, grade, salesStatus
- 최근 입출고와 최근 검수 ID·유형·시각
- `recentEventLabel`, `recentEventAt`

최근 입출고 라벨은 `입고`, `출고`, `입고 취소`, `출고 취소`를 구분한다.

summary:

| 그룹 | 필드 |
|---|---|
| 전체·보유 | totalCount, heldCount |
| 판매 | waitingCount, salesAvailableCount, salesHoldCount, salesUnavailableCount |
| 등급 | gradeACount, gradeBCount, gradeCCount, defectiveCount |
| 출고 | outboundCount, outboundAvailableCount(호환 필드) |

- totalCount는 현재 partState까지 포함한 전체 건수이며 `totalElements`의 원천이다.
- 나머지 통계는 partState를 제외하고 검색어·전표·품목·분류 조건을 유지한다.
- heldCount는 waiting + available + unavailable + hold다.
- 출고 외 통계는 현재 보유 중인 IN_STOCK unit만 집계한다.

## 상세

상세는 기본 상태와 최근 입출고·검수 이력을 각각 최대 10건 제공한다.

```text
unit
stockHistories
inspectionHistories
```

정정·재검수 입력은 하지 않고 해당 검수 화면으로 연결한다. 다른 회사 또는 없는 unitId는 `PART_UNIT_NOT_FOUND`다.

## 화면

```text
static/part-units.html
static/css/pages/part-units.css
static/js/part-units.js
```

- 사이드바에는 `부품 관리`로 표시한다.
- 검색 필드는 검색어, 전표, 분류만 둔다.
- 화면 page size는 15다.
- 통계 카드는 보유·대기·판매 상태, 등급, 출고를 클릭 가능한 필터로 제공한다.
- 목록은 관리번호 / 품목 / 분류 / 부품 상태 순서다.
- 부품 상태는 검수·등급·출고 / 판매 상태 / 최근 처리를 하나의 짧은 표시로 합친다.
- 제조사 시리얼은 목록에서 숨기고 상세에서 표시한다.
- 행 선택은 `side-drawer.md`를 따른다.

URL 상태 복원:

```text
keyword, partId, documentId, categoryId, partState, page, unitId
```

공통 `PcsNavigationState`를 사용하고 페이지 전용 저장소를 만들지 않는다.

## 상세 이동

- 입고 후 미검수: 검수 단계 안에 `검수하러 가기`
- 검수 완료·판매 가능·미출고: `출고하러 가기`
- 판매 불가·보류: 버튼 대신 차단 상태 설명
- 전표 조회: 최근 documentId/documentNo 전달
- 검수 이력: documentId, partId, unitId, 최근 inspectionId 전달

처리 흐름 안의 행동과 하단 행동을 중복하지 않는다.

## 테스트 수용 기준

- 목록 조건과 허용 partState가 Service·Mapper에 전달된다.
- salesStatus 검색 조건을 받지 않는다.
- totalElements는 summary.totalCount를 사용한다.
- CANCELED가 active=false 취소 unit을 조회한다.
- navigation state key와 공통 script 순서를 검증한다.
- 조회 API는 STAFF 상태 변경 권한과 무관하게 허용한다.
- DB 계약은 `part-unit-db.md`를 따른다.
