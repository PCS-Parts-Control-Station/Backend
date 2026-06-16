param()

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$GitDir = Join-Path $ProjectRoot ".git"
$GitConfigPath = Join-Path $GitDir "config"
$HooksPath = "harness/hooks"

if (-not (Test-Path $GitDir)) {
    throw "Backend directory is not a Git repository. Run this script from Backend."
}

if (-not (Test-Path (Join-Path $ProjectRoot "harness/hooks/pre-push"))) {
    throw "Missing shared pre-push hook: harness/hooks/pre-push"
}

function Set-HooksPathWithGit {
    $git = Get-Command "git" -ErrorAction SilentlyContinue
    if (-not $git) {
        return $false
    }

    & $git.Source -C $ProjectRoot config core.hooksPath $HooksPath
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set Git core.hooksPath with git command."
    }

    return $true
}

function Set-HooksPathInConfigFile {
    if (-not (Test-Path $GitConfigPath)) {
        throw "Git config file was not found: $GitConfigPath"
    }

    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in [System.IO.File]::ReadAllLines($GitConfigPath)) {
        $lines.Add($line) | Out-Null
    }

    $coreStart = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\[core\]\s*$') {
            $coreStart = $i
            break
        }
    }

    if ($coreStart -lt 0) {
        $lines.Insert(0, "	hooksPath = $HooksPath")
        $lines.Insert(0, "[core]")
    } else {
        $nextSection = $lines.Count
        for ($i = $coreStart + 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\[.+\]\s*$') {
                $nextSection = $i
                break
            }
        }

        $existingIndex = -1
        for ($i = $coreStart + 1; $i -lt $nextSection; $i++) {
            if ($lines[$i] -match '^\s*hooksPath\s*=') {
                $existingIndex = $i
                break
            }
        }

        if ($existingIndex -ge 0) {
            $lines[$existingIndex] = "	hooksPath = $HooksPath"
        } else {
            $lines.Insert($coreStart + 1, "	hooksPath = $HooksPath")
        }
    }

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllLines($GitConfigPath, $lines, $utf8NoBom)
}

$configuredWithGit = Set-HooksPathWithGit
if (-not $configuredWithGit) {
    Set-HooksPathInConfigFile
    Write-Host "git command was not found. Updated .git/config directly."
}

Write-Host ""
Write-Host "Hook policy:"
Write-Host "- git commit: no PCS hook"
Write-Host "- git push: harness/hooks/pre-push"
Write-Host "- pre-push command: harness/run-harness.ps1 -Mode full -RunBuild -RunDb"
Write-Host ""
Write-Host "Configured core.hooksPath: $HooksPath"
