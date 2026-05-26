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
| GET | `/api/workspaces/{companyCode}/partners` | 거래처 목록. `keyword`, `partnerRole`, `active`, `limit` 필터를 지원한다. |
| POST | `/api/workspaces/{companyCode}/partners` | 거래처 생성 |
| GET | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 상세 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}` | 거래처 수정 |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}/active` | 거래처 사용 여부 변경 |

## 주요 규칙

- `partnerName`은 같은 업체 안에서 중복될 수 없다.
- `partnerType`은 `PC_CAFE`, `PERSON`, `COMPANY`, `ETC` 중 하나다.
- `partnerRole`은 `SUPPLIER`, `CUSTOMER`, `BOTH` 중 하나다.
- 입고 전표의 거래처는 `SUPPLIER` 또는 `BOTH`여야 한다.
- 출고 전표의 거래처는 `CUSTOMER` 또는 `BOTH`여야 한다.

## 하네스 포인트

- 거래처 조회는 항상 `companyId` 범위 안에서만 수행한다.
- 사용 중지된 거래처는 신규 입출고 전표에 사용할 수 없다.
