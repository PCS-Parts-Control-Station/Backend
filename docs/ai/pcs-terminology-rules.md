# PCS Terminology Rules

화면 문구, API/DB 이름, 도메인 패키지 이름이 서로 섞이지 않도록 하는 용어 기준이다.

## 기본 원칙

- 사용자에게 보이는 화면 문구는 업무자가 이해하는 한국어를 우선한다.
- 사용자 화면에는 내부 권한 코드, API 이름, URL, `노출/차단/허용` 같은 시스템 구현 설명을 넣지 않는다.
- 화면 안내는 "이 기능이 어떻게 제한되는가"보다 "사용자가 여기서 무엇을 하면 되는가"를 먼저 말한다.
- Java package, API path, DB table/column 이름은 이미 정한 영문 도메인명을 유지한다.
- 화면 문구를 바꾼다고 DB명이나 API path를 즉시 바꾸지 않는다.
- feature 문서에서는 화면 용어와 기술 용어가 다를 수 있음을 명확히 적는다.

## 화면 용어

사용자 화면에서는 아래 용어를 기본으로 한다.

```text
part -> 품목
category -> 분류 또는 품목 분류
partName -> 품목명
partCode -> 품목코드
modelName -> 제조사 모델명
manufacturer -> 제조사
specDefinition -> 사양 항목
specValue -> 사양값
safeQuantity -> 안전 재고
estimatedPrice -> 예상 단가
partner -> 거래처
active(partner) -> 거래 가능 여부
```

기준:

- `/w/{companyCode}/parts` 화면 제목은 `품목 관리`를 사용한다.
- `/w/{companyCode}/categories` 화면 제목은 `품목 분류 관리`를 사용한다.
- 사이드바 관리 메뉴는 `품목 관리`, `품목 분류`, `거래처 관리`, `사용자 관리` 순서와 명칭을 사용한다.
- 품목 등록/수정 폼에서는 `내부 부품코드` 입력을 받지 않는다. 품목코드는 서버가 자동 생성한다.
- 품목 등록/수정 폼에서는 `품목명`, `제조사`, `제조사 모델명`, `분류`, `상세입력`을 사용한다.

## 기술 용어

코드와 DB에서는 기존 도메인명을 유지한다.

```text
com.pcs.domain.part
com.pcs.domain.category
tb_pc_part
tb_part_category
tb_part_spec_definition
tb_part_spec_option
tb_part_spec_value
part_id
category_id
part_name
part_code
```

기준:

- API path는 `/parts`, `/categories`를 유지한다.
- DTO 필드는 현재 API 계약인 `partName`, `categoryId`, `partCode` 등을 유지한다.
- MyBatis XML과 SQL은 DB 컬럼명 기준으로 작성한다.

## 문서 작성 기준

- 화면 디자인 문서에서는 사용자 용어를 우선한다.
- API/DB 문서에서는 기술명을 쓰되, 필요하면 괄호로 화면 용어를 병기한다.
- 같은 문서 안에서 `부품 관리`와 `품목 관리`를 같은 화면 의미로 섞어 쓰지 않는다.
- `부품`은 PCS 전체 도메인 설명이나 개별 실물 부품 추적 맥락에서 사용할 수 있다.
- 품목 마스터 화면, 목록, 등록/수정 폼에서는 `품목`을 사용한다.
- 사용자 화면 문구 예시는 반드시 최종 사용자 관점으로 쓴다. 개발자 설명이 필요하면 화면 문구가 아니라 문서의 구현 메모에만 적는다.

예:

```text
좋음: 품목 마스터는 tb_pc_part에 저장한다.
좋음: category 도메인은 화면에서 품목 분류로 표시한다.
좋음: 업무 메뉴가 보이지 않으면 관리자에게 확인하세요.
피함: 부품 관리 화면에서 부품명과 품목명을 섞어 쓴다.
피함: 사용자 관리는 OWNER와 ADMIN에게만 노출됩니다.
피함: POST /api/... 호출 후 dashboard로 이동합니다.
```
