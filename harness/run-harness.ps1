param(
    [ValidateSet("bootstrap", "gate", "full")]
    [string] $Mode = "bootstrap",

    [string] $Feature = "none",

    [switch] $FixGitignore,

    [switch] $RunBuild,

    [switch] $RunSwagger,

    [switch] $RunDb,

    [string] $DbFeature = "none",

    [switch] $CheckPort,

    [int] $Port = 8080,

    [string] $ChangedFilesPath = "",

    [string] $TrackedFilesPath = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$ReportDir = Join-Path $ScriptDir "reports"
$ReportPath = Join-Path $ReportDir "latest.md"
$FeatureRegistryPath = Join-Path $ScriptDir "config/features.json"

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

if (-not (Test-Path $FeatureRegistryPath)) {
    throw "Feature registry is missing: $FeatureRegistryPath"
}

$FeatureRegistry = Get-Content -Raw -Encoding UTF8 -Path $FeatureRegistryPath | ConvertFrom-Json
$FeatureDefinitions = @($FeatureRegistry.features)
$SupportedFeatureNames = @($FeatureDefinitions | ForEach-Object { $_.name })
$SupportedDbFeatureNames = @($FeatureRegistry.dbChecks)

if ($Feature -ne "none" -and $SupportedFeatureNames -notcontains $Feature) {
    throw "Unsupported Feature: $Feature. Supported values: none, $($SupportedFeatureNames -join ', ')"
}
if ($DbFeature -ne "none" -and $SupportedDbFeatureNames -notcontains $DbFeature) {
    throw "Unsupported DbFeature: $DbFeature. Supported values: none, $($SupportedDbFeatureNames -join ', ')"
}

$failures = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]
$infos = New-Object System.Collections.Generic.List[object]
$ForbiddenGitPathPatterns = @(
    '^\.env$',
    '^\.env\..+',
    '^gradle\.properties$',
    '^application-(local|secret)\.(ya?ml|properties)$',
    '^src/main/resources/application-(local|secret)\.(ya?ml|properties)$',
    '(^|/)\.gradle/',
    '(^|/)build/',
    '(^|/)out/',
    '(^|/)\.idea/(workspace\.xml|tasks\.xml|shelf/|httpRequests/)',
    '(^|/).*\.iml$',
    '(^|/).*\.log$',
    '(^|/).*\.tmp$',
    '^tmp/',
    '^harness/reports/(?!\.gitkeep$).+',
    '^src/main/resources/static/[^/]+-preview\.html$',
    '(^|/)\.DS_Store$',
    '(^|/)Thumbs\.db$'
)
$AllowedGitPathPatterns = @(
    '^\.env\.example$',
    '^harness/reports/\.gitkeep$'
)
$script:SelectedFeatures = @()

function Add-Result {
    param(
        [ValidateSet("FAIL", "WARN", "INFO")]
        [string] $Level,
        [string] $Rule,
        [string] $Message,
        [string] $Fix = ""
    )

    $item = [pscustomobject]@{
        Level = $Level
        Rule = $Rule
        Message = $Message
        Fix = $Fix
    }

    if ($Level -eq "FAIL") {
        $failures.Add($item) | Out-Null
    } elseif ($Level -eq "WARN") {
        $warnings.Add($item) | Out-Null
    } else {
        $infos.Add($item) | Out-Null
    }
}

function Test-PathRequired {
    param(
        [string] $RelativePath,
        [string] $Rule,
        [string] $Fix
    )

    if (-not (Test-Path (Join-Path $ProjectRoot $RelativePath))) {
        Add-Result "FAIL" $Rule "Missing required path: $RelativePath" $Fix
    }
}

function Test-Java17VersionOutput {
    param(
        [string] $VersionOutput
    )

    return $VersionOutput -match 'version "17\.|version "18\.|version "19\.|version "2[0-9]\.'
}

function Test-IsWindowsHost {
    if (Get-Variable -Name IsWindows -Scope Global -ErrorAction SilentlyContinue) {
        return $IsWindows
    }

    return $env:OS -eq "Windows_NT"
}

function Get-JavaExecutablePath {
    param(
        [string] $JavaHome
    )

    if ([string]::IsNullOrWhiteSpace($JavaHome)) {
        return $null
    }

    $candidates = @(
        (Join-Path $JavaHome "bin/java"),
        (Join-Path $JavaHome "bin/java.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Get-JavaVersionOutput {
    param(
        [string] $JavaCommand
    )

    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = & $JavaCommand "-version" 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "Java version command failed with exit code $exitCode."
    }

    return ($output | ForEach-Object { $_.ToString() }) -join "`n"
}

function Resolve-Java17Home {
    $candidates = New-Object System.Collections.Generic.List[string]

    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $candidates.Add($env:JAVA_HOME) | Out-Null
    }

    $candidateRoots = @(
        "C:\Program Files\Java",
        "C:\Program Files\Eclipse Adoptium",
        "C:\Program Files\Microsoft",
        "C:\Program Files\Amazon Corretto",
        "/Library/Java/JavaVirtualMachines",
        "/usr/lib/jvm",
        "/opt/homebrew/opt/openjdk",
        "/usr/local/opt/openjdk"
    )

    foreach ($root in $candidateRoots) {
        if (-not (Test-Path $root)) {
            continue
        }

        if ($root -eq "/Library/Java/JavaVirtualMachines") {
            Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match "17|18|19|2[0-9]" } |
                ForEach-Object {
                    $homePath = Join-Path $_.FullName "Contents/Home"
                    if (Test-Path $homePath) {
                        $candidates.Add($homePath) | Out-Null
                    }
                }
        } else {
            Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match "17|18|19|2[0-9]" } |
                ForEach-Object { $candidates.Add($_.FullName) | Out-Null }

            $candidates.Add($root) | Out-Null
        }
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        $javaHomeCommand = Get-JavaExecutablePath $candidate
        if (-not $javaHomeCommand -or -not (Test-Path $javaHomeCommand)) {
            continue
        }

        try {
            $versionOutput = Get-JavaVersionOutput $javaHomeCommand
            if (Test-Java17VersionOutput $versionOutput) {
                return $candidate
            }
        } catch {
        }
    }

    return $null
}

function Ensure-JavaHome17 {
    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $javaHomeCommand = Get-JavaExecutablePath $env:JAVA_HOME
        if ($javaHomeCommand -and (Test-Path $javaHomeCommand)) {
            try {
                $javaHomeVersionOutput = Get-JavaVersionOutput $javaHomeCommand
                if (Test-Java17VersionOutput $javaHomeVersionOutput) {
                    return $true
                }
            } catch {
            }
        }
    }

    $resolvedJavaHome = Resolve-Java17Home
    if ($resolvedJavaHome) {
        $env:JAVA_HOME = $resolvedJavaHome
        Add-Result "INFO" "JAVA_HOME_17_AUTODETECTED" "Using Java 17 or later for harness checks: $resolvedJavaHome."
        return $true
    }

    return $false
}

function Get-GradleWrapperPath {
    $preferred = if (Test-IsWindowsHost) { "gradlew.bat" } else { "gradlew" }
    $fallback = if (Test-IsWindowsHost) { "gradlew" } else { "gradlew.bat" }

    $preferredPath = Join-Path $ProjectRoot $preferred
    if (Test-Path $preferredPath) {
        return $preferredPath
    }

    $fallbackPath = Join-Path $ProjectRoot $fallback
    if (Test-Path $fallbackPath) {
        return $fallbackPath
    }

    return $null
}

function Invoke-GradleWrapper {
    param(
        [string[]] $Arguments
    )

    $gradleWrapper = Get-GradleWrapperPath
    if (-not $gradleWrapper) {
        throw "Gradle Wrapper was not found."
    }

    if ((Test-IsWindowsHost) -or $gradleWrapper.EndsWith(".bat")) {
        & $gradleWrapper @Arguments
        return
    }

    & sh $gradleWrapper @Arguments
}

function Get-ProjectTextFiles {
    Get-ChildItem -Path $ProjectRoot -Recurse -File |
        Where-Object {
            $path = Normalize-HarnessPath $_.FullName
            $root = Normalize-HarnessPath $ProjectRoot
            if ($path.StartsWith($root)) {
                $path = $path.Substring($root.Length).TrimStart("/")
            }

            $path -notmatch '(^|/)\.git(/|$)' -and
            $path -notmatch '(^|/)\.gradle(/|$)' -and
            $path -notmatch '(^|/)build(/|$)' -and
            $path -notmatch '(^|/)out(/|$)' -and
            $path -notmatch '(^|/)docs(/|$)' -and
            $path -notmatch '(^|/)harness(/|$)'
        }
}

function Test-ContainsPattern {
    param(
        [string] $Pattern,
        [string] $Rule,
        [string] $Message,
        [string] $Fix
    )

    $matches = Get-ProjectTextFiles | Select-String -Pattern $Pattern -SimpleMatch -ErrorAction SilentlyContinue
    if ($matches) {
        $first = $matches | Select-Object -First 5
        $locations = ($first | ForEach-Object { "$($_.Path):$($_.LineNumber)" }) -join ", "
        Add-Result "FAIL" $Rule "$Message Locations: $locations" $Fix
    }
}

function Ensure-GitignoreRules {
    $gitignorePath = Join-Path $ProjectRoot ".gitignore"
    $required = @(
        ".gradle/",
        "build/",
        "out/",
        "*.iml",
        ".idea/",
        ".env",
        ".env.*",
        "!.env.example",
        "application-local.yml",
        "application-local.yaml",
        "application-local.properties",
        "application-secret.yml",
        "application-secret.yaml",
        "application-secret.properties",
        "gradle.properties",
        "*.log",
        "*.tmp",
        "tmp/",
        "harness/reports/*",
        "!harness/reports/.gitkeep",
        "src/main/resources/static/*-preview.html",
        ".DS_Store",
        "Thumbs.db"
    )

    if (-not (Test-Path $gitignorePath)) {
        if ($FixGitignore) {
            New-Item -ItemType File -Force -Path $gitignorePath | Out-Null
        } else {
            Add-Result "FAIL" "GITIGNORE_EXISTS" ".gitignore is missing." "Create .gitignore or run with -FixGitignore."
            return
        }
    }

    $content = Get-Content -Path $gitignorePath -ErrorAction SilentlyContinue
    $missing = $required | Where-Object { $_ -notin $content }

    if ($missing.Count -gt 0) {
        if ($FixGitignore) {
            Add-Content -Path $gitignorePath -Value ""
            Add-Content -Path $gitignorePath -Value "# PCS harness shared ignore rules"
            $missing | ForEach-Object { Add-Content -Path $gitignorePath -Value $_ }
            Add-Result "INFO" "GITIGNORE_FIXED" "Missing .gitignore rules were appended."
        } else {
            Add-Result "FAIL" "GITIGNORE_REQUIRED_RULES" "Missing .gitignore rules: $($missing -join ', ')" "Run .\harness\run-harness.ps1 -Mode $Mode -FixGitignore"
        }
    } else {
        Add-Result "INFO" "GITIGNORE_REQUIRED_RULES" ".gitignore contains required rules."
    }
}

function Test-AllowedGitPath {
    param(
        [string] $Path
    )

    $normalizedPath = Normalize-HarnessPath $Path
    foreach ($pattern in $AllowedGitPathPatterns) {
        if ($normalizedPath -match $pattern) {
            return $true
        }
    }

    return $false
}

function Test-ForbiddenGitPath {
    param(
        [string] $Path
    )

    $normalizedPath = Normalize-HarnessPath $Path
    if ([string]::IsNullOrWhiteSpace($normalizedPath)) {
        return $false
    }

    if (Test-AllowedGitPath $normalizedPath) {
        return $false
    }

    foreach ($pattern in $ForbiddenGitPathPatterns) {
        if ($normalizedPath -match $pattern) {
            return $true
        }
    }

    return $false
}

