# PCS API 명세 요약

이 문서는 PCS 백엔드 API의 전체 흐름과 엔드포인트를 요약한다.

화면 URL은 `PageController`가 정적 HTML을 forward하고, 실제 데이터 처리는 `/api/**`에서 수행한다.

## 문서 역할

- 이 문서는 전체 API의 방향과 엔드포인트를 빠르게 확인하기 위한 요약 문서다.
- 실제 구현 직전의 세부 규칙은 `docs/features/{feature}.md`를 우선한다.
- DB 컬럼과 제약 조건은 `docs/sql/pcs-schema-ddl.sql`을 기준으로 확인한다.
- 공통 응답, 예외, ErrorCode 사용 방식은 `docs/ai/pcs-backend-common-rules.md`를 따른다.
- 인증/JWT 정책은 `docs/features/auth.md`, 사용 방식은 `docs/ai/pcs-auth-client-rules.md`를 따른다.
- 페이징 응답과 화면 연동은 `docs/ai/pcs-pagination-rules.md`를 따른다.
- 권한 기준은 `docs/ai/pcs-permission-rules.md`를 따른다.
- `active`와 상태 보존 기준은 `docs/ai/pcs-status-lifecycle-rules.md`를 따른다.
- 이 문서와 feature 문서가 충돌하면 feature 문서를 최신 기준으로 보고, 필요한 경우 이 문서를 요약 수준으로 갱신한다.

## 1. API 설계 원칙

- API 응답은 `docs/ai/pcs-backend-common-rules.md` 기준의 `ApiResultDto<T>`로 감싼다.
- 화면 URL과 API URL은 분리한다.
- 업체 업무 API는 `/api/workspaces/{companyCode}/**` 아래에 둔다.
- 업체 업무 API의 회사 범위 검증은 `docs/features/auth.md` 기준을 따른다.
- 마스터 데이터는 `PATCH`로 수정하고, 삭제 대신 `docs/ai/pcs-status-lifecycle-rules.md` 기준의 `active`를 변경한다.
- 품목 분류는 예외적으로 `active`를 두지 않는다.
- 입출고와 검수는 이력성 데이터이므로 원본 수정/삭제를 하지 않는다.
- 입출고 오류는 취소 이력으로 남긴다.
- 검수 오류는 정정 이력 또는 재검수 이력으로 남긴다.
- Write API 트랜잭션 경계는 `docs/ai/pcs-project-structure-reference.md` 기준을 따른다.
- 목록/검색/통계는 SQL에서 필터링/집계한다.

## 2. 공통 응답

공통 응답, 예외, ErrorCode는 `docs/ai/pcs-backend-common-rules.md`를 원본 기준으로 한다.

페이징 응답은 `docs/ai/pcs-pagination-rules.md`를 원본 기준으로 한다.

