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
| `categoryId` | 품목 분류 필터 |
| `partState` | `WAITING`, `A`, `B`, `C`, `DEFECTIVE`, `OUTBOUND` |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | 기존 단순 목록 호환용 size 별칭 |

검색 조건에는 `salesStatus`를 두지 않는다. 판매상태는 별도 검색 조건이나 별도 목록 컬럼으로 두지 않고, 화면의 `부품 상태` 표시값에 합쳐 보여준다.

`partState` 의미:

| 값 | 조건 |
|---|---|
| `WAITING` | `inspection_status = WAITING` |
| `A`, `B`, `C` | `inspection_status = COMPLETED`이고 `grade`가 같은 값 |
| `DEFECTIVE` | `inspection_status = COMPLETED`이고 `grade = DEFECTIVE` |
| `OUTBOUND` | `unit_status = OUTBOUND` |

응답은 `PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse>` 구조를 사용한다.

목록 정렬은 `tb_pc_part_unit.updated_at DESC, tb_pc_part_unit.unit_id DESC` 기준이다. 관리번호는 사람이 보는 식별자이며 정렬 기준으로 사용하지 않는다.

요약 필드:

| 이름 | 설명 |
|---|---|
| `totalCount` | 조회 조건에 맞는 관리번호 수 |
| `waitingCount` | 조회 조건 안의 검수대기 관리번호 수 |
| `outboundAvailableCount` | 조회 조건 안의 출고 가능 관리번호 수 |

출고 가능 조건은 `docs/features/stock.md`의 출고 대상 조건을 따른다.

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
| `recentEventLabel`, `recentEventAt` | 화면의 최근 처리 표시용 값 |

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
- 필터는 검색어, 분류, 부품 상태만 둔다.
- 판매상태는 검색 조건과 별도 목록 컬럼에서 제외하고 `부품 상태` 표시값에 합쳐 보여준다.
- 분류 필터는 `parts.html`, `outbound-register.html`과 같은 `category-picker-button`과 분류 선택 모달을 사용한다.
- 목록은 관리번호, 품목, 분류, 부품 상태, 최근 처리 순서로 보여준다.
- 목록의 관리번호, 품목, 분류, 최근 처리는 한 줄로 표시하고 넘치는 글자는 말줄임 처리한다.
- 목록의 관리번호 칸에서는 제조사 시리얼을 숨기고, 제조사 시리얼은 상세 패널에서 확인한다.
- 목록의 `부품 상태`는 검수대기, 보류, 등급, 출고, 판매불가 같은 현재 관리 상태를 한 배지로 표시한다.
- 행 클릭 또는 Enter/Space로 오른쪽 상세 패널을 연다.
- 상세 패널은 배경 오버레이를 쓰지 않고, 닫기 버튼·Escape·패널 밖 클릭으로 닫는다.
- 상세 패널은 상태 변경을 수행하지 않고 입출고 이력, 검수 이력, 출고 등록 화면으로 연결한다.

## 주요 규칙

- 목록과 상세 조회는 항상 `company_id` 범위를 지킨다.
- 기본 목록은 `tb_pc_part_unit.active = true`인 관리번호만 조회한다.
- 검색과 요약은 SQL에서 같은 조건으로 처리한다.
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
  - 목록 조회는 판매상태 검색 조건을 받지 않는다.
  - `partState`는 WAITING, 등급, OUTBOUND 조건으로 SQL에 전달된다.
  - 응답은 `PageResultDto<SearchPartUnitResponse, SearchPartUnitSummaryResponse>` 구조를 사용한다.
  - 상세 조회는 업체 범위 검증 후 존재하지 않는 관리번호를 `PART_UNIT_NOT_FOUND`로 처리한다.
  - STAFF 권한은 조회 API를 막지 않는다. 상태 변경 API가 아니기 때문이다.
