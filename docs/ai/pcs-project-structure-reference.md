# PCS 프로젝트 구조 기준

이 문서는 애플리케이션 구조와 계층 책임의 원본이다.

## 기술 기준

- Java 17, Spring Boot 4.0.3, Gradle
- Spring MVC, Spring Security, Jakarta Validation
- MyBatis Mapper 인터페이스와 XML SQL
- MariaDB
- 정적 HTML + Vanilla JavaScript + REST API
- JPA, `jakarta.persistence`, `JpaRepository`, `EntityManager`, JPQL, Hibernate Dirty Checking 전제 금지

의존성 버전은 `build.gradle`을 실제 원본으로 보고, 문서에는 선택 이유와 금지 기준만 유지한다.

## 백엔드 구조

```text
src/main/java/com/pcs
├─ PcsApiApplication.java
├─ domain/{domain}
│  ├─ api
│  ├─ dto/request
│  ├─ dto/response
│  ├─ entity
│  ├─ facade
│  ├─ mapper
│  ├─ service
│  ├─ type
│  └─ validation
├─ global
└─ web/controller
```

Mapper XML:

```text
src/main/resources/mapper/{domain}/{MapperName}.xml
```

Mapper 인터페이스와 XML namespace는 1:1로 맞춘다.

## 계층 책임

Controller:

- URL과 Method, `@Valid`, `@AuthenticationPrincipal`
- Request DTO 수신, Facade 호출, Response DTO와 `ApiResultDto` 반환
- Service·Mapper 직접 호출, JWT 직접 파싱, 업무 로직 금지

Facade:

- 하나의 유스케이스 흐름과 회사 범위 검증 조립
- 여러 Service 호출과 유스케이스 단위 트랜잭션 경계
- 부분 성공이 허용되지 않는 작업 통합

Service:

- DB 조회·변경, 비즈니스 검증, 상태 변경
- Mapper 호출

Mapper:

- SQL 실행만 담당
- 비즈니스 흐름 작성 금지

PageController:

- 정적 HTML forward와 통합 화면 redirect 같은 페이지 라우팅만 담당
- Model 데이터 주입, Facade·Service·Mapper 호출, API 응답 생성 금지

## DTO와 도메인 타입

- DTO는 `record`를 기본으로 한다.
- Request DTO는 입력과 validation, Response DTO는 응답 모양을 담당한다.
- Entity는 DB row와 도메인 상태를 담당한다.
- DTO와 Entity는 서로 import하지 않는다.
- enum은 `type` 패키지에 둔다.
- 변환은 유스케이스 경계에서 명시적으로 수행하고 `DTO.toEntity()`를 남발하지 않는다.

## 프론트 구조

```text
src/main/resources/static
├─ {page}.html
├─ css/core
├─ css/layouts
├─ css/components
├─ css/pages/{page}.css
├─ js
└─ images
```

- 화면은 서버 Model을 받지 않는다.
- JS가 `/api/**`를 호출하고 JSON을 렌더링한다.
- CSS 소유권은 `docs/ai/design/css-architecture.md`를 따른다.
- 화면별 JS 규칙은 `docs/ai/pcs-frontend-js-rules.md`를 따른다.

REST 흐름:

```text
HTML -> page.js -> PcsApi -> Controller -> Facade -> Service
     -> Mapper -> XML SQL -> DB -> ApiResultDto -> JS 렌더링
```

## 트랜잭션

- 쓰기 트랜잭션은 하나의 유스케이스를 기준으로 Facade public 메서드에 둔다.
- Service 호출 개수로 트랜잭션을 나누지 않는다.
- 재고·검수·이력처럼 부분 성공이 허용되지 않는 변경은 같은 트랜잭션에서 처리한다.

## 공통 구현 위치

백엔드:

| 역할 | 공통 구현 |
|---|---|
| 업체 코드/JWT 회사 범위 | `global/workspace/WorkspaceAccessValidator.java` |
| 회사 활성 조회 | `global/workspace/WorkspaceMapper.java` |
| Security role 그룹 | `global/security/PcsRoleGroups.java` |
| page/size/offset | `global/pagination/PageQuery.java` |
| 문자열 required/optional 정규화 | `global/util/TextNormalizer.java` |
| API 응답과 예외 | `docs/ai/pcs-backend-common-rules.md` |

프론트:

| 역할 | 공통 구현/기준 |
|---|---|
| 인증 요청과 token refresh | `static/js/pcs-api.js` |
| 페이징 | `static/js/pcs-pagination.js` |
| 토스트 | `static/js/pcs-ui.js` |
| workspace·포맷·폼·테이블·드로어 | `static/js/pcs-common.js` |
| 목록 상태 복원 | `static/js/pcs-navigation-state.js` |
| 사용 규칙 | `docs/ai/pcs-frontend-js-rules.md` |

새 기능은 같은 구현을 다시 만들지 않는다. 공통 구현으로 부족하면 공통 구현을 확장한다.

## 주요 도메인

| 도메인 | 책임 |
|---|---|
| company/member/auth | 작업공간, 계정, 인증 |
| partner | 입출고 거래처 |
| category/part | 품목 분류, 품목 마스터, 사양 |
| part-unit | 관리번호 단위 조회. Java 패키지는 `part` 공유 |
| stock | 입고·출고·취소·재고 변화 |
| inspection | 검수·정정·재검수·템플릿·검수 이력 |
| dashboard | 운영 요약과 집계 조회 |

기능별 계약은 `docs/features/{feature}.md`, DB 동작 계약은 `{feature}-db.md`, 물리 스키마는 `docs/sql/pcs-schema-ddl.sql`을 원본으로 한다.
