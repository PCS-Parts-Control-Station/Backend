# PCS API 명세 설계서

이 문서는 PCS의 화면 라우트와 REST API 설계를 정리한다.  
화면 URL은 `PageController`가 정적 HTML을 forward하고, 실제 데이터 처리는 `/api/**`에서 수행한다.

## 1. API 설계 원칙

- 모든 API 응답은 `ApiResultDto<T>`로 감싼다.
- 화면 URL과 API URL을 분리한다.
- 업체 업무 API는 `/api/workspaces/{companyCode}/**` 아래에 둔다.
- `companyCode`는 URL 식별값일 뿐이며, JWT와 DB 기준으로 실제 소속 업체를 검증한다.
- 마스터 데이터는 `PATCH`로 수정하고, 삭제 대신 `active`를 변경한다.
- 입출고와 검수는 이력성 데이터이므로 원본 수정/삭제를 하지 않는다.
- 입출고 오류는 취소 이력으로 남긴다.
- 검수 오류는 정정 이력 또는 재검수 이력으로 남긴다.
- write API는 Facade public 메서드에서 트랜잭션을 가진다.
- 목록/검색/통계는 SQL에서 필터링/집계한다.

## 2. 공통 응답

성공:

```json
{
  "status": 200,
  "code": null,
  "message": "조회 성공",
  "data": {}
}
```

실패:

```json
{
  "status": 404,
  "code": "PART_NOT_FOUND",
  "message": "부품 정보를 찾을 수 없습니다.",
  "data": null
}
```

페이징:

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 0,
  "totalPages": 0
}
```

공통 query:

```text
keyword
from
to
page
size
sort
```

## 3. 화면 라우트

```text
/                              PCS 사이트 메인
/owner/signup                  Owner 회원가입
/owner/login                   Owner 로그인
/owner/company                 회사 생성 / 회사 코드 발급
/owner/company/complete        회사 생성 완료 / 업체 접속 안내
/w                             업체 코드 + 아이디 + 비밀번호 로그인
/w/{companyCode}               특정 업체 로그인
/w/{companyCode}/dashboard     업무 대시보드
/w/{companyCode}/parts         부품 / 재고 목록
/w/{companyCode}/parts/{partId} 부품 상세 / 관리번호별 상태
/w/{companyCode}/inbound       입고 등록
/w/{companyCode}/inspection    검수 등록 / 검수 관리
/w/{companyCode}/outbound      출고 등록
/w/{companyCode}/history       이력 관리
/w/{companyCode}/users         사용자 관리
/w/{companyCode}/categories    카테고리 관리
/w/{companyCode}/partners      거래처 관리
/w/{companyCode}/standards     부품 기준 관리
/w/{companyCode}/mypage        내 정보
```

## 4. 인증 / Owner / 회사

| Method | API | 설명 |
|---|---|---|
| POST | `/api/owners/signup` | Owner 회원가입 |
| POST | `/api/owners/login` | Owner 로그인 |
| POST | `/api/owners/companies` | 회사 생성 / 회사 코드 발급 |
| GET | `/api/owners/company` | Owner 회사 조회 |
| PATCH | `/api/owners/company` | 회사 정보 수정 |
| PATCH | `/api/owners/company/active` | 회사 활성 여부 변경 |
| POST | `/api/auth/refresh` | 토큰 재발급 |
| POST | `/api/auth/logout` | 로그아웃 |

Owner 회사 생성 요청 후보:

```json
{
  "companyName": "그린파츠",
  "companyCode": "greenparts"
}
```

## 5. 업체 로그인 / 세션

| Method | API | 설명 |
|---|---|---|
| POST | `/api/workspaces/login` | 업체 코드 + 아이디 + 비밀번호 로그인 |
| POST | `/api/workspaces/{companyCode}/login` | 특정 업체 로그인 |
| GET | `/api/workspaces/{companyCode}/me` | 내 세션 정보 조회 |

업체 로그인 요청 후보:

```json
{
  "companyCode": "greenparts",
  "loginId": "staff01",
  "password": "password"
}
```

## 6. 대시보드

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard/summary` | 대시보드 요약 |
| GET | `/api/workspaces/{companyCode}/dashboard/todos` | 우선 처리 목록 |
| GET | `/api/workspaces/{companyCode}/dashboard/statistics` | 운영 통계 |

