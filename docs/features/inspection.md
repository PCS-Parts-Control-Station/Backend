# Inspection Feature

## 목적

검수 대상 조회, 최초 검수 등록, 검수 정정, 재검수, 검수 이력 조회를 담당한다.

검수 템플릿 관리는 같은 도메인 안의 하위 관리 기능이며, 상세 규칙은 `docs/features/inspection-template.md`를 따른다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents` | 검수 대상 입고 전표 목록. `keyword`, `partnerId`, `inspectionStatus`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units` | 전표별 검수 대상 관리번호 목록 |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/bulk` | 여러 관리번호 일괄 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` | 검수 정정 이력 생성 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` | 재검수 이력 생성 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록. `keyword`, `documentId`, `unitId`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |

개별 부품 기준 검수 이력은 별도 URL을 두지 않고 `GET /api/workspaces/{companyCode}/inspections?unitId={unitId}`로 조회한다.

## 화면

```text
src/main/resources/static/inspection.html
src/main/resources/static/css/inspection.css
src/main/resources/static/js/inspection.js
```

검수 관리 화면은 JS가 `/api/workspaces/{companyCode}/**` API를 호출한다. 전표 목록, 전표별 관리번호, 검수 등록, 일괄 검수, 검수 이력 상세, 정정 등록, 재검수 등록은 API 연동 대상이다.

화면 흐름:

1. 검수할 전표 선택
2. 개별 부품별 검수 대상 확인
3. 관리번호 선택 후 검수 등록
4. 검수 이력에서 상세, 정정 등록, 재검수 등록 확인

4단계 검수 이력 상세는 목록 아래에 펼치지 않고 모달로 표시한다. 모달 첫 화면은 관리번호, 검수 유형/등급/결과, 전표/부품/처리자/메모, 항목별 결과를 보여주고, 하단에서 정정 등록과 재검수 등록을 시작한다.

검수 이력 상세 모달은 `docs/ai/design/modal-dialog.md`의 `조회 상세 모달`과 `작업 전환 모달` 기준을 따른다. 첫 화면은 읽기 전용 상세이고, 정정 등록 또는 재검수 등록 버튼을 누르면 같은 모달 안에서 입력 폼으로 전환한다.

## 주요 규칙

- 최초 검수는 `inspectionType = INITIAL`이다.
- 정정은 `inspectionType = CORRECTION`이며 원본 검수 ID를 가진다.
- 재검수는 `inspectionType = REINSPECTION`이며 원본 검수 ID를 가진다.
- 정정 또는 재검수의 기준 이력이 이미 정정/재검수 이력이면, 새 이력은 기준 이력의 `originalInspectionId`를 유지한다.
- 검수 결과는 원본 row를 수정하지 않고 새 이력으로 저장한다.
- 검수 요청 body에는 `inspectedAt`을 받지 않는다.
- 서버가 검수 저장 시점의 현재 시각을 `tb_inspection.inspected_at`에 저장한다.
- 검수 등록 DTO에서는 `grade = NONE`을 허용하지 않는다.
- `grade = DEFECTIVE`이면 `salesStatus = UNAVAILABLE`이어야 한다.
- 검수 후 개별 부품의 `inspectionStatus`, `grade`, `salesStatus`를 갱신한다.
- 상태 변경 시 `tb_part_status_history`를 저장한다.
- 검수 항목 결과는 저장 시점의 항목명과 선택지 라벨/값 snapshot을 함께 저장한다.
- 과거 검수 결과는 템플릿, 항목, 선택지가 수정되거나 중지되어도 snapshot 기준으로 유지한다.

## 검수 템플릿 기반 입력

- 검수 등록 폼은 고정 항목이 아니라 검수 템플릿 기반 동적 폼이다.
- 검수 화면은 선택한 템플릿의 항목을 기준으로 `itemResults`를 구성한다.
- `inputType = SELECT` 항목은 선택지 ID와 선택지 snapshot을 함께 저장한다.
- `active = false`인 템플릿, 항목, 선택지는 신규 검수 입력에 노출하지 않는다.

항목 입력 방식:

| inputType | 화면 입력 | 저장 대상 |
|---|---|---|
| `CHECK` | 통과, 불합격, 해당 없음 | `result` |
| `NUMBER` | 숫자 값과 결과 상태 | `valueNumber`, `result` |
| `TEXT` | 텍스트 값 | `valueText` |
| `SELECT` | 템플릿 선택지 중 하나 | `selectedOptionId`, 선택지 snapshot |

## 하네스 포인트

- 검수 등록, 정정, 재검수는 단일 트랜잭션이어야 한다.
- 검수 저장과 개별 부품 상태 변경, 상태 변경 이력 저장은 같은 트랜잭션에서 처리한다.
- `grade = DEFECTIVE`이면 `salesStatus = UNAVAILABLE`이어야 한다.
- `inputType = SELECT`인 항목만 선택지를 사용할 수 있다.
- 검수 DB 구조와 제약은 `docs/features/inspection-db.md` 기준으로 검증한다.

## 테스트 기준

서비스 단위 테스트는 `src/test/java/com/pcs/domain/inspection/service/InspectionServiceTest.java`에서 관리한다.

현재 JUnit 검증 범위:

- 최초 검수 저장 시 검수 이력, 항목별 결과, 개별 부품 상태, 상태 변경 이력을 저장한다.
- 이미 검수 완료된 관리번호는 최초 검수로 다시 저장할 수 없다.
- 선택형 항목은 해당 항목에 속한 선택지만 저장할 수 있다.
- 정정 등록은 원본 검수 ID를 기준으로 신규 `CORRECTION` 이력을 생성한다.
- 재검수 등록은 기준 이력이 정정/재검수여도 기존 `originalInspectionId`를 유지한다.
- 검수 이력 목록은 필터, 기간, 페이징 값을 정규화해 조회한다.
- 검수 이력 상세는 항목별 결과를 포함해 반환한다.
