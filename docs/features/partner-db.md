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

## 저장 / 수정 대상 컬럼

거래처 생성 시 저장한다.

- `company_id`
- `partner_name`
- `partner_type`
- `partner_role`
- `phone`
- `email`
- `address`
- `memo`
- `active`
- `created_by`
- `created_at`
- `updated_at`

거래처 기본 정보 수정 시 갱신한다.

- `partner_name`
- `partner_type`
- `partner_role`
- `phone`
- `email`
- `address`
- `memo`
- `active`
- `updated_at`

거래 가능 여부 변경 시 갱신한다.

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
- 기본 목록 정렬은 `idx_trade_partner_company_list (company_id, updated_at DESC, partner_id DESC)`를 기준으로 검증한다.
- 페이징 query와 응답 기준은 `docs/ai/pcs-pagination-rules.md`를 따른다.
- SQL은 `LIMIT`, `OFFSET`, `COUNT(*)`를 사용해 목록과 전체 건수를 분리 조회한다.

## 정합성 기준

- 비활성 회사의 거래처는 조회하지 않는다.
- 거래처 `active` 의미와 신규 입출고 전표 선택 제외 기준은 `docs/ai/pcs-status-lifecycle-rules.md`를 따른다.
- 거래처 목록 요약 숫자는 현재 검색 조건 기준으로 계산한다.
- 거래처 생성 시 같은 `company_id` 안에서 `partner_name`이 중복되면 실패한다.
- 거래처 수정 시 자기 자신을 제외한 같은 `company_id` 안에서 `partner_name`이 중복되면 실패한다.
- 거래처 생성 요청의 `active`가 없으면 `TRUE`로 저장한다.
- 거래처 수정 요청에 `active`가 포함되면 같은 수정 트랜잭션에서 거래 가능 여부도 함께 저장한다.
- 거래처 수정 요청에 `active`가 없으면 기존 거래 가능 여부를 유지한다.
- 거래 가능 여부만 단독 변경해야 하는 경우 별도 active API를 사용할 수 있다.
- 거래처는 하드 삭제하지 않는다. 업무 제외는 `active = FALSE`로 처리한다.
## DB Integration Test Coverage

- Integration test: `PartnerPersistenceIntegrationTest`
- Schema fixture: `src/integrationTest/resources/pcs-account-test-schema.sql`
- Required checks:
  - partner rows are stored in `tb_trade_partner` with company scope
  - search filters support keyword, type, role, active, and pagination
  - `SUPPLIER` and `CUSTOMER` role filters include `BOTH`
  - duplicate partner name is blocked per company
  - active status can be changed without hard deleting the row
