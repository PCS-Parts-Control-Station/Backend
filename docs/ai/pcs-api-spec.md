# PCS API Route Index

feature 문서의 API 계약을 경로로 찾기 위한 파생 인덱스다. 설명·요청·응답·권한의 원본은 `docs/features/{feature}.md`다.

## 사용

- 신규 또는 불명확한 경로를 확인할 때만 도메인·URL로 이 문서를 검색한다.
- 상세 계약은 표의 feature 문서에서 확인한다.
- 응답은 `pcs-backend-common-rules.md`, 페이징은 `pcs-pagination-rules.md`, 권한은 `pcs-permission-rules.md`를 따른다.
- 업체 업무 API는 `/api/workspaces/{companyCode}/**`, 실제 데이터 처리는 `/api/**`에 둔다.

## Auth — `auth.md`

| Method | Path |
|---|---|
| POST | `/api/owners/login` |
| POST | `/api/workspaces/login` |
| POST | `/api/workspaces/{companyCode}/login` |
| POST | `/api/auth/refresh` |
| POST | `/api/auth/logout` |
| GET | `/api/workspaces/{companyCode}/me` |

## Company — `company.md`

| Method | Path |
|---|---|
| POST | `/api/owners/signup` |
| GET | `/api/workspaces/{companyCode}/public-info` |
| GET | `/api/owners/company` |
| PATCH | `/api/owners/company` |

## Member / Mypage — `member.md`, `mypage.md`

| Method | Path |
|---|---|
| GET, POST | `/api/workspaces/{companyCode}/users` |
| GET, PATCH | `/api/workspaces/{companyCode}/users/{memberId}` |
| POST | `/api/workspaces/{companyCode}/users/{memberId}/temporary-password` |
| GET, PATCH | `/api/workspaces/{companyCode}/users/staff-permissions` |
| GET, PATCH | `/api/workspaces/{companyCode}/mypage` |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` |

## Partner — `partner.md`

| Method | Path |
|---|---|
| GET, POST | `/api/workspaces/{companyCode}/partners` |
| GET, PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}` |
| PATCH | `/api/workspaces/{companyCode}/partners/{partnerId}/active` |

## Category — `category.md`

| Method | Path |
|---|---|
| GET, POST | `/api/workspaces/{companyCode}/categories` |
| GET, PATCH, DELETE | `/api/workspaces/{companyCode}/categories/{categoryId}` |

## Part / Part Unit — `part.md`, `part-unit.md`

| Method | Path |
|---|---|
| GET, POST | `/api/workspaces/{companyCode}/parts` |
| GET, PATCH | `/api/workspaces/{companyCode}/parts/{partId}` |
| GET | `/api/workspaces/{companyCode}/part-units` |
| GET | `/api/workspaces/{companyCode}/part-units/{unitId}` |

## Stock — `stock.md`

| Method | Path |
|---|---|
| POST | `/api/workspaces/{companyCode}/stock/documents/inbounds` |
| GET | `/api/workspaces/{companyCode}/stock/outbound-candidates` |
| POST | `/api/workspaces/{companyCode}/stock/documents/outbounds` |
| POST | `/api/workspaces/{companyCode}/stock/documents/{documentId}/cancel` |
| GET | `/api/workspaces/{companyCode}/stock/documents` |
| GET | `/api/workspaces/{companyCode}/stock/documents/{documentId}` |

## Inspection write — `inspection.md`

| Method | Path |
|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents` |
| GET | `/api/workspaces/{companyCode}/inspections/waiting-documents/{documentId}/units` |
| POST | `/api/workspaces/{companyCode}/inspections` |
| POST | `/api/workspaces/{companyCode}/inspections/bulk` |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/corrections` |
| POST | `/api/workspaces/{companyCode}/inspections/{inspectionId}/reinspections` |

## Inspection history — `inspection-history.md`

| Method | Path |
|---|---|
| GET | `/api/workspaces/{companyCode}/inspections/history-documents` |
| GET | `/api/workspaces/{companyCode}/inspections` |
| GET | `/api/workspaces/{companyCode}/inspections/{inspectionId}` |

## Inspection template — `inspection-template.md`

| Method | Path |
|---|---|
| GET, POST | `/api/workspaces/{companyCode}/inspection-templates` |
| GET, PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/active` |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/active` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/sort-order` |
| POST | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/{optionId}/active` |
| PATCH | `/api/workspaces/{companyCode}/inspection-templates/{templateId}/items/{itemId}/options/sort-order` |

## Dashboard — `dashboard.md`

| Method | Path |
|---|---|
| GET | `/api/workspaces/{companyCode}/dashboard` |

별도 `/history/*` API는 사용하지 않는다. 입출고 이력은 stock, 검수 이력은 inspection 경로를 사용한다.
