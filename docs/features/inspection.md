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
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents` | 검수 대상 입고 전표 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units` | 전표별 검수 대상 관리번호 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-units` | 검수 대기 개별 부품 조회 |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/bulk` | 여러 관리번호 일괄 최초 검수 등록 |
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

## 화면 초안

검수 관리 화면은 `src/main/resources/static/inspection.html`, `src/main/resources/static/css/inspection.css`, `src/main/resources/static/js/inspection.js`에 정적 mock 기반으로 구성한다.

현재 화면 흐름:

1. `검수할 전표 선택`
   - 입고 전표를 먼저 선택한다.
   - 전표별 총수량, 완료, 대기, 진행률을 보여준다.
2. `부품별 검수 대상`
   - 선택한 전표 안의 부품 묶음과 관리번호를 보여준다.
   - 부품 묶음 안에서 개별 관리번호 검수, 선택 검수, 대기만 선택을 지원한다.
3. `검수 등록`
   - 2단계에서 관리번호를 선택한 뒤에만 활성화한다.
   - 검수 대상 요약, 검수 템플릿, 결과/등급/판매상태, 템플릿 항목, 메모를 입력한다.
4. `참고 이력`
   - 최근 검수, 정정, 재검수 기록을 보여준다.
   - 개별 검수 이력 상세와 항목별 결과를 확인한다.

## 검수 템플릿 기반 폼

검수 등록 폼은 고정 항목 폼이 아니라 검수 템플릿 기반 동적 폼이어야 한다.

- `tb_inspection_template`은 검수 양식 본체다.
- `tb_inspection_template_item`은 템플릿 안의 검수 항목이다.
- `tb_inspection_template_item_option`은 `input_type = SELECT` 항목의 선택지다.
- 검수 화면에서 작업자는 템플릿을 선택하고, 선택된 템플릿의 항목 결과를 입력한다.
- 템플릿 항목의 개수, `BASIC`/`DETAIL` 그룹, 입력 방식, 필수 여부, 실패 정책은 관리자 템플릿 관리에서 설정한다.

항목 입력 방식:

| input_type | 화면 입력 | 저장 대상 |
|---|---|---|
| `CHECK` | 통과, 불합격, 해당 없음 | `tb_inspection_item_result.result` |
| `NUMBER` | 숫자 값과 결과 상태 | `value_number`, `result` |
| `TEXT` | 텍스트 값 | `value_text` |
| `SELECT` | 템플릿 선택지 중 하나 | `selected_option_id`, 선택지 snapshot |

검수 저장 시 `itemResults`는 선택한 템플릿 항목 기준으로 구성한다. 항목명과 선택지 라벨/값은 이후 템플릿이 수정돼도 과거 이력이 흔들리지 않도록 snapshot으로 저장한다.

## 검수 템플릿 관리 화면 초안

검수 템플릿은 검수 도메인 전용 관리 화면으로 분리한다. 범용 `템플릿 관리`보다 `검수 템플릿 관리`가 적합하다.

필요 화면:

1. 템플릿 목록
   - 템플릿명, 품목 분류, 버전, 사용 여부, 생성자, 수정일
2. 템플릿 기본 정보
   - 템플릿명, 품목 분류, 버전, 사용 여부
3. 항목 구성
   - 항목명, 그룹(`BASIC`/`DETAIL`), 입력 방식, 필수 여부, 정렬 순서, 등급 영향도, 실패 정책
4. 선택지 설정
   - `SELECT` 항목의 옵션명, 옵션값, 정렬 순서, 사용 여부

## 주요 규칙

- 최초 검수는 `inspection_type = INITIAL`이다.
- 정정은 `inspection_type = CORRECTION`이며 원본 검수 ID를 가진다.
- 재검수는 `inspection_type = REINSPECTION`이며 기준 검수 ID를 가진다.
- 검수 결과는 원본 row를 수정하지 않고 새 이력으로 저장한다.
- 검수 결과 저장 시 항목명과 선택지 값 snapshot을 함께 저장한다.
- 검수 등록 DTO에서는 `grade = NONE`을 허용하지 않는다.
- 검수 요청 body에는 `inspectedAt`을 받지 않는다.
- 서버가 검수 저장 시점의 현재 시각을 `tb_inspection.inspected_at`에 저장한다.
- 검수 후 개별 부품의 검수 상태, 등급, 판매 상태를 갱신한다.
- 상태 변경 시 `tb_part_status_history`를 저장한다.
- `grade = DEFECTIVE`이면 `salesStatus = UNAVAILABLE`이어야 한다.
- `result = FAIL`이면 불량 등급과 판매 불가 상태로 자동 보정하거나 검증 오류로 처리한다.
- `inputType = SELECT`인 항목만 선택지를 사용할 수 있다.
- `active = false`인 템플릿, 항목, 선택지는 신규 검수 입력에는 노출하지 않는다.
- 과거 검수 결과는 템플릿/항목/선택지 snapshot 기준으로 유지한다.

## 하네스 포인트

- 검수 등록, 정정, 재검수는 단일 트랜잭션이어야 한다.
- `grade = DEFECTIVE`이면 `salesStatus = UNAVAILABLE`이어야 한다.
- `inputType = SELECT`인 항목만 선택지를 사용할 수 있다.