function Get-GitTrackedFiles {
    if (-not [string]::IsNullOrWhiteSpace($TrackedFilesPath)) {
        $resolvedPath = $TrackedFilesPath
        if (-not [System.IO.Path]::IsPathRooted($resolvedPath)) {
            $resolvedPath = Join-Path $ProjectRoot $resolvedPath
        }

        if (Test-Path $resolvedPath) {
            return @(Get-Content -Path $resolvedPath | ForEach-Object { Normalize-HarnessPath $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        }

        Add-Result "WARN" "GIT_TRACKED_FILES_LIST_MISSING" "Tracked files list was not found: $TrackedFilesPath" "Check the pre-push hook tracked-file collection."
    }

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Add-Result "WARN" "GIT_COMMAND_UNAVAILABLE" "git command is not available, so tracked forbidden-file checks were skipped." "Run the harness from a shell where git is available."
        return @()
    }

    try {
        Push-Location $ProjectRoot
        $trackedFiles = @(git ls-files 2>$null)
        Pop-Location
        return @($trackedFiles | ForEach-Object { Normalize-HarnessPath $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    } catch {
        try {
            Pop-Location
        } catch {
        }
        Add-Result "WARN" "GIT_TRACKED_FILES_UNAVAILABLE" "git tracked-file list could not be read." "Check git installation and repository state."
        return @()
    }
}

function Test-GitForbiddenFiles {
    $trackedFiles = @(Get-GitTrackedFiles)
    if ($trackedFiles.Count -gt 0) {
        $forbiddenTrackedFiles = @($trackedFiles | Where-Object { Test-ForbiddenGitPath $_ } | Select-Object -Unique)
        if ($forbiddenTrackedFiles.Count -gt 0) {
            Add-Result "FAIL" "GIT_TRACKED_FORBIDDEN_FILES" "Forbidden files are already tracked by Git: $($forbiddenTrackedFiles -join ', ')" "Remove them from Git tracking with git rm --cached, keep them in .gitignore, then commit the removal."
        } else {
            Add-Result "INFO" "GIT_TRACKED_FORBIDDEN_FILES" "No forbidden files are tracked by Git."
        }
    }

    if ([string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
        return
    }

    $changedFiles = @(Get-ChangedFilesForGate)
    if ($changedFiles.Count -eq 0) {
        return
    }

    $forbiddenChangedFiles = New-Object System.Collections.Generic.List[string]
    foreach ($changedFile in $changedFiles) {
        $normalizedPath = Normalize-HarnessPath $changedFile
        if (-not (Test-ForbiddenGitPath $normalizedPath)) {
            continue
        }

        $absolutePath = Join-Path $ProjectRoot $normalizedPath
        if (Test-Path $absolutePath) {
            $forbiddenChangedFiles.Add($normalizedPath) | Out-Null
        }
    }

    $forbiddenChangedFiles = @($forbiddenChangedFiles | Select-Object -Unique)
    if ($forbiddenChangedFiles.Count -gt 0) {
        Add-Result "FAIL" "GIT_PUSH_FORBIDDEN_FILES" "Forbidden files are included in this push: $($forbiddenChangedFiles -join ', ')" "Remove these files from the commit or add only the approved example file."
    } else {
        Add-Result "INFO" "GIT_PUSH_FORBIDDEN_FILES" "No forbidden files are included in the changed-file list."
    }
}

function Test-JavaVersion {
    try {
        $versionOutput = Get-JavaVersionOutput "java"
        if (-not (Test-Java17VersionOutput $versionOutput)) {
            Add-Result "FAIL" "JAVA_17_REQUIRED" "java command is not Java 17 or later. Output: $versionOutput" "Set JAVA_HOME and IntelliJ Project SDK to JDK 17 or later."
        } else {
            Add-Result "INFO" "JAVA_17_REQUIRED" "Java 17 or later is available."
        }
    } catch {
        Add-Result "FAIL" "JAVA_COMMAND_REQUIRED" "java command is not available." "Install JDK 17 or later and configure PATH/JAVA_HOME."
    }

    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $javaHomeCommand = Get-JavaExecutablePath $env:JAVA_HOME
        if (-not $javaHomeCommand -or -not (Test-Path $javaHomeCommand)) {
            if (-not (Ensure-JavaHome17)) {
                Add-Result "FAIL" "JAVA_HOME_COMMAND_REQUIRED" "JAVA_HOME does not point to a JDK with a java executable: $env:JAVA_HOME" "Set JAVA_HOME to JDK 17 or later."
            }
            return
        }

        try {
            $javaHomeVersionOutput = Get-JavaVersionOutput $javaHomeCommand
            if (-not (Test-Java17VersionOutput $javaHomeVersionOutput)) {
                if (-not (Ensure-JavaHome17)) {
                    Add-Result "FAIL" "JAVA_HOME_17_REQUIRED" "JAVA_HOME is not Java 17 or later. Output: $javaHomeVersionOutput" "Set JAVA_HOME to JDK 17 or later."
                }
            } else {
                Add-Result "INFO" "JAVA_HOME_17_REQUIRED" "JAVA_HOME points to Java 17 or later."
            }
        } catch {
            if (-not (Ensure-JavaHome17)) {
                Add-Result "FAIL" "JAVA_HOME_VERSION_CHECK_FAILED" "Failed to execute JAVA_HOME java command." "Set JAVA_HOME to a valid JDK 17 or later."
            }
        }
    } elseif ($RunBuild -or $RunSwagger) {
        Ensure-JavaHome17 | Out-Null
    }
}

function Test-PortAvailable {
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
        if ($connection) {
            $owners = ($connection | Select-Object -ExpandProperty OwningProcess -Unique) -join ", "
            Add-Result "WARN" "PORT_IN_USE" "Port $Port is already in use. PID: $owners" "Stop the running server before clean/build if needed."
        } else {
            Add-Result "INFO" "PORT_AVAILABLE" "Port $Port is available."
        }
    } catch {
        Add-Result "WARN" "PORT_CHECK_SKIPPED" "Port check was skipped."
    }
}

function Test-BootstrapStructure {
    Test-PathRequired "build.gradle" "GRADLE_BUILD_FILE" "Keep Backend/build.gradle."
    Test-PathRequired "settings.gradle" "GRADLE_SETTINGS_FILE" "Keep Backend/settings.gradle."
    Test-PathRequired "gradlew.bat" "GRADLE_WRAPPER_WINDOWS" "Share Gradle Wrapper files."
    Test-PathRequired "gradlew" "GRADLE_WRAPPER_UNIX" "Share Gradle Wrapper files."
    Test-PathRequired "gradle/wrapper/gradle-wrapper.jar" "GRADLE_WRAPPER_JAR" "Share gradle/wrapper files."
    Test-PathRequired "gradle/wrapper/gradle-wrapper.properties" "GRADLE_WRAPPER_PROPERTIES" "Share gradle/wrapper files."
    Test-PathRequired "src/main/java/com/pcs/PcsApiApplication.java" "SPRING_BOOT_APPLICATION" "Keep the Spring Boot application class."
    Test-PathRequired "src/main/java/com/pcs/web/controller/PageController.java" "PAGE_CONTROLLER" "Keep the page forward controller."
    Test-PathRequired "src/main/resources/application.yaml" "APPLICATION_YAML" "Keep application.yaml."
    Test-PathRequired "src/main/resources/static/main.html" "MAIN_HTML" "Keep the bootstrap main page."
    Test-PathRequired "src/main/resources/static/css/pages/main.css" "MAIN_CSS" "Keep page CSS paired with main.html."
    Test-PathRequired "src/main/resources/static/js/main.js" "MAIN_JS" "Keep JS paired with main.html."
}

function Test-ProjectSettings {
    $buildFile = Join-Path $ProjectRoot "build.gradle"
    $applicationFile = Join-Path $ProjectRoot "src/main/resources/application.yaml"
    $pageController = Join-Path $ProjectRoot "src/main/java/com/pcs/web/controller/PageController.java"

    if (Test-Path $buildFile) {
        $build = Get-Content -Raw $buildFile
        if ($build -notmatch "org\.springframework\.boot' version '4\.0\.3'") {
            Add-Result "FAIL" "SPRING_BOOT_VERSION" "Spring Boot version is not 4.0.3." "Set Spring Boot version to 4.0.3."
        }
        if ($build -notmatch "JavaLanguageVersion\.of\(17\)") {
            Add-Result "FAIL" "JAVA_TOOLCHAIN_17" "Gradle Java toolchain 17 is missing." "Keep Java 17 toolchain in build.gradle."
        }
        if ($build -notmatch "spring-boot-starter-web") {
            Add-Result "FAIL" "SPRING_WEB_REQUIRED" "spring-boot-starter-web is missing." "Keep web starter for the main page."
        }
        if ($build -notmatch "spring-boot-starter-security") {
            Add-Result "FAIL" "SPRING_SECURITY_REQUIRED" "spring-boot-starter-security is missing." "Use Spring Security for JWT request authentication."
        }
        if ($build -notmatch "springdoc-openapi-starter-webmvc-ui") {
            Add-Result "FAIL" "SPRINGDOC_OPENAPI_REQUIRED" "springdoc-openapi UI starter is missing." "Keep automatic Swagger/OpenAPI generation enabled."
        }
    }

    if (Test-Path $applicationFile) {
        $application = Get-Content -Raw $applicationFile
        if ($application -notmatch "name:\s*pcs-api") {
            Add-Result "FAIL" "APPLICATION_NAME" "spring.application.name is not pcs-api." "Keep spring.application.name as pcs-api."
        }
    }

    if (Test-Path $pageController) {
        $controller = Get-Content -Raw $pageController
        if ($controller -notmatch "@Controller") {
            Add-Result "FAIL" "PAGE_CONTROLLER_ANNOTATION" "PageController must use @Controller." "Keep PageController as an HTML forward controller."
        }
        if ($controller -notmatch 'forward:/main\.html') {
            Add-Result "FAIL" "PAGE_CONTROLLER_FORWARD" "PageController does not forward to main.html." "Return forward:/main.html."
        }
        if ($controller -match "Model|model\.addAttribute|Service|Mapper|Repository|@RestController|/api/") {
            Add-Result "FAIL" "PAGE_CONTROLLER_ONLY_FORWARD" "PageController has responsibilities other than forwarding." "PageController must not know Model, Service, Mapper, or API routes."
        }
    }
}

function Test-ForbiddenAlways {
    Test-ContainsPattern "spring-boot-starter-data-jpa" "NO_JPA_DEPENDENCY" "JPA dependency was found." "PCS must use MyBatis, not JPA."
    Test-ContainsPattern "jakarta.persistence" "NO_JPA_IMPORT" "JPA import was found." "Use plain domain objects and MyBatis Mapper later."
    Test-ContainsPattern "javax.persistence" "NO_JPA_IMPORT_LEGACY" "JPA import was found." "Use plain domain objects and MyBatis Mapper later."
    Test-ContainsPattern "JpaRepository" "NO_JPA_REPOSITORY" "JpaRepository usage was found." "Use MyBatis Mapper later."
    Test-ContainsPattern "EntityManager" "NO_ENTITY_MANAGER" "EntityManager usage was found." "Use MyBatis Mapper XML SQL later."
}

function Test-NoFeatureCodeBeforeSpec {
    $domainRoot = Join-Path $ProjectRoot "src/main/java/com/pcs/domain"
    if (-not (Test-Path $domainRoot)) {
        Add-Result "INFO" "NO_DOMAIN_BEFORE_SPEC" "No domain code exists before feature specs."
        return
    }

    $featureDocRoot = Join-Path $ProjectRoot "docs/features"
    $domains = Get-ChildItem -Path $domainRoot -Directory -ErrorAction SilentlyContinue
    foreach ($domain in $domains) {
        $featureDoc = Join-Path $featureDocRoot "$($domain.Name).md"
        if (-not (Test-Path $featureDoc)) {
            Add-Result "FAIL" "FEATURE_SPEC_REQUIRED" "domain/$($domain.Name) exists but docs/features/$($domain.Name).md is missing." "Write the feature spec before adding domain code."
        }
    }
}

function Test-JavaScriptSyntax {
    $jsRoot = Join-Path $ProjectRoot "src/main/resources/static/js"
    $jsFiles = Get-ChildItem -Path $jsRoot -Filter "*.js" -Recurse -File -ErrorAction SilentlyContinue
    if (-not $jsFiles) {
        Add-Result "WARN" "JS_FILES_EMPTY" "No JS files were found."
        return
    }

    foreach ($jsFile in $jsFiles) {
        try {
            & node --check $jsFile.FullName | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Add-Result "FAIL" "JS_SYNTAX" "$($jsFile.FullName) failed node --check." "Fix JS syntax errors."
            }
        } catch {
            Add-Result "WARN" "NODE_NOT_AVAILABLE" "node command is not available, so JS syntax check was skipped." "Install Node.js to enable JS syntax checks."
            return
        }
    }
    Add-Result "INFO" "JS_SYNTAX" "JS syntax check passed."
}

function Test-CssArchitecture {
    $staticRoot = Join-Path $ProjectRoot "src/main/resources/static"
    $cssRoot = Join-Path $staticRoot "css"
    $requiredCommonFiles = @(
        "css/core/tokens.css",
        "css/core/base.css",
        "css/layouts/workspace.css",
        "css/components/components.css",
        "css/components/workflow.css",
        "css/components/feedback.css"
    )

    foreach ($relativePath in $requiredCommonFiles) {
        Test-PathRequired "src/main/resources/static/$relativePath" "CSS_ARCHITECTURE_FILE" "Keep the layered CSS architecture defined in docs/ai/design/css-architecture.md."
    }

    $legacyAdminCss = Join-Path $cssRoot "admin.css"
    if (Test-Path $legacyAdminCss) {
        Add-Result "FAIL" "CSS_LEGACY_ADMIN_FILE" "Legacy admin.css exists." "Move shared rules to core/layouts/components and page rules to pages, then remove admin.css."
    } else {
        Add-Result "INFO" "CSS_LEGACY_ADMIN_FILE" "Legacy admin.css is absent."
    }

    $legacyFlatCssFiles = @(Get-ChildItem -Path $cssRoot -Filter "*.css" -File -ErrorAction SilentlyContinue)
    if ($legacyFlatCssFiles.Count -gt 0) {
        Add-Result "FAIL" "CSS_LEGACY_FLAT_FILES" "CSS files exist outside core/layouts/components/pages: $($legacyFlatCssFiles.Name -join ', ')" "Move each file to its owning CSS directory."
    }

    $htmlFiles = @(
        Get-ChildItem -Path $staticRoot -Filter "*.html" -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notlike "*-preview.html" }
    )
    foreach ($htmlFile in $htmlFiles) {
        $pageName = $htmlFile.BaseName
        $content = Get-Content -Raw $htmlFile.FullName
        $pageCssRelativePath = "css/pages/$pageName.css"
        $pageCssPath = Join-Path $staticRoot $pageCssRelativePath

        if (-not (Test-Path $pageCssPath)) {
            Add-Result "FAIL" "CSS_PAGE_FILE_MISSING" "$($htmlFile.Name) has no matching pages/$pageName.css." "Create one page CSS file for every HTML page."
        }
        foreach ($requiredHref in @("/css/core/tokens.css", "/css/core/base.css", "/css/components/components.css", "/css/pages/$pageName.css")) {
            if ($content -notmatch [regex]::Escape($requiredHref)) {
                Add-Result "FAIL" "CSS_PAGE_LINK_MISSING" "$($htmlFile.Name) does not load $requiredHref." "Load common CSS in standard order and page CSS last."
            }
        }
        $orderedHrefs = @("/css/core/tokens.css", "/css/core/base.css")
        if ($content -match "workspace-page") {
            $orderedHrefs += "/css/layouts/workspace.css"
            if ($content -notmatch [regex]::Escape("/css/layouts/workspace.css")) {
                Add-Result "FAIL" "CSS_WORKSPACE_LAYOUT_MISSING" "$($htmlFile.Name) is a workspace page without layouts/workspace.css." "Load the shared workspace layout before components."
            }
        }
        $orderedHrefs += "/css/components/components.css"
        if ($content -match [regex]::Escape("/css/components/workflow.css")) {
            $orderedHrefs += "/css/components/workflow.css"
        }
        if ($content -match [regex]::Escape("/css/components/feedback.css")) {
            $orderedHrefs += "/css/components/feedback.css"
        }
        $orderedHrefs += "/css/pages/$pageName.css"
        $previousIndex = -1
        foreach ($href in $orderedHrefs) {
            $currentIndex = $content.IndexOf($href, [System.StringComparison]::Ordinal)
            if ($currentIndex -lt $previousIndex) {
                Add-Result "FAIL" "CSS_LINK_ORDER" "$($htmlFile.Name) loads $href out of order." "Load tokens, base, layout, components, optional shared CSS, then page CSS."
                break
            }
            $previousIndex = $currentIndex
        }
        if ($content -match "/css/admin\.css") {
            Add-Result "FAIL" "CSS_LEGACY_ADMIN_REFERENCE" "$($htmlFile.Name) still references admin.css." "Use the layered CSS files instead."
        }
        if ($content -notmatch "page-$([regex]::Escape($pageName))") {
            Add-Result "FAIL" "CSS_PAGE_SCOPE_CLASS" "$($htmlFile.Name) body is missing page-$pageName." "Scope page-only rules with a page body class."
        }
        if ($content -match "\sstyle\s*=") {
            Add-Result "FAIL" "CSS_STATIC_INLINE_STYLE" "$($htmlFile.Name) contains an inline style attribute." "Move static styles to the matching page CSS."
        }
    }

    $cssFiles = @(Get-ChildItem -Path $cssRoot -Filter "*.css" -File -Recurse -ErrorAction SilentlyContinue)
    foreach ($cssFile in $cssFiles) {
        $content = Get-Content -Raw $cssFile.FullName
        if ($content -notmatch "@layer") {
            Add-Result "FAIL" "CSS_LAYER_MISSING" "$($cssFile.FullName) has rules outside the layer architecture." "Wrap CSS in its owning layer."
        }
        $importantMatches = @([regex]::Matches($content, "!important"))
        $allowedHiddenImportant = $cssFile.Name -eq "base.css" -and $importantMatches.Count -eq 1 -and $content -match "\[hidden\]"
        if ($importantMatches.Count -gt 0 -and -not $allowedHiddenImportant) {
            Add-Result "FAIL" "CSS_IMPORTANT_FORBIDDEN" "$($cssFile.FullName) contains !important." "Resolve priority through layer ownership and scoped selectors."
        }
        if ($cssFile.Directory.Name -eq "pages" -and $content -notmatch "@layer\s+page") {
            Add-Result "FAIL" "CSS_PAGE_LAYER_INVALID" "$($cssFile.FullName) is not owned by the page layer." "Wrap page-only styles in @layer page."
        }
    }

    Add-Result "INFO" "CSS_ARCHITECTURE" "Layered common and page CSS checks completed."
}

function Test-FeatureRegistry {
    Test-PathRequired "harness/config/features.json" "FEATURE_REGISTRY_FILE" "Keep all feature path and DB dependency mappings in one registry."

    $names = @($FeatureDefinitions | ForEach-Object { [string] $_.name })
    $duplicateNames = @($names | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    if ($duplicateNames.Count -gt 0) {
        Add-Result "FAIL" "FEATURE_REGISTRY_DUPLICATE" "Duplicate feature names: $($duplicateNames -join ', ')." "Keep each feature exactly once in harness/config/features.json."
    }

    foreach ($definition in $FeatureDefinitions) {
        $name = [string] $definition.name
        $patterns = @($definition.pathPatterns)
        if ([string]::IsNullOrWhiteSpace($name) -or $patterns.Count -eq 0) {
            Add-Result "FAIL" "FEATURE_REGISTRY_ENTRY_INVALID" "A feature registry entry is missing name or pathPatterns." "Complete every feature registry entry."
            continue
        }

        foreach ($pattern in $patterns) {
            try {
                [void] [regex]::new([string] $pattern)
            } catch {
                Add-Result "FAIL" "FEATURE_REGISTRY_REGEX_INVALID" "Feature $name has invalid regex: $pattern." "Fix the path pattern in harness/config/features.json."
            }
        }

        foreach ($dbCheck in @($definition.dbChecks)) {
            if ($SupportedDbFeatureNames -notcontains $dbCheck) {
                Add-Result "FAIL" "FEATURE_REGISTRY_DB_INVALID" "Feature $name references unsupported DB check: $dbCheck." "Add the DB checker or remove the reference."
            }
        }
    }

    Add-Result "INFO" "FEATURE_REGISTRY" "Feature registry checks completed for $($names.Count) features."
}

function Test-CodexHookConfiguration {
    $hooksPath = Join-Path $ProjectRoot ".codex/hooks.json"
    $stopHookPath = Join-Path $ProjectRoot ".codex/hooks/stop.ps1"
    Test-PathRequired ".codex/hooks.json" "CODEX_HOOK_CONFIG" "Keep the shared project Stop hook configuration."
    Test-PathRequired ".codex/hooks/stop.ps1" "CODEX_STOP_HOOK" "Keep the shared Stop hook adapter."

    if (Test-Path $hooksPath) {
        try {
            $hooksConfig = Get-Content -Raw -Encoding UTF8 -Path $hooksPath | ConvertFrom-Json
            $stopGroups = @($hooksConfig.hooks.Stop)
            if ($stopGroups.Count -ne 1) {
                Add-Result "FAIL" "CODEX_STOP_HOOK_COUNT" "Expected exactly one Stop hook group, found $($stopGroups.Count)." "Keep one deterministic PCS Stop validation hook."
            }
            $handlers = @($stopGroups | ForEach-Object { $_.hooks })
            foreach ($handler in $handlers) {
                if ($handler.type -ne "command") {
                    Add-Result "FAIL" "CODEX_HOOK_TYPE_UNSUPPORTED" "Unsupported Codex hook type: $($handler.type)." "Use command hooks until Codex supports agent or prompt handlers."
                }
                if ([string]::IsNullOrWhiteSpace($handler.command) -or [string]::IsNullOrWhiteSpace($handler.commandWindows)) {
                    Add-Result "FAIL" "CODEX_HOOK_CROSS_PLATFORM_COMMAND" "Stop hook must define command and commandWindows." "Keep macOS and Windows launch commands in hooks.json."
                }
                if ([int] $handler.timeout -le 0 -or [int] $handler.timeout -gt 600) {
                    Add-Result "FAIL" "CODEX_HOOK_TIMEOUT" "Stop hook timeout must be between 1 and 600 seconds." "Use a bounded timeout for Stop validation."
                }
                $commands = "$($handler.command)`n$($handler.commandWindows)"
                if ($commands -match '[A-Za-z]:\\') {
                    Add-Result "FAIL" "CODEX_HOOK_ABSOLUTE_PATH" "Stop hook contains a Windows absolute path." "Resolve the hook from the Git root."
                }
            }
        } catch {
            Add-Result "FAIL" "CODEX_HOOK_JSON_INVALID" "Cannot parse .codex/hooks.json: $($_.Exception.Message)" "Fix the project hook JSON."
        }
    }

    if (Test-Path $stopHookPath) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $stopHookPath
        foreach ($pattern in @("run-feedback-loop.ps1", 'Mode = "gate"', "ChangedFilesPath", "TrackedFilesPath")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "CODEX_STOP_HOOK_CONTRACT" "stop.ps1 is missing required pattern: $pattern" "Keep the Stop hook as a thin gate-mode adapter."
            }
        }
        foreach ($forbidden in @("-Mode full", "bootRun", "Stop-Process", "Start-Process")) {
            if ($content -match [regex]::Escape($forbidden)) {
                Add-Result "FAIL" "CODEX_STOP_HOOK_FORBIDDEN" "stop.ps1 contains forbidden behavior: $forbidden" "Do not run full regression or control the server from a Stop hook."
            }
        }
    }

    Add-Result "INFO" "CODEX_STOP_HOOK" "Codex Stop hook configuration checks completed."
}

