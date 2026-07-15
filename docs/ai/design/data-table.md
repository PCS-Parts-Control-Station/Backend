# Data Table Design

검색·필터·요약·목록 행의 정보 구조 원본이다. breakpoint는 `responsive-layout.md`, 페이징 동작은 `docs/ai/pcs-pagination-rules.md`를 따른다.

## 기본 구조

```text
content-main
- filter-card
- table-card
  - table-header
  - data-table
  - pagination 선택
```

오른쪽 작업이 필요하면 `side-drawer.md`, 관리형 전체 조합은 `management-page.md`를 함께 적용한다.

## 목록 유형

| 유형 | 공통 class | 용도 |
|---|---|---|
| 단순 관리 | `simple-management-data-row` | 4열 전후 읽기 중심 |
| 선택형 관리 | `management-data-table`, `management-data-row` | 행 선택 후 드로어 작업 |
| 전표·이력 | `document-data-table`, `document-data-row` | 긴 식별자와 상태·날짜 비교 |

modifier는 grid와 정보 우선순위만 조정한다. 카드·배지·버튼 기본 모양은 공통 CSS를 사용한다.

## 검색 카드

```text
filter-card
- 제목과 한 줄 설명
- filter-form
  - 검색어
  - 선택 필터
  - 검색
```

- 제목은 어떤 목록을 좁히는지 말한다.
- 검색어 입력칸을 가장 넓게 둔다.
- 검색은 primary를 사용한다.
- 필터 수에 따른 줄바꿈은 `responsive-layout.md`를 따른다.
- 검색 실행 시 페이지를 0으로 초기화한다.

공통 modifier:

```text
management-filter-form
document-filter-form
```

## 테이블 헤더와 요약

```text
table-card
- table-header
  - 제목과 설명
  - list-summary 선택
- data-table
```

요약은 현재 페이지 행을 세지 않고 API의 전체 검색 조건 summary를 사용한다.

박스형:

- 숫자가 목록 판단의 핵심일 때 사용한다.
- 전체·가능·대기처럼 3~5개 핵심 값만 둔다.

인라인형:

- 보조 숫자일 때 `inline-summary-header`를 사용한다.
- 배경과 큰 숫자 강조 없이 항목 사이 구분선만 둔다.
- 3개 이하면 `summary-compact`를 사용할 수 있다.

## 데이터 행

- 첫 열은 대표 이름 또는 식별값이다.
- 상태는 공통 badge를 사용한다.
- 긴 이름·코드·모델은 한 줄 말줄임 처리하고 상세 확인 경로를 제공한다.
- JS에서 표시용으로 원본 값을 잘라 저장하지 않는다.
- 행 높이는 같은 목록에서 안정적으로 유지한다.
- 행 버튼은 `상세`, `수정`, `취소`처럼 짧게 쓴다.

### 단순 관리 행

예: 분류명 / 설명 / 품목 수 / 수정일.

- 행별 작업이 없거나 드로어에서 처리할 때 사용한다.
- 모바일 라벨은 실제 필드 의미와 일치해야 한다.

### 선택형 관리 행

- 행 전체 클릭과 Enter/Space를 지원한다.
- 선택 상태는 `is-selected`와 왼쪽 accent, 옅은 배경으로 표시한다.
- 수정·상태 버튼을 모든 행에 반복하지 않고 드로어에 둔다.
- 다른 행을 선택하면 열린 드로어 내용만 교체한다.
- 목록 카드는 `container-name`에 `management-card-table`을 추가한다.
- 열 폭은 페이지 CSS의 `--management-row-columns`, `--management-row-min-width`, `--management-row-gap`으로 전달한다.
- 840px 이하의 카드 외형·셀 라벨과 440px 이하의 1열 전환은 `management-page.css`가 소유한다.
- 페이지 CSS는 카드 외형을 복사하지 않고 `--management-cell-column`, `--management-cell-row`로 도메인 고유 노출 순서만 지정한다.

### 전표·이력 행

우선순위:

```text
전표 번호 / 상태
거래처 또는 내용
수량 / 처리일
행동
```

- 전표 번호와 관리번호는 monospace를 사용한다.
- 중간 폭에서는 내부 가로 스크롤과 행 `min-width`를 허용한다.
- 행 클릭 상세와 내부 버튼 이벤트를 분리한다.
- `is-created`, `is-selected` 같은 공통 상태를 사용한다.

## 긴 식별자

- API와 검색은 전체 값을 사용한다.
- 목록에서는 작은 monospace와 `overflow-wrap`으로 레이아웃을 보호한다.
- 축약은 상세·복사 경로가 있을 때만 허용한다.
- 반복 관리번호가 길면 내부 목록 스크롤 또는 접기/펼치기를 사용한다.

## 모바일 정보 구조

단순 관리 목록:

- 헤더를 숨기고 카드형 행으로 전환한다.
- 값만으로 의미가 약한 셀에만 짧은 라벨을 붙인다.
- 행동은 카드 하단에 둔다.
- 선택형 관리 목록의 공통 전환 기준은 840px, 단일 열 전환 기준은 440px이다.

전표형 목록:

```text
전표 번호              상태
거래처 / 내용
수량                 처리일
행동 버튼
```

- 전표 번호, 내용, 관리 같은 자명한 라벨은 반복하지 않는다.
- 수량과 처리일처럼 의미 보강이 필요한 값만 표시한다.
- 셀마다 큰 구분선을 넣지 않고 한 건을 하나의 카드로 보이게 한다.

## 페이징

- 테이블 하단에 `현재 페이지 / 전체 페이지 · 총 N건`을 표시한다.
- 이동은 이전/다음이며 불가능한 방향은 disabled다.
- 서버 응답과 JS 사용법은 `pcs-pagination-rules.md`만 원본으로 한다.

## 상태 화면

목록은 다음을 구분한다.

- 로딩
- 첫 데이터 없음
- 검색 결과 없음
- API 오류와 재시도
- 직전 생성·처리 결과

빈·로딩·오류는 공통 안내 행을 사용한다. 오류는 과한 빨강보다 짧은 설명과 재시도를 우선한다. 직전 처리 안내는 목록 위에 한 번만 표시할 수 있다.
