# Inspection Feature

## 목적

검수 대상 조회와 최초 검수, 정정, 재검수 저장을 담당한다. 이력 조회는 `inspection-history.md`, 템플릿 관리는 `inspection-template.md`가 원본이다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

| Method | API | 계약 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents` | 검수 대상 전표. 검색·기간·페이징 |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units` | 전표의 검수 대상 관리번호 |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 |
| POST | `/api/workspaces/{companyCode}/inspections/bulk` | 여러 관리번호 최초 검수 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` | 정정 이력 생성 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` | 재검수 이력 생성 |

## 화면

```text
static/inspection.html
static/css/pages/inspection.css
static/js/inspection.js
```

화면 흐름:

1. 검수 대상 입고 전표 검색·선택
2. 품목 묶음과 관리번호 확인
3. 관리번호 선택 후 검수 등록

- 전표 목록은 10개 단위로 전표 번호, 거래처, 입고일, 수량, 대기·완료·진행률을 비교한다.
- 품목 묶음은 품목명, 모델, 분류를 보여주고 선택한 묶음의 관리번호를 표시한다.
- 단일·일괄 검수는 같은 입력과 상태 기준을 사용한다.
- 오른쪽 보조 영역은 `design/workflow-panel.md`의 검수 active 흐름만 표시한다.

딥링크:

```text
/w/{companyCode}/inspection?documentId={id}&movementId={id}&unitId={id}
```

대상을 자동 선택하고 검수 입력 단계로 이동한다.

검수 화면에서 이력 상세·정정·재검수로 전환할 수 있지만 조회 계약과 상세 데이터는 `inspection-history.md`, UI는 `modal-dialog.md`를 따른다.

## 저장 규칙

- 최초: `inspectionType=INITIAL`, `originalInspectionId=null`
- 정정: `CORRECTION`, 원본 검수 ID 필요
- 재검수: `REINSPECTION`, 원본 검수 ID 필요
- 정정·재검수를 다시 기준으로 삼아도 최초 chain의 `originalInspectionId`를 유지한다.
- 기존 검수 row를 수정하지 않고 새 이력으로 저장한다.
- 요청에서 `inspectedAt`을 받지 않고 서버 현재 시각을 저장한다.
- `grade=NONE`은 저장할 수 없다.
- `grade=DEFECTIVE`이면 `salesStatus=UNAVAILABLE`이어야 한다.
- 저장 후 unit의 inspection status, grade, sales status를 최신 결과로 갱신한다.
- 상태 전후 값은 `tb_part_status_history`에 남긴다.

## 템플릿 입력

- 신규 검수는 active 템플릿·항목·선택지만 사용한다.
- 항목명과 선택값은 저장 시 snapshot으로 보존한다.

| inputType | 입력·저장 |
|---|---|
| CHECK | 통과·불합격·해당 없음 `result` |
| NUMBER | `valueNumber`와 결과 |
| TEXT | `valueText` |
| SELECT | 소속 option ID와 label/value snapshot |

SELECT가 아닌 항목에는 option을 저장할 수 없다.

## 트랜잭션

검수 row, 항목 결과, unit 상태, 상태 이력은 하나의 Facade 트랜잭션이다. 일괄 처리 중 한 건이 실패하면 전체를 롤백한다. DB 계약은 `inspection-db.md`를 따른다.

## 권한

- 회사 범위와 권한은 공통 규칙을 따른다.
- STAFF는 검수 권한이 꺼져 있으면 조회가 아닌 저장 작업을 수행할 수 없다.
- 관리번호 단위 조회와 상태 변경 책임을 섞지 않는다. 통합 조회는 `part-unit.md`가 담당한다.

## 테스트 수용 기준

- `InspectionServiceTest`, `InspectionDecisionValidatorTest`, `InspectionApiControllerTest`
- 최초 검수는 이력·항목 snapshot·unit 상태·상태 이력을 함께 저장한다.
- 이미 최초 검수가 끝난 unit은 INITIAL로 다시 저장할 수 없다.
- SELECT option 소속과 불량 판매 상태를 검증한다.
- 정정·재검수는 새 row를 추가하고 최초 chain ID를 유지한다.
- 권한 차단은 공통 security 테스트에서 검증한다.
