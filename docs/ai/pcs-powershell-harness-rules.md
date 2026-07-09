# PCS PowerShell Harness Rules

이 문서는 `*.ps1` 하네스 코드가 Windows와 macOS에서 같은 검증 로직으로 동작하도록 유지하기 위한 규칙이다.

## 적용 대상

- `harness/run-harness.ps1`
- `harness/run-feedback-loop.ps1`
- `harness/install-hooks.ps1`
- `.codex/hooks/*.ps1`
- `harness/config/features.json`을 읽는 PowerShell 코드
- 앞으로 추가되는 하네스/검증/훅 관련 PowerShell 스크립트

## 핵심 원칙

검증 로직은 한 번만 작성한다.

OS 차이는 검증 로직에 섞지 말고, 얇은 실행 어댑터 함수에만 둔다.

금지되는 구조:

```powershell
if (Test-IsWindowsHost) {
    # Windows용 빌드 검증 전체 로직
} else {
    # macOS용 빌드 검증 전체 로직
}
```

허용되는 구조:

```powershell
function Get-GradleCommand {
    if (Test-IsWindowsHost) {
        return Join-Path $ProjectRoot "gradlew.bat"
    }

    return Join-Path $ProjectRoot "gradlew"
}

function Invoke-BuildCheck {
    $exitCode = Invoke-Gradle @("compileJava")

    if ($exitCode -ne 0) {
        Add-Result "FAIL" "COMPILE_JAVA" "compileJava failed." "Fix compile errors first."
    } else {
        Add-Result "INFO" "COMPILE_JAVA" "compileJava passed."
    }
}
```

## OS 어댑터 규칙

OS별 차이는 아래 성격의 함수에만 둔다.

- `Test-IsWindowsHost`
- `Test-IsMacHost`
- `Get-GradleCommand`
- `Get-JavaExecutable`
- `Invoke-ExternalCommand`
- `Test-PortAvailable`
- `Start-HarnessProcess`
- `Normalize-ProjectPath`

새로운 OS별 처리가 필요하면 먼저 어댑터 함수를 만들거나 기존 어댑터를 확장한다.

`Invoke-BuildCheck`, `Invoke-DbChecks`, `Test-AuthFeature`, `Test-CategoryFeature` 같은 실제 검증 함수는 Windows/macOS를 직접 판단하지 않는다.

## 금지 패턴

아래 코드는 OS 어댑터 함수 밖에서 직접 사용하지 않는다.

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

- `gradlew.bat` 존재 여부 자체를 검증하는 bootstrap 규칙
- Windows 전용 어댑터 내부
- `.codex/hooks.json`의 Windows용 얇은 실행 명령
- Windows 호스트 분기 안에서만 사용하는 `-ExecutionPolicy Bypass`
- 명시적으로 Windows 전용임을 문서화한 일회성 로컬 스크립트

## Gradle 실행 규칙

Gradle 실행은 반드시 공통 함수로 감싼다.

```powershell
function Invoke-Gradle {
    param([string[]] $Tasks)

    $gradle = Get-GradleCommand
    & $gradle @Tasks
    return $LASTEXITCODE
}
```

검증 함수에서는 직접 `gradlew.bat`, `./gradlew`를 호출하지 않는다.

```powershell
$exitCode = Invoke-Gradle @("compileJava")
```

## Java 실행 규칙

Java 실행 파일은 `Get-JavaExecutable`에서만 결정한다.

Windows:

```text
$env:JAVA_HOME/bin/java.exe
```

macOS/Linux:

```text
$env:JAVA_HOME/bin/java
```

`java -version` 확인도 `cmd /c`로 감싸지 않는다. `Invoke-ExternalCommand` 또는 전용 Java 실행 헬퍼를 사용한다.

## 경로 처리 규칙

파일 경로는 `Join-Path`, `Resolve-Path`, `[System.IO.Path]`를 우선 사용한다.

