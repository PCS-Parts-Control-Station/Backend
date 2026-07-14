# PCS (Parts Control Station)

업체별 작업공간에서 PC 부품의 품목, 개별 관리번호, 재고, 입출고, 검수, 거래처와 사용자를 관리하는 웹 기반 업무 시스템입니다.

## 1. 프로젝트 작성자, 소개, 목적

### 작성자

- 이태현
- 김진렬

### 프로젝트 소개

PCS는 중고 PC 부품 또는 재고 부품을 취급하는 작업장에서 품목 정보와 개별 부품의 전체 흐름을 한 곳에서 추적하기 위한 시스템입니다.

업체별 화면은 `/w/{companyCode}/**`, 업무 API는 `/api/workspaces/{companyCode}/**` 구조로 분리됩니다. 인증된 사용자의 회사 정보와 URL의 업체 코드를 함께 검증하고, 모든 주요 조회와 변경 SQL에 `company_id` 범위를 적용합니다.

백엔드와 프론트엔드는 하나의 Spring Boot 프로젝트로 구성되어 있습니다. 백엔드는 REST API와 정적 페이지 라우팅을 담당하고, 화면은 별도 SPA 프레임워크 없이 HTML, CSS, Vanilla JavaScript로 구현합니다.

### 목적

- 업체별 데이터 격리와 작업공간 기반 업무 흐름 제공
- 품목, 분류, 개별 관리번호 단위의 재고 현황 관리
- 입고, 검수, 출고, 취소, 정정, 재검수의 상태 전이 추적
- 거래처, 사용자, 권한 등 운영에 필요한 관리 기능 제공
- 공통 API, 디자인, 테스트 규칙을 통한 일관된 유지보수 구조 확보

## 2. 아키텍처, 기술, 버전

### 애플리케이션 아키텍처

```text
Browser
  |
  | HTML / CSS / Vanilla JavaScript
  v
Spring Boot Static Pages + REST API
  |
  | Controller -> Facade -> Service -> Mapper
  v
MyBatis XML Mapper
  |
  v
MariaDB
```

계층별 책임:

- `Controller`: 요청 검증과 공통 API 응답 반환
- `Facade`: 인증 작업공간 검증, 유스케이스 흐름, 트랜잭션 경계
- `Service`: 비즈니스 검증과 DB 조회·변경 조합
- `Mapper`: MyBatis Interface와 XML SQL 실행
- `PageController`: 정적 HTML forward 또는 redirect

### 백엔드 기술

| 항목 | 기술 및 버전 |
|---|---|
| Language | Java 17 |
| Framework | Spring Boot 4.0.3 |
| Build | Gradle Wrapper 9.4.1 |
| Web | Spring MVC |
| Security | Spring Security, OAuth2 Resource Server, JWT |
| Validation | Jakarta Validation, Spring Validation |
| Persistence | MyBatis Spring Boot Starter 4.0.1 |
| Database | MariaDB 10.11 호환 |
| API 문서 | springdoc-openapi 3.0.3 |
| Test | JUnit 5, Mockito, MockMvc, Testcontainers 또는 로컬 격리 MariaDB 통합 테스트 |

### 프론트엔드 기술

| 항목 | 기술 |
|---|---|
| Markup | HTML5 |
| Style | CSS3, CSS Variables, 공통 디자인 토큰 |
| Script | Vanilla JavaScript |
| API 통신 | `fetch` 기반 공통 API 유틸 |
| 페이지 상태 | 공통 pagination 및 navigation state 유틸 |

### 공통 설계 기준

- API 응답은 `ApiResultDto<T>` 형식으로 통일합니다.
- 목록 API는 `PageResultDto<T, S>` 구조를 사용합니다.
- DB 접근에는 JPA를 사용하지 않고 MyBatis Mapper Interface와 XML SQL을 사용합니다.
- 입고, 출고, 취소, 검수 상태 변경은 Facade의 단일 트랜잭션에서 처리합니다.
- 개별 부품의 물류 상태와 검수 상태는 원본 이력을 보존하면서 변경합니다.
- `/api/workspaces/{companyCode}/**` 요청은 인증 사용자와 업체 코드가 일치해야 합니다.

## 3. 주요 기능

### 인증과 작업공간

