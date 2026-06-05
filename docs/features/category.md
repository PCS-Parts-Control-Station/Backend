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
| GET | `/api/workspaces/{companyCode}/categories` | 카테고리 목록 |
| POST | `/api/workspaces/{companyCode}/categories` | 카테고리 생성 |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 상세 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 수정 |

## 주요 규칙

- `categoryName`은 같은 업체 안에서 중복될 수 없다.
- 카테고리는 별도 `active` 상태를 갖지 않는다.
- 카테고리는 부품 분류 기준이므로 삭제/비활성화 정책은 별도 설계 후 추가한다.

## 하네스 포인트

- 카테고리 등록/수정 권한은 `docs/ai/pcs-permission-rules.md` 기준을 따른다.
- 카테고리명 중복과 회사 범위 격리를 검증한다.