통계 query 후보:

```text
from
to
```

## 7. 거래처

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/partners` | 거래처 목록 |
| POST | `/api/workspaces/{companyCode}/partners` | 거래처 생성 |
| GET | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 상세 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 수정 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}/active` | 거래처 사용 여부 변경 |

목록 query 후보:

```text
keyword
partnerType
partnerRole
active
page
size
```

생성 요청 후보:

```json
{
  "partnerName": "A피시방",
  "partnerType": "PC_CAFE",
  "partnerRole": "SUPPLIER",
  "phone": "010-0000-0000",
  "email": null,
  "address": "서울시",
  "memo": "중고 부품 매입 거래처"
}
```

규칙:

- `partnerName`은 같은 업체 안에서 중복될 수 없다.
- 입고 거래처는 `SUPPLIER` 또는 `BOTH`여야 한다.
- 출고 거래처는 `CUSTOMER` 또는 `BOTH`여야 한다.

## 8. 카테고리

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/categories` | 카테고리 목록 |
| POST | `/api/workspaces/{companyCode}/categories` | 카테고리 생성 |
| GET | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 상세 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}` | 카테고리 수정 |
| PATCH | `/api/workspaces/{companyCode}/categories/{categoryId}/active` | 카테고리 사용 여부 변경 |

생성 요청 후보:

```json
{
  "categoryName": "GPU",
  "description": "그래픽카드"
}
```

규칙:

- `categoryName`은 같은 업체 안에서 중복될 수 없다.
- 사용 중지된 카테고리는 신규 부품 등록에서 선택할 수 없다.

## 9. 부품 / 개별 부품

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/parts` | 부품/재고 목록 검색 |
| POST | `/api/workspaces/{companyCode}/parts` | 부품 마스터 등록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}` | 부품 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}` | 부품 마스터 수정 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/active` | 부품 활성 여부 변경 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units` | 개별 부품 목록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}` | 개별 부품 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/sales-status` | 개별 부품 판매 상태 변경 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/active` | 개별 부품 활성 여부 변경 |

부품 목록 query 후보:

```text
keyword
categoryId
manufacturer
unitStatus
inspectionStatus
grade
salesStatus
stockStatus
active
page
size
```

부품 등록 요청 후보:

```json
{
  "categoryId": 1,
  "partName": "RTX 3060 Twin Edge",
  "modelName": "RTX 3060 Twin Edge",
  "manufacturer": "ZOTAC",
  "partCode": "GPU-ZT-3060-12G",
  "estimatedPrice": 180000,
  "safeQuantity": 3
}
```

개별 부품 판매 상태 변경 요청 후보:

```json
{
  "salesStatus": "AVAILABLE",
  "reason": "검수 완료 후 판매 가능 처리"
}
```

규칙:

- `partCode`는 같은 업체 안에서 중복될 수 없다.
- 개별 부품의 현재 상태는 `tb_pc_part_unit` 기준이다.
- `grade = DEFECTIVE`인 개별 부품은 `AVAILABLE`로 변경할 수 없다.
- 판매 상태 변경 시 `tb_part_status_history`를 저장한다.

## 10. 입고 / 출고 전표

