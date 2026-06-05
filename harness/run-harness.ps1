param(
    [ValidateSet("bootstrap", "full")]
    [string] $Mode = "bootstrap",

    [ValidateSet("none", "company", "member", "auth", "partner", "category")]
    [string] $Feature = "none",

    [switch] $FixGitignore,

    [switch] $RunBuild,

    [switch] $RunDb,

    [ValidateSet("none", "company", "member", "auth", "partner", "category")]
    [string] $DbFeature = "none",

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

    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $javaHomeCommand = Join-Path $env:JAVA_HOME "bin\java.exe"
        if (-not (Test-Path $javaHomeCommand)) {
            Add-Result "FAIL" "JAVA_HOME_COMMAND_REQUIRED" "JAVA_HOME does not point to a JDK with bin\java.exe: $env:JAVA_HOME" "Set JAVA_HOME to JDK 17 or later."
            return
        }

        try {
            $javaHomeVersionOutput = (cmd /c "`"$javaHomeCommand`" -version 2>&1") -join "`n"
            if ($javaHomeVersionOutput -notmatch 'version "17\.|version "18\.|version "19\.|version "2[0-9]\.') {
                Add-Result "FAIL" "JAVA_HOME_17_REQUIRED" "JAVA_HOME is not Java 17 or later. Output: $javaHomeVersionOutput" "Set JAVA_HOME to JDK 17 or later."
            } else {
                Add-Result "INFO" "JAVA_HOME_17_REQUIRED" "JAVA_HOME points to Java 17 or later."
            }
        } catch {
            Add-Result "FAIL" "JAVA_HOME_VERSION_CHECK_FAILED" "Failed to execute JAVA_HOME bin\java.exe." "Set JAVA_HOME to a valid JDK 17 or later."
        }
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
        if ($build -notmatch "spring-boot-starter-security") {
            Add-Result "FAIL" "SPRING_SECURITY_REQUIRED" "spring-boot-starter-security is missing." "Use Spring Security for JWT request authentication."
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
        foreach ($pattern in @("HmacSHA256", "companyId", "companyCode", "memberId", "tokenType", "exp", "MessageDigest.isEqual", "SecretKeySpec", "DEFAULT_LOCAL_SECRET", "allowDefaultSecret")) {
            if ($jwtContent -notmatch $pattern) {
                Add-Result "FAIL" "AUTH_JWT_PATTERN" "JwtTokenProvider is missing required JWT claim/signing pattern: $pattern" "Access token must include workspace/member claims and HS256 signature."
            }
        }
    }

    $securityConfig = Join-Path $ProjectRoot "src/main/java/com/pcs/global/security/SecurityConfig.java"
    if (Test-Path $securityConfig) {
        $securityContent = Get-Content -Raw $securityConfig
        foreach ($pattern in @("SecurityFilterChain", "SessionCreationPolicy.STATELESS", "/api/**", "authenticated", "permitAll", "addFilterBefore")) {
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
        foreach ($column in @("tb_auth_refresh_token", "refresh_token_hash", "token_family_id", "revoked_reason", "tb_auth_login_history", "login_result", "last_login_at", "login_failed_count", "locked_until_at", "revokeRefreshTokenFamily")) {
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

    $facade = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/partner/facade/PartnerFacade.java"
    if (Test-Path $facade) {
        $facadeContent = Get-Content -Raw $facade
        foreach ($pattern in @("principal.companyId", "principal.companyCode", "AUTH_WORKSPACE_MISMATCH")) {
            if ($facadeContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_SCOPE_PATTERN" "PartnerFacade is missing company-scope pattern: $pattern" "Validate URL companyCode against authenticated workspace and query by companyId."
            }
        }
    }

    $service = Join-Path $ProjectRoot "src/main/java/com/pcs/domain/partner/service/PartnerService.java"
    if (Test-Path $service) {
        $serviceContent = Get-Content -Raw $service
        foreach ($pattern in @("DEFAULT_SIZE", "MAX_SIZE", "countPartners", "searchPartners", "summarizePartners", "COMPANY_INACTIVE")) {
            if ($serviceContent -notmatch $pattern) {
                Add-Result "FAIL" "PARTNER_SERVICE_PATTERN" "PartnerService is missing required search/paging pattern: $pattern" "Keep partner list paging, summary, and inactive-company guard."
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
    Test-PathRequired "src/main/java/com/pcs/domain/category/dto/response/SearchCategoryResponse.java" "CATEGORY_SEARCH_RESPONSE" "Keep category list/detail response DTO."
    Test-PathRequired "src/main/java/com/pcs/domain/category/entity/PartCategory.java" "CATEGORY_ENTITY" "Keep tb_part_category row state in category/entity."
    Test-PathRequired "src/main/java/com/pcs/domain/category/facade/CategoryFacade.java" "CATEGORY_FACADE" "Keep category company-scope validation in category/facade."
    Test-PathRequired "src/main/java/com/pcs/domain/category/service/CategoryService.java" "CATEGORY_SERVICE" "Keep category business rules in category/service."
    Test-PathRequired "src/main/java/com/pcs/domain/category/mapper/CategoryMapper.java" "CATEGORY_MAPPER" "Keep MyBatis mapper interface for category persistence."
    Test-PathRequired "src/main/resources/mapper/category/CategoryMapper.xml" "CATEGORY_MAPPER_XML" "Keep MyBatis mapper XML for category persistence."

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
        foreach ($pattern in @("DEFAULT_SIZE", "MAX_SIZE", "countCategories", "searchCategories", "existsByName", "countPartsByCategory", "deleteById", "CATEGORY_IN_USE", "COMPANY_INACTIVE")) {
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
        foreach ($pattern in @("tb_part_category", "tb_pc_part", "part_count", "LIMIT", "OFFSET", "COUNT(*)", "updated_at DESC", "category_id DESC", "DELETE FROM tb_part_category")) {
            if ($mapperXmlContent -notmatch [regex]::Escape($pattern)) {
                Add-Result "FAIL" "CATEGORY_MAPPER_PATTERN" "CategoryMapper.xml is missing required SQL pattern: $pattern" "Keep category search, partCount, and delete SQL aligned with docs/features/category.md."
            }
        }
    }

    Add-Result "INFO" "CATEGORY_FEATURE" "Category feature checks completed."
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

    foreach ($root in $roots) {
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

    $gradlew = Join-Path $ProjectRoot "gradlew.bat"
    if (-not (Test-Path $gradlew)) {
        Add-Result "FAIL" "DB_DRIVER_GRADLEW_MISSING" "MariaDB JDBC driver was not found and gradlew.bat is missing." "Restore Gradle Wrapper or download dependencies."
        return $null
    }

    Push-Location $ProjectRoot
    try {
        & $gradlew "--quiet" "dependencies" "--configuration" "runtimeClasspath" | Out-Null
    } catch {
        Add-Result "FAIL" "DB_DRIVER_RESOLVE_FAILED" "Failed to resolve runtimeClasspath dependencies for MariaDB JDBC driver." "Run Gradle dependency resolution after configuring JDK 17."
        return $null
    } finally {
        Pop-Location
    }

    $driverJar = Find-MariaDbDriverJar
    if (-not $driverJar) {
        Add-Result "FAIL" "DB_DRIVER_NOT_FOUND" "MariaDB JDBC driver jar was not found in Gradle cache." "Run .\gradlew.bat dependencies --configuration runtimeClasspath or check build.gradle runtimeOnly dependency."
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

        boolean originalAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try {
            long companyId = insertCompany("PCS Harness Category Company", "pcs-harness-category-" + runSuffix, null, null, "445-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            long otherCompanyId = insertCompany("PCS Harness Category Other Company", "pcs-harness-category-other-" + runSuffix, null, null, "446-00-" + runSuffix.substring(Math.max(0, runSuffix.length() - 5)));
            long memberId = insertMember(companyId, "category-owner-" + runSuffix, "Category Owner", "OWNER", 1, "ACTIVE");

            long categoryId = insertCategory(companyId, "Harness Category " + runSuffix, "Category memo", memberId);
            insertCategory(otherCompanyId, "Harness Category " + runSuffix, "Other company category", null);

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

    if ($RunDb -and $Feature -ne "none") {
        $requestedChecks.Add($Feature) | Out-Null
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
    $lines.Add("- Feature: $Feature") | Out-Null
    $lines.Add("- RunDb: $RunDb") | Out-Null
    $lines.Add("- DbFeature: $DbFeature") | Out-Null
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

if ($Feature -eq "company") {
    Test-CompanyFeature
}

if ($Feature -eq "member") {
    Test-MemberFeature
}

if ($Feature -eq "auth") {
    Test-AuthFeature
}

if ($Feature -eq "partner") {
    Test-PartnerFeature
}

if ($Feature -eq "category") {
    Test-CategoryFeature
}

Invoke-DbChecks

if ($RunBuild) {
    Invoke-BuildCheck
}

Write-Report

Write-Host ""
Write-Host "PCS Harness Result"
Write-Host "Mode: $Mode"
Write-Host "Feature: $Feature"
Write-Host "RunDb: $RunDb"
Write-Host "DbFeature: $DbFeature"
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