function Test-WorkspaceNavigation {
    $fragmentPath = Join-Path $ProjectRoot "src/main/resources/static/fragments/workspace-sidebar.html"
    $partsPath = Join-Path $ProjectRoot "src/main/resources/static/parts.html"
    $partsScriptPath = Join-Path $ProjectRoot "src/main/resources/static/js/parts.js"
    $partsStylePath = Join-Path $ProjectRoot "src/main/resources/static/css/pages/parts.css"
    $componentsStylePath = Join-Path $ProjectRoot "src/main/resources/static/css/components/components.css"
    $layoutScriptPath = Join-Path $ProjectRoot "src/main/resources/static/js/workspace-layout.js"
    $layoutStylePath = Join-Path $ProjectRoot "src/main/resources/static/css/layouts/workspace.css"

    foreach ($requiredPath in @($fragmentPath, $partsPath, $partsScriptPath, $partsStylePath, $componentsStylePath, $layoutScriptPath, $layoutStylePath)) {
        if (-not (Test-Path $requiredPath)) {
            Add-Result "FAIL" "WORKSPACE_NAV_FILE_MISSING" "$requiredPath is missing." "Restore the common workspace navigation file."
            return
        }
    }

    $fragment = Get-Content -Raw -Encoding UTF8 -Path $fragmentPath
    $parts = Get-Content -Raw -Encoding UTF8 -Path $partsPath
    $partsScript = Get-Content -Raw -Encoding UTF8 -Path $partsScriptPath
    $partsStyle = Get-Content -Raw -Encoding UTF8 -Path $partsStylePath
    $componentsStyle = Get-Content -Raw -Encoding UTF8 -Path $componentsStylePath
    $layoutScript = Get-Content -Raw -Encoding UTF8 -Path $layoutScriptPath
    $layoutStyle = Get-Content -Raw -Encoding UTF8 -Path $layoutStylePath

    if ($fragment -match 'data-route="categories"') {
        Add-Result "FAIL" "WORKSPACE_CATEGORY_SIDEBAR_DUPLICATED" "The category route is exposed as an independent sidebar item." "Keep one item-management entry and expose categories from the parts page."
    }

    foreach ($pattern in @(
        'data-route="parts"',
        'data-staff-any-permissions="STAFF_PART_CREATE,STAFF_CATEGORY_MANAGE"',
        'data-staff-fallback-route="categories"'
    )) {
        if ($fragment -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_PART_NAV_INVALID" "workspace-sidebar.html is missing $pattern." "Preserve the combined item-management navigation contract."
        }
    }

    foreach ($pattern in @(
        'data-route="categories"',
        'data-staff-permission="STAFF_CATEGORY_MANAGE"'
    )) {
        if ($parts -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_CATEGORY_ENTRY_MISSING" "parts.html is missing $pattern." "Expose category management from the parts page header."
        }
    }

    foreach ($pattern in @(
        'data-part-create-drawer',
        'data-part-detail-drawer',
        'data-close-part-drawer',
        'management-detail-drawer part-detail-drawer',
        'parts-content-grid'
    )) {
        if ($parts -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_PART_DRAWER_MARKUP_INVALID" "parts.html is missing $pattern." "Move part create, detail, and edit modes into the management detail drawer."
        }
    }

    foreach ($pattern in @(
        'getStaffAnyPermissions',
        'applyStaffFallbackRoute',
        'activeRoute === "categories" ? "parts" : activeRoute'
    )) {
        if ($layoutScript -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_NAV_SCRIPT_INVALID" "workspace-layout.js is missing $pattern." "Preserve permission fallback and parent active-state behavior."
        }
    }

    foreach ($pattern in @(
        'if (isCollapsibleSidebarPage)',
        'document.body.classList.add("sidebar-collapsed")',
        'const isOpen = body.classList.contains("sidebar-open")',
        'backdrop.addEventListener("click", () => closeMenu())',
        'event.key === "Escape"',
        'closeMenu(false)'
    )) {
        if ($layoutScript -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_SIDEBAR_AUTOCLOSE_INVALID" "workspace-layout.js is missing $pattern." "Keep the sidebar closed by default and close it through backdrop or Escape."
        }
    }

    if ($parts -match '<aside class="side-panel"') {
        Add-Result "FAIL" "WORKSPACE_PART_DRAWER_INVALID" "parts.html still contains the legacy fixed side panel." "Move part create, detail, and edit modes into the management detail drawer."
    }

    foreach ($pattern in @(
        'const setDrawerOpen',
        'const openDrawer',
        'const closeDrawer',
        'event.key === "Escape"',
        'selectPart(part.partId, row)'
    )) {
        if ($partsScript -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_PART_DRAWER_SCRIPT_INVALID" "parts.js is missing $pattern." "Preserve part drawer open, close, selection, and keyboard behavior."
        }
    }

    if ($partsStyle -notmatch [regex]::Escape('.parts-content-grid')) {
        Add-Result "FAIL" "WORKSPACE_PART_DRAWER_STYLE_INVALID" "parts.css is missing the full-width list layout." "Keep the part list full width when the drawer is closed."
    }

    foreach ($pattern in @(
        '.management-detail-drawer',
        '.management-detail-drawer.is-open',
        '.management-detail-drawer-panel'
    )) {
        if ($componentsStyle -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_MANAGEMENT_DRAWER_STYLE_INVALID" "components.css is missing $pattern." "Use the shared stock-history drawer shell for management detail drawers."
        }
    }

    if ($layoutScript -match 'desktopSidebarQuery') {
        Add-Result "FAIL" "WORKSPACE_SIDEBAR_BREAKPOINT_BEHAVIOR" "Sidebar behavior still changes at the desktop breakpoint." "Use the same default-closed off-canvas behavior at every viewport width."
    }

    foreach ($pattern in @(
        '.has-collapsible-sidebar .workspace-layout',
        'position: fixed',
        '.has-collapsible-sidebar.sidebar-open .workspace-sidebar'
    )) {
        if ($layoutStyle -notmatch [regex]::Escape($pattern)) {
            Add-Result "FAIL" "WORKSPACE_SIDEBAR_BREAKPOINT_BEHAVIOR" "workspace.css is missing $pattern." "Use default-closed off-canvas behavior at every viewport width."
        }
    }

    if ($layoutStyle -notmatch [regex]::Escape('.has-collapsible-sidebar.sidebar-open .sidebar-backdrop')) {
        Add-Result "FAIL" "WORKSPACE_SIDEBAR_BACKDROP_STYLE_MISSING" "The open sidebar backdrop style is missing." "Keep the backdrop available at every viewport width."
    }

    Add-Result "INFO" "WORKSPACE_NAVIGATION" "Workspace navigation and default-closed sidebar checks completed."
}

function Test-FrontendCommonUtilityReuse {
    $jsRoot = Join-Path $ProjectRoot "src/main/resources/static/js"
    $managementPages = @(
        "partners.js",
        "categories.js",
        "parts.js",
        "users.js"
    )

    foreach ($fileName in $managementPages) {
        $filePath = Join-Path $jsRoot $fileName
        if (-not (Test-Path $filePath)) {
            continue
        }

        $content = Get-Content -Raw -Encoding UTF8 -Path $filePath
        $duplicated = New-Object System.Collections.Generic.List[string]

        if ($content -match 'const\s+getCompanyCode\s*=\s*\(\)\s*=>') {
            $duplicated.Add("companyCode extraction") | Out-Null
        }
        if ($content -match 'const\s+formatDate\s*=\s*\([^)]*\)\s*=>') {
            $duplicated.Add("date formatting") | Out-Null
        }
        if ($content -match 'const\s+numberText\s*=\s*\([^)]*\)\s*=>') {
            $duplicated.Add("number formatting") | Out-Null
        }
        if ($content -match 'window\.PcsUi\??\.toast') {
            $duplicated.Add("toast feedback") | Out-Null
        }
        if ($content -match 'querySelectorAll\("button, input') {
            $duplicated.Add("form saving state") | Out-Null
        }
        if ($content -match 'const\s+setEmptyMessage\s*=\s*\([^)]*\)\s*=>\s*\{') {
            $duplicated.Add("empty table row rendering") | Out-Null
        }

        if ($duplicated.Count -gt 0) {
            Add-Result "WARN" "FRONTEND_COMMON_UTILITY_REUSE" "$fileName appears to reimplement common frontend utilities: $($duplicated -join ', ')." "Use pcs-common.js helpers described in docs/ai/pcs-frontend-js-rules.md."
        }
    }
}

function Test-FullModeStructure {
    $requiredDomains = @(
        "auth",
        "company",
        "member",
        "partner",
        "category",
        "part",
        "stock",
        "inspection",
        "history",
        "dashboard"
    )
    $requiredDomainSubdirs = @(
        "api",
        "dto/request",
        "dto/response",
        "entity",
        "facade",
        "mapper",
        "service",
        "type",
        "validation"
    )

    Test-PathRequired "src/main/java/com/pcs/domain" "FULL_DOMAIN_ROOT" "Create domain root after feature structure is decided."
    Test-PathRequired "src/main/java/com/pcs/global" "FULL_GLOBAL_ROOT" "Create global root after API common structure is decided."
    Test-PathRequired "src/main/resources/mapper" "FULL_MAPPER_ROOT" "Create mapper XML root after MyBatis is introduced."

    foreach ($domain in $requiredDomains) {
        Test-PathRequired "src/main/java/com/pcs/domain/$domain" "FULL_DOMAIN_$($domain.ToUpper())" "Create $domain structure after feature spec is decided."

        foreach ($subdir in $requiredDomainSubdirs) {
            $ruleName = "FULL_DOMAIN_$($domain.ToUpper())_$($subdir.ToUpper().Replace('/', '_'))"
            Test-PathRequired "src/main/java/com/pcs/domain/$domain/$subdir" $ruleName "Keep the standard domain structure: api, dto/request, dto/response, entity, facade, mapper, service, type, validation."
        }
    }
}

function Normalize-HarnessPath {
    param(
        [string] $Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ""
    }

    $normalized = ($Path -replace "\\", "/").Trim()
    while ($normalized.StartsWith("./")) {
        $normalized = $normalized.Substring(2)
    }

    return $normalized
}

function Add-FeatureIfSupported {
    param(
        [System.Collections.Generic.List[string]] $Features,
        [string] $FeatureName
    )

    if ([string]::IsNullOrWhiteSpace($FeatureName)) {
        return
    }

    if ($SupportedFeatureNames -notcontains $FeatureName) {
        return
    }

    if ($Features -notcontains $FeatureName) {
        $Features.Add($FeatureName) | Out-Null
    }
}

function Get-FeatureDefinition {
    param(
        [string] $FeatureName
    )

    return $FeatureDefinitions | Where-Object { $_.name -eq $FeatureName } | Select-Object -First 1
}

function Resolve-FeaturesFromChangedPath {
    param(
        [string] $Path
    )

    $path = Normalize-HarnessPath $Path
    $resolved = New-Object System.Collections.Generic.List[string]

    foreach ($definition in $FeatureDefinitions) {
        foreach ($pattern in @($definition.pathPatterns)) {
            if ($path -match $pattern) {
                $resolved.Add([string] $definition.name) | Out-Null
                break
            }
        }
    }

    return $resolved.ToArray()
}

