# PCS 프로젝트 구조 기준

기능 구현 시 따라야 할 구조 기준이다.  
현재 PCS는 기본 프로젝트와 하네스 위에 회사 등록, 인증, 거래처, 품목 분류 등 일부 기능이 붙기 시작한 단계다.  
새 기능을 추가할 때는 아래 구조를 기준으로 확장하고, 이미 구현된 기능도 같은 기준에서 벗어나면 정리한다.

## 기본 방향

- Spring Boot 4.0.3
- Java 17
- Gradle
- JPA 금지
- MyBatis 사용
- 정적 HTML + JS + REST API
- API 응답은 `docs/ai/pcs-backend-common-rules.md` 기준으로 통일

## 의존성 기준

기능 구조가 확정되면 아래 계열을 사용한다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-validation'
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:4.0.1'
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:3.0.3'
implementation 'com.fasterxml.jackson.core:jackson-databind'
runtimeOnly 'org.mariadb.jdbc:mariadb-java-client'
```

금지:

```text
spring-boot-starter-data-jpa
jakarta.persistence
JpaRepository
EntityManager
JPQL
Hibernate Dirty Checking 전제
```

## 백엔드 구조

```text
src/main/java/com/pcs
├─ PcsApiApplication.java
├─ domain
│   ├─ auth
│   ├─ company
│   ├─ member
│   ├─ partner
│   ├─ category
│   ├─ part
│   ├─ stock
│   ├─ inspection
│   ├─ history
│   └─ dashboard
├─ global
└─ web/controller
```

도메인별 기본 구조:

```text
domain/{domain}
├─ api
├─ dto/request
├─ dto/response
├─ entity
├─ facade
├─ mapper
├─ service
├─ type
└─ validation
```

기준:

- `api`에는 Controller만 둔다.
- Request/Response DTO는 `api` 하위가 아니라 `dto/request`, `dto/response`에 둔다.
- Entity는 DTO를 import하지 않는다.
- DTO도 Entity를 직접 참조하지 않는 것을 기본으로 한다.
- enum은 Entity가 아니라 도메인 타입으로 보고 `type` 패키지에 둔다.
- DTO, Entity, Service는 필요한 enum을 `type` 패키지에서 참조한다.
- validation은 해당 도메인의 입력 검증 어노테이션과 Validator를 둔다.

Mapper XML:

```text
src/main/resources/mapper/{domain}/{MapperName}.xml
```

Mapper 인터페이스와 XML namespace는 1:1로 맞춘다.

## 프론트 구조

```text
src/main/resources/static
├─ main.html
├─ company-register.html
├─ workspace-login.html
├─ dashboard.html
├─ categories.html
├─ partners.html
├─ inbound-register.html
├─ documents.html
├─ css
├─ js
└─ images
```

페이지 파일 기준:

```text
static/{page}.html
```

CSS와 JS 작성 기준은 화면 유형별 문서를 따른다.

- 공개/진입 화면: `docs/ai/pcs-design-system.md`, `docs/ai/design/public-pages.md`
- 로그인 후 업무 화면: `docs/ai/pcs-design-system.md`, `docs/ai/design/workspace-layout.md`
- CSS 구조: `docs/ai/design/css-architecture.md`의 core/layout/components/pages 소유권과 layer 순서를 따른다.
- 화면별 JS: 실제 API 연동이나 상호작용이 있을 때만 작성

공통 JS:

```text
pcs-api.js
pcs-pagination.js
pcs-ui.js
pcs-common.js
pcs-navigation-state.js
```

- 공통 JS 사용 기준은 `docs/ai/pcs-frontend-js-rules.md`를 따른다.
- 인증 API 호출 방식은 `docs/ai/pcs-auth-client-rules.md`를 따른다.
- 페이징 목록 화면은 `docs/ai/pcs-pagination-rules.md`를 따른다.
- 회사 코드 추출, workspace 링크 갱신, 날짜/숫자 포맷, 토스트 래핑, 폼 저장중 처리, 공통 테이블 빈 행 처리는 `pcs-common.js`를 우선 사용한다.
- 목록 화면의 검색 조건, 페이지, 선택된 상세 행, 스크롤 위치 복원은 `pcs-navigation-state.js`를 우선 사용한다. 사용 예시는 `docs/ai/pcs-navigation-state-guide.md`를 참고한다.

입고 화면 JS:

```text
inbound.js
inbound-register.js
```

- `inbound.js`는 입고 전표 목록, 검색, 페이지네이션, 우측 상세 패널, 전표 취소 모달을 담당한다.
- `inbound-register.js`는 입고 전표 등록, 품목 검색, 품목 라인 편집, 저장 확인 모달을 담당한다.
- 입고 목록은 `pcs-api.js`, `pcs-pagination.js`, `pcs-ui.js`를 함께 사용한다.
- 입고 등록은 `pcs-api.js`, `pcs-ui.js`를 함께 사용한다.

## PageController 기준

PageController는 정적 HTML forward만 한다.

```java
@GetMapping("/parts")
public String parts() {
    return "forward:/parts.html";
}
```

금지:

- `Model`
- `model.addAttribute`
- Facade/Service/Mapper 주입
- DB 조회
- API 응답 생성

## REST API 흐름

```text
HTML
-> page.js
-> PcsApi.request('/api/**')
-> Controller
-> Facade
-> Service
-> Mapper
-> Mapper XML
-> DB
-> ApiResultDto JSON
-> JS 렌더링
```

## 트랜잭션 기준

Write 유스케이스는 Facade public 메서드에 둔다.

```java
// 출고 등록: 부품 조회 -> 판매 가능 검증 -> 재고 차감 -> 출고 이력 저장
@Transactional
public StockOutboundResult outbound(...) {
}
```

트랜잭션 기준은 Service 호출 개수가 아니라 하나의 유스케이스 작업 단위인지 여부다.

## 주요 도메인

- Company: 업체 작업 공간, 회사 코드, 회사 활성 상태
- Member: Owner, Admin, Staff 작업자 계정
- TradePartner: 입고/출고 거래처
- PartCategory: 품목 분류
- PcPart: 부품 종류/모델 마스터
- PcPartUnit: 개별 중고 부품, 관리번호 단위
- PartStock: 현재 재고 집계
- StockDocument: 거래처와 연결되는 입출고 전표
- StockMovement: 전표 안의 부품별 재고 변화 라인
- StockMovementUnit: 재고 변화 라인에 포함된 개별 부품 매핑
- Inspection: 검수, 정정, 재검수 이력
- InspectionTemplate: 품목 분류별 검수 양식
- InspectionTemplateItem: 검수 항목
- InspectionTemplateItemOption: SELECT 항목 선택지
- InspectionItemResult: 실제 검수 항목별 결과
- PartStatusHistory: 개별 부품 상태 변경 이력
- Dashboard: 운영 요약, 우선 처리 목록, 통계 조회

## 공통 구현 위치

새 도메인 구현 전에 같은 기능을 이미 공통으로 제공하는지 먼저 확인한다.

```text
global/workspace/WorkspaceAccessValidator.java
global/workspace/WorkspaceMapper.java
global/pagination/PageQuery.java
global/util/TextNormalizer.java
domain/category/type/PartSpecInputTypes.java
```

기준:

- `/api/workspaces/{companyCode}/**` API의 업체 코드/JWT 회사 범위 검증은 `WorkspaceAccessValidator`를 사용한다.
- 회사 활성 여부 확인 SQL은 도메인별 Mapper에 반복하지 않고 `WorkspaceMapper`를 사용한다.
- 목록 API의 page/size/offset 계산은 `PageQuery`를 사용한다.
- request 문자열의 required/optional trim 처리는 `TextNormalizer`를 사용한다.
- 품목 분류 사양 입력 타입은 `PartSpecInputTypes` 기준을 사용한다.

## SQL 중심 기능

- 품목 검색/필터
- 입출고 전표 조회
- 검수 이력 조회
- 상태 변경 이력 조회
- 품목 분류별 재고 수량
- 제조사별 재고 수량
- 등급별 재고 수량
- 기간별 입고/출고 합계
- 최근 많이 출고된 부품 TOP 5
- 검수 불합격률
- 판매 가능 재고 비율
