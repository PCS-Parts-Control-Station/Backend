# Part Unit Feature

## 목적

부품 관리 화면에서 실제 부품을 관리번호 단위로 조회하고 상세 상태를 확인한다.

품목 마스터의 등록·수정·사양값 관리는 `docs/features/part.md`가 담당한다. 입고, 출고, 취소로 개별 부품 상태가 바뀌는 규칙은 `docs/features/stock.md`가 담당한다. 최초 검수, 정정, 재검수로 검수 상태·등급·판매상태가 바뀌는 규칙은 `docs/features/inspection.md`가 담당한다.

이 기능은 상태를 변경하지 않는다. 이미 구현된 입고·검수·출고·이력 데이터에서 관리번호를 찾고, 관리에 필요한 상태를 한 화면에 모아 보여주는 조회 기능이다.

## 패키지

```text
com.pcs.domain.part
```

`part-unit`은 새 Java 최상위 패키지를 만들지 않고 기존 `part` 도메인 안에 조회 API와 DTO를 둔다. 화면 경로와 문서명은 `part-unit`을 사용해 품목 마스터와 실제 부품을 구분한다.

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/part-units` | 관리번호 목록 검색 |
| GET | `/api/workspaces/{companyCode}/part-units/{unitId}` | 관리번호 상세 |

## 목록 검색

`GET /api/workspaces/{companyCode}/part-units`

Query:

| 이름 | 설명 |
|---|---|
| `keyword` | 관리번호, 제조사 시리얼, 품목명, 제조사 모델명, 제조사, 품목코드 검색 |
| `documentId` | 입출고 전표 필터. 해당 전표에 포함된 관리번호만 조회 |
| `categoryId` | 품목 분류 필터 |
| `partState` | 통계 카드 클릭으로 적용되는 상태 필터 |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | 기존 단순 목록 호환용 size 별칭 |

검색 조건에는 화면 select 형태의 `부품 상태` 필터와 `salesStatus`를 두지 않는다. 부품 상태는 상단 통계 카드를 클릭해 `partState`로 적용한다. 판매상태와 최근 처리 정보는 별도 검색 조건이나 별도 목록 컬럼으로 두지 않고, 화면의 `부품 상태` 표시값에 `/`로 합쳐 보여준다.

`partState` 의미:

| 값 | 조건 |
|---|---|
| `HELD` | 업무상 보유 기준. `검수대기 + 판매가능 + 판매불가 + 판매보류` |
| `WAITING` | `inspection_status = WAITING` |
| `SALES_AVAILABLE` | `unit_status = IN_STOCK`, `inspection_status = COMPLETED`, `sales_status = AVAILABLE`, `grade != DEFECTIVE` |
| `SALES_UNAVAILABLE` | `unit_status = IN_STOCK`, `inspection_status = COMPLETED`, `sales_status = UNAVAILABLE` |
| `SALES_HOLD` | `unit_status = IN_STOCK`, `inspection_status = COMPLETED`, `sales_status = HOLD` |
| `A`, `B`, `C` | `unit_status = IN_STOCK`, `inspection_status = COMPLETED`이고 `grade`가 같은 값 |
| `DEFECTIVE` | `unit_status = IN_STOCK`, `inspection_status = COMPLETED`이고 `grade = DEFECTIVE` |
| `OUTBOUND` | `unit_status = OUTBOUND` |

응답은 `PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse>` 구조를 사용한다.

목록 정렬은 `tb_pc_part_unit.updated_at DESC, tb_pc_part_unit.unit_id DESC` 기준이다. 관리번호는 사람이 보는 식별자이며 정렬 기준으로 사용하지 않는다.

목록 조회의 `totalElements`는 `SearchPartUnitSummaryResponse.totalCount`를 사용한다. 같은 where 조건으로 별도 `countPartUnits` 쿼리를 추가하지 않는다.

목록 SQL은 먼저 정렬 조건에 맞는 `unit_id` 페이지만 확정한 뒤, 그 결과에 대해서만 품목/분류/최근 입출고/최근 검수 정보를 붙인다. 최근 이력 서브쿼리가 전체 후보 관리번호에 대해 실행되지 않도록 한다.

요약 필드:

| 이름 | 설명 |
|---|---|
| `totalCount` | 현재 `partState`까지 포함한 조회 조건에 맞는 관리번호 수. 페이지 전체 건수의 원천 |
| `heldCount` | `partState`를 제외한 현재 검색어, 전표, 분류 조건 안의 업무상 보유 관리번호 수. `waitingCount + salesAvailableCount + salesUnavailableCount + salesHoldCount` 기준 |
| `waitingCount` | `partState`를 제외한 조건 안의 검수대기 관리번호 수. 출고된 부품을 제외하고 `unit_status = IN_STOCK` 기준 |
| `salesAvailableCount` | `partState`를 제외한 조건 안의 판매가능 관리번호 수. 출고된 부품을 제외하고 보유 기준으로 계산 |
| `salesHoldCount` | `partState`를 제외한 조건 안의 판매보류 관리번호 수. 출고된 부품과 검수대기 부품을 제외하고 검수완료 기준으로 계산 |
| `salesUnavailableCount` | `partState`를 제외한 조건 안의 판매불가 관리번호 수. 출고된 부품과 검수대기 부품을 제외하고 검수완료 기준으로 계산 |
| `gradeACount` | `partState`를 제외한 조건 안의 A등급 관리번호 수. 출고된 부품을 제외하고 보유 기준으로 계산 |
| `gradeBCount` | `partState`를 제외한 조건 안의 B등급 관리번호 수. 출고된 부품을 제외하고 보유 기준으로 계산 |
| `gradeCCount` | `partState`를 제외한 조건 안의 C등급 관리번호 수. 출고된 부품을 제외하고 보유 기준으로 계산 |
| `defectiveCount` | `partState`를 제외한 조건 안의 불량 관리번호 수. 출고된 부품을 제외하고 보유 기준으로 계산 |
| `outboundCount` | `partState`를 제외한 조건 안의 출고 관리번호 수 |
| `outboundAvailableCount` | 기존 API 호환 필드. `salesAvailableCount`와 같은 기준 |

출고 통계를 제외한 화면 통계는 현재 보유 중인 부품 관리 목적에 맞춰 출고된 부품을 제외하고 계산한다. 화면의 `보유부품`은 업무 흐름 기준 대표값이므로 `검수대기 + 판매가능 + 판매불가 + 판매보류`를 더한다.

목록 응답 주요 필드:

| 이름 | 설명 |
|---|---|
| `unitId` | 개별 부품 내부 식별자 |
| `internalSerialNo` | 화면의 관리번호 |
| `manufacturerSerialNo` | 제조사 시리얼 |
| `partId`, `partName`, `modelName`, `manufacturer`, `partCode` | 품목 마스터 정보 |
| `categoryId`, `categoryName` | 품목 분류 정보 |
| `unitStatus` | 입출고 상태 |
| `inspectionStatus` | 검수 상태 |
| `grade` | 등급 |
| `salesStatus` | 판매상태 |
| `lastStockDocumentNo`, `lastStockMovementType`, `lastStockProcessedAt` | 최근 입출고 이력 |
| `lastInspectionId`, `lastInspectionType`, `lastInspectedAt` | 최근 검수 이력 |
| `recentEventLabel`, `recentEventAt` | 화면의 최근 처리 표시용 값. 입출고 이력은 `입고`, `출고`, `입고취소`, `출고취소`처럼 movement type 기준으로 구분 |

## 상세 조회

`GET /api/workspaces/{companyCode}/part-units/{unitId}`

상세 응답은 목록의 기본 상태에 최근 입출고 이력과 최근 검수 이력을 함께 내려준다.

상세 응답 주요 필드:

| 이름 | 설명 |
|---|---|
| `unit` | 목록 응답과 같은 관리번호 기본 정보 |
| `stockHistories` | 최근 입출고 이력. 전표번호, 이동유형, 전후 상태, 처리자, 처리일을 포함 |
| `inspectionHistories` | 최근 검수 이력. 검수유형, 결과, 등급, 판매상태, 처리자, 처리일을 포함 |

상세 화면에서 정정·재검수 입력은 하지 않는다. 해당 업무는 `docs/features/inspection.md`와 `docs/features/inspection-history.md`의 화면으로 연결한다.

## 화면

```text
src/main/resources/static/part-units.html
src/main/resources/static/css/pages/part-units.css
src/main/resources/static/js/part-units.js
```

화면 기준:

- 사이드바 관리 메뉴에는 `부품 관리`로 표시한다.
- `품목`은 모델/마스터 정보이고, `부품`은 관리번호를 가진 실제 개별 물건이다.
- 필터는 검색어, 전표 선택, 분류 선택만 둔다.
- 부품 상태 select는 두지 않는다. 상단 통계 카드가 상태 필터 버튼 역할을 한다.
- 통계 카드는 `보유부품`, `검수대기`, `판매가능`, `판매불가`, `A등급`, `B등급`, `C등급`, `불량`, `판매보류`, `출고` 모두 클릭 가능해야 한다.
- 통계 카드 클릭 시 기존 검색어, 전표, 분류 조건은 유지하고 해당 `partState`만 바꿔 즉시 검색한다.
- 전표 선택은 분류 선택처럼 모달로 열고, 전표번호/거래처/품목명 기준으로 검색한 뒤 선택한다.
- 판매상태는 검색 조건과 별도 목록 컬럼에서 제외하고 `부품 상태` 표시값에 합쳐 보여준다.
- 분류 필터는 `parts.html`, `outbound-register.html`과 같은 `category-picker-button`과 분류 선택 모달을 사용한다.
- 목록은 관리번호, 품목, 분류, 부품 상태 순서로 보여준다.
- 화면 목록은 한 페이지에 15개씩 조회한다.
- 상단 통계는 제목이나 설명 박스 없이 카드만 배치한다. 첫 묶음은 `보유부품`, `검수대기`, `판매가능`, `판매불가`, `판매보류`로 둔다. 둘째 영역은 `등급 현황` 제목 아래 `A등급`, `B등급`, `C등급`, `불량`을 한 줄로 배치하고, `기타 상태` 제목 아래 `출고`를 배치한다.
- 목록의 관리번호, 품목, 분류, 부품 상태는 한 줄로 표시하고 넘치는 글자는 말줄임 처리한다.
- 목록의 관리번호 칸에서는 제조사 시리얼을 숨기고, 제조사 시리얼은 상세 패널에서 확인한다.
- 목록의 `부품 상태`는 `검수/등급/출고 상태 / 판매상태 / 최근처리` 형식으로 한 배지에 표시한다. 예: `검수대기 / 보류 / 입고 · 2026-06-08 05:30`.
- 입고되어 아직 등급이 없거나 `grade=NONE`인 부품은 `부품 상태`의 첫 값으로 `검수대기`를 표시한다.
- 출고된 부품은 첫 값으로 `출고`가 아니라 검수 등급을 표시하고, 최근 처리에는 `출고 · 처리일시`를 표시한다.
- 출고 완료된 부품은 실제 검수 당시 판매상태가 판매불가였더라도 현재 화면의 판매상태 표시값은 `판매완료`로 보여준다.
- 목록 컬럼은 고정 비율을 사용해 행마다 관리번호, 품목, 분류, 부품 상태 시작점이 달라지지 않게 한다.
- 행 클릭 또는 Enter/Space로 오른쪽 상세 패널을 연다.
- 상세 패널은 배경 오버레이를 쓰지 않고, 닫기 버튼·Escape·패널 밖 클릭으로 닫는다.
- 상세 패널은 상태 변경을 수행하지 않고 입출고 이력, 검수 이력, 출고 등록 화면으로 연결한다.
- 상세 패널 본문 기본 정보는 품목 상세와 같은 공통 `side-detail-card`, `detail-list` 구조를 사용한다.
- 상세 패널 본문의 분류와 최근 처리 항목은 상단 요약·상태와 중복되므로 별도 기본 정보 항목으로 표시하지 않는다.
- 상세 패널의 처리 흐름은 기존 타임라인형 `detail-section`, `process-flow-list` 구조로 표시한다.
- 입고 이력만 있고 검수 이력이 없으면 처리 흐름 끝에 `검수` 단계를 추가하고 `검수하러가기` 버튼을 그 단계 안에 표시한다. 버튼은 `/w/{companyCode}/inspection?documentId={입고전표ID}&movementId={입고묶음ID}&unitId={관리번호ID}`로 이동한다.
- 검수 이력이 있고 아직 출고되지 않았으며 판매가능이면 처리 흐름 끝에 `출고` 단계를 추가하고 `출고하러가기` 버튼을 그 단계 안에 표시한다. 버튼은 `/w/{companyCode}/outbound/new?unitId={관리번호ID}&partId={품목ID}&categoryId={분류ID}&keyword={관리번호}`로 이동한다.
- 검수 이력이 있지만 판매불가 또는 판매보류이면 출고 단계와 출고 버튼 대신 각각 `판매불가상태입니다.`, `판매보류상태입니다.`를 처리 흐름 안에 표시한다.
- 상세 하단 이력 버튼은 기본 `입고이력`으로 표시하고, 출고 이력이 있을 때만 `입출고이력`으로 바꾼다. `검수이력` 버튼은 검수 이력이 있을 때만 표시한다.
- 관리번호는 상세 패널 제목에만 표시하고 본문 기본 정보에는 중복 표시하지 않는다.

## 주요 규칙

- 목록과 상세 조회는 항상 `company_id` 범위를 지킨다.
- 기본 목록은 `tb_pc_part_unit.active = true`인 관리번호만 조회한다.
- 목록 전체 건수 요약은 목록 검색과 같은 조건으로 처리한다.
- 목록 전체 건수는 현재 `partState`까지 포함한 summary의 `totalCount`와 같아야 한다.
- 통계 카드 숫자는 `partState`를 제외한 검색어, 전표, 분류 조건 기준으로 계산한다. 그래야 상태 필터를 바꿀 때 기존 검색 조건을 유지한 채 다른 상태로 즉시 전환할 수 있다.
- 목록 행은 `LIMIT/OFFSET`으로 확정된 관리번호에 대해서만 상세 컬럼과 최근 이력을 계산한다.
- `salesStatus`는 검색 파라미터로 받지 않는다.
- 존재하지 않거나 다른 업체의 `unitId` 상세 조회는 `PART_UNIT_NOT_FOUND`로 실패한다.
- 부품 관리 API는 개별 부품의 상태, 등급, 판매상태를 변경하지 않는다.
- 상태 변경은 입고·출고·취소는 `stock`, 검수·정정·재검수는 `inspection`에서만 처리한다.

## 하네스 포인트

- `docs/features/part-unit.md`와 `docs/features/part-unit-db.md`가 실제 부품 조회의 주인 문서다.
- `part.md`는 품목 마스터 문서이며 실제 부품 조회 규칙을 중복 작성하지 않는다.
- `PartApiController`는 `/part-units` 목록과 상세 API를 노출해야 한다.
- `PartService`는 `PageQuery`로 page/size/limit을 정규화해야 한다.
- `PartMapper.xml`은 `tb_pc_part_unit`, `tb_pc_part`, `tb_part_category`, `LIMIT`, `OFFSET`, `COUNT(*)`를 포함해야 한다.
- `part-units.js`는 `pcs-api.js`, `pcs-pagination.js`, `pcs-common.js` 공통 기능을 사용해야 한다.

## Test Coverage

- Unit/service tests: `src/test/java/com/pcs/domain/part/service/PartServiceTest.java`
- API tests: `src/test/java/com/pcs/domain/part/api/PartApiControllerTest.java`
- Required checks:
- 목록 조회는 keyword, categoryId, partState, page, size, limit 조건을 Facade와 Service로 전달한다.
- 목록 조회는 documentId 조건을 Facade와 Service로 전달한다.
- 목록 조회는 판매상태 검색 조건을 받지 않는다.
- `partState`는 HELD, WAITING, 판매상태 계열, 등급, OUTBOUND 조건으로 SQL에 전달된다.
  - 응답은 `PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse>` 구조를 사용한다.
  - `totalElements`는 summary의 `totalCount`를 사용하고, 별도 관리번호 count 쿼리는 호출하지 않는다.
  - 상세 조회는 업체 범위 검증 후 존재하지 않는 관리번호를 `PART_UNIT_NOT_FOUND`로 처리한다.
  - STAFF 권한은 조회 API를 막지 않는다. 상태 변경 API가 아니기 때문이다.
