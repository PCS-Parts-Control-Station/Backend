# Member Feature

## 목적

업체 작업자 계정, 권한, 임시 비밀번호, 마이페이지를 관리한다.

## 패키지

```text
com.pcs.domain.member
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/users` | 사용자 목록 |
| POST | `/api/workspaces/{companyCode}/users` | 사용자 생성 |
| GET | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 상세 |
| PATCH | `/api/workspaces/{companyCode}/users/{memberId}` | 사용자 수정 |
| PATCH | `/api/workspaces/{companyCode}/users/{memberId}/active` | 사용자 활성 여부 변경 |
| POST | `/api/workspaces/{companyCode}/users/{memberId}/temporary-password` | 임시 비밀번호 발급 |
| GET | `/api/workspaces/{companyCode}/users/staff-permissions` | STAFF 공통 업무 권한 조회 |
| PATCH | `/api/workspaces/{companyCode}/users/staff-permissions` | STAFF 공통 업무 권한 저장 |
| GET | `/api/workspaces/{companyCode}/mypage` | 내 정보 조회 |
| PATCH | `/api/workspaces/{companyCode}/mypage` | 내 정보 수정 |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` | 비밀번호 변경 |

## 주요 규칙

- `loginId`는 같은 업체 안에서 중복될 수 없다.
- OWNER는 회사 소유자 성격의 계정이다.
- OWNER 저장 규칙과 `ownerSlot` DB 기준은 `docs/features/member-db.md`를 따른다.
- 역할별 권한 기준은 `docs/ai/pcs-permission-rules.md`를 따른다.
- 사용자 삭제는 하지 않고 `docs/ai/pcs-status-lifecycle-rules.md` 기준의 `active` 상태만 변경한다.
- 사용자 관리 화면과 API는 로그인한 사용자가 관리 가능한 역할만 다룬다.
- OWNER는 ADMIN/STAFF를 조회, 검색, 생성, 수정, 임시 비밀번호 발급할 수 있다.
- ADMIN은 STAFF만 조회, 검색, 생성, 수정, 임시 비밀번호 발급할 수 있다.
- STAFF는 사용자 관리 기능에 접근하지 않는다.
- STAFF 업무 권한 설정은 개인별 권한이 아니라 업체 단위 공통 정책이며 `docs/ai/pcs-permission-rules.md` 기준을 따른다.
- STAFF 업무 권한은 꺼진 권한만 DB에 저장한다. 저장 row가 없으면 전체 허용이다.
- 마이페이지는 OWNER/ADMIN/STAFF 공통 계정 화면이다.
- 사이드바 톱니 아이콘은 모든 권한에서 마이페이지로 이동한다.
- 사용자 관리 화면은 OWNER/ADMIN만 접근하지만, 마이페이지는 STAFF도 접근할 수 있어야 한다.
- OWNER 마이페이지에는 회사 정보 영역을 포함하고, ADMIN/STAFF는 개인 계정과 역할별 안내를 중심으로 구성한다.
- 마이페이지 입력 폼과 주요 작업은 왼쪽 본문에 배치한다.
- 마이페이지 오른쪽 패널에는 입력 폼을 두지 않고 계정 요약, 권한별 안내, 빠른 이동, 계정 기준 같은 읽기용 보조 정보만 둔다.
- 마이페이지에서 이름은 본인 계정만 수정한다.
- 마이페이지 비밀번호 변경은 현재 비밀번호 확인 후 처리하며, 성공 시 `password_status`를 `ACTIVE`로 바꾸고 임시 비밀번호 만료값을 비운다.
- 비밀번호 변경 성공 시 해당 계정의 활성 refresh token을 모두 폐기하고 access token도 브라우저에서 제거한 뒤 다시 로그인하게 한다.
- 사용자 생성 시 초기 비밀번호는 로그인 아이디와 동일하게 발급하고 `TEMPORARY` 상태로 저장한다.
- 임시 비밀번호 재발급 시 원문 비밀번호는 응답에서 한 번만 보여주고 DB에는 해시만 저장한다.
- 임시 비밀번호 재발급 시 갱신 대상 row가 없으면 성공으로 처리하지 않고 `MEMBER_NOT_FOUND`를 반환한다.
- 임시 비밀번호 재발급 즉시 해당 계정의 기존 refresh token을 모두 `ADMIN_REVOKED`로 폐기한다.
- 임시 비밀번호 원문은 다시 조회할 수 없다. 분실하면 새 임시 비밀번호를 다시 발급한다.
- 임시 비밀번호 상태에서는 내 세션/마이페이지 조회, 비밀번호 변경, 로그아웃만 허용하고 나머지 업무 API는 `MEMBER_PASSWORD_CHANGE_REQUIRED`로 차단한다.

## 목록 / 검색 응답

- 사용자 목록은 `PageResultDto` 구조를 사용한다.
- `summary.totalCount`, `summary.adminCount`, `summary.staffCount`는 현재 검색 조건과 관리 가능 역할 범위 기준으로 계산한다.
- 프론트는 현재 페이지 행을 직접 세서 요약을 만들지 않고 서버 summary를 사용한다.

## STAFF 권한 설정 응답

- `permissions[].code`는 `StaffPermission` enum 값을 사용한다.
- `permissions[].enabled`가 `false`이면 해당 업체의 모든 STAFF에게 메뉴와 업무 API를 열지 않는다.
- `/api/workspaces/{companyCode}/me` 응답의 `staffPermissions`는 현재 세션이 사용할 수 있는 STAFF 업무 권한 목록이다.

## 하네스 포인트

- 사용자 생성/수정 Request DTO에는 validation을 둔다.
- 권한 변경은 `docs/ai/pcs-permission-rules.md` 기준으로 인증 사용자 권한 검증을 거쳐야 한다.
- 비밀번호 해시는 Service 계층 밖으로 노출하지 않는다.
