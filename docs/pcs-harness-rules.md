# PCS 하네스 규칙

하네스는 기능 구현 도구가 아니라 검사 도구다.  
목적은 프로젝트가 정한 구조와 금지 규칙을 계속 지키는지 확인하는 것이다.

## 결과 등급

- FAIL: 반드시 수정해야 하는 위반
- WARN: 수정 권장 또는 수동 검토 필요
- INFO: 통과 요약 또는 참고 정보

## 모드

bootstrap:

- 기능 구현 전 초기 프로젝트용
- 메인 화면과 하네스 구조를 지킨다.
- 기능 명세 없이 코드가 먼저 생기는 것을 막는다.

full:

- 기능 구조 확정 후 사용할 강한 검사
- Controller/Facade/Service/Mapper, MyBatis, 인증, 이력 정합성까지 검사한다.

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
- Spring Boot 4.0.3
- `spring.application.name = pcs-api`
- PageController는 forward만 담당
- JPA 흔적 금지
- JS 문법 검사
- `.gitignore` 필수 규칙 확인
- `domain/{feature}`가 있으면 `docs/features/{feature}.md`가 있어야 함

## 기능 명세 먼저 규칙

기능 코드를 만들기 전 문서를 먼저 만든다.

```text
docs/features/part.md
src/main/java/com/pcs/domain/part
```

문서 없이 `domain` 코드가 생기면 하네스가 실패한다.

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

- Controller는 Facade만 호출
- Controller에서 Service/Mapper 직접 호출 금지
- Facade는 유스케이스 흐름 조립
- Service는 DB 조회/변경과 비즈니스 검증
- Mapper는 SQL 실행만 담당

DTO/Validation:

- DTO는 record
- Request DTO에는 validation
- `@RequestBody`에는 `@Valid`
- Entity와 DTO 상호 참조 금지
- enum은 `entity`가 아니라 도메인별 `type` 패키지에 둔다.

API/예외:

- `/api/**` 응답은 `ApiResultDto`
- `ErrorCode`, `BusinessException`, `GlobalExceptionHandler`
- 인증 실패 API 응답은 JSON

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

```powershell
.\harness\run-harness.ps1 -Mode bootstrap
.\harness\run-harness.ps1 -Mode bootstrap -RunBuild
```

리포트:

```text
harness/reports/latest.md
```
