# Inspection History Feature

## 목적

검수·정정·재검수 이력을 전표에서 관리번호로 내려가며 조회한다. 저장 규칙은 `inspection.md`가 원본이다.

## 패키지

```text
com.pcs.domain.inspection
```

## API

| Method | API | 조건 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` | keyword, documentId, partId, type, result, grade, 기간, page/size |
| GET | `/api/workspaces/{companyCode}/inspections` | 위 조건 + unitId |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` | 항목 결과 포함 상세 |

- 전표 목록은 `history-documents` 집계 API를 사용한다.
- 전표 선택 후 `inspections?documentId=...`로 관리번호 이력을 조회한다.
- 개별 부품 이력은 `inspections?unitId=...`를 사용한다.
- 페이징과 기간 정규화는 서버에서 처리한다.

## 딥링크

```text
/w/{companyCode}/history/inspection
  ?documentId={id}&partId={id}&unitId={id}&inspectionId={id}
```

query가 있으면 기간 폼에 막히지 않게 documentId를 직접 조회해 전표, 품목 묶음, 관리번호, 상세 드로어를 순서대로 복원한다.

## 화면

```text
static/history-inspection.html
static/css/pages/history-inspection.css
static/js/history-inspection.js
```

```text
검색
전표 목록
전표 상세
- 품목 묶음
- 관리번호 목록
관리번호 상세 드로어
```

- 검색어는 전표 번호, 품목명, 관리번호를 통합 검색한다.
- 전표 목록은 10개 단위이며 전표 번호, 품목 요약, 검수·불합격 건수, 최근 검수일을 표시한다.
- 행 전체 클릭과 Enter/Space로 선택한다.
- 전표 선택 전에는 상세 영역을 숨긴다.
- 관리번호 목록은 전체·최초·정정·재검수·불합격 수를 제공한다.
- 상세는 `side-drawer.md`를 따르고 타임라인, 항목 결과, 메모 순서로 표시한다.

## 조회 규칙

- 실제 이력 row는 관리번호 단위 `tb_inspection`이다.
- 전표 목록은 documentId 기준 집계 결과이며 관리번호 row 페이징과 분리한다.
- 개별 추적은 unitId와 inspectionId를 사용한다.
- 정렬은 `inspectedAt DESC, inspectionId DESC`다.
- 응답은 품목명, 모델명, 분류명을 포함한다.
- 정정·재검수는 원본을 수정하지 않고 별도 이력으로 조회한다.
- 상세 timeline은 최초·정정·재검수를 시간순으로 표시한다.

DB 조회와 인덱스는 `inspection-db.md`를 따른다.

## 테스트 수용 기준

- `InspectionServiceTest`, `InspectionApiControllerTest`
- 전표 목록이 documentId 기준으로 집계되고 별도 페이징된다.
- 필터·기간·페이지가 정규화되어 Mapper에 전달된다.
- 상세가 항목 snapshot을 포함한다.
- 다른 회사의 전표·unit·inspection을 조회할 수 없다.
