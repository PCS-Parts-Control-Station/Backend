# Part Feature

## 목적

품목 마스터, 개별 품목, 현재 재고, 품목별 상세 사양과 관리 기준을 담당한다.

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
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/active` | 품목 활성 여부 변경 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units` | 개별 품목 목록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}` | 개별 품목 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/sales-status` | 개별 품목 판매 상태 변경 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/active` | 개별 품목 활성 여부 변경 |

## 등록 / 수정 요청

품목 등록과 수정은 아래 값을 받는다.

```text
categoryId
partName
manufacturer
modelName
estimatedPrice
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
- 상세입력은 예상 단가, 안전 재고, 분류별 사양 항목을 함께 입력한다.
- 사양 항목은 해당 분류에 정의된 `tb_part_spec_definition` 기준만 입력할 수 있다.
- `SELECT` 사양은 `tb_part_spec_option`에 존재하는 선택지만 저장할 수 있다.
- 수정 시 기존 사양값은 삭제 후 현재 요청값으로 다시 저장한다.
- 검수 상태, 등급, 판매 상태는 개별 품목 기준으로 관리한다.
- 품목 마스터와 개별 품목의 `active` 의미는 `docs/ai/pcs-status-lifecycle-rules.md` 기준을 따른다.
- 품목 검색은 `keyword`, `categoryId`, `active`, `limit` 조건을 지원하고 기본 `active=true`, `limit=20`으로 조회한다.
- `grade = DEFECTIVE`인 개별 품목은 판매 가능 상태가 될 수 없다.
- 판매 상태 변경 시 `tb_part_status_history`를 저장한다.

## 하네스 포인트

- 품목 목록 검색과 필터링은 SQL에서 처리한다.
- 등록/수정은 Facade에서 업체 코드와 JWT의 업체 코드를 비교한 뒤 Service 트랜잭션에서 처리한다.
- 품목코드는 DB 저장 전에 생성하고 `tb_pc_part.part_code` 유니크 제약을 만족해야 한다.
- 사양값 저장은 `tb_part_spec_value`를 사용한다.
- 개별 품목 조회는 항상 `companyId`와 `partId` 범위를 함께 검증한다.
- 상태 변경은 Facade 트랜잭션 안에서 처리한다.