문자열 패턴으로 경로를 비교해야 하면 `/`와 `\`를 모두 처리한다.

```powershell
$normalizedPath = $path -replace "\\", "/"
```

그 다음 공통 패턴으로 검사한다.

```powershell
if ($normalizedPath -notmatch "/build/") {
    # common logic
}
```

## 포트 확인 규칙

포트 확인은 OS별 명령이 다르므로 `Get-PortListeners` 같은 어댑터 안에만 둔다.

- Windows: `Get-NetTCPConnection`
- macOS/Linux: `lsof`, 없으면 `netstat`

검증 본문에서 `Get-NetTCPConnection`을 직접 호출하지 않는다.

DB 하네스처럼 Java 소스를 컴파일하고 실행하는 검사는 PATH의 `java`, `javac`를 직접 호출하지 않는다. `Ensure-JavaHome17`로 JDK 17 이상을 확정한 뒤 `JAVA_HOME/bin/java`와 `JAVA_HOME/bin/javac`를 사용한다.

## 프로세스 실행 규칙

백그라운드 프로세스 실행이 필요한 검증은 공통 실행 함수로 감싼다.

`Start-Process -WindowStyle Hidden`은 Windows 전용 옵션이므로 공통 검증 함수에서 직접 사용하지 않는다.

서버 실행이 필요한 검증은 기본 hook 검증에 포함하지 않는다. 서버를 띄우는 smoke check는 명시 옵션이 있을 때만 실행한다.

## 결과 리포트 규칙

OS가 달라도 결과 리포트 형식은 같아야 한다.

- `harness/reports/latest.md`
- `harness/reports/agent-failures.md`

Windows와 macOS가 다른 메시지를 내야 한다면 `Fix` 문구에만 OS별 안내를 포함한다.

검증 규칙명은 OS에 따라 달라지지 않는다.

```text
COMPILE_JAVA
DB_CHECK_FAILED
AUTH_FEATURE
```

## 훅 변경 파일 검사

Git pre-push 훅과 Codex Stop 훅은 변경 파일 목록을 `run-harness.ps1`의 `ChangedFilesPath`로 넘긴다.

변경 파일에 아래 경로가 포함되면 하네스는 Windows/macOS 공통 실행 규칙을 검사해야 한다.

- `harness/run-harness.ps1`
- `harness/run-feedback-loop.ps1`
- `harness/install-hooks.ps1`
- `harness/hooks/*`
- `harness/config/features.json`
- `.codex/hooks.json`
- `.codex/hooks/*.ps1`

검사 기준:

- `run-harness.ps1`는 Gradle, Java 실행을 OS 어댑터 함수로 처리해야 한다.
- `run-feedback-loop.ps1`는 `run-harness.ps1`을 호출하는 얇은 래퍼로 유지하고, Windows 전용 옵션은 Windows 분기 안에 둔다.
- `harness/hooks/pre-push`는 macOS/Linux에서 `pwsh`, Windows에서 `powershell.exe`를 사용할 수 있어야 한다.
- `.codex/hooks.json`은 공통 `command`와 Windows 전용 `commandWindows`를 분리해야 한다.
- `.codex/hooks/stop.ps1`는 변경 파일 목록을 만들고 `run-feedback-loop.ps1 -Mode gate`를 호출하는 얇은 어댑터여야 한다.

## 새 PS1 코드 추가 체크리스트

새 PowerShell 코드를 추가하거나 수정할 때 아래를 확인한다.

- 같은 검증 로직을 Windows용/macOS용으로 복제하지 않았는가?
- OS 차이가 어댑터 함수 안에만 있는가?
- `gradlew.bat`, `java.exe`, `cmd /c`, `Get-NetTCPConnection`을 직접 호출하지 않았는가?
- 경로 비교가 `/`, `\` 양쪽에서 동작하는가?
- 실패 시 Windows/macOS 모두 이해 가능한 수정 안내가 나오는가?
- hook에서 실행될 수 있는 스크립트라면 서버를 임의로 시작/종료하지 않는가?

## 검증 기준

최종적으로 같은 명령이 Windows와 macOS에서 모두 동작해야 한다.

Windows:

```powershell
pwsh -NoProfile -File .\harness\run-harness.ps1 -Mode full -RunBuild -RunDb
```

macOS:

```bash
pwsh -NoProfile -File ./harness/run-harness.ps1 -Mode full -RunBuild -RunDb
```

macOS 팀원은 `pwsh`가 필요하다.

```bash
brew install --cask powershell
```
