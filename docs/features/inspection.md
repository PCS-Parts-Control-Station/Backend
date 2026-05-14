# Inspection Feature

## 목적

검수, 검수 정정, 재검수, 검수 템플릿, 검수 항목, 선택지, 항목별 결과를 담당한다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-units` | 검수 대기 개별 부품 조회 |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` | 검수 정정 이력 생성 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` | 재검수 이력 생성 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/inspections` | 개별 부품 검수 이력 |
| GET | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 목록 |
| POST | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 생성 |
| GET | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` | 검수 템플릿 상세 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` | 검수 템플릿 수정 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/active` | 검수 템플릿 사용 여부 변경 |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items` | 검수 항목 추가 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}` | 검수 항목 수정 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/active` | 검수 항목 사용 여부 변경 |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options` | 선택지 추가 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}` | 선택지 수정 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}/active` | 선택지 사용 여부 변경 |

## 주요 규칙

- 최초 검수는 `inspection_type = INITIAL`이다.
- 정정은 `inspection_type = CORRECTION`이며 원본 검수 ID를 가진다.
- 재검수는 `inspection_type = REINSPECTION`이며 기준 검수 ID를 가진다.
- 검수 결과는 원본 row를 수정하지 않고 새 이력으로 저장한다.
- 검수 결과 저장 시 항목명과 선택지 값 snapshot을 함께 저장한다.
- 검수 후 개별 부품의 검수 상태, 등급, 판매 상태를 갱신한다.
- 상태 변경 시 `tb_part_status_history`를 저장한다.

## 하네스 포인트

- 검수 등록, 정정, 재검수는 단일 트랜잭션이어야 한다.
- `grade = DEFECTIVE`이면 `salesStatus = UNAVAILABLE`이어야 한다.
- `inputType = SELECT`인 항목만 선택지를 사용할 수 있다.
