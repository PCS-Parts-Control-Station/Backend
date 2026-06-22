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

function Invoke-GitLines {
    param([string[]] $Arguments)

    $stderrPath = Join-Path ([System.IO.Path]::GetTempPath()) ("pcs-codex-git-{0}.log" -f [guid]::NewGuid())
    $previousErrorActionPreference = $ErrorActionPreference

    try {
        $ErrorActionPreference = "Continue"
        $output = & git -C $ProjectRoot @Arguments 2> $stderrPath
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        $stderr = if (Test-Path $stderrPath) { Get-Content -Raw -Path $stderrPath } else { "" }
        Remove-Item -Force -Path $stderrPath -ErrorAction SilentlyContinue
        throw "Git command failed: git $($Arguments -join ' ')`n$stderr"
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