function Get-ChangedFilesForGate {
    if (-not [string]::IsNullOrWhiteSpace($ChangedFilesPath)) {
        $resolvedPath = $ChangedFilesPath
        if (-not [System.IO.Path]::IsPathRooted($resolvedPath)) {
            $resolvedPath = Join-Path $ProjectRoot $resolvedPath
        }

        if (Test-Path $resolvedPath) {
            return @(Get-Content -Path $resolvedPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        }

        Add-Result "WARN" "GATE_CHANGED_FILES_MISSING" "Changed files list was not found: $ChangedFilesPath" "Check the pre-push hook changed-file collection."
        return @()
    }

    Add-Result "INFO" "GATE_CHANGED_FILES_EMPTY" "No changed files list was provided." "Pass -ChangedFilesPath from pre-push hook when running gate mode."
    return @()
}

function Resolve-GateFeatures {
    $features = [System.Collections.Generic.List[string]]::new()

    if ($Feature -ne "none") {
        Add-FeatureIfSupported $features $Feature
        return $features.ToArray()
    }

    $changedFiles = Get-ChangedFilesForGate
    foreach ($changedFile in $changedFiles) {
        foreach ($resolvedFeature in @(Resolve-FeaturesFromChangedPath $changedFile)) {
            Add-FeatureIfSupported $features $resolvedFeature
        }
    }

    if ($features.Count -eq 0) {
        Add-Result "INFO" "GATE_FEATURES_NONE" "No supported feature-specific checks were inferred from changed files." "Common, build, and DB preflight checks still run."
    } else {
        Add-Result "INFO" "GATE_FEATURES" "Gate inferred feature checks: $($features -join ', ')." "Feature inference is based on changed file paths."
    }

    return $features.ToArray()
}

function Invoke-FeatureChecks {
    param(
        [string[]] $Features
    )

    foreach ($selectedFeature in $Features) {
        if ($selectedFeature -eq "company") {
            Test-CompanyFeature
        } elseif ($selectedFeature -eq "member") {
            Test-MemberFeature
        } elseif ($selectedFeature -eq "auth") {
            Test-AuthFeature
        } elseif ($selectedFeature -eq "partner") {
            Test-PartnerFeature
        } elseif ($selectedFeature -eq "category") {
            Test-CategoryFeature
        } elseif ($selectedFeature -eq "part") {
            Test-PartFeature
        } elseif ($selectedFeature -eq "stock") {
            Test-StockFeature
        } elseif ($selectedFeature -eq "inspection") {
            Test-InspectionFeature
        } elseif ($selectedFeature -eq "history") {
            Test-HistoryFeature
        } elseif ($selectedFeature -eq "dashboard") {
            Test-DashboardFeature
        }
    }
}

function Test-CompanyFeature {
    Test-PathRequired "docs/features/company.md" "COMPANY_FEATURE_DOC" "Keep docs/features/company.md as the company feature rule source."
    Test-PathRequired "src/main/java/com/pcs/domain/company/api/OwnerSignupApiController.java" "COMPANY_SIGNUP_API" "Expose POST /api/owners/signup in company/api."
    Test-PathRequired "src/main/java/com/pcs/domain/company/dto/request/OwnerSignupRequest.java" "COMPANY_SIGNUP_REQUEST" "Keep owner signup request DTO with validation."
    Test-PathRequired "src/main/java/com/pcs/domain/company/dto/response/OwnerSignupResponse.java" "COMPANY_SIGNUP_RESPONSE" "Keep owner signup response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/company/entity/Company.java" "COMPANY_ENTITY" "Keep tb_company row state in company/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/company/facade/CompanyFacade.java" "COMPANY_FACADE" "Keep company signup use case in company/facade."
    Test-PathRequired "src/main/java/com/pcs/domain/company/service/CompanyService.java" "COMPANY_SERVICE" "Keep company DB validation and persistence in company/service."
    Test-PathRequired "src/main/java/com/pcs/domain/company/mapper/CompanyMapper.java" "COMPANY_MAPPER" "Keep MyBatis mapper interface for company persistence."
    Test-PathRequired "src/main/resources/mapper/company/CompanyMapper.xml" "COMPANY_MAPPER_XML" "Keep MyBatis mapper XML for company persistence."

    $controller = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/company/api/OwnerSignupApiController.java"
    if (Test-Path $controller) {
        $controllerContent = Get-Content -Raw $controller
        foreach ($pattern in @("@RestController", '@RequestMapping\("/api/owners"\)', '@PostMapping\("/signup"\)', "@Valid", "ApiResultDto")) {
            if ($controllerContent -notmatch $pattern) {
                Add-Result "FAIL" "COMPANY_SIGNUP_CONTROLLER_$($pattern.ToUpper().Replace('\', '').Replace('/', '').Replace('"', '').Replace('@', ''))" "OwnerSignupApiController is missing required pattern: $pattern" "Keep signup API shape aligned with docs/features/company.md."
            }
        }
    }

    $request = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/company/dto/request/OwnerSignupRequest.java"
    if (Test-Path $request) {
        $requestContent = Get-Content -Raw $request
        foreach ($field in @("companyName", "companyCode", "ownerName", "ownerLoginId", "ownerPassword")) {
            if ($requestContent -notmatch $field) {
                Add-Result "FAIL" "COMPANY_REQUEST_$($field.ToUpper())" "OwnerSignupRequest is missing $field." "Keep required company + owner signup fields."
            }
        }
        foreach ($validation in @("@NotBlank", "@Size", "@Pattern")) {
            if ($requestContent -notmatch $validation) {
                Add-Result "FAIL" "COMPANY_REQUEST_VALIDATION_$($validation.Replace('@', '').ToUpper())" "OwnerSignupRequest is missing $validation." "Request DTO must own input validation."
            }
        }
    }

    $facade = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/company/facade/CompanyFacade.java"
    if (Test-Path $facade) {
        $facadeContent = Get-Content -Raw $facade
        if ($facadeContent -notmatch "@Transactional") {
            Add-Result "FAIL" "COMPANY_SIGNUP_TRANSACTION" "CompanyFacade.signupOwner is not transactional." "Company creation and OWNER creation must be one transaction."
        }
        foreach ($pattern in @("companyService.create", "memberService.createOwner", "COMPANY_CODE_DUPLICATED")) {
            if ($facadeContent -notmatch $pattern) {
                Add-Result "FAIL" "COMPANY_SIGNUP_FLOW_$($pattern.ToUpper().Replace('.', '_'))" "CompanyFacade is missing signup flow pattern: $pattern" "Keep company creation, owner creation, and duplicate companyCode handling."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/company/CompanyMapper.xml"
    if (Test-Path $mapperXml) {
        $mapperXmlContent = Get-Content -Raw $mapperXml
        if ($mapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.company\.mapper\.CompanyMapper"') {
            Add-Result "FAIL" "COMPANY_MAPPER_NAMESPACE" "CompanyMapper.xml namespace does not match CompanyMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($column in @("company_name", "company_code", "representative_email", "representative_phone", "business_registration_no")) {
            if ($mapperXmlContent -notmatch $column) {
                Add-Result "FAIL" "COMPANY_MAPPER_COLUMN_$($column.ToUpper())" "CompanyMapper.xml does not insert $column." "Insert required tb_company columns."
            }
        }
    }

    $schema = Join-Path $ProjectRoot "docs/sql/pcs-schema-ddl.sql"
    if (Test-Path $schema) {
        $schemaContent = Get-Content -Raw $schema
        foreach ($pattern in @("uk_company_code", "representative_email", "representative_phone", "business_registration_no")) {
            if ($schemaContent -notmatch $pattern) {
                Add-Result "FAIL" "COMPANY_SCHEMA_$($pattern.ToUpper())" "Schema is missing $pattern." "Keep company signup columns and unique companyCode in DDL."
            }
        }
    }

    Add-Result "INFO" "COMPANY_FEATURE" "Company feature checks completed."
}

function Test-MemberFeature {
    Test-PathRequired "docs/features/member.md" "MEMBER_FEATURE_DOC" "Keep docs/features/member.md as the member feature rule source."
    Test-PathRequired "src/main/java/com/pcs/domain/member/type/MemberRole.java" "MEMBER_ROLE_ENUM" "Keep OWNER, ADMIN, STAFF in MemberRole."
    Test-PathRequired "src/main/java/com/pcs/domain/member/type/PasswordStatus.java" "MEMBER_PASSWORD_STATUS_ENUM" "Keep TEMPORARY, ACTIVE in PasswordStatus."
    Test-PathRequired "src/main/java/com/pcs/domain/member/entity/Member.java" "MEMBER_ENTITY" "Keep tb_member row state in member/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/member/service/MemberService.java" "MEMBER_SERVICE" "Keep member creation and password hashing in member/service."
    Test-PathRequired "src/main/java/com/pcs/domain/member/mapper/MemberMapper.java" "MEMBER_MAPPER" "Keep MyBatis mapper interface for member persistence."
    Test-PathRequired "src/main/resources/mapper/member/MemberMapper.xml" "MEMBER_MAPPER_XML" "Keep MyBatis mapper XML for member persistence."

    $memberRole = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/member/type/MemberRole.java"
    if (Test-Path $memberRole) {
        $roleContent = Get-Content -Raw $memberRole
        foreach ($role in @("OWNER", "ADMIN", "STAFF")) {
            if ($roleContent -notmatch $role) {
                Add-Result "FAIL" "MEMBER_ROLE_$role" "MemberRole is missing $role." "Keep OWNER, ADMIN, STAFF."
            }
        }
    }

    $passwordStatus = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/member/type/PasswordStatus.java"
    if (Test-Path $passwordStatus) {
        $passwordStatusContent = Get-Content -Raw $passwordStatus
        foreach ($status in @("TEMPORARY", "ACTIVE")) {
            if ($passwordStatusContent -notmatch $status) {
                Add-Result "FAIL" "MEMBER_PASSWORD_STATUS_$status" "PasswordStatus is missing $status." "Keep TEMPORARY, ACTIVE."
            }
        }
    }

    $memberEntity = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/member/entity/Member.java"
    if (Test-Path $memberEntity) {
        $memberEntityContent = Get-Content -Raw $memberEntity
        if ($memberEntityContent -notmatch "ownerSlot") {
            Add-Result "FAIL" "MEMBER_OWNER_SLOT" "Member entity does not contain ownerSlot." "OWNER must use ownerSlot = 1 and other roles must use null."
        }
        if ($memberEntityContent -match "getPasswordHash") {
            Add-Result "FAIL" "MEMBER_PASSWORD_HASH_NOT_EXPOSED" "Member exposes passwordHash through a public getter." "Do not expose password hash outside persistence mapping."
        }
    }

    $memberService = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/member/service/MemberService.java"
    if (Test-Path $memberService) {
        $memberServiceContent = Get-Content -Raw $memberService
        if ($memberServiceContent -notmatch "PasswordEncoder" -or $memberServiceContent -notmatch "passwordEncoder\.encode") {
            Add-Result "FAIL" "MEMBER_PASSWORD_HASHED_IN_SERVICE" "MemberService does not hash raw passwords with PasswordEncoder." "Hash passwords in MemberService before saving."
        }
        if ($memberServiceContent -match "return owner;") {
            Add-Result "FAIL" "MEMBER_PASSWORD_HASH_RESULT_LEAK" "MemberService returns the Member entity after password hashing." "Return a result that does not contain passwordHash."
        }
    }

    $memberMapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/member/MemberMapper.xml"
    if (Test-Path $memberMapperXml) {
        $memberMapperXmlContent = Get-Content -Raw $memberMapperXml
        if ($memberMapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.member\.mapper\.MemberMapper"') {
            Add-Result "FAIL" "MEMBER_MAPPER_NAMESPACE" "MemberMapper.xml namespace does not match MemberMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($column in @("password_hash", "owner_slot", "password_status")) {
            if ($memberMapperXmlContent -notmatch $column) {
                Add-Result "FAIL" "MEMBER_MAPPER_COLUMN_$($column.ToUpper())" "MemberMapper.xml does not insert $column." "Insert required tb_member columns."
            }
        }
    }

    $schema = Join-Path $ProjectRoot "docs/sql/pcs-schema-ddl.sql"
    if (Test-Path $schema) {
        $schemaContent = Get-Content -Raw $schema
        foreach ($pattern in @("uk_member_company_login", "uk_member_company_owner", "chk_member_owner_slot")) {
            if ($schemaContent -notmatch $pattern) {
                Add-Result "FAIL" "MEMBER_SCHEMA_$($pattern.ToUpper())" "Schema is missing $pattern." "Keep member uniqueness and ownerSlot constraints in DDL."
            }
        }
    }

    $memberResponseRoot = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/member/dto/response"
    if (Test-Path $memberResponseRoot) {
        $passwordResponseMatches = Get-ChildItem -Path $memberResponseRoot -Recurse -File |
            Select-String -Pattern "passwordHash" -SimpleMatch -ErrorAction SilentlyContinue
        if ($passwordResponseMatches) {
            $locations = ($passwordResponseMatches | Select-Object -First 5 | ForEach-Object { "$($_.Path):$($_.LineNumber)" }) -join ", "
            Add-Result "FAIL" "MEMBER_RESPONSE_PASSWORD_HASH" "Member response DTO exposes passwordHash. Locations: $locations" "Never expose passwordHash in response DTOs."
        }
    }

    Add-Result "INFO" "MEMBER_FEATURE" "Member feature checks completed."
}

function Test-AuthFeature {
    Test-PathRequired "docs/features/auth.md" "AUTH_FEATURE_DOC" "Keep docs/features/auth.md as the auth feature rule source."
    Test-PathRequired "src/main/java/com/pcs/domain/auth/api/AuthApiController.java" "AUTH_API" "Expose login, refresh, logout, and me APIs in auth/api."
    Test-PathRequired "src/main/java/com/pcs/domain/auth/dto/request/WorkspaceLoginRequest.java" "AUTH_LOGIN_REQUEST" "Keep workspace login request DTO with validation."
    Test-PathRequired "src/main/java/com/pcs/domain/auth/dto/response/LoginResponse.java" "AUTH_LOGIN_RESPONSE" "Keep login response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/auth/facade/AuthFacade.java" "AUTH_FACADE" "Keep auth use case flow in auth/facade."
    Test-PathRequired "src/main/java/com/pcs/domain/auth/service/AuthService.java" "AUTH_SERVICE" "Keep auth DB validation and token persistence in auth/service."
    Test-PathRequired "src/main/java/com/pcs/domain/auth/mapper/AuthMapper.java" "AUTH_MAPPER" "Keep MyBatis mapper interface for auth persistence."
    Test-PathRequired "src/main/resources/mapper/auth/AuthMapper.xml" "AUTH_MAPPER_XML" "Keep MyBatis mapper XML for auth persistence."
    Test-PathRequired "src/main/java/com/pcs/global/jwt/JwtTokenProvider.java" "AUTH_JWT_PROVIDER" "Keep JWT creation and validation in global/jwt."
    Test-PathRequired "src/main/java/com/pcs/global/security/SecurityConfig.java" "AUTH_SECURITY_CONFIG" "Use Spring Security for API authentication boundaries."
    Test-PathRequired "src/main/java/com/pcs/global/security/JwtAuthenticationFilter.java" "AUTH_JWT_FILTER" "JWT Authorization header parsing must live in a Security filter."
    Test-PathRequired "src/main/java/com/pcs/global/security/JwtAuthenticationEntryPoint.java" "AUTH_ENTRY_POINT" "Security authentication failures must return ApiResultDto JSON."
    Test-PathRequired "src/main/java/com/pcs/global/security/JwtAccessDeniedHandler.java" "AUTH_ACCESS_DENIED_HANDLER" "Security authorization failures must return ApiResultDto JSON."
    Test-PathRequired "src/main/java/com/pcs/global/security/TemporaryPasswordAuthorizationFilter.java" "AUTH_TEMP_PASSWORD_FILTER" "Temporary passwords must be restricted to password-change endpoints."
    Test-PathRequired "src/main/java/com/pcs/global/security/PcsPrincipal.java" "AUTH_SECURITY_PRINCIPAL" "Authenticated user claims must be exposed through PcsPrincipal."
    Test-PathRequired "src/main/resources/static/js/pcs-api.js" "AUTH_STATIC_API_FETCH" "Keep common fetch wrapper for access token attachment and refresh retry."

    $controller = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/auth/api/AuthApiController.java"
    if (Test-Path $controller) {
        $controllerContent = Get-Content -Raw $controller
        foreach ($pattern in @("@RestController", '@RequestMapping\("/api"\)', '@PostMapping\("/workspaces/login"\)', '@PostMapping\("/auth/refresh"\)', '@PostMapping\("/auth/logout"\)', '@GetMapping\("/workspaces/\{companyCode\}/me"\)', "ApiResultDto", "ResponseCookie")) {
            if ($controllerContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_CONTROLLER_PATTERN" "AuthApiController is missing required pattern: $pattern" "Keep auth API shape aligned with docs/features/auth.md."
            }
        }
        if ($controllerContent -notmatch "@AuthenticationPrincipal" -or $controllerContent -notmatch "PcsPrincipal") {
            Add-Result "FAIL" "AUTH_CONTROLLER_PRINCIPAL" "AuthApiController does not use @AuthenticationPrincipal for authenticated user access." "Do not parse Authorization headers in Controller."
        }
        if ($controllerContent -match "AUTHORIZATION|RequestHeader") {
            Add-Result "FAIL" "AUTH_CONTROLLER_NO_AUTH_HEADER_PARSE" "AuthApiController directly reads Authorization headers." "Move JWT request authentication to global/security."
        }
        if ($controllerContent -match "Service|Mapper") {
            Add-Result "FAIL" "AUTH_CONTROLLER_FACADE_ONLY" "AuthApiController directly references Service or Mapper." "Controller must call Facade only."
        }
    }

    $facade = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/auth/facade/AuthFacade.java"
    if (Test-Path $facade) {
        $facadeContent = Get-Content -Raw $facade
        foreach ($pattern in @("@Transactional", "loginWorkspace", "refresh", "logout", "findMe")) {
            if ($facadeContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_FACADE_PATTERN" "AuthFacade is missing required pattern: $pattern" "Keep auth use cases transactional where DB state changes."
            }
        }
        if ($facadeContent -match "parseAccessToken|extractBearerToken|AUTHORIZATION|Authorization") {
            Add-Result "FAIL" "AUTH_FACADE_NO_AUTH_HEADER_PARSE" "AuthFacade parses JWT or Authorization header directly." "JWT request parsing must live in global/security."
        }
    }

    $service = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/auth/service/AuthService.java"
    if (Test-Path $service) {
        $serviceContent = Get-Content -Raw $service
        foreach ($pattern in @("PasswordEncoder", "matches", "insertLoginHistory", "recordLoginSuccess", "recordLoginFailure", "SHA-256", "hashRefreshToken", "AUTH_WORKSPACE_MISMATCH", "EXPIRED", "REUSE_DETECTED", "revokeRefreshTokenFamily")) {
            if ($serviceContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_SERVICE_PATTERN" "AuthService is missing required pattern: $pattern" "Keep password verification, login history, and refresh token hash handling."
            }
        }
    }

    $jwtProvider = Join-Path $ProjectRoot "src/main/java/com/pcs/global/jwt/JwtTokenProvider.java"
    if (Test-Path $jwtProvider) {
        $jwtContent = Get-Content -Raw $jwtProvider
        foreach ($pattern in @("HmacSHA256", "companyId", "companyCode", "memberId", "tokenType", "exp", "SecretKeySpec", "DEFAULT_LOCAL_SECRET", "allowDefaultSecret")) {
            if ($jwtContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_JWT_PATTERN" "JwtTokenProvider is missing required JWT claim/signing pattern: $pattern" "Access token must include workspace/member claims and HS256 signature."
            }
        }

        $usesConstantTimeComparison = $jwtContent -match "MessageDigest\.isEqual"
        $usesNimbusHs256Decoder = $jwtContent -match "NimbusJwtDecoder" -and
                $jwtContent -match "\.macAlgorithm\(MacAlgorithm\.HS256\)"
        if (-not $usesConstantTimeComparison -and -not $usesNimbusHs256Decoder) {
            Add-Result "FAIL" "AUTH_JWT_SIGNATURE_VALIDATION" "JwtTokenProvider is missing an approved JWT signature verifier." "Use MessageDigest.isEqual for manual verification or NimbusJwtDecoder configured with HS256."
        }
    }

    $securityConfig = Join-Path $ProjectRoot "src/main/java/com/pcs/global/security/SecurityConfig.java"
    if (Test-Path $securityConfig) {
        $securityContent = Get-Content -Raw $securityConfig
        foreach ($pattern in @("SecurityFilterChain", "SessionCreationPolicy.STATELESS", "/api/**", "authenticated", "permitAll", "addFilterBefore", "TemporaryPasswordAuthorizationFilter")) {
            if ($securityContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "AUTH_SECURITY_CONFIG_PATTERN" "SecurityConfig is missing required pattern: $pattern" "Keep stateless JWT Security configuration."
            }
        }
    }

    $jwtFilter = Join-Path $ProjectRoot "src/main/java/com/pcs/global/security/JwtAuthenticationFilter.java"
    if (Test-Path $jwtFilter) {
        $filterContent = Get-Content -Raw $jwtFilter
        foreach ($pattern in @("OncePerRequestFilter", "Authorization", "Bearer ", "parseAccessToken", "SecurityContextHolder", "UsernamePasswordAuthenticationToken")) {
            if ($filterContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "AUTH_JWT_FILTER_PATTERN" "JwtAuthenticationFilter is missing required pattern: $pattern" "JWT request authentication must be handled by the Security filter."
            }
        }
    }

    $application = Join-Path $ProjectRoot "src/main/resources/application.yaml"
    if (Test-Path $application) {
        $applicationContent = Get-Content -Raw $application
        if ($applicationContent -notmatch "access-token-expiration-minutes:\s*\$\{PCS_JWT_ACCESS_TOKEN_MINUTES:10\}") {
            Add-Result "FAIL" "AUTH_ACCESS_TOKEN_10_MINUTES" "Default access token expiration is not 10 minutes." "Keep pcs.jwt.access-token-expiration-minutes default as 10."
        }
        foreach ($pattern in @("allow-default-secret", "refresh-cookie-secure")) {
            if ($applicationContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_APPLICATION_SECURITY_SETTING" "application.yaml is missing required JWT security setting: $pattern" "Keep explicit JWT secret and refresh cookie security settings."
            }
        }
    }

    $apiJs = Join-Path $ProjectRoot "src/main/resources/static/js/pcs-api.js"
    if (Test-Path $apiJs) {
        $apiJsContent = Get-Content -Raw $apiJs
        foreach ($pattern in @("pcsAccessToken", "/api/auth/refresh", "Authorization", "Bearer", "retryOnAuthError", "localStorage")) {
            if ($apiJsContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "AUTH_STATIC_API_PATTERN" "pcs-api.js is missing required pattern: $pattern" "Common fetch must attach access token and retry once through refresh."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/auth/AuthMapper.xml"
    if (Test-Path $mapperXml) {
        $mapperXmlContent = Get-Content -Raw $mapperXml
        if ($mapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.auth\.mapper\.AuthMapper"') {
            Add-Result "FAIL" "AUTH_MAPPER_NAMESPACE" "AuthMapper.xml namespace does not match AuthMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($column in @("tb_auth_refresh_token", "refresh_token_hash", "token_family_id", "revoked_reason", "tb_auth_login_history", "login_result", "last_login_at", "login_failed_count", "locked_until_at", "revokeRefreshTokenFamily", "revokeMemberRefreshTokens")) {
            if ($mapperXmlContent -notmatch $column) {
                Add-Result "FAIL" "AUTH_MAPPER_COLUMN_$($column.ToUpper())" "AuthMapper.xml does not use $column." "Keep required auth DB columns in Mapper XML."
            }
        }
    }

    $schema = Join-Path $ProjectRoot "docs/sql/pcs-schema-ddl.sql"
    if (Test-Path $schema) {
        $schemaContent = Get-Content -Raw $schema
        foreach ($pattern in @("tb_auth_refresh_token", "tb_auth_login_history", "login_failed_count", "locked_until_at", "uk_auth_refresh_token_hash", "EXPIRED")) {
            if ($schemaContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_SCHEMA_$($pattern.ToUpper())" "Schema is missing $pattern." "Keep auth tables and member login tracking columns in DDL."
            }
        }
    }

    Add-Result "INFO" "AUTH_FEATURE" "Auth feature checks completed."
}

function Test-PartnerFeature {
    Test-PathRequired "docs/features/partner.md" "PARTNER_FEATURE_DOC" "Keep docs/features/partner.md as the partner feature rule source."
    Test-PathRequired "docs/features/partner-db.md" "PARTNER_DB_DOC" "Keep docs/features/partner-db.md as the partner DB rule source."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/api/PartnerApiController.java" "PARTNER_API" "Expose partner workspace APIs in partner/api."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/dto/response/SearchPartnerResponse.java" "PARTNER_SEARCH_RESPONSE" "Keep partner list response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/dto/response/SearchPartnerSummaryResponse.java" "PARTNER_SUMMARY_RESPONSE" "Keep partner list summary response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/facade/PartnerFacade.java" "PARTNER_FACADE" "Keep partner company-scope validation in partner/facade."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/service/PartnerService.java" "PARTNER_SERVICE" "Keep partner search rules in partner/service."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/mapper/PartnerMapper.java" "PARTNER_MAPPER" "Keep MyBatis mapper interface for partner persistence."
    Test-PathRequired "src/main/resources/mapper/partner/PartnerMapper.xml" "PARTNER_MAPPER_XML" "Keep MyBatis mapper XML for partner persistence."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/type/PartnerType.java" "PARTNER_TYPE_ENUM" "Keep partner type enum."
    Test-PathRequired "src/main/java/com/pcs/domain/partner/type/PartnerRole.java" "PARTNER_ROLE_ENUM" "Keep partner role enum."

    $controller = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/partner/api/PartnerApiController.java"
    if (Test-Path $controller) {
        $controllerContent = Get-Content -Raw $controller
        foreach ($pattern in @("@RestController", '@RequestMapping\("/api"\)', '@GetMapping\("/workspaces/\{companyCode\}/partners"\)', "@AuthenticationPrincipal", "ApiResultDto", "PageResultDto")) {
            if ($controllerContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_CONTROLLER_PATTERN" "PartnerApiController is missing required pattern: $pattern" "Keep partner list API aligned with docs/features/partner.md."
            }
        }
    }

    $workspaceAccessValidator = Join-Path $ProjectRoot "src/main/java/com/pcs/global/workspace/WorkspaceAccessValidator.java"
    $pageQuery = Join-Path $ProjectRoot "src/main/java/com/pcs/global/pagination/PageQuery.java"
    Test-PathRequired "src/main/java/com/pcs/global/workspace/WorkspaceAccessValidator.java" "PARTNER_WORKSPACE_VALIDATOR" "Keep shared workspace scope validation available to partner/facade."
    Test-PathRequired "src/main/java/com/pcs/global/pagination/PageQuery.java" "PARTNER_PAGE_QUERY" "Keep shared pagination normalization available to partner/service."

    $facade = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/partner/facade/PartnerFacade.java"
    if (Test-Path $facade) {
        $facadeContent = Get-Content -Raw $facade
        foreach ($pattern in @("WorkspaceAccessValidator", "validateAuthenticatedWorkspace", "checkedPrincipal.companyId")) {
            if ($facadeContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_SCOPE_PATTERN" "PartnerFacade is missing company-scope pattern: $pattern" "Validate URL companyCode against authenticated workspace and query by companyId."
            }
        }
    }

    if (Test-Path $workspaceAccessValidator) {
        $workspaceAccessValidatorContent = Get-Content -Raw $workspaceAccessValidator
        foreach ($pattern in @("principal.companyCode", "AUTH_WORKSPACE_MISMATCH", "COMPANY_INACTIVE")) {
            if ($workspaceAccessValidatorContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_WORKSPACE_VALIDATOR_PATTERN" "WorkspaceAccessValidator is missing required pattern: $pattern" "Keep shared workspace identity and active-company validation intact."
            }
        }
    }

    $service = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/partner/service/PartnerService.java"
    if (Test-Path $service) {
        $serviceContent = Get-Content -Raw $service
        foreach ($pattern in @("DEFAULT_SIZE", "PageQuery.of", "countPartners", "searchPartners", "summarizePartners", "validateCompanyActive")) {
            if ($serviceContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_SERVICE_PATTERN" "PartnerService is missing required search/paging pattern: $pattern" "Keep partner list paging, summary, and inactive-company guard."
            }
        }
    }

    if (Test-Path $pageQuery) {
        $pageQueryContent = Get-Content -Raw $pageQuery
        foreach ($pattern in @("MAX_SIZE", "Math.min")) {
            if ($pageQueryContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_PAGE_QUERY_PATTERN" "PageQuery is missing required pagination bound pattern: $pattern" "Keep shared page-size bounds intact."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/partner/PartnerMapper.xml"
    if (Test-Path $mapperXml) {
        $mapperXmlContent = Get-Content -Raw $mapperXml
        if ($mapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.partner\.mapper\.PartnerMapper"') {
            Add-Result "FAIL" "PARTNER_MAPPER_NAMESPACE" "PartnerMapper.xml namespace does not match PartnerMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($pattern in @("tb_trade_partner", "company_id", "partner_name", "partner_type", "partner_role", "LIMIT", "OFFSET", "COUNT(*)", "updated_at DESC", "partner_id DESC")) {
            if ($mapperXmlContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "PARTNER_MAPPER_PATTERN" "PartnerMapper.xml is missing required SQL pattern: $pattern" "Keep partner search SQL aligned with docs/features/partner-db.md."
            }
        }
    }

    Add-Result "INFO" "PARTNER_FEATURE" "Partner feature checks completed."
}

function Test-CategoryFeature {
    Test-PathRequired "docs/features/category.md" "CATEGORY_FEATURE_DOC" "Keep docs/features/category.md as the category feature rule source."
    Test-PathRequired "src/main/java/com/pcs/domain/category/api/CategoryApiController.java" "CATEGORY_API" "Expose category workspace APIs in category/api."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/request/CreateCategoryRequest.java" "CATEGORY_CREATE_REQUEST" "Keep category create request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/request/UpdateCategoryRequest.java" "CATEGORY_UPDATE_REQUEST" "Keep category update request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/request/CategorySpecDefinitionRequest.java" "CATEGORY_SPEC_DEFINITION_REQUEST" "Keep category spec definition request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/request/CategorySpecOptionRequest.java" "CATEGORY_SPEC_OPTION_REQUEST" "Keep category spec option request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/response/SearchCategoryResponse.java" "CATEGORY_SEARCH_RESPONSE" "Keep category list/detail response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/response/CategoryDetailResponse.java" "CATEGORY_DETAIL_RESPONSE" "Keep category detail response with specDefinitions."
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/response/CategorySpecDefinitionResponse.java" "CATEGORY_SPEC_DEFINITION_RESPONSE" "Keep category spec definition response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/entity/PartCategory.java" "CATEGORY_ENTITY" "Keep tb_part_category row state in category/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/category/entity/PartSpecDefinition.java" "CATEGORY_SPEC_DEFINITION_ENTITY" "Keep tb_part_spec_definition row state in category/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/category/entity/PartSpecOption.java" "CATEGORY_SPEC_OPTION_ENTITY" "Keep tb_part_spec_option row state in category/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/category/facade/CategoryFacade.java" "CATEGORY_FACADE" "Keep category company-scope validation in category/facade."
    Test-PathRequired "src/main/java/com/pcs/domain/category/service/CategoryService.java" "CATEGORY_SERVICE" "Keep category business rules in category/service."
    Test-PathRequired "src/main/java/com/pcs/domain/category/mapper/CategoryMapper.java" "CATEGORY_MAPPER" "Keep MyBatis mapper interface for category persistence."
    Test-PathRequired "src/main/java/com/pcs/domain/category/mapper/PartSpecMapper.java" "CATEGORY_PART_SPEC_MAPPER" "Keep shared part spec read mapper in category/mapper."
    Test-PathRequired "src/main/resources/mapper/category/CategoryMapper.xml" "CATEGORY_MAPPER_XML" "Keep MyBatis mapper XML for category persistence."
    Test-PathRequired "src/main/resources/mapper/category/PartSpecMapper.xml" "CATEGORY_PART_SPEC_MAPPER_XML" "Keep shared part spec read mapper XML in mapper/category."

    $controller = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/category/api/CategoryApiController.java"
    if (Test-Path $controller) {
        $controllerContent = Get-Content -Raw $controller
        foreach ($pattern in @("@RestController", '@RequestMapping\("/api"\)', '@GetMapping\("/workspaces/\{companyCode\}/categories"\)', '@PostMapping\("/workspaces/\{companyCode\}/categories"\)', '@PatchMapping\("/workspaces/\{companyCode\}/categories/\{categoryId\}"\)', '@DeleteMapping\("/workspaces/\{companyCode\}/categories/\{categoryId\}"\)', "@AuthenticationPrincipal", "ApiResultDto", "PageResultDto")) {
            if ($controllerContent -notmatch $pattern) {
                Add-Result "FAIL" "CATEGORY_CONTROLLER_PATTERN" "CategoryApiController is missing required pattern: $pattern" "Keep category CRUD API aligned with docs/features/category.md."
            }
        }
    }

    $service = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/category/service/CategoryService.java"
    if (Test-Path $service) {
        $serviceContent = Get-Content -Raw $service
        foreach ($pattern in @("PageQuery", "TextNormalizer", "validateCompanyActive", "countCategories", "searchCategories", "existsByName", "createSpecDefinitions", "replaceSpecDefinitions", "insertSpecDefinition", "insertSpecOption", "partSpecMapper.findDefinitionsByCategory", "partSpecMapper.findOptionsByDefinitionIds", "countPartsByCategory", "deleteSpecValuesByCategory", "deleteById", "CATEGORY_IN_USE")) {
            if ($serviceContent -notmatch $pattern) {
                Add-Result "FAIL" "CATEGORY_SERVICE_PATTERN" "CategoryService is missing required rule pattern: $pattern" "Keep category paging, duplicate-name, delete guard, and inactive-company checks."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/category/CategoryMapper.xml"
    if (Test-Path $mapperXml) {
        $mapperXmlContent = Get-Content -Raw $mapperXml
        if ($mapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.category\.mapper\.CategoryMapper"') {
            Add-Result "FAIL" "CATEGORY_MAPPER_NAMESPACE" "CategoryMapper.xml namespace does not match CategoryMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($pattern in @("tb_part_category", "tb_part_spec_definition", "tb_part_spec_option", "tb_part_spec_value", "tb_pc_part", "part_count", "LIMIT", "OFFSET", "COUNT(*)", "updated_at DESC", "category_id DESC", "DELETE FROM tb_part_spec_value", "DELETE FROM tb_part_category")) {
            if ($mapperXmlContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "CATEGORY_MAPPER_PATTERN" "CategoryMapper.xml is missing required SQL pattern: $pattern" "Keep category search, partCount, and delete SQL aligned with docs/features/category.md."
            }
        }
    }

    $specMapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/category/PartSpecMapper.xml"
    if (Test-Path $specMapperXml) {
        $specMapperXmlContent = Get-Content -Raw $specMapperXml
        if ($specMapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.category\.mapper\.PartSpecMapper"') {
            Add-Result "FAIL" "CATEGORY_PART_SPEC_MAPPER_NAMESPACE" "PartSpecMapper.xml namespace does not match PartSpecMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($pattern in @("tb_part_spec_definition", "tb_part_spec_option", "findDefinitionsByCategory", "findOptionsByDefinitionIds", "active = TRUE", "ORDER BY sort_order ASC")) {
            if ($specMapperXmlContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "CATEGORY_PART_SPEC_MAPPER_PATTERN" "PartSpecMapper.xml is missing required SQL pattern: $pattern" "Keep shared spec definition/option read SQL in PartSpecMapper.xml."
            }
        }
    }

    Add-Result "INFO" "CATEGORY_FEATURE" "Category feature checks completed."
}

function Test-PartFeature {
    Test-PathRequired "docs/features/part.md" "PART_FEATURE_DOC" "Keep docs/features/part.md as the part feature rule source."
    Test-PathRequired "docs/features/part-db.md" "PART_DB_DOC" "Keep docs/features/part-db.md as the part DB rule source."
    Test-PathRequired "src/main/java/com/pcs/domain/part/api/PartApiController.java" "PART_API" "Expose part workspace APIs in part/api."
    Test-PathRequired "src/main/java/com/pcs/domain/part/dto/request/CreatePartRequest.java" "PART_CREATE_REQUEST" "Keep part create request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/part/dto/request/UpdatePartRequest.java" "PART_UPDATE_REQUEST" "Keep part update request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/part/dto/request/PartSpecValueRequest.java" "PART_SPEC_VALUE_REQUEST" "Keep part spec value request DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/part/dto/response/SearchPartResponse.java" "PART_SEARCH_RESPONSE" "Keep part list response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/part/dto/response/PartDetailResponse.java" "PART_DETAIL_RESPONSE" "Keep part detail response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/part/dto/response/PartSpecValueResponse.java" "PART_SPEC_VALUE_RESPONSE" "Keep part spec value response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/part/entity/PcPart.java" "PART_ENTITY" "Keep tb_pc_part row state in part/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/part/entity/PartSpecValue.java" "PART_SPEC_VALUE_ENTITY" "Keep tb_part_spec_value row state in part/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/part/facade/PartFacade.java" "PART_FACADE" "Keep part company-scope validation in part/facade."
    Test-PathRequired "src/main/java/com/pcs/domain/part/service/PartService.java" "PART_SERVICE" "Keep part business rules in part/service."
    Test-PathRequired "src/main/java/com/pcs/domain/part/mapper/PartMapper.java" "PART_MAPPER" "Keep MyBatis mapper interface for part persistence."
    Test-PathRequired "src/main/resources/mapper/part/PartMapper.xml" "PART_MAPPER_XML" "Keep MyBatis mapper XML for part persistence."

    $controller = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/part/api/PartApiController.java"
    if (Test-Path $controller) {
        $controllerContent = Get-Content -Raw $controller
        foreach ($pattern in @("@RestController", '@RequestMapping\("/api"\)', '@GetMapping\("/workspaces/\{companyCode\}/parts"\)', '@PostMapping\("/workspaces/\{companyCode\}/parts"\)', '@PatchMapping\("/workspaces/\{companyCode\}/parts/\{partId\}"\)', "@AuthenticationPrincipal", "ApiResultDto", "PageResultDto")) {
            if ($controllerContent -notmatch $pattern) {
                Add-Result "FAIL" "PART_CONTROLLER_PATTERN" "PartApiController is missing required pattern: $pattern" "Keep part CRUD/list API aligned with docs/features/part.md."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/part/PartMapper.xml"
    if (Test-Path $mapperXml) {
        $mapperXmlContent = Get-Content -Raw $mapperXml
        if ($mapperXmlContent -notmatch 'namespace="com\.pcs\.domain\.part\.mapper\.PartMapper"') {
            Add-Result "FAIL" "PART_MAPPER_NAMESPACE" "PartMapper.xml namespace does not match PartMapper FQCN." "Match XML namespace to mapper interface."
        }
        foreach ($pattern in @("tb_pc_part", "tb_part_spec_value", "tb_part_category", "LIMIT", "OFFSET", "COUNT(*)", "ORDER BY p.part_id DESC")) {
            if ($mapperXmlContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "PART_MAPPER_PATTERN" "PartMapper.xml is missing required SQL pattern: $pattern" "Keep part search and spec value SQL aligned with docs/features/part.md."
            }
        }
    }

    Add-Result "INFO" "PART_FEATURE" "Part feature checks completed."
}

function Test-StockFeature {
    foreach ($required in @(
        @("docs/features/stock.md", "STOCK_FEATURE_DOC"),
        @("docs/features/stock-db.md", "STOCK_DB_DOC"),
        @("src/main/java/com/pcs/domain/stock/api/StockApiController.java", "STOCK_API"),
        @("src/main/java/com/pcs/domain/stock/facade/StockFacade.java", "STOCK_FACADE"),
        @("src/main/java/com/pcs/domain/stock/service/StockService.java", "STOCK_SERVICE"),
        @("src/main/java/com/pcs/domain/stock/mapper/StockMapper.java", "STOCK_MAPPER"),
        @("src/main/resources/mapper/stock/StockMapper.xml", "STOCK_MAPPER_XML"),
        @("src/test/java/com/pcs/domain/stock/service/StockServiceTest.java", "STOCK_SERVICE_TEST"),
        @("src/test/java/com/pcs/domain/stock/facade/StockFacadeTest.java", "STOCK_FACADE_TEST")
    )) {
        Test-PathRequired $required[0] $required[1] "Keep the stock implementation aligned with docs/features/stock.md."
    }

    $controller = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/stock/api/StockApiController.java"
    if (Test-Path $controller) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $controller
        foreach ($pattern in @("@RestController", "@AuthenticationPrincipal", "ApiResultDto", "PageResultDto", "/stock/documents/inbounds", "/stock/documents/outbounds", "/stock/documents/{documentId}/cancel")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "STOCK_CONTROLLER_PATTERN" "StockApiController is missing required pattern: $pattern" "Keep inbound, outbound, cancel, and list APIs in StockApiController."
            }
        }
    }

    $facade = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/stock/facade/StockFacade.java"
    if (Test-Path $facade) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $facade
        foreach ($pattern in @("@Transactional", "createInboundDocument", "createOutboundDocument", "cancelDocument")) {
            if ($content -notmatch $pattern) {
                Add-Result "FAIL" "STOCK_TRANSACTION_PATTERN" "StockFacade is missing required transaction pattern: $pattern" "Keep stock-changing use cases transactional in StockFacade."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/stock/StockMapper.xml"
    if (Test-Path $mapperXml) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $mapperXml
        foreach ($pattern in @("tb_stock_document", "tb_stock_movement", "tb_stock_movement_unit", "tb_pc_part_unit", "tb_part_stock", "company_id", "LIMIT", "OFFSET", "FOR UPDATE")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "STOCK_MAPPER_PATTERN" "StockMapper.xml is missing required SQL pattern: $pattern" "Keep stock persistence, company scope, paging, and locking rules."
            }
        }
    }

    Add-Result "INFO" "STOCK_FEATURE" "Stock feature checks completed."
}

function Test-InspectionFeature {
    foreach ($required in @(
        @("docs/features/inspection.md", "INSPECTION_FEATURE_DOC"),
        @("docs/features/inspection-history.md", "INSPECTION_HISTORY_DOC"),
        @("docs/features/inspection-template.md", "INSPECTION_TEMPLATE_DOC"),
        @("docs/features/inspection-db.md", "INSPECTION_DB_DOC"),
        @("src/main/java/com/pcs/domain/inspection/api/InspectionApiController.java", "INSPECTION_API"),
        @("src/main/java/com/pcs/domain/inspection/api/InspectionTemplateApiController.java", "INSPECTION_TEMPLATE_API"),
        @("src/main/java/com/pcs/domain/inspection/facade/InspectionFacade.java", "INSPECTION_FACADE"),
        @("src/main/java/com/pcs/domain/inspection/service/InspectionService.java", "INSPECTION_SERVICE"),
        @("src/main/java/com/pcs/domain/inspection/mapper/InspectionMapper.java", "INSPECTION_MAPPER"),
        @("src/main/resources/mapper/inspection/InspectionMapper.xml", "INSPECTION_MAPPER_XML"),
        @("src/test/java/com/pcs/domain/inspection/service/InspectionServiceTest.java", "INSPECTION_SERVICE_TEST"),
        @("src/test/java/com/pcs/domain/inspection/service/InspectionTemplateServiceTest.java", "INSPECTION_TEMPLATE_SERVICE_TEST")
    )) {
        Test-PathRequired $required[0] $required[1] "Keep the inspection implementation aligned with its feature documents."
    }

    $facade = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/inspection/facade/InspectionFacade.java"
    if (Test-Path $facade) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $facade
        foreach ($pattern in @("@Transactional", "createBulkInitialInspection", "createCorrection", "createReinspection")) {
            if ($content -notmatch $pattern) {
                Add-Result "FAIL" "INSPECTION_TRANSACTION_PATTERN" "InspectionFacade is missing required transaction pattern: $pattern" "Keep inspection creation and revision use cases transactional."
            }
        }
    }

    $mapperXml = Join-Path $ProjectRoot "src/main/resources/mapper/inspection/InspectionMapper.xml"
    if (Test-Path $mapperXml) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $mapperXml
        foreach ($pattern in @("tb_inspection", "tb_inspection_item_result", "tb_part_status_history", "tb_pc_part_unit", "company_id", "LIMIT", "OFFSET")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "INSPECTION_MAPPER_PATTERN" "InspectionMapper.xml is missing required SQL pattern: $pattern" "Keep inspection history, status history, company scope, and paging rules."
            }
        }
    }

    Add-Result "INFO" "INSPECTION_FEATURE" "Inspection feature checks completed."
}

function Test-HistoryFeature {
    foreach ($required in @(
        @("docs/features/history.md", "HISTORY_FEATURE_DOC"),
        @("src/main/resources/static/history-stock.html", "HISTORY_STOCK_HTML"),
        @("src/main/resources/static/js/history-stock.js", "HISTORY_STOCK_JS"),
        @("src/main/resources/static/history-inspection.html", "HISTORY_INSPECTION_HTML"),
        @("src/main/resources/static/js/history-inspection.js", "HISTORY_INSPECTION_JS")
    )) {
        Test-PathRequired $required[0] $required[1] "Keep history pages connected to stock and inspection APIs."
    }

    $stockJs = Join-Path $ProjectRoot "src/main/resources/static/js/history-stock.js"
    if (Test-Path $stockJs) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $stockJs
        foreach ($pattern in @("window.PcsApi", "window.PcsPagination", "/stock/documents", "buildParams")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "HISTORY_STOCK_CLIENT_PATTERN" "history-stock.js is missing required pattern: $pattern" "Use the authenticated stock document API with server-side filters."
            }
        }
    }

    $inspectionJs = Join-Path $ProjectRoot "src/main/resources/static/js/history-inspection.js"
    if (Test-Path $inspectionJs) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $inspectionJs
        foreach ($pattern in @("window.PcsApi", "window.PcsPagination", "/inspections", "buildParams")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "HISTORY_INSPECTION_CLIENT_PATTERN" "history-inspection.js is missing required pattern: $pattern" "Use the authenticated inspection history API with server-side filters."
            }
        }
    }

    Add-Result "INFO" "HISTORY_FEATURE" "History feature checks completed."
}

function Test-DashboardFeature {
    Test-PathRequired "docs/features/dashboard.md" "DASHBOARD_FEATURE_DOC" "Keep dashboard behavior documented."
    Test-PathRequired "src/main/resources/static/dashboard.html" "DASHBOARD_HTML" "Keep the workspace dashboard page."
    Test-PathRequired "src/main/resources/static/js/dashboard.js" "DASHBOARD_JS" "Keep dashboard client behavior in dashboard.js."

    $dashboardJs = Join-Path $ProjectRoot "src/main/resources/static/js/dashboard.js"
    if (Test-Path $dashboardJs) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $dashboardJs
        foreach ($pattern in @("window.PcsApi", "/me")) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "DASHBOARD_CLIENT_PATTERN" "dashboard.js is missing required pattern: $pattern" "Keep authenticated workspace context loading on the dashboard."
            }
        }
    }

    Add-Result "INFO" "DASHBOARD_FEATURE" "Dashboard feature checks completed."
}

function Get-DbConfig {
    $dbUrl = $env:DB_URL
    $dbUser = $env:DB_USER
    $dbPassword = $env:DB_PASSWORD

    if ([string]::IsNullOrWhiteSpace($dbUrl)) {
        $dbUrl = "jdbc:mariadb://localhost:3306/pcs_db"
    }
    if ([string]::IsNullOrWhiteSpace($dbUser)) {
        $dbUser = "localuser"
    }
    if ([string]::IsNullOrWhiteSpace($dbPassword)) {
        $dbPassword = "pcs123#"
    }

    [pscustomobject]@{
        Url = $dbUrl
        User = $dbUser
        Password = $dbPassword
    }
}

function Find-MariaDbDriverJar {
    $roots = New-Object System.Collections.Generic.List[string]

    if (-not [string]::IsNullOrWhiteSpace($env:GRADLE_USER_HOME)) {
        $roots.Add((Join-Path $env:GRADLE_USER_HOME "caches/modules-2/files-2.1/org.mariadb.jdbc/mariadb-java-client")) | Out-Null
    }
    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $roots.Add((Join-Path $env:USERPROFILE ".gradle/caches/modules-2/files-2.1/org.mariadb.jdbc/mariadb-java-client")) | Out-Null
    }
    if (-not [string]::IsNullOrWhiteSpace($env:HOME)) {
        $roots.Add((Join-Path $env:HOME ".gradle/caches/modules-2/files-2.1/org.mariadb.jdbc/mariadb-java-client")) | Out-Null
    }

    foreach ($root in ($roots | Select-Object -Unique)) {
        if (-not (Test-Path $root)) {
            continue
        }

        $jar = Get-ChildItem -Path $root -Recurse -Filter "mariadb-java-client-*.jar" -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notmatch "-sources\.jar$" -and $_.Name -notmatch "-javadoc\.jar$" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($jar) {
            return $jar.FullName
        }
    }

    return $null
}

function Resolve-MariaDbDriverJar {
    $driverJar = Find-MariaDbDriverJar
    if ($driverJar) {
        return $driverJar
    }

    $gradlew = Get-GradleWrapperPath
    if (-not $gradlew) {
        Add-Result "FAIL" "DB_DRIVER_GRADLEW_MISSING" "MariaDB JDBC driver was not found and Gradle Wrapper is missing." "Restore Gradle Wrapper or download dependencies."
        return $null
    }

    Push-Location $ProjectRoot
    try {
        Invoke-GradleWrapper @("--quiet", "dependencies", "--configuration", "runtimeClasspath") | Out-Null
    } catch {
        Add-Result "FAIL" "DB_DRIVER_RESOLVE_FAILED" "Failed to resolve runtimeClasspath dependencies for MariaDB JDBC driver." "Run Gradle dependency resolution after configuring JDK 17."
        return $null
    } finally {
        Pop-Location
    }

    $driverJar = Find-MariaDbDriverJar
    if (-not $driverJar) {
        Add-Result "FAIL" "DB_DRIVER_NOT_FOUND" "MariaDB JDBC driver jar was not found in Gradle cache." "Run Gradle dependencies --configuration runtimeClasspath or check build.gradle runtimeOnly dependency."
        return $null
    }

    return $driverJar
}

function New-HarnessDbCheckerSource {
    param(
        [string] $SourcePath
    )

    $source = @'
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.HashSet;
import java.util.Set;

public class PcsHarnessDbCheck {
    private static final String PASSWORD_HASH = "$2a$10$pcsHarnessPasswordHashValueForDbCheckOnly1234567890";
    private static Connection connection;
    private static String schemaName;
    private static boolean failed;
    private static String runSuffix;

    public static void main(String[] args) throws Exception {
        if (args.length < 4) {
            fail("DB_CHECK_ARGUMENTS", "Usage: PcsHarnessDbCheck <url> <user> <password> <checks>");
            System.exit(1);
        }

        String url = args[0];
        String user = args[1];
        String password = args[2];
        String[] checks = args[3].split(",");
        runSuffix = Long.toString(System.currentTimeMillis());

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connection = DriverManager.getConnection(url, user, password);
            schemaName = queryString("SELECT DATABASE()");

            for (String check : checks) {
                String normalized = check.trim();
                if (normalized.isEmpty()) {
                    continue;
                }
                if ("checkdb".equals(normalized)) {
                    checkCommonSchema();
                } else if ("company".equals(normalized)) {
                    checkCompanyDb();
                } else if ("member".equals(normalized)) {
                    checkMemberDb();
                } else if ("auth".equals(normalized)) {
                    checkAuthDb();
                } else if ("partner".equals(normalized)) {
                    checkPartnerDb();
                } else if ("category".equals(normalized)) {
                    checkCategoryDb();
                } else if ("part".equals(normalized)) {
                    checkPartDb();
                } else if ("stock".equals(normalized)) {
                    checkStockDb();
                } else if ("inspection".equals(normalized)) {
                    checkInspectionDb();
                } else {
                    fail("DB_CHECK_UNKNOWN", "Unknown DB check: " + normalized);
                }
            }
        } catch (SQLException exception) {
            fail("DB_CONNECTION", exception.getMessage());
        } finally {
            if (connection != null) {
                connection.close();
            }
        }

        System.exit(failed ? 1 : 0);
    }

    private static void checkCommonSchema() throws SQLException {
        pass("DB_CONNECTED", "Connected to database: " + schemaName);

        String[] requiredTables = {
            "tb_company",
            "tb_member",
            "tb_auth_refresh_token",
            "tb_auth_login_history",
            "tb_trade_partner",
            "tb_part_category",
            "tb_pc_part",
            "tb_pc_part_unit",
            "tb_part_stock",
            "tb_stock_document",
            "tb_stock_movement",
            "tb_stock_movement_unit",
            "tb_inspection_template",
            "tb_inspection_template_item",
            "tb_inspection_template_item_option",
            "tb_inspection",
            "tb_part_status_history",
            "tb_inspection_item_result"
        };

        for (String table : requiredTables) {
            requireTable(table);
        }

        String[] companyOwnedTables = {
            "tb_member",
            "tb_auth_refresh_token",
            "tb_auth_login_history",
            "tb_trade_partner",
            "tb_part_category",
            "tb_pc_part",
            "tb_pc_part_unit",
            "tb_part_stock",
            "tb_stock_document",
            "tb_stock_movement",
            "tb_inspection_template",
            "tb_inspection",
            "tb_part_status_history"
        };

        for (String table : companyOwnedTables) {
            requireColumn(table, "company_id");
        }

        requireColumn("tb_company", "company_code");
        requireColumn("tb_company", "representative_email");
        requireColumn("tb_company", "representative_phone");
        requireColumn("tb_company", "business_registration_no");
        requireColumn("tb_member", "owner_slot");
        requireColumn("tb_member", "password_hash");
        requireColumn("tb_member", "password_status");
        requireColumn("tb_member", "login_failed_count");
        requireColumn("tb_member", "locked_until_at");
        requireColumn("tb_member", "last_login_ip");
        requireColumn("tb_member", "last_login_user_agent");
        requireColumn("tb_auth_refresh_token", "refresh_token_hash");
        requireColumn("tb_auth_refresh_token", "token_family_id");
        requireColumn("tb_auth_refresh_token", "expires_at");
        requireColumn("tb_auth_login_history", "login_result");

        requireConstraint("tb_company", "uk_company_code");
        requireConstraint("tb_company", "uk_company_business_registration_no");
        requireConstraint("tb_member", "uk_member_company_login");
        requireConstraint("tb_member", "uk_member_company_owner");
        requireConstraint("tb_member", "chk_member_owner_slot");
        requireConstraint("tb_auth_refresh_token", "uk_auth_refresh_token_hash");

        pass("CHECKDB_SCHEMA", "Common DB preflight checks completed.");
    }

    private static void checkCompanyDb() throws SQLException {
        requireColumn("tb_company", "company_name");
        requireColumn("tb_company", "company_code");
        requireColumn("tb_company", "business_registration_no");
        requireColumn("tb_member", "company_id");
        requireColumn("tb_member", "role");
        requireColumn("tb_member", "owner_slot");

        boolean originalAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            String companyCode = "pcs-harness-company-" + runSuffix;
            String businessNo = "999-" + runSuffix.substring(Math.max(0, runSuffix.length() - 2)) + "-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5));
            long companyId = insertCompany("PCS Harness Company", companyCode, "harness-" + runSuffix + "@pcs.local", "010-0000-0000", businessNo);
            insertMember(companyId, "owner-" + runSuffix, "Harness Owner", "OWNER", Integer.valueOf(1), "ACTIVE");

            int ownerCount = queryInt(
                "SELECT COUNT(*) FROM tb_member WHERE company_id = ? AND role = 'OWNER' AND owner_slot = 1",
                companyId
            );
            if (ownerCount == 1) {
                pass("COMPANY_OWNER_CREATED", "Company and OWNER member are saved with the same company_id.");
            } else {
                fail("COMPANY_OWNER_CREATED", "Expected exactly one OWNER member but found " + ownerCount + ".");
            }

            expectSqlFailure("COMPANY_CODE_UNIQUE", new SqlAction() {
                public void run() throws SQLException {
                    insertCompany("PCS Harness Duplicate Code", companyCode, "dup-code-" + runSuffix + "@pcs.local", "010-0000-0001", "888-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
                }
            });

            expectSqlFailure("COMPANY_BUSINESS_NO_UNIQUE", new SqlAction() {
                public void run() throws SQLException {
                    insertCompany("PCS Harness Duplicate Business No", companyCode + "-other", "dup-business-" + runSuffix + "@pcs.local", "010-0000-0002", businessNo);
                }
            });

            pass("COMPANY_DB_ROLLBACK_SCOPE", "Company DB scenario was executed inside a rollback transaction.");
        } finally {
            connection.rollback();
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    private static void checkMemberDb() throws SQLException {
        requireColumn("tb_member", "company_id");
        requireColumn("tb_member", "login_id");
        requireColumn("tb_member", "password_hash");
        requireColumn("tb_member", "role");
        requireColumn("tb_member", "owner_slot");
        requireColumn("tb_member", "password_status");
        requireConstraint("tb_member", "uk_member_company_login");
        requireConstraint("tb_member", "uk_member_company_owner");
        requireConstraint("tb_member", "chk_member_owner_slot");

        boolean originalAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            long companyId = insertCompany("PCS Harness Member Company", "pcs-harness-member-" + runSuffix, null, null, "777-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            insertMember(companyId, "owner-" + runSuffix, "Harness Owner", "OWNER", Integer.valueOf(1), "ACTIVE");
            insertMember(companyId, "admin-" + runSuffix, "Harness Admin", "ADMIN", null, "TEMPORARY");
            insertMember(companyId, "staff-" + runSuffix, "Harness Staff", "STAFF", null, "TEMPORARY");

            int memberCount = queryInt("SELECT COUNT(*) FROM tb_member WHERE company_id = ?", companyId);
            if (memberCount == 3) {
                pass("MEMBER_ROLE_STORAGE", "OWNER, ADMIN, STAFF rows are saved with expected owner_slot usage.");
            } else {
                fail("MEMBER_ROLE_STORAGE", "Expected 3 member rows but found " + memberCount + ".");
            }

            expectSqlFailure("MEMBER_LOGIN_ID_UNIQUE", new SqlAction() {
                public void run() throws SQLException {
                    insertMember(companyId, "admin-" + runSuffix, "Duplicate Login", "ADMIN", null, "TEMPORARY");
                }
            });

            expectSqlFailure("MEMBER_SINGLE_OWNER", new SqlAction() {
                public void run() throws SQLException {
                    insertMember(companyId, "owner2-" + runSuffix, "Second Owner", "OWNER", Integer.valueOf(1), "ACTIVE");
                }
            });

            expectSqlFailure("MEMBER_OWNER_SLOT_REQUIRED", new SqlAction() {
                public void run() throws SQLException {
                    insertMember(companyId, "owner-null-" + runSuffix, "Owner Null Slot", "OWNER", null, "ACTIVE");
                }
            });

            long otherCompanyId = insertCompany("PCS Harness Invalid Member Company", "pcs-harness-member-invalid-" + runSuffix, null, null, "666-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            expectSqlFailure("MEMBER_NON_OWNER_SLOT_BLOCKED", new SqlAction() {
                public void run() throws SQLException {
                    insertMember(otherCompanyId, "admin-slot-" + runSuffix, "Admin Slot", "ADMIN", Integer.valueOf(1), "TEMPORARY");
                }
            });

            pass("MEMBER_DB_ROLLBACK_SCOPE", "Member DB scenario was executed inside a rollback transaction.");
        } finally {
            connection.rollback();
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    private static void checkAuthDb() throws SQLException {
        requireColumn("tb_member", "last_login_at");
        requireColumn("tb_member", "login_failed_count");
        requireColumn("tb_member", "locked_until_at");
        requireColumn("tb_member", "last_login_ip");
        requireColumn("tb_member", "last_login_user_agent");
        requireColumn("tb_auth_refresh_token", "company_id");
        requireColumn("tb_auth_refresh_token", "member_id");
        requireColumn("tb_auth_refresh_token", "refresh_token_hash");
        requireColumn("tb_auth_refresh_token", "token_family_id");
        requireColumn("tb_auth_refresh_token", "expires_at");
        requireColumn("tb_auth_refresh_token", "revoked_at");
        requireColumn("tb_auth_refresh_token", "revoked_reason");
        requireColumn("tb_auth_refresh_token", "replaced_by_token_id");
        requireEnumValue("tb_auth_refresh_token", "revoked_reason", "EXPIRED");
        requireEnumValue("tb_auth_refresh_token", "revoked_reason", "REUSE_DETECTED");
        requireEnumValue("tb_auth_refresh_token", "revoked_reason", "ADMIN_REVOKED");
        requireColumn("tb_auth_login_history", "company_code_snapshot");
        requireColumn("tb_auth_login_history", "login_id_snapshot");
        requireColumn("tb_auth_login_history", "login_result");
        requireConstraint("tb_auth_refresh_token", "uk_auth_refresh_token_hash");

        boolean originalAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            long companyId = insertCompany("PCS Harness Auth Company", "pcs-harness-auth-" + runSuffix, null, null, "555-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            long memberId = insertMember(companyId, "auth-" + runSuffix, "Harness Auth", "ADMIN", null, "ACTIVE");
            updateMemberLoginSuccess(companyId, memberId);
            String refreshHash = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
            long tokenId = insertRefreshToken(companyId, memberId, refreshHash, "11111111-1111-1111-1111-111111111111");
            insertLoginHistory(companyId, memberId, "pcs-harness-auth-" + runSuffix, "auth-" + runSuffix, "SUCCESS");

            int loginUpdated = queryInt(
                "SELECT COUNT(*) FROM tb_member WHERE company_id = ? AND member_id = ? AND last_login_at IS NOT NULL AND login_failed_count = 0",
                companyId,
                memberId
            );
            if (loginUpdated == 1) {
                pass("AUTH_MEMBER_LOGIN_STATE", "Member login state columns can be updated.");
            } else {
                fail("AUTH_MEMBER_LOGIN_STATE", "Member login state columns were not updated as expected.");
            }

            int refreshCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE company_id = ? AND member_id = ? AND token_id = ? AND revoked_at IS NULL",
                companyId,
                memberId,
                tokenId
            );
            if (refreshCount == 1) {
                pass("AUTH_REFRESH_TOKEN_SAVED", "Refresh token hash row is saved.");
            } else {
                fail("AUTH_REFRESH_TOKEN_SAVED", "Refresh token hash row was not saved.");
            }

            String rotatedHash = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
            long replacementTokenId = insertRefreshToken(companyId, memberId, rotatedHash, "11111111-1111-1111-1111-111111111111");
            rotateRefreshToken(tokenId, replacementTokenId);
            int rotatedCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE token_id = ? AND revoked_at IS NOT NULL AND revoked_reason = 'ROTATED' AND replaced_by_token_id = ?",
                tokenId,
                replacementTokenId
            );
            if (rotatedCount == 1) {
                pass("AUTH_REFRESH_TOKEN_ROTATED", "Refresh token rotation state can be recorded.");
            } else {
                fail("AUTH_REFRESH_TOKEN_ROTATED", "Refresh token rotation state was not recorded as expected.");
            }

            String expiredHash = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc";
            long expiredTokenId = insertRefreshToken(companyId, memberId, expiredHash, "33333333-3333-3333-3333-333333333333");
            expireRefreshToken(expiredTokenId);
            int expiredCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE token_id = ? AND revoked_at IS NOT NULL AND revoked_reason = 'EXPIRED'",
                expiredTokenId
            );
            if (expiredCount == 1) {
                pass("AUTH_REFRESH_TOKEN_EXPIRED", "Expired refresh token state can be recorded.");
            } else {
                fail("AUTH_REFRESH_TOKEN_EXPIRED", "Expired refresh token state was not recorded as expected.");
            }

            String reuseHash = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd";
            long reuseTokenId = insertRefreshToken(companyId, memberId, reuseHash, "44444444-4444-4444-4444-444444444444");
            revokeRefreshTokenFamily(companyId, memberId, "44444444-4444-4444-4444-444444444444");
            int reuseCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE token_id = ? AND revoked_at IS NOT NULL AND revoked_reason = 'REUSE_DETECTED'",
                reuseTokenId
            );
            if (reuseCount == 1) {
                pass("AUTH_REFRESH_TOKEN_REUSE_DETECTED", "Refresh token family reuse-detected state can be recorded.");
            } else {
                fail("AUTH_REFRESH_TOKEN_REUSE_DETECTED", "Refresh token family reuse-detected state was not recorded as expected.");
            }

            String adminRevokedHash = "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
            insertRefreshToken(companyId, memberId, adminRevokedHash, "55555555-5555-5555-5555-555555555555");
            revokeMemberRefreshTokens(companyId, memberId);
            int activeTokenCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE company_id = ? AND member_id = ? AND revoked_at IS NULL",
                companyId,
                memberId
            );
            int adminRevokedCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_refresh_token WHERE company_id = ? AND member_id = ? AND revoked_reason = 'ADMIN_REVOKED'",
                companyId,
                memberId
            );
            if (activeTokenCount == 0 && adminRevokedCount >= 2) {
                pass("AUTH_MEMBER_REFRESH_TOKENS_REVOKED", "Password reset can revoke all active member refresh tokens.");
            } else {
                fail("AUTH_MEMBER_REFRESH_TOKENS_REVOKED", "Expected all active member refresh tokens to be ADMIN_REVOKED.");
            }

            expectSqlFailure("AUTH_REFRESH_TOKEN_HASH_UNIQUE", new SqlAction() {
                public void run() throws SQLException {
                    insertRefreshToken(companyId, memberId, refreshHash, "22222222-2222-2222-2222-222222222222");
                }
            });

            int historyCount = queryInt(
                "SELECT COUNT(*) FROM tb_auth_login_history WHERE company_id = ? AND member_id = ? AND login_result = 'SUCCESS'",
                companyId,
                memberId
            );
            if (historyCount == 1) {
                pass("AUTH_LOGIN_HISTORY_SAVED", "Login history row is saved.");
            } else {
                fail("AUTH_LOGIN_HISTORY_SAVED", "Expected one login history row but found " + historyCount + ".");
            }

            pass("AUTH_DB_ROLLBACK_SCOPE", "Auth DB scenario was executed inside a rollback transaction.");
        } finally {
            connection.rollback();
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    private static void checkPartnerDb() throws SQLException {
        requireColumn("tb_trade_partner", "company_id");
        requireColumn("tb_trade_partner", "partner_name");
        requireColumn("tb_trade_partner", "partner_type");
        requireColumn("tb_trade_partner", "partner_role");
        requireColumn("tb_trade_partner", "phone");
        requireColumn("tb_trade_partner", "email");
        requireColumn("tb_trade_partner", "address");
        requireColumn("tb_trade_partner", "memo");
        requireColumn("tb_trade_partner", "active");
        requireColumn("tb_trade_partner", "updated_at");
        requireEnumValue("tb_trade_partner", "partner_type", "PC_CAFE");
        requireEnumValue("tb_trade_partner", "partner_type", "PERSON");
        requireEnumValue("tb_trade_partner", "partner_type", "COMPANY");
        requireEnumValue("tb_trade_partner", "partner_type", "ETC");
        requireEnumValue("tb_trade_partner", "partner_role", "SUPPLIER");
        requireEnumValue("tb_trade_partner", "partner_role", "CUSTOMER");
        requireEnumValue("tb_trade_partner", "partner_role", "BOTH");
        requireConstraint("tb_trade_partner", "uk_trade_partner_company_name");
        requireConstraint("tb_trade_partner", "uk_trade_partner_company_partner_id");

        boolean originalAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            long companyId = insertCompany("PCS Harness Partner Company", "pcs-harness-partner-" + runSuffix, null, null, "444-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            long otherCompanyId = insertCompany("PCS Harness Partner Other Company", "pcs-harness-partner-other-" + runSuffix, null, null, "443-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            insertTradePartner(companyId, "Harness Partner Supplier " + runSuffix, "PC_CAFE", "SUPPLIER", "010-1000-0000", "supplier-" + runSuffix + "@pcs.local", "Seoul", "Supplier memo", true);
            insertTradePartner(companyId, "Harness Partner Customer " + runSuffix, "COMPANY", "CUSTOMER", null, null, null, null, false);
            insertTradePartner(otherCompanyId, "Harness Partner Supplier " + runSuffix, "PERSON", "BOTH", null, null, null, null, true);

            int companyScopedCount = queryInt(
                "SELECT COUNT(*) FROM tb_trade_partner WHERE company_id = ? AND partner_name LIKE ?",
                companyId,
                "Harness Partner%"
            );
            if (companyScopedCount == 2) {
                pass("PARTNER_COMPANY_SCOPE", "Partner rows are scoped by company_id.");
            } else {
                fail("PARTNER_COMPANY_SCOPE", "Expected 2 partner rows in company scope but found " + companyScopedCount + ".");
            }

            int supplierSelectableCount = queryInt(
                "SELECT COUNT(*) FROM tb_trade_partner WHERE company_id = ? AND partner_role IN ('SUPPLIER', 'BOTH')",
                companyId
            );
            if (supplierSelectableCount == 1) {
                pass("PARTNER_SUPPLIER_ROLE_SEARCH", "Supplier search can include supplier-capable partners.");
            } else {
                fail("PARTNER_SUPPLIER_ROLE_SEARCH", "Expected 1 supplier-capable partner but found " + supplierSelectableCount + ".");
            }

            int activeSelectableCount = queryInt(
                "SELECT COUNT(*) FROM tb_trade_partner WHERE company_id = ? AND active = TRUE",
                companyId
            );
            if (activeSelectableCount == 1) {
                pass("PARTNER_ACTIVE_FILTER", "Active partner filter can exclude inactive partners.");
            } else {
                fail("PARTNER_ACTIVE_FILTER", "Expected 1 active partner but found " + activeSelectableCount + ".");
            }

            expectSqlFailure("PARTNER_NAME_UNIQUE_PER_COMPANY", new SqlAction() {
                public void run() throws SQLException {
                    insertTradePartner(companyId, "Harness Partner Supplier " + runSuffix, "ETC", "SUPPLIER", null, null, null, null, true);
                }
            });

            pass("PARTNER_DB_ROLLBACK_SCOPE", "Partner DB scenario was executed inside a rollback transaction.");
        } finally {
            connection.rollback();
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    private static void checkCategoryDb() throws SQLException {
        requireColumn("tb_part_category", "company_id");
        requireColumn("tb_part_category", "category_name");
        requireColumn("tb_part_category", "description");
        requireColumn("tb_part_category", "created_by");
        requireColumn("tb_part_category", "created_at");
        requireColumn("tb_part_category", "updated_at");
        requireColumnAbsent("tb_part_category", "active");
        requireConstraint("tb_part_category", "uk_part_category_company_name");
        requireConstraint("tb_part_category", "uk_part_category_company_category_id");
        requireColumn("tb_part_spec_definition", "company_id");
        requireColumn("tb_part_spec_definition", "category_id");
        requireColumn("tb_part_spec_definition", "spec_key");
        requireColumn("tb_part_spec_definition", "spec_name");
        requireColumn("tb_part_spec_definition", "input_type");
        requireColumn("tb_part_spec_definition", "unit");
        requireColumn("tb_part_spec_definition", "required");
        requireColumn("tb_part_spec_definition", "searchable");
        requireColumn("tb_part_spec_definition", "sort_order");
        requireColumn("tb_part_spec_definition", "active");
        requireColumn("tb_part_spec_definition", "created_by");
        requireColumn("tb_part_spec_definition", "created_at");
        requireColumn("tb_part_spec_definition", "updated_at");
        requireConstraint("tb_part_spec_definition", "uk_part_spec_definition_company_category_key");
        requireColumn("tb_part_spec_option", "spec_definition_id");
        requireColumn("tb_part_spec_option", "option_label");
        requireColumn("tb_part_spec_option", "option_value");
        requireColumn("tb_part_spec_option", "sort_order");
        requireColumn("tb_part_spec_option", "active");
        requireConstraint("tb_part_spec_option", "uk_part_spec_option_definition_value");
        requireColumn("tb_part_spec_value", "company_id");
        requireColumn("tb_part_spec_value", "part_id");
        requireColumn("tb_part_spec_value", "spec_definition_id");
        requireColumn("tb_part_spec_value", "value_text");
        requireColumn("tb_part_spec_value", "value_number");
        requireColumn("tb_part_spec_value", "value_boolean");
        requireColumn("tb_part_spec_value", "selected_option_id");
        requireColumn("tb_part_spec_value", "selected_option_label_snapshot");
        requireColumn("tb_part_spec_value", "selected_option_value_snapshot");
        requireConstraint("tb_part_spec_value", "uk_part_spec_value_part_definition");

        boolean originalAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            long companyId = insertCompany("PCS Harness Category Company", "pcs-harness-category-" + runSuffix, null, null, "445-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            long otherCompanyId = insertCompany("PCS Harness Category Other Company", "pcs-harness-category-other-" + runSuffix, null, null, "446-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            long memberId = insertMember(companyId, "category-owner-" + runSuffix, "Category Owner", "OWNER", 1, "ACTIVE");

            long categoryId = insertCategory(companyId, "Harness Category " + runSuffix, "Category memo", memberId);
            insertCategory(otherCompanyId, "Harness Category " + runSuffix, "Other company category", null);
            long specDefinitionId = insertPartSpecDefinition(companyId, categoryId, "memory_type", "Memory Type", "SELECT", null, true, true, 0, memberId);
            insertPartSpecOption(specDefinitionId, "DDR4", "DDR4", 0);
            insertPartSpecOption(specDefinitionId, "DDR5", "DDR5", 1);

            int companyScopedCount = queryInt(
                "SELECT COUNT(*) FROM tb_part_category WHERE company_id = ? AND category_name LIKE ?",
                companyId,
                "Harness Category%"
            );
            if (companyScopedCount == 1) {
                pass("CATEGORY_COMPANY_SCOPE", "Category rows are scoped by company_id.");
            } else {
                fail("CATEGORY_COMPANY_SCOPE", "Expected 1 category row in company scope but found " + companyScopedCount + ".");
            }

            expectSqlFailure("CATEGORY_NAME_UNIQUE_PER_COMPANY", new SqlAction() {
                public void run() throws SQLException {
                    insertCategory(companyId, "Harness Category " + runSuffix, "Duplicate category", null);
                }
            });

            int specDefinitionCount = queryInt(
                "SELECT COUNT(*) FROM tb_part_spec_definition WHERE company_id = ? AND category_id = ? AND active = TRUE",
                companyId,
                categoryId
            );
            if (specDefinitionCount == 1) {
                pass("CATEGORY_SPEC_DEFINITION_INSERT", "Category spec definition can be inserted and scoped by category.");
            } else {
                fail("CATEGORY_SPEC_DEFINITION_INSERT", "Expected 1 category spec definition but found " + specDefinitionCount + ".");
            }

            int specOptionCount = queryInt(
                "SELECT COUNT(*) FROM tb_part_spec_option WHERE spec_definition_id = ? AND active = TRUE",
                specDefinitionId
            );
            if (specOptionCount == 2) {
                pass("CATEGORY_SPEC_OPTION_INSERT", "Select spec options can be inserted for a spec definition.");
            } else {
                fail("CATEGORY_SPEC_OPTION_INSERT", "Expected 2 spec options but found " + specOptionCount + ".");
            }

            expectSqlFailure("CATEGORY_SPEC_KEY_UNIQUE_PER_CATEGORY", new SqlAction() {
                public void run() throws SQLException {
                    insertPartSpecDefinition(companyId, categoryId, "memory_type", "Duplicate Spec", "TEXT", null, false, false, 1, memberId);
                }
            });

            expectSqlFailure("CATEGORY_SPEC_OPTION_UNIQUE_PER_DEFINITION", new SqlAction() {
                public void run() throws SQLException {
                    insertPartSpecOption(specDefinitionId, "DDR4 Duplicate", "DDR4", 2);
                }
            });

            deletePartSpecValuesByCategory(companyId, categoryId);
            deletePartSpecOptionsByCategory(companyId, categoryId);
            deletePartSpecDefinitionsByCategory(companyId, categoryId);
            int deleted = deleteCategory(companyId, categoryId);
            int remaining = queryInt(
                "SELECT COUNT(*) FROM tb_part_category WHERE company_id = ? AND category_id = ?",
                companyId,
                categoryId
            );
            if (deleted == 1 && remaining == 0) {
                pass("CATEGORY_DELETE_UNUSED", "Unused category row can be deleted.");
            } else {
                fail("CATEGORY_DELETE_UNUSED", "Unused category row was not deleted as expected.");
            }

            pass("CATEGORY_DB_ROLLBACK_SCOPE", "Category DB scenario was executed inside a rollback transaction.");
        } finally {
            connection.rollback();
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    private static void checkPartDb() throws SQLException {
        String[][] requiredColumns = {
            {"tb_pc_part", "company_id"},
            {"tb_pc_part", "category_id"},
            {"tb_pc_part", "part_name"},
            {"tb_pc_part", "model_name"},
            {"tb_pc_part", "manufacturer"},
            {"tb_pc_part", "part_code"},
            {"tb_pc_part", "safe_quantity"},
            {"tb_part_spec_value", "company_id"},
            {"tb_part_spec_value", "part_id"},
            {"tb_part_spec_value", "spec_definition_id"},
            {"tb_part_spec_value", "value_text"},
            {"tb_part_spec_value", "value_number"},
            {"tb_part_spec_value", "value_boolean"},
            {"tb_part_spec_value", "selected_option_id"},
            {"tb_pc_part_unit", "internal_serial_no"},
            {"tb_pc_part_unit", "unit_status"},
            {"tb_pc_part_unit", "inspection_status"},
            {"tb_pc_part_unit", "sales_status"},
            {"tb_part_stock", "company_id"},
            {"tb_part_stock", "part_id"},
            {"tb_part_stock", "quantity"}
        };
        for (String[] column : requiredColumns) {
            requireColumn(column[0], column[1]);
        }
        requireConstraint("tb_pc_part", "uk_pc_part_company_code");
        requireConstraint("tb_pc_part", "chk_pc_part_safe_quantity");
        requireConstraint("tb_part_spec_value", "uk_part_spec_value_part_definition");
        requireConstraint("tb_pc_part_unit", "uk_pc_part_unit_internal_serial");
        requireConstraint("tb_part_stock", "uk_part_stock_company_part");
        requireConstraint("tb_part_stock", "chk_part_stock_quantity");
        pass("PART_DB_STRUCTURE", "Part master, specification, unit, and stock structures are valid.");
    }

    private static void checkStockDb() throws SQLException {
        String[][] requiredColumns = {
            {"tb_stock_document", "company_id"},
            {"tb_stock_document", "partner_id"},
            {"tb_stock_document", "document_no"},
            {"tb_stock_document", "document_type"},
            {"tb_stock_document", "document_status"},
            {"tb_stock_document", "processed_by"},
            {"tb_stock_movement", "company_id"},
            {"tb_stock_movement", "document_id"},
            {"tb_stock_movement", "part_id"},
            {"tb_stock_movement", "movement_type"},
            {"tb_stock_movement", "movement_status"},
            {"tb_stock_movement", "canceled_movement_id"},
            {"tb_stock_movement", "quantity"},
            {"tb_stock_movement", "before_quantity"},
            {"tb_stock_movement", "after_quantity"},
            {"tb_stock_movement_unit", "movement_id"},
            {"tb_stock_movement_unit", "unit_id"},
            {"tb_stock_movement_unit", "before_unit_status"},
            {"tb_stock_movement_unit", "after_unit_status"}
        };
        for (String[] column : requiredColumns) {
            requireColumn(column[0], column[1]);
        }
        requireEnumValue("tb_stock_document", "document_type", "INBOUND");
        requireEnumValue("tb_stock_document", "document_type", "OUTBOUND");
        requireEnumValue("tb_stock_document", "document_status", "CANCELED");
        requireEnumValue("tb_stock_movement", "movement_type", "INBOUND_CANCEL");
        requireEnumValue("tb_stock_movement", "movement_type", "OUTBOUND_CANCEL");
        requireConstraint("tb_stock_document", "uk_stock_document_document_no");
        requireConstraint("tb_stock_document", "uk_stock_document_company_document_id");
        requireConstraint("tb_stock_movement", "uk_stock_movement_company_movement_id");
        requireConstraint("tb_stock_movement", "chk_stock_movement_quantity");
        requireConstraint("tb_stock_movement", "chk_stock_movement_before_after");
        requireConstraint("tb_stock_movement_unit", "uk_stock_movement_unit");
        pass("STOCK_DB_STRUCTURE", "Stock document, movement, unit, and quantity constraints are valid.");
    }

    private static void checkInspectionDb() throws SQLException {
        String[][] requiredColumns = {
            {"tb_inspection_template", "company_id"},
            {"tb_inspection_template", "category_id"},
            {"tb_inspection_template", "template_name"},
            {"tb_inspection_template", "version"},
            {"tb_inspection_template_item", "template_id"},
            {"tb_inspection_template_item", "input_type"},
            {"tb_inspection_template_item", "sort_order"},
            {"tb_inspection_template_item_option", "item_id"},
            {"tb_inspection_template_item_option", "option_value"},
            {"tb_inspection", "company_id"},
            {"tb_inspection", "unit_id"},
            {"tb_inspection", "inspection_type"},
            {"tb_inspection", "original_inspection_id"},
            {"tb_inspection", "sales_status"},
            {"tb_inspection", "result"},
            {"tb_inspection", "grade"},
            {"tb_inspection_item_result", "item_name_snapshot"},
            {"tb_inspection_item_result", "selected_option_id"},
            {"tb_inspection_item_result", "selected_option_label_snapshot"},
            {"tb_part_status_history", "company_id"},
            {"tb_part_status_history", "unit_id"},
            {"tb_part_status_history", "changed_by"}
        };
        for (String[] column : requiredColumns) {
            requireColumn(column[0], column[1]);
        }
        requireEnumValue("tb_inspection", "inspection_type", "INITIAL");
        requireEnumValue("tb_inspection", "inspection_type", "CORRECTION");
        requireEnumValue("tb_inspection", "inspection_type", "REINSPECTION");
        requireEnumValue("tb_inspection", "grade", "DEFECTIVE");
        requireConstraint("tb_inspection_template", "uk_inspection_template_version");
        requireConstraint("tb_inspection_template", "chk_inspection_template_version");
        requireConstraint("tb_inspection_template_item", "chk_inspection_template_item_sort_order");
        requireConstraint("tb_inspection_template_item_option", "uk_inspection_template_item_option_value");
        requireConstraint("tb_inspection", "uk_inspection_company_inspection_id");
        requireConstraint("tb_inspection", "chk_inspection_original");
        pass("INSPECTION_DB_STRUCTURE", "Inspection, template, result, and status-history structures are valid.");
    }

    private static long insertCompany(String name, String code, String email, String phone, String businessNo) throws SQLException {
        String sql = "INSERT INTO tb_company (company_name, company_code, representative_email, representative_phone, business_registration_no, active) VALUES (?, ?, ?, ?, ?, TRUE)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, name);
            statement.setString(2, code);
            setNullableString(statement, 3, email);
            setNullableString(statement, 4, phone);
            setNullableString(statement, 5, businessNo);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated company_id.");
    }

    private static long insertMember(long companyId, String loginId, String name, String role, Integer ownerSlot, String passwordStatus) throws SQLException {
        String sql = "INSERT INTO tb_member (company_id, login_id, password_hash, name, role, owner_slot, password_status, temp_password_expires_at, active, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, TRUE, NULL)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, companyId);
            statement.setString(2, loginId);
            statement.setString(3, PASSWORD_HASH);
            statement.setString(4, name);
            statement.setString(5, role);
            if (ownerSlot == null) {
                statement.setNull(6, Types.TINYINT);
            } else {
                statement.setInt(6, ownerSlot.intValue());
            }
            statement.setString(7, passwordStatus);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated member_id.");
    }

    private static void updateMemberLoginSuccess(long companyId, long memberId) throws SQLException {
        String sql = "UPDATE tb_member SET last_login_at = CURRENT_TIMESTAMP(6), login_failed_count = 0, locked_until_at = NULL, last_login_ip = '127.0.0.1', last_login_user_agent = 'pcs-harness' WHERE company_id = ? AND member_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, memberId);
            statement.executeUpdate();
        }
    }

    private static long insertRefreshToken(long companyId, long memberId, String refreshTokenHash, String tokenFamilyId) throws SQLException {
        String sql = "INSERT INTO tb_auth_refresh_token (company_id, member_id, refresh_token_hash, token_family_id, expires_at, created_ip, created_user_agent) VALUES (?, ?, ?, ?, DATE_ADD(CURRENT_TIMESTAMP(6), INTERVAL 14 DAY), '127.0.0.1', 'pcs-harness')";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, companyId);
            statement.setLong(2, memberId);
            statement.setString(3, refreshTokenHash);
            statement.setString(4, tokenFamilyId);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated token_id.");
    }

    private static long insertTradePartner(long companyId, String partnerName, String partnerType, String partnerRole, String phone, String email, String address, String memo, boolean active) throws SQLException {
        String sql = "INSERT INTO tb_trade_partner (company_id, partner_name, partner_type, partner_role, phone, email, address, memo, active, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, companyId);
            statement.setString(2, partnerName);
            statement.setString(3, partnerType);
            statement.setString(4, partnerRole);
            setNullableString(statement, 5, phone);
            setNullableString(statement, 6, email);
            setNullableString(statement, 7, address);
            setNullableString(statement, 8, memo);
            statement.setBoolean(9, active);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated partner_id.");
    }

    private static long insertCategory(long companyId, String categoryName, String description, Long createdBy) throws SQLException {
        String sql = "INSERT INTO tb_part_category (company_id, category_name, description, created_by) VALUES (?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, companyId);
            statement.setString(2, categoryName);
            setNullableString(statement, 3, description);
            if (createdBy == null) {
                statement.setNull(4, Types.BIGINT);
            } else {
                statement.setLong(4, createdBy.longValue());
            }
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated category_id.");
    }

    private static long insertPartSpecDefinition(long companyId, long categoryId, String specKey, String specName, String inputType, String unit, boolean required, boolean searchable, int sortOrder, Long createdBy) throws SQLException {
        String sql = "INSERT INTO tb_part_spec_definition (company_id, category_id, spec_key, spec_name, input_type, unit, required, searchable, sort_order, active, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, companyId);
            statement.setLong(2, categoryId);
            statement.setString(3, specKey);
            statement.setString(4, specName);
            statement.setString(5, inputType);
            setNullableString(statement, 6, unit);
            statement.setBoolean(7, required);
            statement.setBoolean(8, searchable);
            statement.setInt(9, sortOrder);
            if (createdBy == null) {
                statement.setNull(10, Types.BIGINT);
            } else {
                statement.setLong(10, createdBy.longValue());
            }
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated spec_definition_id.");
    }

    private static long insertPartSpecOption(long specDefinitionId, String optionLabel, String optionValue, int sortOrder) throws SQLException {
        String sql = "INSERT INTO tb_part_spec_option (spec_definition_id, option_label, option_value, sort_order, active) VALUES (?, ?, ?, ?, TRUE)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, specDefinitionId);
            statement.setString(2, optionLabel);
            statement.setString(3, optionValue);
            statement.setInt(4, sortOrder);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Failed to read generated option_id.");
    }

    private static int deletePartSpecValuesByCategory(long companyId, long categoryId) throws SQLException {
        String sql = "DELETE FROM tb_part_spec_value WHERE company_id = ? AND spec_definition_id IN (SELECT spec_definition_id FROM tb_part_spec_definition WHERE company_id = ? AND category_id = ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, companyId);
            statement.setLong(3, categoryId);
            return statement.executeUpdate();
        }
    }

    private static int deletePartSpecOptionsByCategory(long companyId, long categoryId) throws SQLException {
        String sql = "DELETE FROM tb_part_spec_option WHERE spec_definition_id IN (SELECT spec_definition_id FROM tb_part_spec_definition WHERE company_id = ? AND category_id = ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, categoryId);
            return statement.executeUpdate();
        }
    }

    private static int deletePartSpecDefinitionsByCategory(long companyId, long categoryId) throws SQLException {
        String sql = "DELETE FROM tb_part_spec_definition WHERE company_id = ? AND category_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, categoryId);
            return statement.executeUpdate();
        }
    }

    private static int deleteCategory(long companyId, long categoryId) throws SQLException {
        String sql = "DELETE FROM tb_part_category WHERE company_id = ? AND category_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, categoryId);
            return statement.executeUpdate();
        }
    }

    private static void rotateRefreshToken(long tokenId, long replacedByTokenId) throws SQLException {
        String sql = "UPDATE tb_auth_refresh_token SET revoked_at = CURRENT_TIMESTAMP(6), revoked_reason = 'ROTATED', replaced_by_token_id = ? WHERE token_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, replacedByTokenId);
            statement.setLong(2, tokenId);
            statement.executeUpdate();
        }
    }

    private static void expireRefreshToken(long tokenId) throws SQLException {
        String sql = "UPDATE tb_auth_refresh_token SET revoked_at = CURRENT_TIMESTAMP(6), revoked_reason = 'EXPIRED' WHERE token_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, tokenId);
            statement.executeUpdate();
        }
    }

    private static void revokeRefreshTokenFamily(long companyId, long memberId, String tokenFamilyId) throws SQLException {
        String sql = "UPDATE tb_auth_refresh_token SET revoked_at = CURRENT_TIMESTAMP(6), revoked_reason = 'REUSE_DETECTED' WHERE company_id = ? AND member_id = ? AND token_family_id = ? AND revoked_at IS NULL";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, memberId);
            statement.setString(3, tokenFamilyId);
            statement.executeUpdate();
        }
    }

    private static void revokeMemberRefreshTokens(long companyId, long memberId) throws SQLException {
        String sql = "UPDATE tb_auth_refresh_token SET revoked_at = CURRENT_TIMESTAMP(6), revoked_reason = 'ADMIN_REVOKED' WHERE company_id = ? AND member_id = ? AND revoked_at IS NULL";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, memberId);
            statement.executeUpdate();
        }
    }

    private static void insertLoginHistory(long companyId, long memberId, String companyCode, String loginId, String loginResult) throws SQLException {
        String sql = "INSERT INTO tb_auth_login_history (company_id, member_id, company_code_snapshot, login_id_snapshot, login_result, login_ip, user_agent) VALUES (?, ?, ?, ?, ?, '127.0.0.1', 'pcs-harness')";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, companyId);
            statement.setLong(2, memberId);
            statement.setString(3, companyCode);
            statement.setString(4, loginId);
            statement.setString(5, loginResult);
            statement.executeUpdate();
        }
    }

    private static void requireTable(String tableName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?";
        if (queryInt(sql, tableName) == 1) {
            pass("DB_TABLE_" + tableName.toUpperCase(), tableName + " exists.");
        } else {
            fail("DB_TABLE_" + tableName.toUpperCase(), tableName + " is missing.");
        }
    }

    private static void requireColumn(String tableName, String columnName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?";
        if (queryInt(sql, tableName, columnName) == 1) {
            pass("DB_COLUMN_" + tableName.toUpperCase() + "_" + columnName.toUpperCase(), tableName + "." + columnName + " exists.");
        } else {
            fail("DB_COLUMN_" + tableName.toUpperCase() + "_" + columnName.toUpperCase(), tableName + "." + columnName + " is missing.");
        }
    }

    private static void requireColumnAbsent(String tableName, String columnName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?";
        if (queryInt(sql, tableName, columnName) == 0) {
            pass("DB_COLUMN_ABSENT_" + tableName.toUpperCase() + "_" + columnName.toUpperCase(), tableName + "." + columnName + " is absent.");
        } else {
            fail("DB_COLUMN_ABSENT_" + tableName.toUpperCase() + "_" + columnName.toUpperCase(), tableName + "." + columnName + " should be absent.");
        }
    }

    private static void requireConstraint(String tableName, String constraintName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND LOWER(CONSTRAINT_NAME) = LOWER(?)";
        if (queryInt(sql, tableName, constraintName) == 1) {
            pass("DB_CONSTRAINT_" + constraintName.toUpperCase(), tableName + "." + constraintName + " exists.");
        } else {
            fail("DB_CONSTRAINT_" + constraintName.toUpperCase(), tableName + "." + constraintName + " is missing.");
        }
    }

    private static void requireEnumValue(String tableName, String columnName, String enumValue) throws SQLException {
        String sql = "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? AND COLUMN_TYPE LIKE ?";
        if (queryInt(sql, tableName, columnName, "%" + enumValue + "%") == 1) {
            pass("DB_ENUM_" + tableName.toUpperCase() + "_" + columnName.toUpperCase() + "_" + enumValue, tableName + "." + columnName + " supports " + enumValue + ".");
        } else {
            fail("DB_ENUM_" + tableName.toUpperCase() + "_" + columnName.toUpperCase() + "_" + enumValue, tableName + "." + columnName + " does not support " + enumValue + ".");
        }
    }

    private static void expectSqlFailure(String rule, SqlAction action) throws SQLException {
        try {
            action.run();
            fail(rule, "Expected SQL failure, but statement succeeded.");
        } catch (SQLException expected) {
            pass(rule, "Expected SQL failure occurred: " + expected.getErrorCode());
        }
    }

    private static int queryInt(String sql, Object... values) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, values);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
            }
        }
        return 0;
    }

    private static String queryString(String sql) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                return resultSet.getString(1);
            }
        }
        return "";
    }

    private static void bind(PreparedStatement statement, Object... values) throws SQLException {
        for (int index = 0; index < values.length; index++) {
            Object value = values[index];
            if (value == null) {
                statement.setObject(index + 1, null);
            } else if (value instanceof Long) {
                statement.setLong(index + 1, ((Long) value).longValue());
            } else if (value instanceof Integer) {
                statement.setInt(index + 1, ((Integer) value).intValue());
            } else {
                statement.setString(index + 1, value.toString());
            }
        }
    }

    private static void setNullableString(PreparedStatement statement, int parameterIndex, String value) throws SQLException {
        if (value == null) {
            statement.setNull(parameterIndex, Types.VARCHAR);
        } else {
            statement.setString(parameterIndex, value);
        }
    }

    private static void pass(String rule, String message) {
        System.out.println("PASS|" + rule + "|" + message);
    }

    private static void fail(String rule, String message) {
        failed = true;
        System.out.println("FAIL|" + rule + "|" + message);
    }

    private interface SqlAction {
        void run() throws SQLException;
    }
}
'@

    Set-Content -Path $SourcePath -Value $source -Encoding ASCII
}

