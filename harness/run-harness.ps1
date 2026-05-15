param(
    [ValidateSet("bootstrap", "full")]
    [string] $Mode = "bootstrap",

    [switch] $FixGitignore,

    [switch] $RunBuild,

    [switch] $CheckPort,

    [int] $Port = 8080
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "..")
$ReportDir = Join-Path $ScriptDir "reports"
$ReportPath = Join-Path $ReportDir "latest.md"

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

$failures = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]
$infos = New-Object System.Collections.Generic.List[object]

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

function Get-ProjectTextFiles {
    Get-ChildItem -Path $ProjectRoot -Recurse -File |
        Where-Object {
            $path = $_.FullName
            $path -notmatch "\\.git\\" -and
            $path -notmatch "\\.gradle\\" -and
            $path -notmatch "\\build\\" -and
            $path -notmatch "\\out\\" -and
            $path -notmatch "\\docs\\" -and
            $path -notmatch "\\harness\\" -and
            $path -notmatch "\\harness\\reports\\"
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
        "gradle.properties",
        "*.log",
        "*.tmp",
        "tmp/",
        "harness/reports/*",
        "!harness/reports/.gitkeep"
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

function Test-JavaVersion {
    try {
        $versionOutput = (cmd /c "java -version 2>&1") -join "`n"
        if ($versionOutput -notmatch 'version "17\.|version "18\.|version "19\.|version "2[0-9]\.') {
            Add-Result "FAIL" "JAVA_17_REQUIRED" "java command is not Java 17 or later. Output: $versionOutput" "Set JAVA_HOME and IntelliJ Project SDK to JDK 17 or later."
        } else {
            Add-Result "INFO" "JAVA_17_REQUIRED" "Java 17 or later is available."
        }
    } catch {
        Add-Result "FAIL" "JAVA_COMMAND_REQUIRED" "java command is not available." "Install JDK 17 or later and configure PATH/JAVA_HOME."
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
    Test-PathRequired "src/main/resources/static/css/main.css" "MAIN_CSS" "Keep CSS paired with main.html."
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

function Invoke-BuildCheck {
    $gradlew = Join-Path $ProjectRoot "gradlew.bat"
    if (-not (Test-Path $gradlew)) {
        Add-Result "FAIL" "BUILD_GRADLEW_MISSING" "gradlew.bat is missing." "Restore Gradle Wrapper."
        return
    }

    if ($env:JAVA_HOME) {
        $javaHomeExe = Join-Path $env:JAVA_HOME "bin/java.exe"
        if (-not (Test-Path $javaHomeExe)) {
            Add-Result "FAIL" "JAVA_HOME_INVALID" "JAVA_HOME is set but bin/java.exe does not exist: $env:JAVA_HOME" "Set JAVA_HOME to JDK 17 or remove the invalid value."
            return
        }

        $javaHomeVersion = (cmd /c "`"$javaHomeExe`" -version 2>&1") -join "`n"
        if ($javaHomeVersion -notmatch 'version "17\.|version "18\.|version "19\.|version "2[0-9]\.') {
            Add-Result "FAIL" "JAVA_HOME_17_REQUIRED" "Gradle uses JAVA_HOME, but JAVA_HOME is not JDK 17 or later: $env:JAVA_HOME" "Set JAVA_HOME to JDK 17 or create an ignored local gradle.properties from gradle.properties.example."
            return
        }
    }

    Push-Location $ProjectRoot
    try {
        & $gradlew "compileJava" | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Add-Result "FAIL" "COMPILE_JAVA" "compileJava failed." "Fix compile errors first."
        } else {
            Add-Result "INFO" "COMPILE_JAVA" "compileJava passed."
        }
    } finally {
        Pop-Location
    }
}

function Write-Report {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# PCS Harness Report") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- Mode: $Mode") | Out-Null
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
Test-JavaVersion
Test-BootstrapStructure
Test-ProjectSettings
Test-ForbiddenAlways
Test-NoFeatureCodeBeforeSpec
Test-JavaScriptSyntax

if ($CheckPort) {
    Test-PortAvailable
}

if ($Mode -eq "full") {
    Test-FullModeStructure
}

if ($RunBuild) {
    Invoke-BuildCheck
}

Write-Report

Write-Host ""
Write-Host "PCS Harness Result"
Write-Host "Mode: $Mode"
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