응답 data 예시:

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 0,
  "totalPages": 0
}
```

공통 query 예시:

```text
keyword
from
to
page
size
sort
```

## 3. 도메인별 API 요약

### 3.1 인증 / 세션 `auth`

| Method | API | 설명 |
|---|---|---|
| POST | `/api/owners/login` | Owner 로그인 |
| POST | `/api/workspaces/login` | 업체 코드 + 아이디 + 비밀번호 로그인 |
| POST | `/api/workspaces/{companyCode}/login` | 특정 업체 로그인 |
| POST | `/api/auth/refresh` | 토큰 재발급 |
| POST | `/api/auth/logout` | 로그아웃 |
| GET | `/api/workspaces/{companyCode}/me` | 내 세션 정보 조회 |

업체 로그인 요청 예시:

```json
{
  "companyCode": "greenparts",
  "loginId": "staff01",
  "password": "password"
}
```


인증/JWT 정책은 `docs/features/auth.md`, 인증 DB 검증 기준은 `docs/features/auth-db.md`를 따른다.

로그인 성공 응답 예시:

```json
{
  "accessToken": "jwt",
  "tokenType": "Bearer",
  "expiresInSeconds": 600,
  "companyId": 1,
  "companyCode": "greenparts",
  "memberId": 10,
  "loginId": "staff01",
  "name": "이검수",
  "role": "STAFF",
  "passwordChangeRequired": false
}
```


### 3.2 회사 / Owner 가입 `company`

| Method | API | 설명 |
|---|---|---|
| POST | `/api/owners/signup` | Owner 회원가입 + 회사 생성 / 회사 코드 발급 |
| GET | `/api/workspaces/{companyCode}/public-info` | 업체 주소 존재/사용 가능 여부 확인 |
| GET | `/api/owners/company` | Owner 회사 조회 |
| PATCH | `/api/owners/company` | 회사 정보 수정 |
| PATCH | `/api/owners/company/active` | 회사 활성 여부 변경 |

Owner 회원가입은 회사 생성과 하나의 API에서 처리한다. 상세 규칙은 `docs/features/company.md`, OWNER 저장 규칙은 `docs/features/member-db.md`를 따른다.

Owner 회원가입 + 회사 생성 요청 예시:

```json
{
  "companyName": "그린파츠",
  "companyCode": "greenparts",
  "businessRegistrationNo": "000-00-00000",
  "representativeEmail": "owner@greenparts.com",
  "representativePhone": "010-0000-0000",
  "ownerLoginId": "owner01",
  "ownerPassword": "password",
  "ownerName": "김대표"
}
```

응답 data 예시:

```json
{
  "companyCode": "greenparts",
  "workspaceLoginUrl": "/w/greenparts"
}
```

### 3.3 사용자 / 마이페이지 `member`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/users` | 사용자 목록 |
| POST | `/api/workspaces/{companyCode}/users` | 사용자 생성 |
| GET | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 상세 |
| PATCH | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 수정 |
| POST | `/api/workspaces/{companyCode}/users/{memberId}/temporary-password` | 임시 비밀번호 발급 |
| GET | `/api/workspaces/{companyCode}/users/staff-permissions` | STAFF 공통 업무 권한 조회 |
| PATCH | `/api/workspaces/{companyCode}/users/staff-permissions` | STAFF 공통 업무 권한 저장 |
| GET | `/api/workspaces/{companyCode}/mypage` | 내 정보 조회 |
| PATCH | `/api/workspaces/{companyCode}/mypage` | 내 정보 수정 |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` | 비밀번호 변경 |

사용자 생성 요청 예시:

```json
{
  "loginId": "staff01",
  "memberName": "이검수",
  "role": "STAFF"
}
```

사용자 생성 시 로그인 아이디와 무관한 난수 임시 비밀번호를 발급한다. 응답에는 생성된 사용자와 일회성 임시 비밀번호를 함께 반환하며 `Cache-Control: no-store`를 사용한다.

사용자 생성 응답 `data` 예시:

```json
{
  "member": {
    "memberId": 15,
    "memberName": "이검수",
    "loginId": "staff01",
    "role": "STAFF",
    "passwordStatus": "TEMPORARY",
    "active": true,
    "updatedAt": "2026-06-19T15:30:00"
  },
  "temporaryPassword": "PCS-Ab3de5Fg7H",
  "expiresAt": "2026-06-26T15:30:00"
}
```

임시 비밀번호 재발급 응답 예시:

```json
{
  "temporaryPassword": "PCS-Ab3de5Fg7H",
  "expiresAt": "2026-06-24T15:30:00"
}
```

임시 비밀번호 원문은 이 응답에서 한 번만 확인할 수 있다. 발급과 동시에 기존 refresh token은 폐기하며, 사용자는 비밀번호 변경 전까지 업무 API를 사용할 수 없다.

### 3.4 거래처 `partner`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/partners` | 거래처 목록. `keyword`, `partnerType`, `partnerRole`, `active`, `page`, `size`, `limit` 지원 |
| POST | `/api/workspaces/{companyCode}/partners` | 거래처 생성 |
| GET | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 상세 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 수정. `active` 포함 시 거래 가능 여부도 함께 수정 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}/active` | 거래 가능 여부만 단독 변경 |

거래처는 회사 하위 데이터지만 역할이 커서 `company`에 넣기보다 `partner` 도메인으로 분리한다.

거래처 목록 응답은 `docs/ai/pcs-pagination-rules.md`의 공통 페이징 기준을 따른다.

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 0,
  "totalPages": 0,
  "hasPrevious": false,
  "hasNext": false,
  "summary": {
    "totalCount": 0,
    "supplierCount": 0,
    "customerCount": 0,
    "activeCount": 0
  }
}
```

