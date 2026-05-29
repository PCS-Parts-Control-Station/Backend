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
- 거래처 `active` 의미는 `docs/ai/pcs-status-lifecycle-rules.md`의 `tb_trade_partner.active` 기준을 따른다.
- 거래처 목록의 페이징 기본 규칙은 `docs/ai/pcs-pagination-rules.md`를 따른다.
- 기존 선택 목록 화면과의 호환을 위해 `limit`은 `size` 별칭으로 허용한다.
- `active`를 보내지 않으면 거래 가능/거래 불가 거래처를 모두 조회한다.
- 거래처 목록 응답은 공통 페이징 응답에 `summary`를 포함한다.
- `summary`는 현재 검색 조건 기준의 `totalCount`, `supplierCount`, `customerCount`, `activeCount`를 제공한다.

## 화면 규칙

- 거래처 목록 행에는 줄별 수정/거래 상태 버튼을 반복해서 노출하지 않는다.
- 거래처 행을 선택하면 오른쪽 패널이 상세 모드로 전환된다.
- 상세 모드에서 수정 또는 새 거래처 등록으로 이어진다.
- 새 거래처 등록은 같은 오른쪽 패널을 등록 모드로 되돌려 흐름이 끊기지 않게 한다.
- 거래처 목록 페이징 이동 시 스크롤 위치를 보존한다.

## 하네스 포인트

- 거래처 조회의 회사 범위 검증은 `docs/features/auth.md` 기준을 따른다.
- 거래처 관리 권한은 `docs/ai/pcs-permission-rules.md` 기준을 따른다.
- 거래 불가 상태의 거래처는 신규 입출고 전표에 사용할 수 없다.
- 인증 사용자 사용 방식은 `docs/ai/pcs-auth-client-rules.md` 기준을 따른다.
- 거래처 목록 SQL은 `docs/ai/pcs-pagination-rules.md` 기준으로 페이징한다.