| Method | API | 설명 |
|---|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` | 입고 전표 등록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` | 출고 전표 등록 |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` | 입출고 전표 취소 |
| GET | `/api/workspaces/{companyCode}/stock/documents` | 입출고 전표 목록 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` | 입출고 전표 상세 |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}/movements` | 전표의 부품별 재고 변화 라인 |

전표 목록 query 후보:

```text
documentType
documentStatus
partnerId
processedBy
from
to
page
size
```

입고 전표 등록 요청 후보:

```json
{
  "partnerId": 1,
  "documentNo": "IN-20260513-0001",
  "reason": "A피시방 매입 부품 입고",
  "lines": [
    {
      "partId": 10,
      "quantity": 5,
      "reason": "CPU 입고",
      "units": [
        {
          "internalSerialNo": "PCS-CPU-20260513-0001",
          "manufacturerSerialNo": null
        }
      ]
    },
    {
      "partId": 20,
      "quantity": 10,
      "reason": "RAM 입고",
      "units": []
    }
  ]
}
```

출고 전표 등록 요청 후보:

```json
{
  "partnerId": 2,
  "documentNo": "OUT-20260513-0001",
  "reason": "조립 라인 출고",
  "lines": [
    {
      "partId": 10,
      "unitIds": [101, 102],
      "reason": "CPU 출고"
    }
  ]
}
```

전표 취소 요청 후보:

```json
{
  "reason": "거래처 요청으로 입고 취소"
}
```

입고 트랜잭션:

```text
거래처 검증
전표 번호 중복 검증
부품별 라인 검증
개별 부품 생성
tb_part_stock 증가
tb_stock_document 저장
tb_stock_movement 저장
tb_stock_movement_unit 저장
```

출고 트랜잭션:

```text
거래처 검증
전표 번호 중복 검증
출고 대상 unit 조회
검수 완료 검증
불량 아님 검증
판매 가능 검증
재고 충분 검증
개별 부품 OUTBOUND 변경
tb_part_stock 감소
tb_stock_document 저장
tb_stock_movement 저장
tb_stock_movement_unit 저장
```

취소 트랜잭션:

```text
원본 전표 조회
취소 가능 상태 검증
원본 document/movement를 CANCELED 처리
취소 document 생성
취소 movement 생성
canceled_movement_id 저장
개별 부품 상태 반대로 변경
tb_part_stock 반대로 반영
```

취소 규칙:

```text
원본 document:
document_status = CANCELED

원본 movement:
movement_status = CANCELED

취소 movement:
movement_type = INBOUND_CANCEL 또는 OUTBOUND_CANCEL
movement_status = COMPLETED
canceled_movement_id = 원본 movement_id
```

## 11. 입출고 재고 변화 라인

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/stock/movements` | 입출고 재고 변화 라인 목록 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}` | 입출고 재고 변화 라인 상세 |
| GET | `/api/workspaces/{companyCode}/stock/movements/{movementId}/units` | 라인에 포함된 개별 부품 목록 |

목록 query 후보:

```text
documentId
movementType
movementStatus
partId
unitId
partnerId
processedBy
from
to
page
size
```

## 12. 검수

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-units` | 검수 대기 개별 부품 조회 |
| POST | `/api/workspaces/{companyCode}/inspections` | 최초 검수 등록 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` | 검수 정정 이력 생성 |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` | 재검수 이력 생성 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/inspections` | 개별 부품 검수 이력 |

검수 대기 query 후보:

```text
partId
categoryId
keyword
page
size
```

검수 등록 요청 후보:

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

정정/재검수 요청은 검수 등록 요청과 같은 body를 사용한다.

검수 트랜잭션:

```text
개별 부품 조회
템플릿/항목 검증
검수 요청 검증
tb_inspection 저장
tb_inspection_item_result 저장
tb_pc_part_unit 현재 검수 상태/등급/판매 상태 변경
tb_part_status_history 저장
```

검수 이력 규칙:

```text
INITIAL:
original_inspection_id = null

CORRECTION:
original_inspection_id = 정정 대상 inspection_id

REINSPECTION:
original_inspection_id = 재검수 기준 inspection_id
```

검수 상태 규칙:

```text
result = PASS:
inspection_status = COMPLETED

