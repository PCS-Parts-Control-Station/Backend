# PCS 하네스 규칙

하네스는 기능 구현 도구가 아니라 검사 도구다.  
목적은 프로젝트가 정한 구조와 금지 규칙을 계속 지키는지 확인하는 것이다.

## 결과 등급

- FAIL: 반드시 수정해야 하는 위반
- WARN: 수정 권장 또는 수동 검토 필요
- INFO: 통과 요약 또는 참고 정보

## 모드

bootstrap:

- 기본 프로젝트 구조와 선택한 feature 기준을 함께 검사하는 기본 모드
- 기능 명세 없이 코드가 먼저 생기는 것을 막는다.
- `-Feature`, `-RunBuild`, `-RunDb`, `-DbFeature` 옵션과 함께 기능 구현 후 검증에도 사용한다.

full:

- 기능 구조 확정 후 사용할 강한 검사
- Controller/Facade/Service/Mapper, MyBatis, 인증, 이력 정합성까지 검사한다.

Feature:

- `Mode`와 별도로 특정 기능 문서 기준의 추가 검사를 실행한다.
- 기능 구현 방식은 바꾸지 않고, `docs/features/{feature}.md`에 맞는 구조와 핵심 규칙을 더 확인한다.

## 지원 중인 Feature 값

현재 `run-harness.ps1`과 `run-feedback-loop.ps1`의 `-Feature`, `-DbFeature`에서 바로 선택할 수 있는 값:

```text
none
company
member
auth
partner
category
```

새 도메인 문서를 만들었다고 해서 하네스가 자동으로 그 기능의 세부 규칙을 검사하는 것은 아니다.  
`-Feature`로 검사하려면 `run-harness.ps1`에 해당 기능 검사 함수가 실제로 연결되어 있어야 한다.

예:

```powershell
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature company -RunBuild -RunDb -DbFeature member
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature auth -RunBuild -RunDb -DbFeature member
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature partner -RunBuild -RunDb
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature category -RunBuild -RunDb
.\harness\run-feedback-loop.ps1 -Mode bootstrap -DbFeature member
```

## Feature 검사 추가 방법

새 기능을 하네스에서 직접 검사하려면 `harness/run-harness.ps1`에 기능명을 추가하고 검사 함수를 만든다.

예: `inspection` 기능 검사를 추가하는 경우

1. 파라미터 허용값에 기능명을 추가한다.

```powershell
[ValidateSet("none", "company", "member", "auth", "partner", "category", "inspection")]
[string] $Feature = "none",

[ValidateSet("none", "company", "member", "auth", "partner", "category", "inspection")]
[string] $DbFeature = "none",
```

2. 기능 검사 함수를 만든다.

```powershell
function Test-InspectionFeature {
    Test-PathRequired "docs/features/inspection.md" "INSPECTION_DOC" "Create docs/features/inspection.md first."
    Test-PathRequired "src/main/java/com/pcs/domain/inspection/api/InspectionApiController.java" "INSPECTION_CONTROLLER" "Create InspectionApiController."
    Test-PathRequired "src/main/java/com/pcs/domain/inspection/facade/InspectionFacade.java" "INSPECTION_FACADE" "Create InspectionFacade."
    Test-PathRequired "src/main/java/com/pcs/domain/inspection/service/InspectionService.java" "INSPECTION_SERVICE" "Create InspectionService."
    Test-PathRequired "src/main/java/com/pcs/domain/inspection/mapper/InspectionMapper.java" "INSPECTION_MAPPER" "Create InspectionMapper."
    Test-PathRequired "src/main/resources/mapper/inspection/InspectionMapper.xml" "INSPECTION_MAPPER_XML" "Create InspectionMapper.xml."
}
```

3. 실행부에 연결한다.

```powershell
if ($Feature -eq "inspection") {
    Test-InspectionFeature
}
```

4. DB 검사가 필요하면 `docs/features/{feature}-db.md`를 만들고, DB Java 검사 쪽에도 같은 기능명 체크를 추가한다.

5. `harness/run-feedback-loop.ps1`의 `Feature`, `DbFeature` 허용값에도 같은 기능명을 추가한다.

```powershell
[ValidateSet("none", "company", "member", "auth", "partner", "category", "inspection")]
[string] $Feature = "none",

[ValidateSet("none", "company", "member", "auth", "partner", "category", "inspection")]
[string] $DbFeature = "none",
```

