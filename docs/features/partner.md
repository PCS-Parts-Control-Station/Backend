# Partner Feature

## 목적

입고/출고 거래처를 관리한다. 거래처는 피시방, 개인, 기업 등이 될 수 있다.

## 패키지

```text
com.pcs.domain.partner
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/partners` | 거래처 목록. `keyword`, `partnerType`, `partnerRole`, `active`, `page`, `size`, `limit` 필터를 지원한다. |
| POST | `/api/workspaces/{companyCode}/partners` | 거래처 생성 |
| GET | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 상세 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 수정 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}/active` | 거래처 거래 가능 여부 변경 |

## 주요 규칙

- `partnerName`은 같은 업체 안에서 중복될 수 없다.
- `partnerType`은 `PC_CAFE`, `PERSON`, `COMPANY`, `ETC` 중 하나다.
- `partnerRole`은 `SUPPLIER`, `CUSTOMER`, `BOTH` 중 하나다.
- 입고 전표의 거래처는 `SUPPLIER` 또는 `BOTH`여야 한다.
- 출고 전표의 거래처는 `CUSTOMER` 또는 `BOTH`여야 한다.
- `active = true`는 거래 가능 상태다.
- `active = false`는 거래 불가 상태이며 신규 입출고 전표 거래처 선택 목록에서 제외한다.
- 거래처 목록은 공통 API 규칙에 따라 `page` 0부터 시작하고 `size` 기본값은 20, 최대값은 100이다.
- 기존 선택 목록 화면과의 호환을 위해 `limit`은 `size` 별칭으로 허용한다.
- `active`를 보내지 않으면 거래 가능/거래 불가 거래처를 모두 조회한다.
- 거래처 목록 응답은 `content`, `page`, `size`, `totalElements`, `totalPages`, `hasPrevious`, `hasNext`, `summary`를 포함한다.
- `summary`는 현재 검색 조건 기준의 `totalCount`, `supplierCount`, `customerCount`, `activeCount`를 제공한다.

## 화면 규칙

- 거래처 목록 행에는 줄별 수정/거래 상태 버튼을 반복해서 노출하지 않는다.
- 거래처 행을 선택하면 오른쪽 패널이 상세 모드로 전환된다.
- 상세 모드에서 수정 또는 새 거래처 등록으로 이어진다.
- 새 거래처 등록은 같은 오른쪽 패널을 등록 모드로 되돌려 흐름이 끊기지 않게 한다.
- 거래처 목록 페이징 이동 시 스크롤 위치를 보존한다.

## 하네스 포인트

- 거래처 조회는 항상 `companyId` 범위 안에서만 수행한다.
- 거래 불가 상태의 거래처는 신규 입출고 전표에 사용할 수 없다.
- 거래처 조회 API는 `@AuthenticationPrincipal PcsPrincipal`을 사용하고 Controller/Facade에서 Authorization 헤더를 직접 파싱하지 않는다.
- 거래처 목록 SQL은 `LIMIT`, `OFFSET`, `COUNT(*)`를 사용해 페이징한다.
