# CheckDb Feature

## 목적

기능별 DB 검증을 실행하기 전에 로컬 DB가 PCS 기본 스키마를 갖추고 있는지 확인한다.

`checkdb.md`는 기능 시나리오 문서가 아니다.  
DB 연결, 필수 테이블, 필수 컬럼, 공통 제약 조건만 확인한다.

## 연결 기준

하네스는 아래 환경값을 사용한다.

```text
DB_URL
DB_USER
DB_PASSWORD
```

환경값이 없으면 `src/main/resources/application.yaml`의 기본값과 같은 값을 사용한다.

```text
jdbc:mariadb://localhost:3306/pcs_db
localuser
pcs123#
```

## 필수 테이블

```text
tb_company
tb_member
tb_auth_refresh_token
tb_auth_login_history
tb_trade_partner
tb_part_category
tb_pc_part
tb_pc_part_unit
tb_part_stock
tb_stock_document
tb_stock_movement
tb_stock_movement_unit
tb_inspection_template
tb_inspection_template_item
tb_inspection_template_item_option
tb_inspection
tb_part_status_history
tb_inspection_item_result
```

## 공통 컬럼 기준

업체 하위 데이터 테이블은 `company_id`를 가진다.

```text
tb_member.company_id
tb_auth_refresh_token.company_id
tb_auth_login_history.company_id
tb_trade_partner.company_id
tb_part_category.company_id
tb_pc_part.company_id
tb_pc_part_unit.company_id
tb_part_stock.company_id
tb_stock_document.company_id
tb_stock_movement.company_id
tb_inspection_template.company_id
tb_inspection.company_id
tb_part_status_history.company_id
tb_auth_refresh_token.company_id
```

마스터성 테이블은 `active` 상태를 가진다.

```text
tb_company.active
tb_member.active
tb_trade_partner.active
tb_part_category.active
tb_pc_part.active
tb_pc_part_unit.active
tb_inspection_template.active
tb_inspection_template_item.active
tb_inspection_template_item_option.active
```

인증 공통 컬럼은 로그인/토큰 검증에 필요하다.

```text
tb_member.password_hash
tb_member.password_status
tb_member.login_failed_count
tb_member.locked_until_at
tb_member.last_login_ip
tb_member.last_login_user_agent
tb_auth_refresh_token.refresh_token_hash
tb_auth_refresh_token.token_family_id
tb_auth_refresh_token.expires_at
tb_auth_login_history.login_result
```

## 공통 제약 기준

```text
tb_company.uk_company_code
tb_company.uk_company_business_registration_no
tb_member.uk_member_company_login
tb_member.uk_member_company_owner
tb_member.chk_member_owner_slot
tb_auth_refresh_token.uk_auth_refresh_token_hash
```

## 하네스 기준

- `-RunDb` 또는 `-DbFeature` 실행 시 이 문서의 기준을 먼저 검사한다.
- DB 연결 실패는 FAIL이다.
- 필수 테이블, 필수 컬럼, 필수 제약 조건 누락은 FAIL이다.
- 기능별 저장 시나리오는 `{feature}-db.md`에서 검사한다.
- 실행 명령과 피드백 리포트 생성 기준은 `docs/ai/pcs-harness-rules.md`를 따른다.
