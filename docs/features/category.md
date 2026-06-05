# Category Feature

## 목적

부품 카테고리와 카테고리별 부품 스펙 입력 기준을 관리한다.

## 패키지

```text
com.pcs.domain.category
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/categories` | 카테고리 목록. `keyword`, `page`, `size`, `limit` 지원 |
| POST | `/api/workspaces/{companyCode}/categories` | 카테고리 생성. 필요하면 `specDefinitions`를 함께 등록 |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 상세. 스펙 항목 포함 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리명/설명 수정 |
| DELETE | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 삭제 |

## 주요 규칙

- `categoryName`은 같은 업체 안에서 중복될 수 없다.
- 카테고리는 `active` 상태를 두지 않는다.
- 카테고리 목록은 이름과 설명으로 검색한다.
- 카테고리 목록은 공통 `PageResultDto` 구조로 응답한다.
- 카테고리 목록 응답에는 해당 카테고리에 연결된 부품 마스터 수 `partCount`를 포함한다.
- 카테고리 상세 응답에는 `partCount`와 `specDefinitions`를 포함한다.
- 카테고리 목록은 `updatedAt DESC, categoryId DESC` 순서로 조회한다.
- 연결된 부품 마스터가 없는 카테고리만 삭제할 수 있다.
- 부품에 연결된 카테고리는 삭제하지 않고 이름과 설명을 수정해 정리한다.
- 연결된 부품이 있는 카테고리 삭제 요청은 `CATEGORY_IN_USE`로 실패한다.

## 스펙 항목 규칙

- 스펙 항목은 부품 마스터 등록 시 카테고리별 입력 기준으로 사용한다.
- 카테고리 생성 시 `specDefinitions`를 함께 받을 수 있다.
- 지원 입력 방식은 `TEXT`, `NUMBER`, `SELECT`, `BOOLEAN`이다.
- `SELECT` 방식은 선택지 `options`가 1개 이상 필요하다.
- 한 카테고리에 등록 가능한 스펙 항목은 최대 20개다.
- 한 스펙 항목의 선택지는 최대 30개다.
- 같은 카테고리 생성 요청 안에서 스펙 항목명과 스펙 키는 중복될 수 없다.
- 화면에서 스펙 키를 받지 않으면 서버가 `spec_1`, `spec_2` 형태로 생성한다.
- 현재 구현 범위에서는 카테고리 수정 시 스펙 항목을 수정하지 않는다. 스펙 수정은 기존 부품 스펙 값과의 정합성 정책이 정해진 뒤 별도 기능으로 다룬다.

## 하네스 포인트

- 카테고리 등록/수정/삭제 권한은 `docs/ai/pcs-permission-rules.md` 기준을 따른다.
- `tb_part_category`에 `active` 컬럼이 없음을 확인한다.
- 카테고리 목록은 `tb_pc_part` 집계로 `partCount`를 계산한다.
- 카테고리 상세는 `tb_part_spec_definition`, `tb_part_spec_option`을 조회할 수 있어야 한다.
- 카테고리 삭제 전에는 `tb_pc_part` 연결 수를 확인한다.
- 연결된 부품이 없는 카테고리 삭제 시 스펙 선택지, 스펙 정의, 카테고리 순서로 삭제한다.
