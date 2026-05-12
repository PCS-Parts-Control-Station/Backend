# PCS 에이전트 컨텍스트

PCS는 GSF에서 정리한 구조 기준을 이어받는 연장선 프로젝트다.  
목표는 기능을 빨리 붙이는 것이 아니라, 처음부터 하네스로 구조를 검증하면서 개발하는 것이다.

## 핵심 전제

- 프로젝트명: 파츠관제소 / Parts Control Station / PCS
- 성격: 중고 PC 부품의 입고, 검수, 재고, 출고, 이력 관리 시스템
- GSF의 계층 구조와 리팩토링 기준을 계승한다.
- JPA는 사용하지 않고 MyBatis로 대체한다.
- AI는 서비스 기능에 넣지 않고 개발 보조로만 사용한다.
- 하네스는 AI와 사람이 만든 결과를 검증하는 장치다.

## 작업 원칙

- 기능 확정 전에는 기능 코드를 만들지 않는다.
- `domain/{feature}`를 만들기 전 `docs/features/{feature}.md`를 먼저 작성한다.
- Controller, Facade, Service, Mapper 역할을 섞지 않는다.
- 화면은 서버 Model이 아니라 정적 HTML + JS + REST API로 구성한다.
- 하네스 실패는 다음 기능 작업보다 먼저 해결한다.

## 계층 역할

Controller:

- HTTP 요청/응답 모양 담당
- `@Valid` 실행
- 인증 사용자 식별자 추출
- Facade 호출
- ResponseDto 변환
- `ApiResultDto` 응답 생성
- Swagger 관리

Facade:

- 유스케이스 흐름 조립
- 유스케이스 단위 트랜잭션 경계 담당
- 여러 Service 호출 조합
- 부분 성공이 허용되지 않는 작업을 하나로 묶음

Service:

- DB 조회/변경
- 비즈니스 검증
- Mapper 호출
- 도메인 상태 변경

Mapper:

- MyBatis SQL 실행
- Mapper XML과 1:1 대응
- 비즈니스 흐름 작성 금지

## DTO / Entity 기준

- DTO는 `record`로 작성한다.
- Request DTO는 입력값과 validation을 담당한다.
- Response DTO는 응답 모양을 담당한다.
- Entity는 DB row/domain 상태를 담당한다.
- Entity가 DTO를 import하면 안 된다.
- DTO와 Entity가 서로 참조하면 안 된다.
- `DTO.toEntity()` 남발은 피한다.

## 프론트 기준

- PageController는 HTML forward만 담당한다.
- HTML은 `src/main/resources/static`에 둔다.
- JS가 `/api/**` REST API를 호출한다.
- API 응답은 JSON으로 받는다.
- `Model`, `model.addAttribute`, Thymeleaf 데이터 주입은 사용하지 않는다.

## PCS 범위

포함:

- 회원/작업자
- 카테고리
- 부품
- 개별 관리번호
- 입고/출고
- 재고
- 검수
- 등급/판매 상태
- 상태 변경 이력
- 통계/집계 SQL

제외:

- 사진 업로드
- 결제/배송
- 채팅
- 중고 시세 크롤링
- 다중 창고
- 바코드 스캔
- 엑셀 업로드
- 수리 이력
- 캘린더 중심 기능
- 서비스 기능으로서의 AI
