# PCS 프로젝트 구조 기준

기능 구현 시 따라야 할 구조 기준이다.  
현재 초기 단계에서는 메인 화면과 하네스만 유지하고, 기능 확정 후 아래 구조로 확장한다.

## 기본 방향

- Spring Boot 4.0.3
- Java 17
- Gradle
- JPA 금지
- MyBatis 사용
- 정적 HTML + JS + REST API
- API 응답은 `ApiResultDto`로 통일

## 의존성 기준

기능 구조가 확정되면 아래 계열을 사용한다.

```gradle
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-validation'
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:4.0.1'
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:3.0.3'
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
│  ├─ auth
│  ├─ member
│  ├─ part
│  ├─ stock
│  └─ inspection
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
└─ validation
```

Mapper XML:

```text
src/main/resources/mapper/{domain}/{MapperName}.xml
```

Mapper 인터페이스와 XML namespace는 1:1로 맞춘다.

## 프론트 구조

```text
src/main/resources/static
├─ main.html
├─ dashboard.html
├─ parts.html
├─ stock.html
├─ inspection.html
├─ mypage.html
├─ css
├─ js
├─ fragments
└─ images
```

페이지 쌍:

```text
static/{page}.html
static/css/{page}.css
static/js/{page}.js
```

공통 JS:

```text
common-theme.js
common-api-response.js
common-auth.js
common-form.js
common-navbar.js
```

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
-> fetchJsonWithAuth('/api/**')
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

## 주요 도메인 후보

- Member: 작업자
- PartCategory: 부품 분류
- PcPart: 부품 마스터
- PartItem: 입고된 개별 제품, 관리번호 단위
- PartStock: 현재 재고
- StockMovement: 입출고 이력
- Inspection: 검수 결과
- PartStatusHistory: 상태 변경 이력

## SQL 중심 기능

- 부품 검색/필터
- 입출고 이력 조회
- 검수 이력 조회
- 상태 변경 이력 조회
- 카테고리별 재고 수량/가치
- 제조사별 재고 수량
- 등급별 재고 수량
- 기간별 입고/출고 합계
- 최근 많이 출고된 부품 TOP 5
- 검수 불합격률
- 판매 가능 재고 비율