거래처 생성 요청 예시:

```json
{
  "partnerName": "A피시방",
  "partnerType": "PC_CAFE",
  "partnerRole": "SUPPLIER",
  "phone": "010-0000-0000",
  "email": null,
  "address": "서울시",
  "memo": "중고 부품 매입 거래처",
  "active": true
}
```

### 3.5 품목 분류 `category`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/categories` | 품목 분류 목록. `keyword`, `page`, `size`, `limit` 지원 |
| POST | `/api/workspaces/{companyCode}/categories` | 품목 분류 생성. 사양 항목 동시 등록 가능 |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 상세. 사양 항목 포함 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 분류명/설명 수정. 연결 품목이 없으면 사양 항목 교체 가능 |
| DELETE | `/api/workspaces/{companyCode}/categories/{categoryId}` | 품목 분류 삭제 |

품목 분류 생성 요청 예시:

```json
{
  "categoryName": "GPU",
  "description": "그래픽카드",
  "specDefinitions": [
    {
      "specName": "메모리 용량",
      "inputType": "NUMBER",
      "unit": "GB",
      "required": true,
      "searchable": true,
      "sortOrder": 0,
      "options": []
    },
    {
      "specName": "메모리 타입",
      "inputType": "SELECT",
      "unit": null,
      "required": false,
      "searchable": true,
      "sortOrder": 1,
      "options": [
        {
          "optionLabel": "GDDR6",
          "optionValue": "GDDR6",
          "sortOrder": 0
        }
      ]
    }
  ]
}
```

품목 분류 목록 응답은 `docs/ai/pcs-pagination-rules.md`의 공통 페이징 구조를 따른다. 각 항목은 해당 분류에 연결된 품목 마스터 수 `partCount`를 포함한다. 품목 분류 상세 응답은 `specDefinitions`를 함께 내려준다. 삭제는 `partCount = 0`인 분류만 허용하며, 연결된 품목이 있으면 `CATEGORY_IN_USE`로 실패한다.

품목 분류 수정 요청에서 `specDefinitions`를 생략하면 분류명/설명만 수정한다. 연결된 품목 마스터가 없는 분류는 `specDefinitions`를 보내 사양 항목 전체를 교체할 수 있다. 연결된 품목 마스터가 있는 분류에 `specDefinitions`가 포함되면 `INVALID_INPUT_VALUE`로 실패한다.

```json
{
  "content": [
    {
      "categoryId": 1,
      "categoryName": "GPU",
      "description": "그래픽카드",
      "partCount": 12,
      "updatedAt": "2026-06-04T10:00:00"
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 1,
  "totalPages": 1,
  "hasPrevious": false,
  "hasNext": false,
  "summary": null
}
```

### 3.6 품목 / 기준 `part`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/parts` | 품목/재고 목록 검색 |
| POST | `/api/workspaces/{companyCode}/parts` | 품목 마스터 등록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}` | 품목 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}` | 품목 마스터 수정 |

품목 기준 입력은 현재 별도 `/standards` API가 아니라 품목 분류의 `specDefinitions`와 품목의 `specValues`를 통해 처리한다.

품목 검색 요청:

```text
GET /api/workspaces/{companyCode}/parts?keyword=RTX&categoryId=1&active=true&page=0&size=10
```

품목 검색 응답 항목:

```json
{
  "partId": 32,
  "categoryId": 1,
  "categoryName": "그래픽카드",
  "partName": "RTX 3060",
  "modelName": "Ventus 2X",
  "manufacturer": "MSI",
  "partCode": "VGA-RTX3060-MSI",
  "safeQuantity": 0,
  "currentStockQuantity": 3,
  "active": true
}
```

품목 검색 응답은 `PageResultDto<SearchPartResponse, Void>` 구조이며 현재 `summary`는 `null`이다.
전체 재고/재고 부족 요약이 필요하면 백엔드 summary DTO와 집계 SQL을 먼저 추가한다.

품목 등록 요청 예시:

```json
{
  "categoryId": 1,
  "partName": "RTX 3060 Twin Edge",
  "modelName": "RTX 3060 Twin Edge",
  "manufacturer": "ZOTAC",
  "safeQuantity": 3,
  "specValues": []
}
```

### 3.7 입고 / 출고 / 재고 변화 `stock`