result = FAIL:
inspection_status = COMPLETED
grade = DEFECTIVE
sales_status = UNAVAILABLE
```

## 13. 검수 템플릿 / 항목 / 선택지

| Method | API | 설명 |
|---|---|---|
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

템플릿 생성 요청 후보:

```json
{
  "categoryId": 1,
  "templateName": "GPU 기본 검수",
  "version": 1
}
```

항목 생성 요청 후보:

```json
{
  "itemGroup": "BASIC",
  "itemName": "팬 동작 여부",
  "inputType": "SELECT",
  "required": true,
  "sortOrder": 1,
  "gradeImpact": "HIGH",
  "failPolicy": "BLOCK_SALE"
}
```

선택지 생성 요청 후보:

```json
{
  "optionLabel": "정상",
  "optionValue": "NORMAL",
  "sortOrder": 1
}
```

규칙:

- `inputType = SELECT`인 항목만 선택지를 가진다.
- 검수 결과에는 항목명과 선택지 값을 snapshot으로 저장한다.

## 14. 이력

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/history/units/{unitId}/timeline` | 개별 부품 전체 타임라인 |
| GET | `/api/workspaces/{companyCode}/history/stock-documents` | 입출고 전표 이력 |
| GET | `/api/workspaces/{companyCode}/history/stock-movements` | 입출고/취소 재고 변화 이력 |
| GET | `/api/workspaces/{companyCode}/history/inspections` | 검수/정정/재검수 이력 |
| GET | `/api/workspaces/{companyCode}/history/status-changes` | 상태 변경 이력 |

공통 query 후보:

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

## 15. 사용자

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/users` | 사용자 목록 |
| POST | `/api/workspaces/{companyCode}/users` | 사용자 생성 |
| GET | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 상세 |
| PATCH | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 수정 |
| PATCH | `/api/workspaces/{companyCode}/users/{memberId}/active` | 사용자 활성 여부 변경 |
| POST | `/api/workspaces/{companyCode}/users/{memberId}/temporary-password` | 임시 비밀번호 발급 |

사용자 생성 요청 후보:

```json
{
  "loginId": "staff01",
  "name": "이검수",
  "role": "STAFF",
  "temporaryPassword": "temp-password"
}
```

규칙:

- `loginId`는 같은 업체 안에서 중복될 수 없다.
- OWNER는 회사 소유자다.
- ADMIN은 사용자/카테고리/기준 관리 권한을 가진다.
- STAFF는 입고/검수/출고 업무 권한을 가진다.

## 16. 부품 기준 관리

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/standards` | 부품 기준 조회 |
| GET | `/api/workspaces/{companyCode}/standards/part-code/check` | 부품 코드 중복 확인 |

부품 코드 중복 확인 query:

```text
partCode
excludePartId
```

응답 데이터 후보:

```json
{
  "duplicated": false
}
```

## 17. 마이페이지

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/mypage` | 내 정보 조회 |
| PATCH | `/api/workspaces/{companyCode}/mypage` | 내 정보 수정 |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` | 비밀번호 변경 |

규칙:

- 본인 정보만 수정한다.
- 임시 비밀번호 상태면 비밀번호 변경을 요구한다.

## 18. 권한 기준

```text
OWNER:
- 회사 생성
- 전체 업체 업무 접근
- 사용자 관리

ADMIN:
- 사용자 관리
- 거래처 관리
- 카테고리 관리
- 부품 기준 관리
- 입고/검수/출고/이력 조회

STAFF:
- 대시보드 조회
- 부품/재고 조회
- 입고 등록
- 검수 등록
- 출고 등록
- 이력 조회
- 내 정보 관리
```

## 19. 우선 구현 순서

```text
1. Owner 회원가입 / 로그인 / 회사 생성
2. 업체 로그인 / 세션 조회 / 토큰 재발급
3. 사용자 / 마이페이지
4. 거래처
5. 카테고리
6. 부품 마스터 / 개별 부품 조회
7. 입고 전표 등록
8. 검수 템플릿 / 검수 등록
9. 출고 전표 등록
10. 입출고 취소 / 검수 정정 / 재검수
11. 이력 조회
12. 대시보드 통계
```

## 20. feature 문서 분리 기준

전체 API 흐름은 이 문서에서 관리한다.  
실제 구현 전에는 도메인별 feature 문서를 먼저 만든다.

```text
docs/features/auth.md
docs/features/company.md
docs/features/member.md
docs/features/partner.md
docs/features/category.md
docs/features/part.md
docs/features/stock.md
docs/features/inspection.md
docs/features/history.md
docs/features/dashboard.md
```

각 feature 문서에는 다음을 포함한다.

```text
화면 요구사항
API 목록
Request DTO
Response DTO
Facade 유스케이스
Service 검증 규칙
Mapper SQL 후보
ErrorCode 후보
하네스 검사 포인트
```