하네스 문서만 추가하면 검사가 생기는 것이 아니다.  
문서는 기준이고, `run-harness.ps1`의 함수가 실제 검사 코드다.
`run-feedback-loop.ps1`은 `run-harness.ps1`을 감싸서 실행 결과를 에이전트용으로 요약하는 보조 실행기다.

## bootstrap 규칙

필수 파일:

```text
build.gradle
settings.gradle
gradlew
gradlew.bat
gradle/wrapper/*
src/main/java/com/pcs/PcsApiApplication.java
src/main/java/com/pcs/web/controller/PageController.java
src/main/resources/application.yaml
src/main/resources/static/main.html
src/main/resources/static/css/main.css
src/main/resources/static/js/main.js
```

검사:

- Java 17 이상
- `JAVA_HOME`도 Java 17 이상
- Spring Boot 4.0.3
- `spring.application.name = pcs-api`
- PageController는 forward만 담당
- JPA 흔적 금지
- JS 문법 검사
- `.gitignore` 필수 규칙 확인
- `domain/{feature}`가 있으면 `docs/features/{feature}.md`가 있어야 함
- 인증 기능은 `docs/features/auth.md`와 `docs/ai/pcs-auth-client-rules.md` 기준을 유지함

## Feature / DB 문서 작성 규칙

기능 코드를 만들기 전에는 기능 문서를 먼저 만든다.

```text
docs/features/{feature}.md
src/main/java/com/pcs/domain/{feature}
```

문서 없이 `domain` 코드가 생기면 하네스가 실패한다.

DB를 사용하는 기능이면 기능 DB 문서도 함께 만든다.

```text
docs/features/{feature}-db.md
```

새로운 `.md` 문서를 추가하면 `docs/ai/AI_INDEX.md`에도 연결 기준을 추가한다.  
새 문서가 인덱스에 연결되지 않으면 팀원이나 에이전트가 다음 작업에서 해당 문서를 참고하지 못할 수 있다.

`{feature}.md`에는 기능 자체를 적는다.

- 목적
- API
- 요청/응답
- 권한
- 비즈니스 규칙
- 처리 흐름
- 예외와 응답 코드
- 화면 또는 정적 JS 연동 기준

`{feature}-db.md`에는 DB 검증 기준만 적는다.

- 사용하는 테이블
- 입력/수정/조회 대상 컬럼
- UNIQUE, INDEX, CHECK 등 제약 조건
- 정상 저장 시나리오
- 중복/실패/롤백 시나리오
- 다른 도메인 테이블을 함께 변경하는 경우의 정합성 기준

예:

```text
docs/features/company.md
docs/features/company-db.md
```

회사 등록 기능이 `tb_company`와 `tb_member`를 함께 사용하면 `company-db.md`에는 회사 등록 트랜잭션 기준을 적고, `member-db.md`에는 회원 테이블 자체의 공통 DB 규칙을 적는다.  
이때 사용자 관리 기능 전체를 검사하려는 것이 아니면 `member.md`가 아니라 `member-db.md` 기준만 검사한다.

공통 DB 사전 검사는 별도 문서로 둔다.

```text
docs/features/checkdb.md
```

`checkdb.md`는 기능 시나리오가 아니라 DB 기본 상태를 확인하는 문서다.

- DB 연결 가능 여부
- 현재 접속 DB
- 필수 테이블 존재 여부
- 공통 필수 컬럼 존재 여부
- 공통 제약 조건 존재 여부

기능 구현 후 검증 흐름:

```powershell
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature {feature} -RunBuild -RunDb
```

다른 도메인의 DB 구조만 함께 확인해야 하면 기능 문서가 아니라 DB 문서 기준으로만 검사한다.

```powershell
.\harness\run-feedback-loop.ps1 -Mode bootstrap -DbFeature member
```

기능 DB와 다른 도메인 DB 구조를 한 번에 확인해야 하면 `-RunDb`와 `-DbFeature`를 함께 쓴다.

예: auth 기능 구현 중 member DB 구조도 함께 확인

```powershell
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature auth -RunBuild -RunDb -DbFeature member
```

## 항상 금지

```text
spring-boot-starter-data-jpa
jakarta.persistence
javax.persistence
@Entity
@Table
@Id
@Column
@GeneratedValue
JpaRepository
EntityManager
JPQL
Hibernate Dirty Checking 전제
```

