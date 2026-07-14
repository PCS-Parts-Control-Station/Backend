# PCS PowerShell Harness Rules

Windows와 macOS/Linux에서 같은 검증 의미를 유지하기 위한 `*.ps1` 구현 정본입니다. Harness 실행 방식과 판정은 [Harness Rules](pcs-harness-rules.md)를 따릅니다.

## 적용 범위

- `harness/*.ps1`, `harness/hooks/*`
- `.codex/hooks/*.ps1`, `.codex/hooks.json`
- `harness/config/features.json`을 읽는 PowerShell 코드
- 이후 추가되는 검증·hook 스크립트

## 핵심 원칙

검증 로직은 한 번만 작성하고 OS 차이는 어댑터 함수 안에서만 처리합니다. 실제 규칙 함수(`Test-*`, `Invoke-*-Check`)에서 OS를 직접 분기하지 않습니다.

기준 어댑터:

| 책임 | 함수 |
|---|---|
| OS 판별 | `Test-IsWindowsHost`, `Test-IsMacHost` |
| Gradle | `Get-GradleCommand`, `Invoke-Gradle` |
| Java | `Ensure-JavaHome17`, `Get-JavaExecutable`, `Invoke-ExternalCommand` |
| 경로 | `Normalize-ProjectPath` |
| 포트 | `Get-PortListeners`, `Test-PortAvailable` |
| 프로세스 | `Start-HarnessProcess` |

새 OS 차이가 필요하면 기존 어댑터를 확장하거나 새 어댑터를 먼저 만듭니다.

## 직접 사용 금지

다음 값은 해당 OS 어댑터 내부나 명시된 설정 파일 외부에서 직접 사용하지 않습니다.

```text
gradlew.bat
cmd /c
powershell.exe
-ExecutionPolicy
java.exe
bin\java.exe
Get-NetTCPConnection
Start-Process -WindowStyle Hidden
C:\Program Files
```

예외:

- bootstrap 존재 여부 검사
- Windows 전용 어댑터 내부
- `.codex/hooks.json`의 `commandWindows`
- Windows 프로세스를 띄우는 코드의 `-ExecutionPolicy Bypass`
- Windows 전용임을 명시한 일회성 로컬 스크립트

## 실행 규칙

### Gradle과 Java

- Gradle은 `Get-GradleCommand`와 `Invoke-Gradle`을 통해 실행합니다.
- Java/Javac은 `JAVA_HOME/bin`에서 찾고 JDK 17 이상을 먼저 확인합니다.
- `cmd /c java -version`이나 PATH의 `java`, `javac`를 검증 본문에서 직접 호출하지 않습니다.
- 외부 명령의 종료 코드를 받아 `FAIL/WARN/INFO` 결과로 변환합니다.

### 경로

- 조립은 `Join-Path`, `Resolve-Path`, `[System.IO.Path]`를 사용합니다.
- 패턴 비교 전 `Normalize-ProjectPath`로 구분자를 `/`로 통일합니다.
- 절대 경로를 하드코딩하지 않습니다.

### 포트와 프로세스

- 포트 확인은 Windows의 `Get-NetTCPConnection`, macOS/Linux의 `lsof` 또는 `netstat` 차이를 `Get-PortListeners` 안에 숨깁니다.
- 백그라운드 프로세스가 꼭 필요하면 `Start-HarnessProcess`를 사용합니다.
- 기본 hook 검증은 서버를 시작하거나 종료하지 않습니다. 서버가 필요한 smoke check는 명시적 옵션일 때만 수행합니다.

## Hook 계약

pre-push와 Codex Stop hook은 변경 파일 목록을 만들고 `run-feedback-loop.ps1 -Mode gate`에 넘기는 얇은 래퍼여야 합니다.

- `harness/hooks/pre-push`: macOS/Linux의 `pwsh`, Windows의 `powershell.exe`를 선택할 수 있어야 합니다.
- `.codex/hooks.json`: 공통 `command`와 Windows용 `commandWindows`를 분리합니다.
- `.codex/hooks/stop.ps1`: 검증 범위 결정 외에 기능 규칙을 복제하지 않습니다.
- hook에서 애플리케이션 서버 생명주기를 제어하지 않습니다.

다음 파일이 변경되면 PowerShell 공통 규칙 검사를 포함합니다.

```text
harness/run-harness.ps1
harness/run-feedback-loop.ps1
harness/install-hooks.ps1
harness/hooks/*
harness/config/features.json
.codex/hooks.json
.codex/hooks/*.ps1
```

## 결과 계약

- 결과 파일: `harness/reports/latest.md`, `harness/reports/agent-failures.md`
- 규칙명과 심각도는 OS와 무관하게 동일해야 합니다.
- OS별 해결법이 다르면 `Fix`에만 차이를 적습니다.
- `latest.md`에는 FAIL/WARN 전체와 INFO 그룹 요약만 기록합니다.
- 두 보고서의 `GeneratedAt`은 같은 실행 시각을 사용합니다.

## 변경 검증

1. PowerShell parser로 변경한 모든 `*.ps1`의 문법을 검사합니다.
2. Windows 경로와 `/` 경로 입력을 모두 고려합니다.
3. 금지 명령이 어댑터 밖에 추가되지 않았는지 확인합니다.
4. [Harness Rules](pcs-harness-rules.md)의 권장 wrapper를 같은 옵션으로 재실행합니다.
