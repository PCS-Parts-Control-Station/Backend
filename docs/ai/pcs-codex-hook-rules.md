# PCS Codex Hook Rules

## 목적

Codex가 작업 종료를 시도하는 `Stop` 시점에 현재 작업 트리 변경을 자동 검증한다.
Git `pre-push` 훅을 대체하지 않으며, 개발 중 조기 피드백 계층으로 사용한다.

## 파일 책임

```text
.codex/hooks.json                 Codex lifecycle 연결
.codex/hooks/stop.ps1             변경 파일 수집과 하네스 호출
harness/config/features.json      변경 경로와 DB 검사 의존성
harness/run-feedback-loop.ps1     실패 요약 생성
harness/run-harness.ps1           실제 검사 구현
```

검사 규칙을 `.codex/hooks/stop.ps1`에 다시 작성하지 않는다.

## Stop 흐름

1. Git의 staged, unstaged, untracked 변경 파일을 수집한다.
2. 변경이 없으면 성공 종료한다.
3. `gate` 모드로 공통 검사와 관련 Feature 검사를 실행한다.
4. 빌드는 항상 증분 실행한다.
5. 도메인 Java, Mapper XML, SQL, `*-db.md` 변경이 있으면 DB 검사를 추가한다.
6. FAIL이면 `harness/reports/agent-failures.md` 내용을 반환하고 작업 완료를 허용하지 않는다.
7. 통과하면 Stop을 허용한다.

## Feature 선택

변경 경로와 DB 의존성은 `harness/config/features.json` 한 곳에서 관리한다.

- `run-harness.ps1`, `run-feedback-loop.ps1`, Stop 훅에 Feature 목록을 각각 복제하지 않는다.
- 한 파일이 여러 Feature에 영향을 주면 관련 Feature를 모두 선택한다.
- Feature의 `dbChecks`는 다른 도메인의 DB 구조까지 필요한 경우 함께 지정한다.
- 실제 검사 함수는 `run-harness.ps1`에 둔다.

## 실패 처리

- FAIL은 Stop 차단 대상이다.
- WARN은 Stop을 차단하지 않지만 최종 응답에 남은 위험으로 알린다.
- Stop 스크립트가 코드를 직접 수정하거나 별도 Codex 프로세스를 실행하면 안 된다.
- 실패 수정은 현재 대화의 Codex 에이전트가 수행하고 다시 Stop 검증을 받는다.
- 동일 실패가 반복되면 원인과 막힌 조건을 사용자에게 보고하며 검사를 우회하지 않는다.

현재 Codex는 command hook만 실행한다. `agent`, `prompt` handler를 사용하지 않는다.
Stop 실패가 현재 Codex 앱에서 에이전트 작업으로 되돌아오는지는 훅 설치 후 고의 실패 시나리오로 확인한다.

## 실행 제한

- `Mode full`을 Stop 훅에서 실행하지 않는다.
- 애플리케이션 서버를 시작, 종료, 재시작하지 않는다.
- `RunSwagger`, `CheckPort`처럼 서버 실행 상태에 의존하는 검사는 자동 Stop 훅에 넣지 않는다.
- 절대 경로, 사용자 계정 경로, 비밀값을 훅 설정에 넣지 않는다.
- 훅 제한 시간은 300초를 기본으로 한다.

## 운영체제

- 검증 로직은 `.codex/hooks/stop.ps1` 하나만 유지한다.
- macOS는 PowerShell 7 `pwsh`로 공통 스크립트를 실행한다.
- Windows Codex 환경은 `commandWindows`에서 기본 제공되는 `powershell.exe`로 같은 스크립트를 실행할 수 있다.
- OS 차이는 `hooks.json`의 얇은 실행 명령에만 두고, 검사 본문을 복제하지 않는다.
- macOS 팀원은 `brew install --cask powershell`로 `pwsh`를 설치한다.

## 설치와 신뢰

프로젝트를 Codex에서 `Backend` 디렉터리 기준으로 연다.

1. Codex에서 `/hooks`를 실행한다.
2. `.codex/hooks.json`의 Stop command hook을 검토한다.
3. 프로젝트 훅을 신뢰 처리한다.
4. 훅 정의가 변경되면 새 해시를 다시 검토한다.

`--dangerously-bypass-hook-trust`는 사용하지 않는다.

## 검증 시나리오

- 변경 없음: 하네스 생략, 성공
- CSS/HTML/JS 변경: 공통 정적 검사와 관련 Feature 검사, DB 생략
- Java 변경: 관련 Feature, 빌드, DB 검사
- Mapper/SQL 변경: 관련 Feature, 빌드, DB 검사
- 고의 컴파일 오류: Stop 실패
- 수정 후 재시도: Stop 성공
- DB 미실행: 서버를 시작하지 않고 DB 연결 실패를 그대로 보고
- Windows/macOS: 동일한 FAIL/WARN 규칙과 리포트 형식
