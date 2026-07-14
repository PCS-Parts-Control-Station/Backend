# PCS 하네스 규칙

하네스는 기능 구현이 아니라 구조·금지 규칙·테스트를 실행하는 검증 도구다.

## 결과

- FAIL: 반드시 수정. 완료와 push를 차단한다.
- WARN: 수동 검토. 현재 변경과 관련된 항목만 우선 확인한다.
- INFO: 통과 또는 실행 요약.

## 모드

| 모드 | 용도 |
|---|---|
| bootstrap | 초기 프로젝트 구조와 feature 문서 선행 확인 |
| gate | 변경 파일 기준 공통·관련 feature 검사. pre-push와 Codex Stop 기본값 |
| full | 프로젝트 완료 후 전체 회귀 |

`Feature`와 `DbFeature`는 모드에 추가하는 선택 범위다. 지원 값, 경로, DB 의존성, 테스트 selector는 `harness/config/features.json`만 원본으로 한다.

## 파일 책임

| 파일 | 책임 |
|---|---|
| `harness/config/features.json` | feature 이름, 변경 경로, DB 의존성, 테스트 selector |
| `harness/run-harness.ps1` | 실제 정적·빌드·DB·테스트 검사 |
| `harness/run-feedback-loop.ps1` | 옵션 전달과 실패 요약 |
| `harness/hooks/pre-push` | 변경·추적 파일 수집과 gate 호출 |
| `.codex/hooks/stop.ps1` | Codex 변경 파일 수집과 gate 호출 |

검사 규칙이나 feature 목록을 wrapper와 hook에 복제하지 않는다.

## Gate

pre-push와 Codex Stop은 `full`이 아니라 `gate`를 사용한다.

```powershell
./harness/run-harness.ps1 -Mode gate -RunBuild -ChangedFilesPath <path> -TrackedFilesPath <path>
```

- 공통 정적 검사와 관련 feature만 실행한다.
- Java·Mapper·DB fixture·DDL·DB 문서 변경은 필요한 DB 검사를 추가한다.
- 하네스 runner 또는 registry 변경은 등록된 selector 전체를 검증한다.
- 아직 구현하지 않은 도메인 때문에 gate가 실패하면 안 된다.
- 전체 도메인 구조 검사는 full의 책임이다.

## Codex 작업 중 최소 실행

- 문서·주석·문구만 변경: 링크·형식 검사, 필요하면 `git diff --check`
- JS 변경: 문법, 화면별 공통 유틸·거래처 picker 재구현 여부, 관련 feature
- Java 변경: `compileJava`, 관련 feature·단위/API 테스트
- Mapper·DDL·DB 변경: 관련 DB 통합 테스트
- 하네스·hook 변경: PowerShell 문법, cross-platform 규칙, registry 검증

`agent-failures.md`는 최신 FAIL만 확인한다. 동일 FAIL 자동 수정·재검증은 최대 2회이며, 이번 변경과 무관한 기존 FAIL/WARN을 자동 수정하지 않는다.

## Feature 검사 추가

1. `features.json`에 이름, `pathPatterns`, `dbChecks`, `tests.unitApi`, `tests.dbIntegration`을 추가한다.
2. `run-harness.ps1`에 구조·정적 검사 함수를 만든다.
3. 공통 `Invoke-FeatureChecks`에 연결한다.
4. DB 계약이 있으면 `{feature}-db.md`와 DB checker를 연결한다.
5. Gradle 명령을 Feature 함수에 직접 쓰지 않는다.
6. registry 검사와 해당 feature gate를 실행한다.

문서만 추가하면 실제 검사가 생기지 않는다. 실제 검사 구현은 runner, 테스트 실행 대상은 registry가 소유한다.

## Feature·DB 문서 계약

기능 코드 전:

```text
docs/features/{feature}.md
src/main/java/com/pcs/domain/{feature}
```

DB를 사용하면 필요한 `{feature}-db.md`가 있어야 한다.

feature 문서:

- 목적과 API
- 도메인 고유 규칙과 예외
- 화면 전용 계약
- 고유 테스트 수용 조건

