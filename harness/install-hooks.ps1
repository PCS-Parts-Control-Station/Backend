param(
    [switch] $Force
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$GitHooksDir = Join-Path $ProjectRoot ".git\hooks"
$SourceHooksDir = Join-Path $ScriptDir "hooks"

if (-not (Test-Path (Join-Path $ProjectRoot ".git"))) {
    throw "Backend directory is not a Git repository. Run this script from Backend."
}

New-Item -ItemType Directory -Force -Path $GitHooksDir | Out-Null

$legacyCommitHook = Join-Path $GitHooksDir "pre-commit"
if (Test-Path $legacyCommitHook) {
    $legacyContent = Get-Content -Raw -Path $legacyCommitHook
    if ($legacyContent -match "harness[/\\]run-harness\.ps1") {
        Remove-Item -LiteralPath $legacyCommitHook -Force
        Write-Host "Removed legacy PCS pre-commit hook: $legacyCommitHook"
    } else {
        Write-Warning "Existing non-PCS pre-commit hook was left unchanged: $legacyCommitHook"
    }
}

$hooks = @("pre-push")

foreach ($hook in $hooks) {
    $source = Join-Path $SourceHooksDir $hook
    $target = Join-Path $GitHooksDir $hook

    if (-not (Test-Path $source)) {
        throw "Hook source file is missing: $source"
    }

    if (Test-Path $target) {
        $targetContent = Get-Content -Raw -Path $target
        if (-not $Force -and $targetContent -notmatch "harness[/\\]run-harness\.ps1") {
            Write-Warning "Existing non-PCS $hook hook was left unchanged: $target"
            continue
        }
    }

    Copy-Item -LiteralPath $source -Destination $target -Force
    Write-Host "Installed $hook hook: $target"
}

Write-Host ""
Write-Host "Hook policy:"
Write-Host "- git commit: no PCS hook"
Write-Host "- git push: harness/run-harness.ps1 -Mode bootstrap -RunBuild -RunSwagger"
