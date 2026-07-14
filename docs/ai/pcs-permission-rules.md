# PCS Permission Rules

PCS 역할과 업무 권한의 정본입니다. 기능 문서는 이 내용을 반복하지 않고 예외만 기록합니다. 업체 범위 인증은 [Auth 기능 계약](../features/auth.md)을 함께 따릅니다.

## 역할 모델

| 역할 | 의미 | 기본 범위 |
|---|---|---|
| `OWNER` | 업체 소유·복구의 최종 책임자 | 회사·사용자·모든 업무 |
| `ADMIN` | 업체 내부 계정 관리자 | STAFF 관리·모든 일반 업무 |
| `STAFF` | 현장 업무 사용자 | 회사 설정·사용자 관리 외 일반 업무 |

권한은 결재 등급이 아닙니다. 품목, 분류, 거래처, 입출고, 검사 같은 일상 업무는 `STAFF`도 기본적으로 처리합니다.

## 기능별 기준

| 기능 | OWNER | ADMIN | STAFF |
|---|:---:|:---:|:---:|
| 회사 생성 | O | - | - |
| 회사 정보 조회·수정·활성 변경 | O | 정책상 허용된 조회만 | - |
| 사용자 목록·생성·수정 | O | O | - |
| STAFF 역할·상태·임시 비밀번호 | O | O | - |
| OWNER 계정 관리 | O | - | - |
| 내 정보 조회·수정 | O | O | O |
| 대시보드 | O | O | O |
| 품목·분류·사양·거래처 | O | O | O |
| 입고·검사·출고·재고 | O | O | O |
| 업무 이력 조회 | O | O | O |
| 확정 이력 수정·삭제 | - | - | - |

`ADMIN`은 OWNER를 강등·비활성화하거나 업체 소유권을 바꿀 수 없습니다. 별도 제한이 없는 `/api/workspaces/{companyCode}/**` 업무 API는 인증된 OWNER/ADMIN/STAFF 모두 접근할 수 있습니다.

## STAFF 업무 권한 스위치

업체는 STAFF 전체에 적용되는 업무 권한을 끌 수 있습니다. 기본값은 모두 허용이며 꺼진 항목만 `tb_company_staff_permission_disabled`에 저장합니다.

```text
STAFF_PARTNER_MANAGE
STAFF_PART_CREATE
STAFF_CATEGORY_MANAGE
STAFF_INBOUND
STAFF_INSPECTION
STAFF_OUTBOUND
```

규칙:

- 설정은 업체 단위이며 STAFF에게만 적용합니다.
- OWNER와 ADMIN의 업무 권한은 이 설정으로 제한하지 않습니다.
- 개별 STAFF 예외 권한은 현재 범위가 아닙니다. 필요하면 별도 정책과 테이블로 분리합니다.
- 권한이 꺼지면 관련 메뉴와 변경 API를 함께 막습니다. UI 숨김만으로 권한을 구현하지 않습니다.
- 일반 전표 목록·상세 조회는 작업공간 사용자에게 허용합니다.
- 입고 전표 생성은 `STAFF_INBOUND`, 출고 전표 생성·출고 후보 조회는 `STAFF_OUTBOUND`를 검사합니다.
- 전표 취소는 전표 유형에 따라 `STAFF_INBOUND` 또는 `STAFF_OUTBOUND`를 검사합니다.

품목 메뉴 표시는 다음 기준을 사용합니다.

- 사이드바에는 통합 메뉴 `부품 관리`만 둡니다.
- 품목 화면의 `품목 분류` 버튼은 `STAFF_CATEGORY_MANAGE`가 있을 때만 표시합니다.
- 실제 API도 같은 권한을 검사합니다.

## 변경·삭제 원칙

권한이 있다고 모든 데이터를 물리 삭제할 수 있는 것은 아닙니다.

- 참조 데이터는 연결 데이터가 없을 때만 삭제를 허용하거나 비활성 상태로 전환합니다.
- 입출고는 삭제 대신 취소와 반대 방향 movement 이력을 남깁니다.
- 검사와 상태 변경 이력은 수정·삭제하지 않습니다.
- 상세 생명주기 조건은 각 기능·DB 문서가 소유합니다.

## 구현 계약

- Controller에서 역할 문자열을 직접 비교하지 않습니다.
- 인증 사용자는 `PcsPrincipal`, 역할은 `MemberRole` enum을 사용합니다.
- URL 접근 제어는 `SecurityConfig`, 역할 그룹은 `PcsRoleGroups`를 사용합니다.
- 업무 권한 검사는 공통 validator/service를 통해 수행합니다.
- 역할 검사 전에 인증, 업체 범위, 회사 활성 상태를 검증합니다.
- 역할 부족과 업무 권한 부족은 공통 403 응답으로 처리합니다.
- 새 기능은 기본 업무 접근 여부를 먼저 판단하고, 차이가 있을 때만 기능 문서에 예외를 적습니다.

기능 문서 표기 예:

```text
- 권한 기준은 docs/ai/pcs-permission-rules.md를 따른다.
- 이 기능의 변경 API는 STAFF_INSPECTION이 필요하다.
```