- Owner 회원가입과 회사 생성
- 업체 작업공간 로그인
- JWT Access Token과 HttpOnly Refresh Token 기반 인증
- 로그아웃, 토큰 재발급, 현재 세션 조회
- 업체 활성 상태와 작업공간 접근 검증

### 품목과 개별 부품

- 품목 분류 등록, 수정, 삭제와 분류별 사양 구성
- 품목 등록, 수정, 검색과 안전 재고 관리
- 관리번호 단위 개별 부품 목록과 상세 조회
- 보유, 검수 대기, 판매 가능, 등급, 출고 상태별 조회
- 관리번호별 최근 입출고·검수 이력 조회

### 입고, 출고와 재고

- 입고·출고 전표 등록과 상세 조회
- 전표별 품목과 관리번호 연결
- 입고·출고 취소 및 반대 방향 movement 이력 생성
- 현재 재고 수량과 개별 관리번호 상태 동시 변경
- 검수 완료·판매 가능 관리번호만 출고 후보로 제공

### 검수

- 검수 대상 입고 전표와 관리번호 조회
- 단건·일괄 최초 검수
- 검수 정정과 재검수 이력 추가
- 검수 결과, 등급, 판매 상태와 상태 변경 이력 저장
- 분류별 검수 템플릿, 항목과 선택지 관리

### 운영 관리와 이력

- 거래처 등록, 수정, 검색과 공급처·고객사 역할 관리
- 사용자 등록, 수정, 임시 비밀번호 발급과 작업자 권한 설정
- 마이페이지 정보와 비밀번호 변경
- 대시보드 운영 현황 집계
- 입출고 이력, 검수 이력과 부품 상태 변경 흐름 조회

## 4. 프로젝트 구조

이 README가 있는 디렉터리가 GitHub 저장소의 루트입니다.

```text
.
├─ README.md
├─ build.gradle
├─ settings.gradle
├─ gradlew
├─ gradlew.bat
├─ docs
│  ├─ ai
│  │  ├─ AI_INDEX.md
│  │  ├─ pcs-backend-common-rules.md
│  │  ├─ pcs-test-strategy.md
│  │  └─ design
│  ├─ features
│  │  ├─ auth.md
│  │  ├─ company.md
│  │  ├─ member.md
│  │  ├─ partner.md
│  │  ├─ category.md
│  │  ├─ part.md
│  │  ├─ part-unit.md
│  │  ├─ stock.md
│  │  ├─ inspection.md
│  │  ├─ inspection-template.md
│  │  └─ inspection-history.md
│  └─ sql
│     └─ pcs-schema-ddl.sql
├─ harness
│  ├─ config
│  │  └─ features.json
│  ├─ hooks
│  └─ run-harness.ps1
└─ src
   ├─ main
   │  ├─ java/com/pcs
   │  │  ├─ domain
   │  │  │  ├─ auth
   │  │  │  ├─ company
   │  │  │  ├─ member
   │  │  │  ├─ partner
   │  │  │  ├─ category
   │  │  │  ├─ part
   │  │  │  ├─ stock
   │  │  │  ├─ inspection
   │  │  │  └─ dashboard
   │  │  ├─ global
   │  │  └─ web/controller
   │  └─ resources
   │     ├─ application.yaml
   │     ├─ mapper
   │     └─ static
   │        ├─ css
   │        │  ├─ core
   │        │  ├─ layouts
   │        │  ├─ components
   │        │  └─ pages
   │        ├─ js
   │        ├─ images
   │        └─ *.html
   ├─ test
   └─ integrationTest
```

### Spring 도메인 구조

