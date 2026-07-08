# Inspection Template Feature

## 목적

검수 등록 화면에서 사용할 동적 입력 양식, 검수 항목, 선택지를 관리한다.

검수 템플릿은 검수 도메인 전용 관리 기능이다. 범용 템플릿 도메인으로 분리하지 않는다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

### 묶음 저장 규칙

- 검수 템플릿 등록/수정 화면에서는 `templateName`, `categoryId`, `version`, `active`, `items`를 하나의 폼 묶음으로 다룬다.
- `POST /inspection-templates`, `PATCH /inspection-templates/{templateId}` 요청은 선택적으로 `items` 배열을 함께 받는다.
- `items`에는 항목 기본값과 `options`를 함께 담는다. 기존 항목/선택지는 `itemId`, `optionId`가 있으면 갱신하고, 없으면 새로 생성한다.
- 화면에서 항목 추가/수정, 사용/중지, 드래그 정렬, 선택지 추가/수정/사용/중지는 즉시 API를 호출하지 않는다. 오른쪽 드로어 하단의 `form-actions` 저장 버튼을 누를 때 템플릿 기본정보와 함께 한 번에 저장한다.
- 개별 항목/선택지 API는 서버 기능 호환과 별도 관리 흐름을 위해 유지한다. 검수 템플릿 관리 화면의 기본 UX에서는 직접 호출하지 않는다.

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 목록. `keyword`, `categoryId`, `active`, `page`, `size`, `limit` 지원 |
| POST | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 생성 |
| GET | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` | 검수 템플릿 상세 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` | 검수 템플릿 수정 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/active` | 검수 템플릿 사용 여부 변경 |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items` | 검수 항목 추가 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}` | 검수 항목 수정 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/active` | 검수 항목 사용 여부 변경 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/sort-order` | 검수 항목 순서 일괄 저장 |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options` | 선택지 추가 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}` | 선택지 수정 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}/active` | 선택지 사용 여부 변경 |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/sort-order` | 선택지 순서 일괄 저장 |

## 화면

```text
src/main/resources/static/inspection-templates.html
src/main/resources/static/css/components/management-page.css
src/main/resources/static/css/pages/inspection-templates.css
src/main/resources/static/js/inspection-templates.js
```

화면 전체 구성은 `docs/ai/design/management-page.md`를 따른다. 공통 관리 화면과 하위 항목 편집 스타일은 `management-page.css`가 소유하고, 검수 템플릿 전용 CSS에는 목록 열과 모바일 셀 배치만 둔다.

화면은 서버 Model을 받지 않고 JS가 `/api/workspaces/{companyCode}/**` API를 호출한다.

카테고리 선택지는 하드코딩하지 않는다. 화면은 `PcsCategory.loadAll(companyCode)` 공통 함수를 사용해 `/categories?page={page}&size=100` 전체 페이지를 순회하고, 응답의 `categoryId`, `categoryName`을 사용한다.

화면 구성:

1. 템플릿 검색과 목록
2. 템플릿 등록/수정/사용 여부 변경
3. 항목 목록과 항목 추가/수정/사용 여부 변경
4. `SELECT` 항목의 선택지 추가/수정/사용 여부 변경
5. 항목과 선택지 드래그 정렬. 드롭 시 정렬 전용 일괄 API를 1회 호출한다.

항목 추가/수정은 항목 목록 상단의 `항목 추가` 버튼과 항목 선택 동작에서 시작한다. 입력 폼은 목록 안에 상시 노출하지 않고 모달로 열어 현재 목록을 유지한 채 작성한다.

항목을 선택하면 오른쪽 패널은 `선택형 항목 설정`에 집중한다. `inputType = SELECT`가 아닌 항목은 선택지 설정 대신 선택지가 필요 없다는 짧은 안내만 보여준다.

반응형과 항목 편집 상태 표현은 `management-page.md`와 `responsive-layout.md`를 따른다.

## 주요 규칙

- 템플릿은 회사와 카테고리 범위 안에서 관리한다.
- 템플릿명, 카테고리, 버전 조합은 같은 회사 안에서 중복될 수 없다.
- 템플릿 목록은 공통 `PageResultDto` 구조로 응답한다.
- 템플릿 목록 summary에는 전체, 사용 중, 항목 수, 선택지 수를 포함한다.
- `active = false`인 템플릿은 신규 검수 등록에서 제외한다.
- 항목은 `BASIC`, `DETAIL` 그룹으로 나눈다.
- 항목 입력 방식은 `CHECK`, `NUMBER`, `TEXT`, `SELECT` 중 하나다.
- `SELECT` 항목만 선택지를 가질 수 있다.
- 선택지의 `optionValue`가 없으면 서버가 `optionLabel`을 저장 코드로 사용한다.
- 선택지를 사용 중지할 때는 UI에서 비활성화 확인 안내를 거친다.
- 항목/선택지 정렬은 클라이언트가 ID 순서만 보내고 서버가 `sortOrder`를 10 단위로 재계산한다.
- 항목 정렬 요청은 해당 템플릿과 항목 그룹에 속한 ID만 허용한다.
- 선택지 정렬 요청은 `SELECT` 항목과 해당 항목에 속한 선택지 ID만 허용한다.
- 템플릿, 항목, 선택지는 하드 삭제하지 않고 `active`로 사용 여부를 바꾼다.
- 과거 검수 결과는 템플릿 수정의 영향을 받지 않도록 snapshot으로 유지한다.
- 항목 생성/수정 시 `gradeImpact` 기본값은 `LOW`, `failPolicy` 기본값은 `NONE`이다.
- 화면에서는 `gradeImpact`, `failPolicy`를 고급 설정으로 분리한다.

## 항목 필드

| 필드 | 설명 |
|---|---|
| `itemName` | 검수 항목명 |
| `itemGroup` | `BASIC`, `DETAIL` |
| `inputType` | `CHECK`, `NUMBER`, `TEXT`, `SELECT` |
| `required` | 필수 입력 여부 |
| `sortOrder` | 표시 순서 |
| `gradeImpact` | `HIGH`, `MEDIUM`, `LOW` |
| `failPolicy` | 화면 라벨은 `불합격 시 처리`. 값은 `NONE`, `GRADE_DOWN`, `MARK_DEFECTIVE`, `BLOCK_SALE` |

## 하네스 포인트

- 모든 조회/수정은 `companyId` 범위를 검증해야 한다.
- 템플릿 생성/수정 시 카테고리가 같은 회사 소속인지 확인해야 한다.
- `inputType = SELECT`인 항목만 선택지를 추가/수정할 수 있다.
- `active` 변경은 하드 삭제가 아니며 과거 검수 이력을 변경하지 않아야 한다.
- 검수 템플릿 DB 구조와 제약은 `docs/features/inspection-db.md` 기준으로 검증한다.

## 테스트 기준

서비스 단위 테스트는 `src/test/java/com/pcs/domain/inspection/service/InspectionTemplateServiceTest.java`에서 관리한다.

현재 JUnit 검증 범위:

- 템플릿 생성 시 회사/카테고리 범위와 템플릿명/버전 중복을 검증한다.
- 템플릿 목록은 필터와 페이징 값을 정규화해 조회한다.
- 항목 생성 시 고급 설정 기본값을 적용하고 템플릿 `updatedAt` 갱신을 호출한다.
- 항목 수정 시 `SELECT`가 아닌 입력 방식으로 변경되면 기존 선택지를 비활성화한다.
- 템플릿, 항목, 선택지 사용 여부 변경은 대상 소속 검증 후 `active`만 변경한다.
- 항목 정렬은 해당 그룹 전체 항목 ID를 포함해야 하며 중복 ID를 허용하지 않는다.
- 선택지 정렬은 해당 항목 전체 선택지 ID를 포함해야 한다.
- 선택지 수정 시 `optionValue`가 없으면 `optionLabel`을 저장 코드로 사용한다.
