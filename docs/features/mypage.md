# Mypage Feature

## 목적

로그인한 사용자의 계정 정보 확인, 이름 수정, 비밀번호 변경, 역할별 계정 정보를 담당한다.
사용자 관리 기능은 `docs/features/member.md`를 따른다.

## 패키지

```text
com.pcs.domain.member
```

## API

| Method | API | 설명 |
|---|---|---|
| GET | `/api/workspaces/{companyCode}/mypage` | 내 정보 조회 |
| PATCH | `/api/workspaces/{companyCode}/mypage` | 내 이름 수정 |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` | 내 비밀번호 변경 |

OWNER의 회사 정보 조회와 수정은 회사 도메인의 `/api/owners/company` API를 사용한다.

## 응답 기준

`MypageResponse`는 아래 값을 반환한다.

```text
companyId
companyCode
memberId
loginId
name
role
passwordStatus
staffPermissions
```

- `loginId`, `role`, `passwordStatus`는 마이페이지에서 수정하지 않는다.
- `staffPermissions`는 현재 세션에서 사용할 수 있는 STAFF 업무 권한 목록이다.
- OWNER/ADMIN은 역할상 전체 업무가 가능하므로 STAFF 권한 목록에 의존하지 않는다.

## 주요 규칙

- 마이페이지는 OWNER/ADMIN/STAFF 모두 접근할 수 있다.
- URL의 `companyCode`와 JWT의 업체 정보가 다르면 실패한다.
- 비활성 회사 또는 비활성 사용자는 마이페이지를 사용할 수 없다.
- 마이페이지에서 수정 가능한 회원 필드는 본인 `name`뿐이다.
- 이름 수정 요청은 `UpdateMypageRequest.name`만 받는다.
- 비밀번호 변경은 현재 비밀번호, 새 비밀번호, 새 비밀번호 확인을 모두 검증한다.
- 새 비밀번호는 8자 이상 72자 이하이다.
- 비밀번호 변경 성공 시 `password_status = ACTIVE`, `temp_password_expires_at = NULL`, `password_changed_at = NOW(6)`으로 갱신한다.
- 비밀번호 변경 성공 시 해당 회원의 refresh token을 모두 폐기한다.
- 프론트는 비밀번호 변경 성공 후 브라우저 세션을 제거하고 로그인 화면으로 이동한다.
- 임시 비밀번호 상태에서는 마이페이지 조회, 비밀번호 변경, 로그아웃만 허용하고 나머지 업무 API는 `MEMBER_PASSWORD_CHANGE_REQUIRED`로 차단한다.
- 임시 비밀번호 상태에서는 이름 수정과 회사 정보 수정 같은 보조 작업을 막고 비밀번호 변경을 우선한다.

## OWNER 회사 정보

- OWNER 마이페이지는 회사 정보를 함께 보여줄 수 있다.
- 회사 정보 저장은 `docs/features/company.md`의 OWNER 회사 API 기준을 따른다.
- 회사 정보 저장 실패가 마이페이지 계정 정보 저장을 롤백하지 않는다. 서로 다른 API로 처리한다.

## 하네스 포인트

- 마이페이지 API는 `@AuthenticationPrincipal PcsPrincipal`을 기준으로 본인 계정만 조회/수정한다.
- `memberId`를 요청 body나 query에서 받지 않는다.
- 비밀번호 해시는 응답에 노출하지 않는다.
- 비밀번호 변경과 refresh token 폐기는 Facade 트랜잭션 안에서 함께 처리한다.
