# Partner DB Feature

## 사용하는 테이블

- `tb_trade_partner`
- `tb_company`

## 조회 대상 컬럼

`tb_trade_partner`:

- `partner_id`
- `company_id`
- `partner_name`
- `partner_type`
- `partner_role`
- `phone`
- `email`
- `address`
- `memo`
- `active`
- `updated_at`

## 제약 조건

- `UNIQUE(company_id, partner_name)`
- `INDEX(company_id, partner_role, active)`
- `INDEX(company_id, partner_type, active)`

## 목록 조회 기준

- 모든 조회는 `company_id` 조건을 반드시 포함한다.
- `keyword`는 `partner_name`, `phone`, `email`에 부분 일치 검색한다.
- `partnerType`은 `partner_type`과 정확히 일치한다.
- `partnerRole = SUPPLIER`는 `SUPPLIER`, `BOTH`를 조회한다.
- `partnerRole = CUSTOMER`는 `CUSTOMER`, `BOTH`를 조회한다.
- `active`가 없으면 거래 가능/거래 불가 거래처를 모두 조회한다.
- 목록은 `updated_at DESC, partner_id DESC` 순서로 정렬한다.
- 페이징 query와 응답 기준은 `docs/ai/pcs-pagination-rules.md`를 따른다.
- SQL은 `LIMIT`, `OFFSET`, `COUNT(*)`를 사용해 목록과 전체 건수를 분리 조회한다.

## 정합성 기준

- 비활성 회사의 거래처는 조회하지 않는다.
- 거래 불가 거래처는 신규 입출고 전표 거래처 선택 목록에서 제외한다.
- 거래처 목록 요약 숫자는 현재 검색 조건 기준으로 계산한다.
