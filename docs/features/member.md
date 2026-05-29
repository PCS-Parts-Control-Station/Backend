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
| GET | `/api/workspaces/{companyCode}/mypage` | 내 정보 조회 |
| PATCH | `/api/workspaces/{companyCode}/mypage` | 내 정보 수정 |
| PATCH | `/api/workspaces/{companyCode}/mypage/password` | 비밀번호 변경 |

## 주요 규칙

- `loginId`는 같은 업체 안에서 중복될 수 없다.
- OWNER는 회사 소유자 성격의 계정이다.
- OWNER 저장 규칙과 `ownerSlot` DB 기준은 `docs/features/member-db.md`를 따른다.
- ADMIN은 사용자, 거래처, 카테고리, 기준 관리 권한을 가진다.
- STAFF는 입고, 검수, 출고, 이력 조회 중심 권한을 가진다.
- 사용자 삭제는 하지 않고 `active` 상태만 변경한다.

## 하네스 포인트

- 사용자 생성/수정 Request DTO에는 validation을 둔다.
- 권한 변경은 인증 사용자 권한 검증을 거쳐야 한다.
- 비밀번호 해시는 Service 계층 밖으로 노출하지 않는다.
