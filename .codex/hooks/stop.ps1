param()

$ErrorActionPreference = "Stop"

$HookDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $HookDir "../..")
$HarnessDir = Join-Path $ProjectRoot "harness"
$ReportDir = Join-Path $HarnessDir "reports"
$ChangedFilesPath = Join-Path $ReportDir "codex-stop-changed-files.txt"
$TrackedFilesPath = Join-Path $ReportDir "codex-stop-tracked-files.txt"
$FeedbackPath = Join-Path $ReportDir "agent-failures.md"
$FeedbackLoopPath = Join-Path $HarnessDir "run-feedback-loop.ps1"

function Test-IsWindowsHost {
    if (Get-Variable -Name IsWindows -Scope Global -ErrorAction SilentlyContinue) {
        return $IsWindows
    }

    return $env:OS -eq "Windows_NT"
}

function Get-GitCommandPath {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCommand) {
        return $gitCommand.Source
    }

    if (Test-IsWindowsHost) {
        $candidates = @(
            (Join-Path $env:ProgramFiles "Git/cmd/git.exe"),
            (Join-Path $env:ProgramFiles "Git/bin/git.exe")
        )

        $programFilesX86 = ${env:ProgramFiles(x86)}
        if (-not [string]::IsNullOrWhiteSpace($programFilesX86)) {
            $candidates += @(
                (Join-Path $programFilesX86 "Git/cmd/git.exe"),
                (Join-Path $programFilesX86 "Git/bin/git.exe")
            )
        }

        foreach ($candidate in $candidates) {
            if (Test-Path $candidate) {
                return $candidate
            }
        }
    }

    throw "Git command was not found. Install Git or add git to PATH."
}

function Invoke-GitLines {
    param([string[]] $Arguments)

    $gitCommand = Get-GitCommandPath
    $stderrPath = Join-Path ([System.IO.Path]::GetTempPath()) ("pcs-codex-git-{0}.log" -f [guid]::NewGuid())
    $previousErrorActionPreference = $ErrorActionPreference

    try {
        $ErrorActionPreference = "Continue"
        $output = & $gitCommand -C $ProjectRoot @Arguments 2> $stderrPath
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        $stderr = if (Test-Path $stderrPath) { Get-Content -Raw -Path $stderrPath } else { "" }
        Remove-Item -Force -Path $stderrPath -ErrorAction SilentlyContinue
        throw "Git command failed: $gitCommand $($Arguments -join ' ')`n$stderr"
    }

    Remove-Item -Force -Path $stderrPath -ErrorAction SilentlyContinue
    return @($output | ForEach-Object { ([string] $_).Trim() } | Where-Object { $_ })
}

function Get-ChangedFiles {
    $changed = New-Object System.Collections.Generic.List[string]

    foreach ($path in (Invoke-GitLines @("diff", "--name-only", "--diff-filter=ACDMRTUXB", "HEAD"))) {
        $changed.Add($path) | Out-Null
    }
    foreach ($path in (Invoke-GitLines @("ls-files", "--others", "--exclude-standard"))) {
        $changed.Add($path) | Out-Null
    }

    return @($changed | ForEach-Object { $_ -replace "\\", "/" } | Sort-Object -Unique)
}

function Test-DbSensitiveChange {
    param([string[]] $Paths)

    foreach ($path in $Paths) {
        if ($path -match '^src/main/java/com/pcs/domain/' -or
            $path -match '^src/main/resources/mapper/' -or
            $path -match '^docs/sql/' -or
            $path -match '^docs/features/.+-db\.md$') {
            return $true
        }
    }

    return $false
}

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

try {
    $changedFiles = @(Get-ChangedFiles)
    $trackedFiles = @(Invoke-GitLines @("ls-files"))

    Set-Content -Path $ChangedFilesPath -Value $changedFiles -Encoding UTF8
    Set-Content -Path $TrackedFilesPath -Value $trackedFiles -Encoding UTF8

    if ($changedFiles.Count -eq 0) {
        Write-Host "PCS Codex Stop: no workspace changes to validate."
        exit 0
    }

    $feedbackArguments = @{
        Mode = "gate"
        RunBuild = $true
        ChangedFilesPath = $ChangedFilesPath
        TrackedFilesPath = $TrackedFilesPath
    }

    if (Test-DbSensitiveChange $changedFiles) {
        $feedbackArguments["RunDb"] = $true
    }

    & $FeedbackLoopPath @feedbackArguments
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -and (Test-Path $FeedbackPath)) {
        [Console]::Error.WriteLine((Get-Content -Raw -Encoding UTF8 -Path $FeedbackPath))
    }

    exit $exitCode
} catch {
    Write-Error "PCS Codex Stop hook failed: $($_.Exception.Message)"
    exit 1
}