function Invoke-HarnessDbJava {
    param(
        [string[]] $Checks
    )

    $driverJar = Resolve-MariaDbDriverJar
    if (-not $driverJar) {
        return
    }

    $dbConfig = Get-DbConfig
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "pcs-harness-db"
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    $sourcePath = Join-Path $tempRoot "PcsHarnessDbCheck.java"
    New-HarnessDbCheckerSource $sourcePath

    try {
        & javac "-encoding" "UTF-8" "-d" $tempRoot $sourcePath | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Add-Result "FAIL" "DB_CHECKER_COMPILE" "Failed to compile the harness DB checker." "Check that JDK javac is available."
            return
        }
    } catch {
        Add-Result "FAIL" "DB_CHECKER_JAVAC" "javac command is not available for DB harness checks." "Use JDK 17 and make javac available in PATH."
        return
    }

    $classPath = "$tempRoot$([System.IO.Path]::PathSeparator)$driverJar"
    $checksArg = ($Checks | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique) -join ","
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & java "-cp" $classPath "PcsHarnessDbCheck" $dbConfig.Url $dbConfig.User $dbConfig.Password $checksArg 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    foreach ($line in $output) {
        $text = [string] $line
        if ($text.StartsWith("PASS|")) {
            $parts = $text.Split("|", 3)
            Add-Result "INFO" $parts[1] $parts[2]
        } elseif ($text.StartsWith("FAIL|")) {
            $parts = $text.Split("|", 3)
            Add-Result "FAIL" $parts[1] $parts[2]
        } elseif (-not [string]::IsNullOrWhiteSpace($text)) {
            Add-Result "INFO" "DB_CHECK_OUTPUT" $text
        }
    }

    if ($exitCode -ne 0) {
        Add-Result "FAIL" "DB_CHECK_FAILED" "One or more DB harness checks failed." "Read harness/reports/latest.md and fix schema/data rules."
    }
}

