# Parts Control Station API

PCS는 중고 PC 부품 관리 시스템을 만들기 위한 Spring Boot 기본 프로젝트입니다.

## 기준

- 현재 단계에서는 기능 구현 없이 메인 정적 페이지만 제공합니다.
- 기능 확정 후 Controller -> Facade -> Service -> Mapper 구조로 확장합니다.
- DB 접근은 JPA가 아니라 MyBatis 기준으로 붙입니다.
- 화면은 정적 HTML + JS + REST API 통신 구조로 확장합니다.

## 실행 전 준비

```powershell
.\gradlew.bat clean compileJava
.\gradlew.bat bootRun
```

메인 화면:

```text
http://localhost:8080/
```

## 하네스 실행

```powershell
.\harness\run-harness.ps1 -Mode bootstrap
```

```powershell
.\harness\run-harness.ps1 -Mode bootstrap -RunBuild
```
