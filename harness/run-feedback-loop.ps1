param(
    [ValidateSet("bootstrap", "full")]
    [string] $Mode = "bootstrap",

    [switch] $RunBuild,

    [switch] $CheckPort,

    [int] $Port = 8080
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$HarnessPath = Join-Path $ScriptDir "run-harness.ps1"
$ReportDir = Join-Path $ScriptDir "reports"
$LatestReportPath = Join-Path $ReportDir "latest.md"
$AgentFeedbackPath = Join-Path $ReportDir "agent-failures.md"

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

function Get-PowerShellRunner {
    $pwsh = Get-Command "pwsh" -ErrorAction SilentlyContinue
    if ($pwsh) {
        return $pwsh.Source
    }

    $powershell = Get-Command "powershell.exe" -ErrorAction SilentlyContinue
    if ($powershell) {
        return $powershell.Source
    }

    throw "PowerShell runner was not found. Install pwsh or run from Windows PowerShell."
}

function Invoke-HarnessCheck {
    $runner = Get-PowerShellRunner
    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        $HarnessPath,
        "-Mode",
        $Mode
    )

    if ($RunBuild) {
        $arguments += "-RunBuild"
    }

    if ($CheckPort) {
        $arguments += @("-CheckPort", "-Port", "$Port")
    }

    Push-Location $ProjectRoot
    try {
        & $runner @arguments
        return $LASTEXITCODE
    } finally {
        Pop-Location
    }
}

function Get-ReportSection {
    param(
        [string[]] $Lines,
        [string] $SectionName
    )

    $start = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -eq "## $SectionName") {
            $start = $i + 1
            break
        }
    }

    if ($start -lt 0) {
        return @()
    }

    $items = New-Object System.Collections.Generic.List[string]
    for ($i = $start; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match "^## ") {
            break
        }

        if ($Lines[$i].Trim().Length -gt 0) {
            $items.Add($Lines[$i]) | Out-Null
        }
    }

    return $items.ToArray()
}

function New-AgentFeedback {
    if (-not (Test-Path $LatestReportPath)) {
        throw "Harness report was not created: $LatestReportPath"
    }

    $reportLines = Get-Content -Path $LatestReportPath
    $failLines = Get-ReportSection -Lines $reportLines -SectionName "FAIL"
    $warnLines = Get-ReportSection -Lines $reportLines -SectionName "WARN"

    $feedback = New-Object System.Collections.Generic.List[string]
    $feedback.Add("# Agent Failures") | Out-Null
    $feedback.Add("") | Out-Null
    $feedback.Add("- Source: harness/reports/latest.md") | Out-Null
    $feedback.Add("- GeneratedAt: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
    $feedback.Add("- Mode: $Mode") | Out-Null
    $feedback.Add("") | Out-Null

    $feedback.Add("## FAIL") | Out-Null
    $feedback.Add("") | Out-Null
    if ($failLines.Count -eq 0 -or ($failLines.Count -eq 1 -and $failLines[0] -eq "- none")) {
        $feedback.Add("- none") | Out-Null
    } else {
        foreach ($line in $failLines) {
            $feedback.Add($line) | Out-Null
        }
    }
    $feedback.Add("") | Out-Null

    $feedback.Add("## WARN") | Out-Null
    $feedback.Add("") | Out-Null
    if ($warnLines.Count -eq 0 -or ($warnLines.Count -eq 1 -and $warnLines[0] -eq "- none")) {
        $feedback.Add("- none") | Out-Null
    } else {
        foreach ($line in $warnLines) {
            $feedback.Add($line) | Out-Null
        }
    }
    $feedback.Add("") | Out-Null

    $feedback.Add("## Fix Loop") | Out-Null
    $feedback.Add("") | Out-Null
    $feedback.Add("1. Fix FAIL items first.") | Out-Null
    $feedback.Add("2. Re-run harness/run-feedback-loop.ps1 with the same options.") | Out-Null
    $feedback.Add("3. Treat WARN items as review targets after FAIL is clear.") | Out-Null

    Set-Content -Path $AgentFeedbackPath -Value $feedback -Encoding UTF8
}

$exitCode = Invoke-HarnessCheck
New-AgentFeedback

Write-Host ""
Write-Host "PCS Feedback Loop Result"
Write-Host "Mode: $Mode"
Write-Host "HarnessExitCode: $exitCode"
Write-Host "HarnessReport: $LatestReportPath"
Write-Host "AgentFeedback: $AgentFeedbackPath"

exit $exitCode