function Invoke-DbChecks {
    $requestedChecks = New-Object System.Collections.Generic.List[string]

    if ($RunDb -or $DbFeature -ne "none") {
        $requestedChecks.Add("checkdb") | Out-Null
    }

    if ($RunDb -and $script:SelectedFeatures -and $script:SelectedFeatures.Count -gt 0) {
        foreach ($selectedFeature in $script:SelectedFeatures) {
            $definition = Get-FeatureDefinition $selectedFeature
            $featureDbChecks = @($definition.dbChecks | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            if ($featureDbChecks.Count -eq 0) {
                Add-Result "INFO" "DB_FEATURE_NOT_IMPLEMENTED_$($selectedFeature.ToUpper())" "DB harness check is not implemented for feature: $selectedFeature." "Add a DB checker before requiring this feature in DB gate."
                continue
            }
            foreach ($dbCheck in $featureDbChecks) {
                if ($SupportedDbFeatureNames -contains $dbCheck) {
                    $requestedChecks.Add([string] $dbCheck) | Out-Null
                } else {
                    Add-Result "FAIL" "DB_FEATURE_REGISTRY_INVALID" "Feature $selectedFeature references unsupported DB check: $dbCheck." "Fix harness/config/features.json."
                }
            }
        }
    }

    if ($DbFeature -ne "none") {
        $requestedChecks.Add($DbFeature) | Out-Null
    }

    $checks = $requestedChecks | Select-Object -Unique
    if (-not $checks -or $checks.Count -eq 0) {
        return
    }

    Test-PathRequired "docs/features/checkdb.md" "CHECKDB_DOC" "Create docs/features/checkdb.md for common DB preflight rules."
    foreach ($check in $checks) {
        if ($check -eq "checkdb") {
            continue
        }
        Test-PathRequired "docs/features/$check-db.md" "DB_FEATURE_DOC_$($check.ToUpper())" "Create docs/features/$check-db.md for DB validation rules."
    }

    Invoke-HarnessDbJava $checks
}

function Invoke-BuildCheck {
    $gradlew = Get-GradleWrapperPath
    if (-not $gradlew) {
        Add-Result "FAIL" "BUILD_GRADLEW_MISSING" "Gradle Wrapper is missing." "Restore Gradle Wrapper."
        return
    }

    if (-not (Ensure-JavaHome17) -and $env:JAVA_HOME) {
        Add-Result "FAIL" "JAVA_HOME_17_REQUIRED" "Gradle uses JAVA_HOME, but JAVA_HOME is not JDK 17 or later: $env:JAVA_HOME" "Set JAVA_HOME to JDK 17 or create an ignored local gradle.properties from gradle.properties.example."
        return
    }

    Push-Location $ProjectRoot
    try {
        Invoke-GradleWrapper @("compileJava") | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Add-Result "FAIL" "COMPILE_JAVA" "compileJava failed." "Fix compile errors first."
        } else {
            Add-Result "INFO" "COMPILE_JAVA" "compileJava passed."
        }
    } finally {
        Pop-Location
    }
}

