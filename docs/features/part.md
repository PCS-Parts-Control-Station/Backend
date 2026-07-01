# Part Feature

## 목적

품목 마스터, 현재 재고 집계, 품목별 상세 사양과 관리 기준을 담당한다.

관리번호를 가진 실제 개별 부품 조회는 `docs/features/part-unit.md`가 담당한다.

## 패키지

```text
com.pcs.domain.part
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/parts` | 품목/재고 목록 검색 |
| POST | `/api/workspaces/{companyCode}/parts` | 품목 마스터 등록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}` | 품목 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}` | 품목 마스터 수정 |

## 등록 / 수정 요청

품목 등록과 수정은 아래 값을 받는다.

```text
categoryId
partName
manufacturer
modelName
safeQuantity
specValues[]
```

`specValues[]`는 선택한 분류의 사양 항목에 대한 입력값이다.

```text
specDefinitionId
valueText
valueNumber
valueBoolean
selectedOptionId
```

## 주요 규칙

- 화면 용어는 `품목명`, `제조사`, `제조사 모델명`, `분류`, `상세입력`을 사용한다.
- 품목코드는 사용자가 입력하지 않고 서버가 자동 생성한다.
- 품목코드는 분류, 제조사, 제조사 모델명, 입력된 사양값을 조합해 생성하고, 같은 업체 안에서 중복될 수 없다.
- 품목 마스터는 모델 단위 정보만 가진다.
- 실제 부품은 관리번호를 가진 개별 물건이며, 목록과 상세 조회 기준은 `docs/features/part-unit.md`를 따른다.
- 상세입력은 안전 재고와 분류별 사양 항목을 함께 입력한다.
- 사양 항목은 해당 분류에 정의된 `tb_part_spec_definition` 기준만 입력할 수 있다.
- `SELECT` 사양은 `tb_part_spec_option`에 존재하는 선택지만 저장할 수 있다.
- 수정 시 기존 사양값은 삭제 후 현재 요청값으로 다시 저장한다.
- 검수 상태, 등급, 판매 상태는 입고, 검수, 출고 도메인에서 관리하고 부품 관리 화면에서는 조회만 한다.
- 품목 마스터의 `active` 의미는 `docs/ai/pcs-status-lifecycle-rules.md` 기준을 따른다.
- 현재 품목 관리 화면에서는 품목 마스터 사용 중지 기능을 노출하지 않는다.
- 품목 관리 화면 헤더 오른쪽에는 품목 분류 화면으로 이동하는 `품목 분류` 버튼을 둔다.
- 품목 검색은 `keyword`, `categoryId`, `active`, `page`, `size`, `limit` 조건을 지원하고 기본 `active=true`로 조회한다.
- 현재 품목 API는 실제 부품 조회/상태 변경 엔드포인트를 제공하지 않는다. 실제 부품 조회는 `/part-units` API를 사용한다.

## 목록 / 검색 응답

- 품목 목록은 `PageResultDto<SearchPartResponse, SearchPartSummaryResponse>` 구조를 사용한다.
- `summary`는 `totalCount`, `totalStock`, `lowStockCount`를 포함한다.
- `totalElements`는 현재 검색 조건 기준 전체 품목 수이다.
- `currentStockQuantity`는 `tb_part_stock.quantity`를 기준으로 내려준다.
- 화면에서 전체 건수는 `totalElements`를 사용한다.
- 화면의 재고/재고 부족 요약은 현재 페이지 행 기준이 아니라 검색 조건 전체 기준의 `summary`를 사용한다.
- 품목 관리 목록은 `품목명`, `제조사 / 제조사 모델명`, `분류`, `현재 재고`, `안전 재고`를 한 행에서 비교할 수 있게 표시한다.
- 품목명, 품목코드, 제조사, 제조사 모델명, 분류명은 목록 행 높이를 늘리지 않고 한 줄 말줄임으로 처리한다. 상세 값은 오른쪽 상세 패널에서 확인한다.

## 하네스 포인트

- 품목 목록 검색과 필터링은 SQL에서 처리한다.
- 등록/수정은 Facade에서 업체 코드와 JWT의 업체 코드를 비교한 뒤 Service 트랜잭션에서 처리한다.
- 품목코드는 DB 저장 전에 생성하고 `tb_pc_part.part_code` 유니크 제약을 만족해야 한다.
- 사양값 저장은 `tb_part_spec_value`를 사용한다.
- 품목 상세 조회는 항상 `companyId`와 `partId` 범위를 함께 검증한다.
- 실제 부품 조회 API는 `docs/features/part-unit.md`와 `docs/features/part-unit-db.md`의 책임이다.

## 테스트 기준

단위 테스트:

- 품목코드는 분류명, 제조사, 제조사 모델명, 사양값을 기준으로 생성한다.
- 같은 입력은 같은 base code를 만든다.
- 중복 코드가 있으면 순번 후보를 증가시켜 다음 품목코드를 만든다.
- 품목코드는 DB 컬럼 길이를 넘지 않도록 잘라낸다.
- `safeQuantity`가 없으면 0으로 처리하고, 음수면 실패한다.
- 필수 사양값이 누락되면 실패한다.
- `BOOLEAN` 사양값은 미입력 시 `false`로 처리한다.
- `SELECT` 사양값은 현재 분류에 등록된 선택지만 허용한다.
- 같은 `specDefinitionId`가 중복 입력되면 실패한다.
- 현재 분류에 없는 `specDefinitionId`가 들어오면 실패한다.

API 테스트:

- 목록 조회는 기본 `active=true` 조건을 사용한다.
- 목록 조회는 `keyword`, `categoryId`, `page`, `size`, `limit` 조건과 `PageResultDto` 구조를 검증한다.
- 목록 응답은 `currentStockQuantity`와 summary 값을 포함해야 한다.
- 생성은 품목코드를 입력받지 않고 서버에서 자동 생성해야 한다.
- 생성은 `TEXT`, `NUMBER`, `SELECT`, `BOOLEAN` 사양값 저장 요청을 검증한다.
- 없는 분류 ID로 생성하면 실패해야 한다.
- 필수 사양값 누락, 잘못된 선택지, 음수 안전 재고는 실패해야 한다.
- 상세 조회는 품목 기본 정보와 사양값 목록을 함께 내려줘야 한다.
- 수정은 기본 정보와 사양값을 현재 요청 기준으로 교체 저장해야 한다.
- 수정 시 품목코드는 현재 입력값 기준으로 다시 생성해야 한다.
- 없는 품목 조회/수정은 실패해야 한다.

권한 테스트:

- `companyCode`와 JWT의 업체가 다르면 실패해야 한다.
- STAFF는 `STAFF_PART_CREATE` 권한이 없으면 생성과 수정을 할 수 없다.
