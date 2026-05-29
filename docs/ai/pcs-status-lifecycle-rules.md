# PCS Status Lifecycle Rules

이 문서는 `active`와 상태 보존 기준의 원본 문서다.
도메인별 feature 문서는 이 문서를 참조하고, 해당 도메인의 추가 제한만 적는다.

## 기본 원칙

- 마스터성 데이터는 물리 삭제하지 않는다.
- 업무 이력은 수정/삭제하지 않고 정정, 취소, 재처리 이력으로 남긴다.
- `active`는 "행이 존재하는가"가 아니라 "현재 업무에서 사용할 수 있는가"를 나타낸다.
- 조회 화면에서는 필요에 따라 active/inactive를 모두 볼 수 있지만, 신규 업무 선택 목록에서는 inactive 데이터를 제외한다.

## 도메인별 active 의미

```text
tb_company.active
```

- 업체 작업공간 사용 가능 여부다.
- `false`이면 Owner 로그인과 회사 조회를 제외한 업체 업무 API 접근을 차단한다.

```text
tb_member.active
```

- 계정 사용 가능 여부다.
- `false`이면 로그인할 수 없다.

```text
tb_trade_partner.active
```

- 거래 가능 여부다.
- `false`이면 신규 입고/출고 전표의 거래처 선택 목록에서 제외한다.
- 과거 전표와 이력 조회에서는 그대로 참조할 수 있어야 한다.

```text
tb_part_category.active
```

- 신규 부품 등록에서 선택 가능한 카테고리인지 나타낸다.
- 기존 부품과 이력은 유지한다.

```text
tb_pc_part.active
```

- 부품 마스터를 신규 업무에서 사용할 수 있는지 나타낸다.
- 재고 수량 자체는 `tb_pc_part_unit`과 `tb_part_stock` 기준으로 판단한다.

```text
tb_pc_part_unit.active
```

- 개별 실물 부품을 관리 대상으로 유지할지 나타낸다.
- 입고/출고/폐기 같은 물류 상태는 `unit_status`로 판단하고, `active`로 대체하지 않는다.

```text
tb_inspection_template.active
tb_inspection_template_item.active
tb_inspection_template_item_option.active
```

- 신규 검수에서 사용할 수 있는 양식, 항목, 선택지인지 나타낸다.
- 과거 검수 결과는 snapshot 기준으로 유지한다.

## 문서 작성 기준

- feature 문서에서는 `active` 의미를 중복 정의하지 않는다.
- 기능에 특별한 선택 제외 규칙이 있으면 이 문서를 참조한 뒤 해당 조건만 적는다.
- DB 검증 문서는 컬럼 존재 여부와 핵심 제약을 검사하고, 의미 설명은 이 문서를 원본으로 둔다.
