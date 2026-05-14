# Part Feature

## 목적

부품 마스터, 개별 부품, 현재 상태, 부품 기준 관리를 담당한다.

## 패키지

```text
com.pcs.domain.part
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/parts` | 부품/재고 목록 검색 |
| POST | `/api/workspaces/{companyCode}/parts` | 부품 마스터 등록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}` | 부품 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}` | 부품 마스터 수정 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/active` | 부품 활성 여부 변경 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units` | 개별 부품 목록 |
| GET | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}` | 개별 부품 상세 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/sales-status` | 개별 부품 판매 상태 변경 |
| PATCH | `/api/workspaces/{companyCode}/parts/{partId}/units/{unitId}/active` | 개별 부품 활성 여부 변경 |
| GET | `/api/workspaces/{companyCode}/standards` | 부품 기준 조회 |
| GET | `/api/workspaces/{companyCode}/standards/part-code/check` | 부품 코드 중복 확인 |

## 주요 규칙

- `partCode`는 같은 업체 안에서 중복될 수 없다.
- 부품 마스터는 모델 단위 정보만 가진다.
- 검수 상태, 등급, 판매 상태는 개별 부품 기준으로 관리한다.
- `grade = DEFECTIVE`인 개별 부품은 판매 가능 상태가 될 수 없다.
- 판매 상태 변경 시 `tb_part_status_history`를 저장한다.

## 하네스 포인트

- 부품 목록 검색과 필터링은 SQL에서 처리한다.
- 개별 부품 조회는 항상 `companyId`와 `partId` 범위를 함께 검증한다.
- 상태 변경은 Facade 트랜잭션 안에서 처리한다.