function Get-FreeTcpPort {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    try {
        $listener.Start()
        return $listener.LocalEndpoint.Port
    } finally {
        $listener.Stop()
    }
}

function Invoke-SwaggerSmokeCheck {
    $gradlew = Get-GradleWrapperPath
    if (-not $gradlew) {
        Add-Result "FAIL" "SWAGGER_GRADLEW_MISSING" "Gradle Wrapper is missing." "Restore Gradle Wrapper."
        return
    }

    if (-not (Ensure-JavaHome17) -and $env:JAVA_HOME) {
        Add-Result "FAIL" "SWAGGER_JAVA_HOME_17_REQUIRED" "Swagger smoke check requires JDK 17 or later." "Set JAVA_HOME to JDK 17 or later."
        return
    }

    Push-Location $ProjectRoot
    try {
        Invoke-GradleWrapper @("bootJar") | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Add-Result "FAIL" "SWAGGER_BOOT_JAR" "bootJar failed before Swagger smoke check." "Fix build errors first."
            return
        }
    } finally {
        Pop-Location
    }

    $jar = Get-ChildItem -Path (Join-Path $ProjectRoot "build/libs") -Filter "*.jar" -File |
        Where-Object { $_.Name -notmatch "-plain\.jar$" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $jar) {
        Add-Result "FAIL" "SWAGGER_BOOT_JAR_NOT_FOUND" "No executable bootJar artifact was found." "Run Gradle bootJar and check build/libs."
        return
    }

    $javaCommand = "java"
    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $javaHomeCommand = Get-JavaExecutablePath $env:JAVA_HOME
        if ($javaHomeCommand -and (Test-Path $javaHomeCommand)) {
            $javaCommand = $javaHomeCommand
        }
    }

    $port = Get-FreeTcpPort
    $stdoutPath = Join-Path $ReportDir "swagger-smoke.out.log"
    $stderrPath = Join-Path $ReportDir "swagger-smoke.err.log"
    $process = $null

    try {
        $startProcessArgs = @{
            FilePath = $javaCommand
            ArgumentList = @("-jar", $jar.FullName, "--server.port=$port")
            RedirectStandardOutput = $stdoutPath
            RedirectStandardError = $stderrPath
            PassThru = $true
        }
        if (Test-IsWindowsHost) {
            $startProcessArgs.WindowStyle = "Hidden"
        }

        $process = Start-Process @startProcessArgs

        $apiDocsResponse = $null
        for ($attempt = 0; $attempt -lt 40; $attempt++) {
            Start-Sleep -Milliseconds 750
            if ($process.HasExited) {
                break
            }

            try {
                $apiDocsResponse = Invoke-WebRequest -Uri "http://127.0.0.1:$port/v3/api-docs" -UseBasicParsing -TimeoutSec 2
                if (
                    $apiDocsResponse.StatusCode -eq 200 -and
                    $apiDocsResponse.Content -match '"openapi"' -and
                    $apiDocsResponse.Content -match '"paths"'
                ) {
                    break
                }
            } catch {
                $apiDocsResponse = $null
            }
        }

        if (
            -not $apiDocsResponse -or
            $apiDocsResponse.StatusCode -ne 200 -or
            $apiDocsResponse.Content -notmatch '"openapi"' -or
            $apiDocsResponse.Content -notmatch '"paths"'
        ) {
            Add-Result "FAIL" "SWAGGER_API_DOCS" "/v3/api-docs did not return a valid OpenAPI document." "Check $stdoutPath and $stderrPath."
            return
        }

        try {
            $swaggerUiResponse = Invoke-WebRequest -Uri "http://127.0.0.1:$port/swagger-ui/index.html" -UseBasicParsing -TimeoutSec 5
            if ($swaggerUiResponse.StatusCode -ne 200) {
                Add-Result "FAIL" "SWAGGER_UI" "Swagger UI returned HTTP $($swaggerUiResponse.StatusCode)." "Check springdoc and security configuration."
                return
            }
        } catch {
            Add-Result "FAIL" "SWAGGER_UI" "Swagger UI did not respond." "Check springdoc and security configuration."
            return
        }

        Add-Result "INFO" "SWAGGER_SMOKE" "Swagger OpenAPI docs and UI responded successfully."
    } finally {
        if ($process -and -not $process.HasExited) {
            Stop-Process -Id $process.Id -Force
            $process.WaitForExit()
        }
    }
}

