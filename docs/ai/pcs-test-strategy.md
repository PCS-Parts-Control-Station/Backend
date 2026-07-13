# PCS Test Strategy

This document defines how backend tests are written and how they are connected to the PCS harness.

## Test Types

| Type | Tool | Location | Purpose |
|---|---|---|---|
| Unit test | JUnit + AssertJ + Mockito | `src/test/java` | Pure Java business rules without DB IO |
| API test | MockMvc | `src/test/java` | REST request/response, validation, exception mapping |
| DB integration test | Testcontainers + MariaDB | `src/integrationTest/java` | MyBatis SQL, table columns, constraints, transaction behavior |

## Writing Rules

- Feature rules live in `docs/features/{feature}.md`.
- DB rules live in `docs/features/{feature}-db.md`.
- Unit/API tests must verify the required behavior described in the feature document.
- DB integration tests must verify the required persistence behavior described in the DB document.
- `run-harness.ps1` should not reimplement test logic; it should check required files and execute the matching Gradle test tasks.
- If a feature uses DB tables, add both unit/API tests and DB integration tests unless there is a clear reason not to.

## Feature Document Test Sections

Each `docs/features/{feature}.md` should include:

```text
## Test Coverage

- Unit/service tests: ...
- API tests: ...
- Required checks:
  - ...
```

Each `docs/features/{feature}-db.md` should include:

```text
## DB Integration Test Coverage

- Integration test: ...
- Schema fixture: ...
- Required checks:
  - ...
```

## Harness-Connected Features

The following features are currently connected to real Gradle test execution from `run-harness.ps1`.

- `company`
- `member`
- `auth`
- `partner`
- `category`
- `part`
- `part-unit`
- `stock`
- `inspection`
- `dashboard`

Current connected commands:

```powershell
.\gradlew.bat test --tests "com.pcs.domain.company.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.company.*"

.\gradlew.bat test --tests "com.pcs.domain.member.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.member.*"

.\gradlew.bat test --tests "com.pcs.domain.auth.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.auth.*"

.\gradlew.bat test --tests "com.pcs.domain.partner.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.partner.*"

.\gradlew.bat test --tests "com.pcs.domain.category.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.category.*"

.\gradlew.bat test --tests "com.pcs.domain.part.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.part.*"

.\gradlew.bat test --tests "com.pcs.domain.stock.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.stock.*"

.\gradlew.bat test --tests "com.pcs.domain.inspection.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.inspection.*"

.\gradlew.bat test --tests "com.pcs.domain.dashboard.*"
.\gradlew.bat integrationTest --tests "com.pcs.domain.dashboard.*"
```

`part-unit`은 별도 Java 최상위 패키지를 만들지 않고 `com.pcs.domain.part`를 공유하므로, 하네스는 같은 Gradle test filter로 실행하되 `Test-PartUnitFeature`에서 문서, SQL, 화면, 하네스 규칙을 별도로 검사한다.

## Adding A New Feature Test

1. Update `docs/features/{feature}.md` and, if DB is used, `docs/features/{feature}-db.md`.
2. Add unit/service tests under `src/test/java`.
3. Add MockMvc API tests under `src/test/java` when the feature exposes REST APIs.
4. Add Testcontainers DB integration tests under `src/integrationTest/java` when MyBatis SQL or constraints matter.
5. Add the test paths to `harness/config/features.json`.
6. Add required test file checks and Gradle test execution to the matching `Test-{Feature}Feature` function in `harness/run-harness.ps1`.

## Current DB Test Fixtures

- `src/integrationTest/resources/pcs-account-test-schema.sql`
  - company, member, auth, partner
- `src/integrationTest/resources/pcs-category-part-test-schema.sql`
  - category, part
- `src/integrationTest/resources/pcs-operations-test-schema-extension.sql`
  - stock, inspection, dashboard에 필요한 거래처, 검수 템플릿, 검수 결과, 상태 이력

Keep fixture schemas small and feature-focused. Do not copy the whole production DDL unless the test needs it.
