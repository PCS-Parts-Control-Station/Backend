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
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}/active` | 카테고리 사용 여부 변경 |

## 주요 규칙

- `categoryName`은 같은 업체 안에서 중복될 수 없다.
- 사용 중지된 카테고리는 신규 부품 등록에서 선택할 수 없다.
- 카테고리 삭제는 하지 않고 `active` 상태만 변경한다.

## 하네스 포인트

- 카테고리 등록/수정은 ADMIN 이상 권한이 필요하다.
- 카테고리 비활성화 시 사용 중인 부품과의 영향 범위를 검토해야 한다.
