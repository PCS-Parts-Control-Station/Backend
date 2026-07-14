# CheckDb Rules

## 목적

기능 DB 검증 전에 현재 로컬 애플리케이션 DB가 PCS 기준 스키마인지 확인한다. 기능 시나리오를 검사하지 않는다.

## 연결

환경값:

```text
DB_URL
DB_USER
DB_PASSWORD
```

값이 없으면 `application.yaml`의 로컬 기본값을 사용한다. 실제 연결 대상과 계정 정보는 설정 파일이 원본이다.

## 검사 범위

- DB 연결과 현재 database 확인
- `pcs-schema-ddl.sql`에 정의된 핵심 도메인 테이블 존재
- 업체 하위 테이블의 company_id
- 상태 원본 문서에 정의된 master active 컬럼
- 인증에 필요한 member·refresh token·login history 구조
- feature-db가 요구하는 핵심 unique·check·index

테이블·컬럼·제약 이름을 이 문서에 다시 열거하지 않는다. 물리 스키마는 DDL, 실제 사전 검사 목록은 `run-harness.ps1`의 checkdb 구현을 사용하며 둘이 달라지면 함께 수정한다.

## 결과

- 연결 실패: FAIL
- 현재 DB가 예상 애플리케이션 DB가 아님: FAIL
- 필수 테이블·컬럼·제약 누락: FAIL
- 기능별 저장·롤백 실패: 해당 feature-db 검사에서 FAIL

## 실행

`-RunDb` 또는 `-DbFeature`가 있으면 공통 checkdb를 먼저 실행한다. 명령과 리포트는 `docs/ai/pcs-harness-rules.md`를 따른다.
