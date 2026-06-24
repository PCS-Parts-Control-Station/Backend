# PCS Backend

Parts Control Station backend and static workspace UI.

## Local Requirements

- JDK 17
- MariaDB compatible with `src/main/resources/application.yaml`
- PowerShell on Windows for the local harness scripts

The Gradle wrapper requires Java 17 or later. If `java -version` prints 17 but Gradle still fails, check `JAVA_HOME`.

PowerShell example:

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
.\gradlew.bat test
```

Persistent Windows user environment example:

```powershell
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "User")
```

Open a new terminal after changing the persistent value.

## Common Commands

```powershell
.\gradlew.bat test
.\gradlew.bat processResources
```

Do not start or stop the local application server from automation unless the user explicitly asks. The usual development server is controlled from IntelliJ.