| Method | API | 설명 |
|---|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` | 입고 전표 등록 |
| GET | `/api/workspaces/{companyCode}/stock/outbound-candidates` | 출고 가능한 관리번호 목록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` | 출고 전표 등록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` | 입출고 전표 취소 |
| GET | `/api/workspaces/{companyCode}/stock/documents` | 입출고 전표 목록 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` | 입출고 전표 상세 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}/movements` | 전표의 부품별 재고 변화 라인 |
| GET | `/api/workspaces/{companyCode}/stock/movements` | 입출고 재고 변화 라인 목록 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}` | 입출고 재고 변화 라인 상세 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}/units` | 라인에 포함된 개별 부품 목록 |

입고 전표 등록 요청 예시:

```json
{
  "partnerId": 1,
  "reason": "A피시방 매입 부품 입고",
  "lines": [
    {
      "partId": 10,
      "quantity": 2,
      "reason": "CPU 입고"
    }
  ]
}
```

입고 전표번호는 서버가 `IN-YYYYMMDD-RANDOM16` 형식으로 자동 발급한다.
내부 정렬과 페이징 기준은 `documentId`를 사용한다.

출고 대상 관리번호 조회 query:

| 이름 | 설명 |
|---|---|
| `keyword` | 관리번호, 품목명, 모델명, 품목코드 검색 |
| `categoryId` | 품목 분류 필터 |
| `partId` | 특정 품목 필터 |
| `grade` | `A`, `B`, `C` 등급 필터 |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | `size` 별칭 |

출고 대상 조건은 `unitStatus = IN_STOCK`, `inspectionStatus = COMPLETED`, `salesStatus = AVAILABLE`, `grade != DEFECTIVE`, `active = true`이다.

출고 대상 관리번호 응답 예시:

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "요청이 정상 처리되었습니다.",
  "data": {
    "content": [
      {
        "unitId": 101,
        "internalSerialNo": "CPU-I5-20260529-0001",
        "partId": 10,
        "partName": "Intel Core i5",
        "modelName": "i5-12400",
        "partCode": "CPU-I5",
        "categoryId": 3,
        "categoryName": "CPU",
        "grade": "A",
        "salesStatus": "AVAILABLE",
        "inspectionStatus": "COMPLETED",
        "unitStatus": "IN_STOCK"
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 1,
    "totalPages": 1,
    "hasPrevious": false,
    "hasNext": false,
    "summary": null
  }
}
```

입출고 전표 목록 query:

| 이름 | 설명 |
|---|---|
| `documentType` | `INBOUND`, `OUTBOUND` |
| `keyword` | 전표번호, 거래처명, 품목명, 모델명, 품목코드 검색 |
| `partnerId` | 거래처 필터 |
| `documentStatus` | `COMPLETED`, `CANCELED` |
| `page` | 0부터 시작 |
| `size` | 기본 20, 최대 100 |
| `limit` | `size` 별칭 |