function Write-Report {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# PCS Harness Report") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- Mode: $Mode") | Out-Null
    $lines.Add("- Feature: $Feature") | Out-Null
    $lines.Add("- RunBuild: $RunBuild") | Out-Null
    $lines.Add("- RunSwagger: $RunSwagger") | Out-Null
    $lines.Add("- RunDb: $RunDb") | Out-Null
    $lines.Add("- DbFeature: $DbFeature") | Out-Null
    $lines.Add("- ChangedFilesPath: $ChangedFilesPath") | Out-Null
    $lines.Add("- TrackedFilesPath: $TrackedFilesPath") | Out-Null
    if ($script:SelectedFeatures.Count -gt 0) {
        $lines.Add("- SelectedFeatures: $($script:SelectedFeatures -join ', ')") | Out-Null
    } else {
        $lines.Add("- SelectedFeatures: none") | Out-Null
    }
    $lines.Add("- GeneratedAt: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
    $lines.Add("- FAIL: $($failures.Count)") | Out-Null
    $lines.Add("- WARN: $($warnings.Count)") | Out-Null
    $lines.Add("- INFO: $($infos.Count)") | Out-Null
    $lines.Add("") | Out-Null

    foreach ($section in @(
        @{ Title = "FAIL"; Items = $failures },
        @{ Title = "WARN"; Items = $warnings },
        @{ Title = "INFO"; Items = $infos }
    )) {
        $lines.Add("## $($section.Title)") | Out-Null
        $lines.Add("") | Out-Null
        if ($section.Items.Count -eq 0) {
            $lines.Add("- none") | Out-Null
            $lines.Add("") | Out-Null
            continue
        }

        $index = 1
        foreach ($item in $section.Items) {
            $lines.Add("$index. [$($item.Rule)] $($item.Message)") | Out-Null
            if ($item.Fix) {
                $lines.Add("   - fix: $($item.Fix)") | Out-Null
            }
            $index++
        }
        $lines.Add("") | Out-Null
    }

    Set-Content -Path $ReportPath -Value $lines -Encoding UTF8
}

Ensure-GitignoreRules
Test-GitForbiddenFiles
Test-JavaVersion
Test-BootstrapStructure
Test-ProjectSettings
Test-ForbiddenAlways
Test-NoFeatureCodeBeforeSpec
Test-JavaScriptSyntax
Test-CssArchitecture
Test-FeatureRegistry
Test-CodexHookConfiguration
Test-WorkspaceNavigation
Test-FrontendCommonUtilityReuse

if ($CheckPort) {
    Test-PortAvailable
}

if ($Mode -eq "full") {
    Test-FullModeStructure
}

if ($Mode -eq "gate") {
    $script:SelectedFeatures = @(Resolve-GateFeatures)
} elseif ($Feature -ne "none") {
    $script:SelectedFeatures = @($Feature)
} else {
    $script:SelectedFeatures = @()
}

Invoke-FeatureChecks $script:SelectedFeatures

Invoke-DbChecks

if ($RunBuild) {
    Invoke-BuildCheck
}

if ($RunSwagger) {
    Invoke-SwaggerSmokeCheck
}

Write-Report

Write-Host ""
Write-Host "PCS Harness Result"
Write-Host "Mode: $Mode"
Write-Host "Feature: $Feature"
Write-Host "RunBuild: $RunBuild"
Write-Host "RunSwagger: $RunSwagger"
Write-Host "RunDb: $RunDb"
Write-Host "DbFeature: $DbFeature"
Write-Host "ChangedFilesPath: $ChangedFilesPath"
Write-Host "TrackedFilesPath: $TrackedFilesPath"
Write-Host "SelectedFeatures: $(if ($script:SelectedFeatures.Count -gt 0) { $script:SelectedFeatures -join ', ' } else { 'none' })"
Write-Host "FAIL: $($failures.Count), WARN: $($warnings.Count), INFO: $($infos.Count)"
Write-Host "Report: $ReportPath"

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Failures:"
    $failures | ForEach-Object {
        Write-Host "- [$($_.Rule)] $($_.Message)"
    }
    exit 1
}

exit 0
