# PCS Test Strategy

백엔드 테스트의 종류, 책임, 안전 기준 원본이다.

## 테스트 종류

| 유형 | 도구 | 위치 | 검증 |
|---|---|---|---|
| 단위 | JUnit, AssertJ, Mockito | `src/test/java` | DB 없는 정책·계산 |
| API | MockMvc | `src/test/java` | 요청·응답·validation·예외·권한 |
| DB 통합 | MariaDB | `src/integrationTest/java` | MyBatis SQL·제약·트랜잭션 |

## 문서와 테스트 책임

- 기능 동작은 `docs/features/{feature}.md`가 원본이다.
- DB 동작은 `{feature}-db.md`가 원본이다.
- feature 문서는 고유한 테스트 수용 조건만 적는다.
- 공통 테스트 종류·실행법·안전 규칙을 feature 문서에 복사하지 않는다.
- 하네스는 테스트를 재구현하지 않고 Gradle selector를 실행한다.

## Feature 연결

지원 feature, 변경 경로, 공통·기능별 selector의 원본은 `harness/config/features.json`이다.

- `run-harness.ps1`은 선택자를 합치고 중복 제거한 뒤 Gradle을 실행한다.
- runner 또는 registry가 바뀌면 등록된 selector 전체를 검증한다.
- 기능별 Gradle 명령을 문서나 Feature 함수에 하드코딩하지 않는다.

대표 실행:

```powershell
./gradlew.bat test
./gradlew.bat integrationTest
```

Harness 실행 명령과 옵션은 `pcs-harness-rules.md`를 따른다.

## 새 기능 테스트

1. feature와 필요한 feature-db의 수용 조건을 작성한다.
2. 순수 정책은 단위 테스트로 작성한다.
3. REST API는 MockMvc로 작성한다.
4. MyBatis·제약·트랜잭션은 DB 통합 테스트로 작성한다.
5. `features.json`에 경로와 selector를 연결한다.
6. 하네스 Feature 함수에는 구조·정적 검사만 둔다.

## Fixture

- fixture는 기능에 필요한 최소 스키마만 가진다.
- 생산 DDL 전체를 복사하지 않는다.
- 현재 fixture 위치와 사용 feature는 `src/integrationTest/resources`와 `features.json`을 원본으로 한다.

## MariaDB 실행

- 기본 `auto`: Docker가 있으면 Testcontainers, 없으면 로컬 격리 DB
- `container`: Testcontainers 강제
- `local`: 로컬 격리 MariaDB 강제
- Testcontainers 의존성은 `integrationTestImplementation`에 둔다.

## 로컬 DB 안전

- 테스트 DB는 로컬 `test_pcs_integration`만 허용한다.
- `pcs_db`, 다른 DB명, 원격 호스트는 Spring context와 fixture 실행 전에 실패해야 한다.
- fixture의 DROP/CREATE는 테스트 DB 안에서만 허용한다.
- 연결값은 `pcs.test.db.*` 시스템 속성으로만 재정의한다.

## 업체 격리

workspace API 통합 테스트는 활성 회사 2개 이상을 사용한다.

- URL companyCode와 principal 회사 불일치를 도메인 쿼리 전에 차단한다.
- 회사 A가 회사 B의 ID를 조회·변경할 수 없어야 한다.
- 거절된 변경 후 회사 B row가 그대로인지 확인한다.
- 목록에는 인증 회사 row만 반환한다.

## 상태 전이와 롤백

- stock·inspection 통합 테스트는 Mapper만이 아니라 트랜잭션 Facade를 호출한다.
- 전표, movement, 재고, unit 상태, 검수, 항목 결과, 상태 이력을 함께 검증한다.
- 정정·재검수는 원본을 수정하지 않고 이력을 추가한다.
- 중간 강제 실패에서 모든 앞선 변경이 롤백되어야 한다.
- 완료 시 `tb_part_stock.quantity`와 활성 `IN_STOCK` unit 수가 일치해야 한다.