```text
domain/{feature}
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

### 웹 리소스 구조

- 공통 JS: `pcs-api.js`, `pcs-common.js`, `pcs-ui.js`, `pcs-pagination.js`, `pcs-navigation-state.js`
- 페이지 JS: `parts.js`, `part-units.js`, `categories.js`, `partners.js`, `users.js`, `inspection.js` 등
- 공통 CSS: `static/css/core`, `static/css/layouts`, `static/css/components`
- 페이지 CSS: `static/css/pages`
- 화면별 HTML: `static/*.html`

### Harness

`harness`는 프로젝트 구조, 금지 패턴, 기능별 필수 파일, Java 빌드와 관련 테스트를 검사하는 PowerShell 기반 검증 도구입니다.

Windows PowerShell:

```powershell
.\harness\run-harness.ps1 -Mode gate -RunBuild
.\harness\run-harness.ps1 -Mode gate -Feature stock -RunBuild
.\harness\run-harness.ps1 -Mode gate -Feature inspection -RunBuild
```

macOS 또는 Linux:

```bash
pwsh -NoProfile -File ./harness/run-harness.ps1 -Mode gate -RunBuild
```

## 5. 실행 환경 설정

### 필수 요구사항

- JDK 17
- MariaDB 10.11 호환 서버
- Windows PowerShell 또는 PowerShell Core
- Git

### 데이터베이스 준비

애플리케이션용 데이터베이스 이름은 기본적으로 `pcs_db`를 사용합니다. MariaDB에 데이터베이스와 접속 계정을 준비한 후 저장소 루트에서 MariaDB Client를 실행합니다.

```powershell
mariadb -h localhost -P 3306 -u localuser -p pcs_db
```

MariaDB Client에서 현재 기준 DDL을 적용합니다.

```sql
SOURCE docs/sql/pcs-schema-ddl.sql;
```

주의사항:

- `docs/sql/pcs-schema-ddl.sql`은 현재 전체 스키마의 기준 파일입니다.
- DDL에는 기존 테이블을 제거하고 다시 만드는 구문이 있으므로 운영 데이터베이스에 바로 실행하면 안 됩니다.
- 저장소에는 운영 데이터, 계정 데이터, 토큰, 업무용 seed 또는 DB dump를 포함하지 않습니다.
- 별도로 전달받은 데이터 포함 dump가 있다면 새 로컬 DB에만 import합니다.

### 애플리케이션 실행

JDK 17이 선택된 상태에서 저장소 루트에서 실행합니다.

Windows:

```powershell
.\gradlew.bat bootRun
```

macOS 또는 Linux:

```bash
./gradlew bootRun
```

기본 접속 주소는 `http://localhost:8080`입니다.

주요 화면:

```text
http://localhost:8080/main
http://localhost:8080/company/register
http://localhost:8080/w/{companyCode}/dashboard
http://localhost:8080/w/{companyCode}/parts
http://localhost:8080/w/{companyCode}/part-units
http://localhost:8080/w/{companyCode}/inspection
http://localhost:8080/w/{companyCode}/inspection/templates
```

Swagger UI:

```text
http://localhost:8080/swagger-ui/index.html
```

### 테스트 실행

단위·API 테스트:

```powershell
.\gradlew.bat test
```

DB 통합 테스트:

```powershell
.\gradlew.bat integrationTest
```

DB 통합 테스트는 실행 환경에 따라 Testcontainers 또는 로컬 MariaDB를 사용합니다. 기본 `auto` 모드는 Docker가 사용 가능하면 MariaDB 10.11 컨테이너를 실행하고, 그렇지 않으면 로컬 MariaDB의 `test_pcs_integration` 데이터베이스를 사용합니다.

실행 방식을 명시하려면 다음 시스템 속성을 사용합니다.

```powershell
.\gradlew.bat integrationTest "-Dpcs.test.db.mode=container"
.\gradlew.bat integrationTest "-Dpcs.test.db.mode=local"
```

로컬 모드에는 다음 안전 규칙을 적용합니다.

- 로컬 호스트 이외의 DB 연결은 거부합니다.
- `pcs_db` 또는 다른 데이터베이스 이름은 거부합니다.
- fixture의 테이블 초기화는 `test_pcs_integration` 안에서만 수행합니다.
- 테스트용 MariaDB 계정은 해당 테스트 DB를 생성하고 변경할 권한이 필요합니다.

전체 테스트:

```powershell
.\gradlew.bat test integrationTest
```

## 문서 기준

- 작업별 참조 문서 선택: `docs/ai/AI_INDEX.md`
- 백엔드 공통 규칙: `docs/ai/pcs-backend-common-rules.md`
- 테스트 작성과 실행: `docs/ai/pcs-test-strategy.md`
- 기능별 계약: `docs/features/{feature}.md`
- DB 규칙: `docs/features/{feature}-db.md`
- 디자인 변경: `docs/ai/design/*.md`
