# PCS Test Strategy

This document defines how backend tests are written and how they are connected to the PCS harness.

## Test Types

| Type | Tool | Location | Purpose |
|---|---|---|---|
| Unit test | JUnit + AssertJ + Mockito | `src/test/java` | Pure Java business rules without DB IO |
| API test | MockMvc | `src/test/java` | REST request/response, validation, exception mapping |
| DB integration test | Testcontainers MariaDB or isolated local MariaDB | `src/integrationTest/java` | MyBatis SQL, table columns, constraints, transaction behavior |

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

The following features are connected to real Gradle test execution through `harness/config/features.json`.

- `company`
- `member`
- `auth`
- `partner`
- `category`
- `part`
- `part-unit`
- `stock`
- `inspection`
- `history`
- `dashboard`

`commonTests.unitApi` and `commonTests.dbIntegration` run for every requested test gate. Each feature adds its own `tests.unitApi` and `tests.dbIntegration` selectors. `run-harness.ps1` merges and de-duplicates those selectors before invoking Gradle, so shared contract and company-isolation tests are not lost or run repeatedly.

Changing `harness/run-harness.ps1` or `harness/config/features.json` selects every registered feature. This validates all selectors whenever the runner or its routing registry changes.

Representative connected commands:

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
4. Add MariaDB integration tests under `src/integrationTest/java` when MyBatis SQL or constraints matter.
5. Add changed-file `pathPatterns` and Gradle selectors under `tests.unitApi` and `tests.dbIntegration` in `harness/config/features.json`.
6. Add only structural/static checks to the matching `Test-{Feature}Feature` function. Do not hardcode Gradle test commands there; the generic configured test runner executes the registry selectors.

## Current DB Test Fixtures

- `src/integrationTest/resources/pcs-account-test-schema.sql`
  - company, member, auth, partner
- `src/integrationTest/resources/pcs-category-part-test-schema.sql`
  - category, part
- `src/integrationTest/resources/pcs-operations-test-schema-extension.sql`
  - stock, inspection, dashboard에 필요한 거래처, 검수 템플릿, 검수 결과, 상태 이력

Keep fixture schemas small and feature-focused. Do not copy the whole production DDL unless the test needs it.

## MariaDB Test Runtime

- The default `auto` mode uses Testcontainers when Docker is available and falls back to local MariaDB otherwise.
- `-Dpcs.test.db.mode=container` forces the Testcontainers runtime.
- `-Dpcs.test.db.mode=local` forces the isolated local MariaDB runtime.
- Testcontainers dependencies belong to `integrationTestImplementation`, not the unit test classpath.

## Local MariaDB Safety

- DB integration tests use only the local `test_pcs_integration` database.
- The test base creates `test_pcs_integration` when it does not exist.
- Fixture SQL may drop and recreate tables only inside this dedicated database.
- A JDBC URL targeting `pcs_db`, another database name, or a remote host must fail before the Spring context and fixture SQL run.
- The default account follows the local application account, while `pcs.test.db.*` system properties can override test connection values.

## Cross-Company Isolation Tests

- DB integration fixtures for workspace APIs must contain at least two active companies.
- The authenticated principal company and URL `companyCode` mismatch must fail before a domain query or mutation runs.
- ID-based detail and mutation tests must request company B resources with company A scope and verify a not-found or workspace error.
- The same test must verify that company B rows remain unchanged after the rejected mutation.
- List tests must seed matching rows in both companies and verify that only the authenticated company rows are returned.
- Company isolation checks apply to partner, category, part, part unit, stock document and movement, inspection and history, and member data.

## Transactional State Transition Tests

- Stock and inspection integration tests must call the transactional Facade, not only the Mapper or a mocked Service.
- Inbound, inspection, outbound, and cancellation tests must verify document, movement, stock quantity, part-unit status, inspection status, grade, sales status, and status history together.
- Correction and reinspection must append inspection rows and preserve the original inspection chain without updating old rows.
- A forced failure after an earlier write must leave no partial document, movement, stock, unit, inspection, item-result, or status-history change.
- `tb_part_stock.quantity` must match the count of active `IN_STOCK` part units after every completed stock transition.
