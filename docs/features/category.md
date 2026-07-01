# Category Feature

## 목적

품목 분류와 분류별 사양 입력 기준을 관리한다.

## 화면 진입

- 품목 분류는 사이드바에 독립 메뉴로 노출하지 않는다.
- `/w/{companyCode}/parts` 품목 관리 화면 헤더의 `품목 분류` 버튼으로 진입한다.
- 품목 관리는 사이드바에 독립 메뉴로 노출하지 않고, 부품 관리 화면 또는 관련 화면의 상단 버튼으로 진입한다.
- STAFF의 `품목 분류` 버튼은 `STAFF_CATEGORY_MANAGE` 권한이 있을 때만 표시한다.
- 품목 분류 목록은 전체 너비로 보여주고, 분류 등록/상세/수정은 오른쪽 드로어에서 처리한다.
- 사양 항목 추가/수정은 드로어 안에서 길어지지 않도록 모달로 처리한다.

## 패키지

```text
com.pcs.domain.category
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/categories` | 품목 분류 목록. `keyword`, `page`, `size`, `limit` 지원 |
| POST | `/api/workspaces/{companyCode}/categories` | 품목 분류 생성. 필요하면 `specDefinitions`를 함께 등록 |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 상세. 사양 항목 포함 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 분류명/설명 수정. 연결 품목이 없으면 사양 항목 교체 가능 |
| DELETE | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 삭제 |

## 주요 규칙

- `categoryName`은 화면에서 분류명으로 표시한다.
- `categoryName`은 같은 업체 안에서 중복될 수 없다.
- 품목 분류는 `active` 상태를 두지 않는다.
- 품목 분류 목록은 이름과 설명으로 검색한다.
- 품목 분류 목록은 공통 `PageResultDto` 구조로 응답한다.
- 품목 분류 목록 응답에는 해당 분류에 연결된 품목 마스터 수 `partCount`를 포함한다.
- 품목 분류 상세 응답에는 `partCount`와 `specDefinitions`를 포함한다.
- 품목 분류 목록은 `updatedAt DESC, categoryId DESC` 순서로 조회한다.
- 연결된 품목 마스터가 없는 분류만 삭제할 수 있다.
- 품목에 연결된 분류는 삭제하지 않고 이름과 설명을 수정해 정리한다.
- 연결된 품목이 있는 분류 삭제 요청은 `CATEGORY_IN_USE`로 실패한다.

## 스펙 항목 규칙

- 사양 항목은 품목 마스터 등록 시 분류별 입력 기준으로 사용한다.
- 품목 분류 생성 시 `specDefinitions`를 함께 받을 수 있다.
- 지원 입력 방식은 `TEXT`, `NUMBER`, `SELECT`, `BOOLEAN`이다.
- `SELECT` 방식은 선택지 `options`가 1개 이상 필요하다.
- 한 분류에 등록 가능한 사양 항목은 최대 20개다.
- 한 사양 항목의 선택지는 최대 30개다.
- 같은 분류 생성 요청 안에서 사양 항목명과 사양 키는 중복될 수 없다.
- 화면에서 스펙 키를 받지 않으면 서버가 `spec_1`, `spec_2` 형태로 생성한다.
- 품목 분류 수정 시 `specDefinitions`를 생략하면 분류명과 설명만 수정한다.
- 연결된 품목 마스터가 없는 분류는 수정 요청에서 `specDefinitions`를 보내 사양 항목 전체를 교체할 수 있다.
- 연결된 품목 마스터가 있는 분류에 `specDefinitions`가 포함되면 `INVALID_INPUT_VALUE`로 실패한다.
- 사양 항목 교체는 기존 사양값, 선택지, 사양 정의를 삭제한 뒤 새 사양 정의를 저장한다.

## 하네스 포인트

- 품목 분류 등록/수정/삭제 권한은 `docs/ai/pcs-permission-rules.md` 기준을 따른다.
- `tb_part_category`에 `active` 컬럼이 없음을 확인한다.
- 품목 분류 목록은 `tb_pc_part` 집계로 `partCount`를 계산한다.
- 품목 분류 상세는 `tb_part_spec_definition`, `tb_part_spec_option`을 조회할 수 있어야 한다.
- 품목 분류 삭제 전에는 `tb_pc_part` 연결 수를 확인한다.
- 연결된 품목이 없는 분류 삭제 시 사양값, 선택지, 사양 정의, 분류 순서로 삭제한다.

## 테스트 기준

단위 테스트:

- 사양 항목 `specKey`가 없으면 `spec_1`, `spec_2` 형태로 생성한다.
- `specKey`는 소문자, 숫자, `_`, `-` 기준으로 정규화한다.
- 같은 요청 안에서 사양 항목명과 `specKey` 중복을 막는다.
- `SELECT` 사양 항목은 선택지가 1개 이상 있어야 한다.
- 선택지 `optionValue`가 없으면 `optionLabel`을 사용한다.
- 같은 사양 항목 안에서 선택지 값 중복을 막는다.
- 사양 항목은 최대 20개, 선택지는 항목당 최대 30개까지만 허용한다.
- `sortOrder`가 없으면 입력 순서를 사용하고, 음수면 실패한다.

API 테스트:

- 목록 조회는 `keyword`, `page`, `size`, `limit` 조건과 `PageResultDto` 구조를 검증한다.
- 목록 응답은 `partCount`를 포함해야 한다.
- 생성은 분류명/설명만 있는 요청과 사양 항목/선택지를 포함한 요청을 모두 검증한다.
- 중복 분류명 생성은 실패해야 한다.
- 상세 조회는 `partCount`, `specDefinitions`, 선택지를 포함해야 한다.
- 수정은 `specDefinitions` 생략 시 분류명/설명만 수정해야 한다.
- 연결 품목이 없는 분류는 사양 항목 전체 교체가 가능해야 한다.
- 연결 품목이 있는 분류에 `specDefinitions`가 포함되면 실패해야 한다.
- 연결 품목이 없는 분류 삭제는 성공하고, 연결 품목이 있는 분류 삭제는 `CATEGORY_IN_USE`로 실패해야 한다.

권한 테스트:

- `companyCode`와 JWT의 업체가 다르면 실패해야 한다.
- STAFF는 `STAFF_CATEGORY_MANAGE` 권한이 없으면 생성, 수정, 삭제를 할 수 없다.
