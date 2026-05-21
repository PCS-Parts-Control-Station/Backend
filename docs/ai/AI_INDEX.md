# PCS AI INDEX

이 문서는 코덱스가 작업별로 어떤 문서를 읽을지 결정하기 위한 문서다.
모든 문서를 매번 읽지 않는다.

## 프로젝트 한 줄 요약

PCS는 중고 PC 부품을 관리번호 단위로 입고, 검수, 재고, 출고, 이력까지 추적하는 국내 업무용 재고관리 시스템이다.

## 기본 참조 문서

작업 성격을 판단하기 위해 필요한 경우에만 읽는다.

- `docs/ai/pcs-handoff.md`
    - 이전 채팅의 결정사항, 최근 변경 파일, 다음 작업 흐름 확인
- `docs/ai/pcs-agent-context.md`
    - 프로젝트 정체성, 전체 작업 원칙, 계층 역할 확인
- `docs/ai/pcs-harness-rules.md`
    - 하네스 검사 기준, 금지 규칙, 완료 기준 확인

## 문서 선택 규칙

### 1. 화면 디자인 / HTML / CSS 작업

읽을 문서:

- `docs/ai/pcs-design-system.md`

읽지 말 문서:

- `docs/sql/pcs-schema-ddl.sql`
- 관련 없는 feature 문서
- 전체 API 명세

예시 작업:

- 메인 화면 디자인 수정
- 관리자 화면 UI 개선
- CSS 리팩토링
- 상태 배지 디자인 정리

---

### 2. 프론트 JS / API 연동 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- 필요한 경우 `docs/ai/pcs-api-spec.md`
- 해당 기능 문서 1개

예시:

- 부품 목록 JS 작성 → `docs/features/part.md`
- 검수 등록 JS 작성 → `docs/features/inspection.md`
- 로그인 JS 작성 → `docs/features/auth.md`

---

### 3. 백엔드 구조 / 패키지 생성 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-harness-rules.md`
- 해당 기능 문서 1개

예시:

- `domain/part` 생성
- Controller/Facade/Service/Mapper 기본 구조 생성
- 공통 응답 구조 생성

---

### 4. API 구현 작업

읽을 문서:

- `docs/ai/pcs-agent-context.md`
- `docs/ai/pcs-project-structure-reference.md`
- `docs/ai/pcs-api-spec.md`
- 해당 기능 문서 1개

예시:

- Owner 회원가입 구현 → `docs/features/company.md`
- 업체 로그인 구현 → `docs/features/auth.md`
- 입고 전표 등록 구현 → `docs/features/stock.md`

---

### 5. DB / SQL / Mapper XML 작업

읽을 문서:

- `docs/ai/pcs-project-structure-reference.md`
- `docs/sql/pcs-schema-ddl.sql`
- 해당 기능 문서 1개

예시:

- MyBatis XML 작성
- 목록 검색 SQL 작성
- 집계 SQL 작성
- 재고 정합성 SQL 작성

---

### 6. 하네스 수정 작업

읽을 문서:

- `docs/ai/pcs-harness-rules.md`
- `docs/ai/pcs-agent-context.md`
- 필요한 경우 `docs/ai/pcs-project-structure-reference.md`

---

## 토큰 절약 규칙

- 한 작업에서 기본적으로 3개 이하의 문서만 읽는다.
- API 구현처럼 `agent-context`, `structure`, `api-spec`, feature 문서가 모두 필요한 경우에는 예외적으로 4개까지 허용한다.
- feature 문서는 해당 도메인 문서 1개만 읽는다.
- `pcs-api-spec.md`와 `pcs-schema-ddl.sql`은 크므로 필요한 경우에만 읽는다.
- 이미 읽은 문서라도 내용이 불확실하면 전체 재독해보다 관련 섹션만 확인한다.
- 작업 완료 후 참조한 문서를 명시한다.
