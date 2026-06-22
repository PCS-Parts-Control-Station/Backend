# Inspection History Feature

## 목적

검수, 정정, 재검수 이력을 전표와 관리번호 기준으로 조회한다.

검수 이력은 검수 도메인의 조회 기능이다. 신규 검수 저장, 정정 생성, 재검수 생성 규칙은 `docs/features/inspection.md`를 따른다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` | 검수 이력 전표 목록. `keyword`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/inspections` | 검수 이력 목록. `keyword`, `documentId`, `unitId`, `partId`, `inspectionType`, `result`, `grade`, `dateFrom`, `dateTo`, `page`, `size`, `limit` 지원 |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 검수 이력 상세 |

전표 목록은 `history-documents` 집계 API를 사용한다. 화면에서는 검색어, 기간, 이력 유형을 전표 목록의 주 필터로 사용한다.

전표 선택 후 관리번호 목록은 `GET /api/workspaces/{companyCode}/inspections?documentId={documentId}`로 조회한다. 검수 결과와 등급 필터는 전표 자체가 아니라 전표 안의 관리번호 이력에 적용한다.

개별 부품 기준 검수 이력은 별도 URL을 두지 않고 `GET /api/workspaces/{companyCode}/inspections?unitId={unitId}`로 조회한다.

## 화면

```text
src/main/resources/static/history-inspection.html
src/main/resources/static/css/history-inspection.css
src/main/resources/static/js/history-inspection.js
```

검수 이력 화면은 서버 Model을 받지 않고 JS가 `/api/workspaces/{companyCode}/**` API를 호출한다.

화면 구성:

1. 이력 검색
2. 전표 목록
3. 전표 상세
   - 품목 묶음
   - 관리번호 목록
4. 관리번호 상세 슬라이드 패널

이력 검색은 검색어, 기간, 이력 유형을 한 영역에 배치한다. 검색어는 전표번호, 품목명, 관리번호를 통합 검색한다.

전표 목록은 전체 너비 테이블로 표시하고 10개 단위 이전/다음 페이징을 제공한다. 컬럼은 전표번호, 품목 요약, 검수 건수, 불합격 건수, 최근 검수일이다. 별도 선택 버튼을 두지 않고 행 전체 클릭과 키보드 Enter/Space로 전표를 선택한다.

전표를 선택하기 전에는 관리번호 목록과 상세 영역을 미리 보여주지 않는다. 전표를 선택하면 `전표 상세` 영역을 표시하고, 왼쪽에는 품목 묶음, 오른쪽에는 관리번호 목록을 배치한다. 품목 묶음을 선택하면 해당 묶음의 관리번호 이력만 좁혀 보여준다.

관리번호 목록은 전체, 최초 검수, 정정, 재검수, 불합격 필터를 제공하며 각 필터의 건수를 함께 표시한다. 검수 결과와 등급은 관리번호 목록의 보조 필터로 둔다. 최근 결과는 결과와 등급을 함께 보여주며, 등급 배지는 A/B/C/미정/불량 상태를 색상으로 구분한다.

관리번호를 선택하면 개별 검수 이력 상세를 오른쪽 논블로킹 슬라이드 패널로 연다. 패널은 배경 오버레이를 사용하지 않고, 목록 클릭을 막지 않는다. 패널이 열린 상태에서 다른 관리번호 행을 클릭하면 패널을 닫지 않고 내용만 교체한다. 닫기는 `닫기` 버튼과 `Escape` 키로 처리하며, 외부 클릭 닫기는 사용하지 않는다. 패널이 열려도 포커스를 강제로 빼앗지 않고, 닫을 때는 가능하면 마지막으로 선택했던 행 또는 버튼으로 포커스를 복귀한다. 패널 본문은 검수 이력 타임라인, 항목별 검수 결과, 메모 순서로 구성한다.

## 주요 규칙

- 실제 검수 이력 row는 `tb_inspection`의 관리번호 단위 기록이다.
- 전표 단위 목록은 `documentId` 기준 집계 결과다.
- 개별 이력 추적은 `unitId`와 `inspectionId` 기준으로 처리한다.
- 목록은 `inspectedAt DESC, inspectionId DESC` 기준으로 정렬한다.
- 품목 묶음에는 품목명, 모델명, 품목 분류를 표시한다.
- 화면 fallback 문구에 의존하지 않도록 API 응답에는 품목 분류명 또는 카테고리명을 포함한다.
- 정정과 재검수는 원본 이력을 수정하지 않고 별도 이력으로 조회된다.
- 상세 패널의 타임라인은 최초 검수, 정정, 재검수를 시간순으로 표시하고, 결과와 등급은 배지로 구분한다.
- 상세 패널은 모달이 아니므로 `aria-modal`을 사용하지 않는다.
- 상세 패널은 목록 조회 흐름을 유지하기 위한 보조 영역이며, 확인/취소 같은 위험 작업은 별도 확인 모달에서 처리한다.

## 하네스 포인트

- 전표 단위 이력 목록은 관리번호 단위 row 페이징과 혼동하지 않도록 별도 집계 응답을 사용한다.
- 전표 선택 후 관리번호 목록은 `documentId` 조건으로 조회한다.
- 관리번호 상세는 항목별 결과를 포함해 반환한다.
- 검색 조건, 기간, 페이징 값은 서버에서 정규화한다.
- 전표 목록 페이징은 `history-documents` API의 `page`, `size`와 DB `LIMIT`, `OFFSET`을 사용한다.
- 검수 DB 구조와 제약은 `docs/features/inspection-db.md` 기준으로 검증한다.

## 테스트 기준

서비스 단위 테스트는 `src/test/java/com/pcs/domain/inspection/service/InspectionServiceTest.java`에서 관리한다.

현재 JUnit 검증 범위:

- 검수 이력 전표 목록은 전표 기준으로 집계해 반환한다.
- 검수 이력 목록은 필터, 기간, 페이징 값을 정규화해 조회한다.
- 검수 이력 상세는 항목별 결과를 포함해 반환한다.