## .gitignore 규칙

반드시 제외:

```text
.gradle/
build/
out/
*.iml
.idea/
.env
.env.*
gradle.properties
*.log
*.tmp
tmp/
harness/reports/*
```

예외:

```text
!.env.example
!harness/reports/.gitkeep
```

## full 모드에서 강화할 규칙

구조:

- `domain/auth`, `domain/company`, `domain/member`, `domain/partner`, `domain/category`
- `domain/part`, `domain/stock`, `domain/inspection`, `domain/history`, `domain/dashboard`
- 각 도메인은 `api`, `dto/request`, `dto/response`, `entity`, `facade`, `mapper`, `service`, `type`, `validation` 기준 구조를 따른다.
- `global/config`, `global/dto`, `global/error`, `global/jwt`
- `resources/mapper`

계층:

- 계층 역할은 `docs/ai/pcs-project-structure-reference.md` 기준을 따른다.

DTO/Validation:

- DTO는 record
- Request DTO에는 validation
- `@RequestBody`에는 `@Valid`
- Entity와 DTO 상호 참조 금지
- enum은 `entity`가 아니라 도메인별 `type` 패키지에 둔다.

API/예외:

- 공통 응답, ErrorCode, BusinessException, GlobalExceptionHandler 기준은 `docs/ai/pcs-backend-common-rules.md`를 따른다.
- 인증 실패 API 응답은 JSON이어야 한다.

MyBatis:

- Mapper 인터페이스와 XML 1:1 대응
- XML namespace와 Mapper FQCN 일치
- `mybatis.mapper-locations`
- `map-underscore-to-camel-case=true`

프론트:

- PageController는 forward만
- HTML에 서버 데이터 직접 주입 금지
- JS는 `/api/**` 호출
- 공통 JS 중복 구현 금지

재고/이력:

- 입고/출고 시 StockMovement 저장
- beforeQuantity/afterQuantity 저장
- processedBy 저장
- 검수 결과 등록 시 Inspection 저장
- 상태 변경 시 PartStatusHistory 저장
- 재고 변경과 이력 저장은 같은 트랜잭션
- 출고 시 재고 부족, 검수 완료, 불량, 판매 가능 상태 검증
- 재고 차감에는 동시성 전략 필요

SQL 품질:

- 집계는 SQL에서 처리
- 기간별 집계에는 날짜 조건 필요
- TOP 조회에는 `ORDER BY` + `LIMIT`
- 목록 조회에는 페이징 권장

## 범위 이탈 금지

- 사진 업로드
- 결제/배송
- 채팅
- 중고 시세 크롤링
- 다중 창고
- 바코드 스캔
- 엑셀 업로드
- 수리 이력
- 캘린더 중심 기능
- 서비스 기능으로서의 AI

## 실행

권장 실행은 `run-feedback-loop.ps1`이다.  
이 스크립트는 내부에서 `run-harness.ps1`을 실행하고, 실패/경고 요약 파일을 추가로 만든다.

```powershell
.\harness\run-feedback-loop.ps1 -Mode bootstrap
.\harness\run-feedback-loop.ps1 -Mode bootstrap -RunBuild
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature company -RunBuild -RunDb -DbFeature member
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature auth -RunBuild -RunDb -DbFeature member
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature partner -RunBuild -RunDb
.\harness\run-feedback-loop.ps1 -Mode bootstrap -Feature category -RunBuild -RunDb
.\harness\run-feedback-loop.ps1 -Mode bootstrap -DbFeature member
```

리포트:

```text
harness/reports/latest.md
harness/reports/agent-failures.md
```

역할:

- `run-harness.ps1`을 실행한다.
- `latest.md`에서 FAIL/WARN 섹션을 읽는다.
- 에이전트가 다음 수정 작업에서 보기 쉬운 `agent-failures.md`를 만든다.
- `Feature`, `RunDb`, `DbFeature` 옵션을 `run-harness.ps1`에 전달한다.

주의:

- 이 스크립트가 코드를 자동 수정하지는 않는다.
- 같은 실행에서 여러 DB 기준을 함께 보고 싶으면 `-RunDb -DbFeature {feature}`를 함께 사용한다.
- `run-feedback-loop.ps1` 결과 파일은 매 실행마다 덮어쓴다.
