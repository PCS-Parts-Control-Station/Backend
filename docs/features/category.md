# Category Feature

## 목적

부품 카테고리를 관리한다.

## 패키지

```text
com.pcs.domain.category
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/categories` | 카테고리 목록. `keyword`, `page`, `size`, `limit` 지원 |
| POST | `/api/workspaces/{companyCode}/categories` | 카테고리 생성 |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 상세 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 수정 |

## 주요 규칙

- `categoryName`은 같은 업체 안에서 중복될 수 없다.
- 카테고리는 `active` 상태를 두지 않는다.
- 카테고리 목록은 이름과 설명으로 검색한다.
- 카테고리 목록은 공통 `PageResultDto` 구조로 응답한다.
- 카테고리 목록/상세 응답에는 해당 카테고리에 연결된 부품 마스터 수 `partCount`를 포함한다.
- 카테고리 목록은 `updatedAt DESC, categoryId DESC` 순서로 조회한다.
- 부품에 연결된 카테고리는 삭제하지 않고 이름과 설명을 수정해 정리한다.

## 하네스 포인트

- 카테고리 등록/수정 권한은 `docs/ai/pcs-permission-rules.md` 기준을 따른다.
- `tb_part_category`에 `active` 컬럼이 없음을 확인한다.
- 카테고리 목록은 `tb_pc_part` 집계로 `partCount`를 계산한다.
