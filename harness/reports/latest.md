# PCS Harness Report

- Mode: bootstrap
- Feature: none
- RunDb: False
- DbFeature: none
- GeneratedAt: 2026-06-16 15:06:28
- FAIL: 7
- WARN: 0
- INFO: 2

## FAIL

1. [JAVA_COMMAND_REQUIRED] java command is not available.
   - fix: Install JDK 17 or later and configure PATH/JAVA_HOME.
2. [JAVA_HOME_COMMAND_REQUIRED] JAVA_HOME does not point to a JDK with bin\java.exe: /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
   - fix: Set JAVA_HOME to JDK 17 or later.
3. [NO_JPA_DEPENDENCY] JPA dependency was found. Locations: /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-harness-rules.md:247, /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-project-structure-reference.md:34, /Users/kimjinryeol/Desktop/Backend/harness/run-harness.ps1:251
   - fix: PCS must use MyBatis, not JPA.
4. [NO_JPA_IMPORT] JPA import was found. Locations: /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-harness-rules.md:248, /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-project-structure-reference.md:35, /Users/kimjinryeol/Desktop/Backend/harness/run-harness.ps1:252
   - fix: Use plain domain objects and MyBatis Mapper later.
5. [NO_JPA_IMPORT_LEGACY] JPA import was found. Locations: /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-harness-rules.md:249, /Users/kimjinryeol/Desktop/Backend/harness/run-harness.ps1:253
   - fix: Use plain domain objects and MyBatis Mapper later.
6. [NO_JPA_REPOSITORY] JpaRepository usage was found. Locations: /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-harness-rules.md:255, /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-project-structure-reference.md:36, /Users/kimjinryeol/Desktop/Backend/harness/run-harness.ps1:254
   - fix: Use MyBatis Mapper later.
7. [NO_ENTITY_MANAGER] EntityManager usage was found. Locations: /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-harness-rules.md:256, /Users/kimjinryeol/Desktop/Backend/docs/ai/pcs-project-structure-reference.md:37, /Users/kimjinryeol/Desktop/Backend/harness/run-harness.ps1:255
   - fix: Use MyBatis Mapper XML SQL later.

## WARN

- none

## INFO

1. [GITIGNORE_REQUIRED_RULES] .gitignore contains required rules.
2. [JS_SYNTAX] JS syntax check passed.