입출고 전표 목록 응답 예시:

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "요청이 정상 처리되었습니다.",
  "data": {
    "content": [
      {
        "documentId": 100,
        "documentNo": "IN-20260529-23456789ABCDEFGH",
        "documentType": "INBOUND",
        "documentStatus": "COMPLETED",
        "partnerId": 1,
        "partnerName": "서울 부품사",
        "firstPartName": "RTX 4060",
        "lineCount": 2,
        "totalQuantity": 5,
        "processedByName": "관리자",
        "createdAt": "2026-05-29T10:00:00"
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 1,
    "totalPages": 1,
    "hasPrevious": false,
    "hasNext": false,
    "summary": {
      "totalCount": 1,
      "totalQuantity": 5,
      "waitingQuantity": 5,
      "canceledCount": 0
    }
  }
}
```

입출고 전표 상세 응답 예시:

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "요청이 정상 처리되었습니다.",
  "data": {
    "documentId": 100,
    "documentNo": "IN-20260529-23456789ABCDEFGH",
    "documentType": "INBOUND",
    "documentStatus": "COMPLETED",
    "partnerId": 1,
    "partnerName": "서울 부품사",
    "reason": "A피시방 매입 부품 입고",
    "processedByName": "관리자",
    "createdAt": "2026-05-29T10:00:00",
    "lineCount": 1,
    "totalQuantity": 2,
    "cancelable": true,
    "cancelBlockedReason": null,
    "lines": [
      {
        "movementId": 200,
        "partId": 10,
        "partName": "RTX 4060",
        "modelName": "RTX 4060 8GB",
        "partCode": "GPU-4060",
        "movementType": "INBOUND",
        "movementStatus": "COMPLETED",
        "quantity": 2,
        "beforeQuantity": 0,
        "afterQuantity": 2,
        "reason": "그래픽카드 입고",
        "units": [
          {
            "movementId": 200,
            "unitId": 1000,
            "internalSerialNo": "GPU-4060-20260529-0001",
            "manufacturerSerialNo": null,
            "unitStatus": "IN_STOCK",
            "grade": "NONE",
            "inspectionStatus": "WAITING",
            "salesStatus": "HOLD",
            "active": true
          }
        ]
      }
    ]
  }
}
```

출고 전표 등록 요청 예시:

```json
{
  "partnerId": 2,
  "reason": "판매 출고",
  "lines": [
    {
      "partId": 10,
      "unitIds": [101, 102],
      "reason": "CPU 출고"
    }
  ]
}
```

출고 전표번호는 서버가 `OUT-YYYYMMDD-RANDOM16` 형식으로 자동 발급한다. 클라이언트는 실제 출고할 `unitIds`를 보내며, 서버는 저장 시점에 각 관리번호가 출고 가능한 상태인지 다시 검증한다.

취소 요청 예시:

```json
{}
```

취소 응답 예시:

```json
{
  "success": true,
  "code": "COMMON-000",
  "message": "입출고 전표가 취소되었습니다.",
  "data": {
    "documentId": 100,
    "documentNo": "IN-20260529-23456789ABCDEFGH",
    "documentStatus": "CANCELED",
    "canceledMovementCount": 1,
    "canceledUnitCount": 2
  }
}
```

### 3.8 검수 / 검수 템플릿 `inspection`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents` | 검수 대상 입고 전표 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units` | 전표별 검수 대상 관리번호 목록 |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/bulk` | 여러 관리번호 일괄 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` | 검수 정정 이력 생성 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` | 재검수 이력 생성 |
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` | 검수 이력 전표 목록 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |
| GET | `/api/workspaces/{companyCode}/inspection-templates` | 검수 템플릿 목록 |
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

검수 대상 조회는 입고 전표를 기준으로 한다. 전표 목록은 `waiting-documents`, 전표별 관리번호는 `waiting-documents/{documentId}/units`를 사용한다.

검수 이력 전표 목록은 `GET /api/workspaces/{companyCode}/inspections/history-documents`로 조회한다. 이 API는 검수 이력 화면의 전표 목록용 집계 응답이며 `keyword`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit`을 지원한다. 화면의 기본 전표 검색은 검색어, 기간, 이력 유형을 사용하고, 검수 결과와 등급은 전표 선택 후 관리번호 목록 보조 필터로 사용한다.

개별 부품 기준 검수 이력은 별도 URL을 두지 않고 `GET /api/workspaces/{companyCode}/inspections?unitId={unitId}`로 조회한다. 전표 선택 후 관리번호 목록은 `GET /api/workspaces/{companyCode}/inspections?documentId={documentId}`로 조회한다. 검수 이력 목록은 `keyword`, `documentId`, `unitId`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit`을 지원한다. 관리번호 상세는 `GET /api/workspaces/{companyCode}/inspections/{inspectionId}`로 항목별 결과를 함께 조회한다.

검수 등록 요청 예시:

```json
{
  "unitId": 101,
  "templateId": 3,
  "result": "PASS",
  "grade": "A",
  "salesStatus": "AVAILABLE",
  "memo": "벤치 테스트 통과",
  "itemResults": [
    {
      "itemId": 100,
      "result": "PASS",
      "valueText": null,
      "valueNumber": null,
      "selectedOptionId": null,
      "memo": null
    }
  ]
}
```

검수 시각 규칙:

- 요청 body에는 `inspectedAt`을 받지 않는다.
- 서버가 검수 저장 시점의 현재 시각을 `inspectedAt`으로 저장한다.
- DB 컬럼은 `tb_inspection.inspected_at`에 저장한다.

검수 정정/재검수 규칙:

- 정정과 재검수는 기존 검수 row를 수정하지 않고 새 `tb_inspection` row로 저장한다.
- 최초 검수는 `inspectionType = INITIAL`, `originalInspectionId = null`이다.
- 정정은 `inspectionType = CORRECTION`, 재검수는 `inspectionType = REINSPECTION`이다.
- 기준 이력이 최초 검수이면 새 이력의 `originalInspectionId`는 기준 검수 ID다.
- 기준 이력이 정정 또는 재검수이면 새 이력의 `originalInspectionId`는 기준 이력의 `originalInspectionId`를 유지한다.

검수 템플릿 목록 요청 예시:

```text
GET /api/workspaces/{companyCode}/inspection-templates?keyword=&categoryId=&active=true&page=0&size=100
```

검수 템플릿 목록 응답 data 예시:

```json
{
  "content": [
    {
      "templateId": 1,
      "categoryId": 10,
      "categoryName": "그래픽카드",
      "templateName": "그래픽카드 기본 검수",
      "version": 1,
      "active": true,
      "itemCount": 3,
      "optionCount": 4,
      "createdByName": "관리자",
      "updatedAt": "2026-06-08T10:30:00"
    }
  ],
  "page": 0,
  "size": 100,
  "totalElements": 1,
  "totalPages": 1,
  "summary": {
    "totalCount": 1,
    "activeCount": 1,
    "itemCount": 3,
    "optionCount": 4
  }
}
```

검수 템플릿 생성/수정 요청 예시:

```json
{
  "categoryId": 10,
  "templateName": "그래픽카드 기본 검수",
  "version": 1,
  "active": true
}
```

검수 항목 추가/수정 요청 예시:

```json
{
  "itemName": "소음 상태",
  "itemGroup": "DETAIL",
  "inputType": "SELECT",
  "required": false,
  "sortOrder": 3,
  "gradeImpact": "LOW",
  "failPolicy": "GRADE_DOWN"
}
```

선택지 추가/수정 요청 예시:

```json
{
  "optionLabel": "팬 소음",
  "optionValue": null,
  "sortOrder": 2
}
```

`optionValue`가 없으면 서버는 `optionLabel`을 저장 코드로 사용한다. 상세 규칙은 `docs/features/inspection-template.md`를 따른다.

### 3.9 이력 `history`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/history/units/{unitId}/timeline` | 개별 부품 전체 타임라인 |
| GET | `/api/workspaces/{companyCode}/history/stock-documents` | 입출고 전표 이력 |
| GET | `/api/workspaces/{companyCode}/history/stock-movements` | 입출고/취소 재고 변화 이력 |
| GET | `/api/workspaces/{companyCode}/history/inspections` | 검수/정정/재검수 이력 |
| GET | `/api/workspaces/{companyCode}/history/status-changes` | 상태 변경 이력 |

공통 query 예시:

```text
partnerId
partId
unitId
keyword
processedBy
changedBy
from
to
page
size
```

### 3.10 대시보드 `dashboard`

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard/summary` | 대시보드 요약 |
| GET | `/api/workspaces/{companyCode}/dashboard/todos` | 우선 처리 목록 |
| GET | `/api/workspaces/{companyCode}/dashboard/statistics` | 운영 통계 |

통계 query 예시:

```text
from
to
```

## 4. 도메인 매핑

```text
com.pcs.domain.auth        인증 / 세션
com.pcs.domain.company     회사 / Owner 가입
com.pcs.domain.member      사용자 / 마이페이지
com.pcs.domain.partner     거래처
com.pcs.domain.category    품목 분류
com.pcs.domain.part        품목 / 개별 부품 / 기준
com.pcs.domain.stock       입고 / 출고 / 재고 변화
com.pcs.domain.inspection  검수 / 검수 템플릿
com.pcs.domain.history     이력
com.pcs.domain.dashboard   대시보드
```

## 5. 권한 기준

권한 기준 원본은 `docs/ai/pcs-permission-rules.md`이다.

권한 검증은 Controller가 아니라 인증/인가 계층과 Service 검증에서 처리한다.
API별 특별 제한이 있으면 각 feature 문서에만 추가한다.

기본 기준:

- 업무 데이터 API는 인증된 `OWNER / ADMIN / STAFF`가 모두 사용할 수 있다.
- `STAFF`도 품목, 품목 분류, 사양 항목, 거래처, 입고, 검수, 출고 같은 실무 기능을 처리할 수 있다.
- `ADMIN`은 STAFF 업무에 사용자 관리 권한이 추가된 계정으로 본다.
- 회사 소유권/회사 정보 변경은 OWNER 중심으로 둔다.
- 사용자 생성/수정/권한 변경/임시 비밀번호 발급은 OWNER/ADMIN만 가능하다.

## 6. 공통 정책 참조

### 6.1 인증 / 토큰 / 회사 범위

- 인증/JWT 정책 원본은 `docs/features/auth.md`이다.
- 로그인 후 API 사용 방식은 `docs/ai/pcs-auth-client-rules.md`를 따른다.
- 인증 DB 검증 기준은 `docs/features/auth-db.md`를 따른다.

### 6.2 페이징 / 검색 / 정렬

- 페이징 응답, query 기준, JS 연동은 `docs/ai/pcs-pagination-rules.md`를 따른다.

### 6.3 날짜 / 시간

- DB 저장 시간은 서버 시간을 기준으로 한다.
- API 응답의 날짜/시간은 ISO-8601 문자열을 사용한다.
- 기간 검색의 `from`, `to`는 API별 기준 일시 컬럼에 적용한다.
- `createdAt`, `updatedAt`, `inspectedAt` 등 서버에서 결정하는 시간은 클라이언트 요청값을 신뢰하지 않는다.
- 검수 등록 시 `inspectedAt`은 요청 body에서 받지 않고 서버 현재 시각으로 저장한다.

### 6.4 상태 변경 / 이력

- 마스터 데이터는 물리 삭제하지 않고 `docs/ai/pcs-status-lifecycle-rules.md` 기준의 `active` 상태로 사용 여부를 관리한다.
- 품목 분류는 이 기준의 예외이며, `active` 없이 이름/설명 수정으로 관리한다.
- 입출고 원본은 수정/삭제하지 않는다.
- 입출고 오류는 취소 전표와 취소 movement로 남긴다.
- 검수 오류는 정정 이력 또는 재검수 이력으로 남긴다.
- 개별 부품의 검수 상태, 등급, 판매 상태 변경은 `tb_part_status_history`에 기록한다.
- 이력 API는 read-only다.

### 6.5 재고 정합성 / 동시성

- 현재 재고의 원천은 `tb_pc_part_unit`이다.
- `tb_part_stock.quantity`는 빠른 조회용 집계 테이블이다.
- `tb_part_stock.quantity`는 `unit_status = IN_STOCK`이고 `active = true`인 개별 부품 수량과 일치해야 한다.
- 입고, 출고, 취소는 재고 변경과 이력 저장을 같은 트랜잭션에서 처리한다.
- 출고 시점에는 개별 부품의 `unitStatus`, `inspectionStatus`, `grade`, `salesStatus`, `active`를 다시 검증한다.
- 출고 재고 차감에는 DB 동시성 전략을 둔다.

## 7. 공통 에러 기준

공통 응답, 예외, ErrorCode 기준은 `docs/ai/pcs-backend-common-rules.md`를 따른다.

## 8. 우선 구현 순서

```text
1. Owner 회원가입 + 회사 생성 / Owner 로그인
2. 업체 로그인 / 세션 조회 / 토큰 재발급
3. 사용자 / 마이페이지
4. 거래처
5. 품목 분류
6. 품목 마스터 / 개별 부품 조회
7. 입고 전표 등록
8. 검수 템플릿 / 검수 등록
9. 출고 전표 등록
10. 입출고 취소 / 검수 정정 / 재검수
11. 이력 조회
12. 대시보드 통계
```

## 9. feature 문서 분리 기준

전체 API 흐름은 이 문서에서 관리한다. 실제 구현 전에는 도메인별 feature 문서를 먼저 맞춘다.

```text
docs/features/auth.md
docs/features/company.md
docs/features/member.md
docs/features/mypage.md
docs/features/partner.md
docs/features/category.md
docs/features/part.md
docs/features/stock.md
docs/features/inspection.md
docs/features/inspection-template.md
docs/features/history.md
docs/features/dashboard.md
```
