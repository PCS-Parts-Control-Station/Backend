param(
    [switch] $Force
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$GitHooksDir = Join-Path $ProjectRoot ".git/hooks"
$SourceHooksDir = Join-Path $ScriptDir "hooks"

if (-not (Test-Path (Join-Path $ProjectRoot ".git"))) {
    throw "Backend 폴더가 Git 저장소가 아닙니다. Backend 폴더 안에서 실행하세요."
}

New-Item -ItemType Directory -Force -Path $GitHooksDir | Out-Null

$hooks = @("pre-commit", "pre-push")

foreach ($hook in $hooks) {
    $source = Join-Path $SourceHooksDir $hook
    $target = Join-Path $GitHooksDir $hook

    if ((Test-Path $target) -and -not $Force) {
        Write-Host "$hook 훅이 이미 있습니다. 덮어쓰려면 -Force 옵션을 사용하세요."
        continue
    }

    Copy-Item -LiteralPath $source -Destination $target -Force
    Write-Host "$hook 훅 설치 완료: $target"
}

Write-Host ""
Write-Host "설치 확인:"
Write-Host "git commit 전: harness/run-harness.ps1 -Mode bootstrap"
Write-Host "git push 전: harness/run-harness.ps1 -Mode bootstrap -RunBuild"