feature-db 문서:

- 사용하는 테이블의 역할
- 트랜잭션과 정합성
- 고유 조회·인덱스 조건
- 실패·롤백과 DB 테스트 수용 조건

물리 컬럼·제약의 원본은 `docs/sql/pcs-schema-ddl.sql`, 테스트 정책은 `pcs-test-strategy.md`다. 공통 내용을 feature 문서에 복사하지 않는다.

DB 사전 검사는 `docs/features/checkdb.md`가 연결·기본 스키마 확인 절차만 정의한다.

## 구조 검사 원본

- 계층·JPA 금지·DTO·MyBatis: `pcs-project-structure-reference.md`
- 응답·예외: `pcs-backend-common-rules.md`
- 인증: `docs/features/auth.md`, `pcs-auth-client-rules.md`
- 권한: `pcs-permission-rules.md`
- 테스트: `pcs-test-strategy.md`
- PowerShell: `pcs-powershell-harness-rules.md`

하네스 문서에서 위 규칙을 다시 열거하지 않는다. runner는 원본의 핵심 금지 패턴을 검사 코드로 구현할 수 있다.

## `.gitignore`와 추적 금지

필수 제외:

```text
.gradle/
build/
out/
*.iml
.idea/
.env
.env.*
application-local.yml
application-local.yaml
application-local.properties
application-secret.yml
application-secret.yaml
application-secret.properties
gradle.properties
*.log
*.tmp
tmp/
harness/reports/*
src/main/resources/static/*-preview.html
.DS_Store
Thumbs.db
```

예외:

```text
!.env.example
!harness/reports/.gitkeep
```

- `.gitignore`에 추가해도 이미 추적된 파일은 `git ls-files`로 실패시킨다.
- 삭제 커밋은 막지 않도록 금지 파일이 현재 존재할 때만 변경 파일 검사를 실패시킨다.
- 추적만 제거할 때는 `git rm --cached <file>`을 사용한다.

## DB 검사

- DB 연결 실패와 필수 구조 누락은 FAIL이다.
- 기본 사전 검사는 `checkdb.md`, 기능 정합성은 feature-db와 통합 테스트가 담당한다.
- DB 검사는 로컬 안전 기준과 fixture 정책을 `pcs-test-strategy.md`에서 따른다.
- 애플리케이션 서버를 시작해 DB 검사를 우회하지 않는다.

## 실행

권장 wrapper:

```powershell
./harness/run-feedback-loop.ps1 -Mode gate
./harness/run-feedback-loop.ps1 -Mode gate -Feature {feature} -RunBuild -RunDb
./harness/run-feedback-loop.ps1 -Mode gate -DbFeature {feature}
```

같은 실행에서 기능 DB와 의존 DB를 확인하면 `-RunDb -DbFeature {feature}`를 함께 사용한다.

## 리포트

```text
harness/reports/latest.md
harness/reports/agent-failures.md
```

- `latest.md`: 실행 설정, FAIL/WARN, 검사 그룹 요약
- `agent-failures.md`: 에이전트가 바로 수정할 최신 FAIL 중심 요약
- 상세 INFO는 기본 MD에 전부 복제하지 않고 verbose 로그에서 확인한다.
- 두 리포트는 같은 실행에서 함께 생성해 `GeneratedAt`이 일치해야 한다.

## Codex Stop

상세 lifecycle 기준은 `pcs-codex-hook-rules.md`를 따른다.

- 변경이 없으면 성공 종료한다.
- 변경 파일 기준 `gate`를 호출한다.
- DB 관련 변경일 때만 DB 검사를 추가한다.
- 서버를 시작·종료·재시작하지 않는다.
- FAIL이면 완료를 차단하고 최신 `agent-failures.md`를 반환한다.
- 검사 우회, 별도 Codex 실행, 코드 자동 수정은 하지 않는다.

## 완료 판단

- 현재 변경과 관련된 FAIL이 없다.
- 관련 WARN을 검토했다.
- 필요한 최소 build·test·DB 검사가 통과했다.
- 리포트 생성 시각과 실행 옵션이 현재 실행과 일치한다.
