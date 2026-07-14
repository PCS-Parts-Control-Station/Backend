# Detail Page Design

한 대상을 깊게 확인하는 상세 화면 기준이다. 목록에서 반복 확인하는 상세는 별도 페이지보다 `side-drawer.md`를 우선 검토한다.

## 구조

```text
detail-header
detail-summary
detail-content
- main-detail-area
- side-summary-panel 선택
```

## Header

- 대상 이름, 보조 식별값, 현재 상태, 주요 행동을 둔다.
- 식별값은 code chip을 사용할 수 있다.
- destructive action은 primary와 섞지 않는다.

## Summary

- 현재 판단에 필요한 상태·수량 3~5개만 둔다.
- 숫자와 상태 badge를 사용한다.
- 목록·API summary와 다른 계산을 화면에서 만들지 않는다.

## Content

- 정보가 많을 때만 실제 전환 단위의 탭을 사용한다.
- 중첩 탭을 만들지 않는다.
- 이력 탭은 `history-timeline.md`를 따른다.
- 개별 부품 목록은 관리번호와 서로 다른 unit 상태가 첫눈에 보이게 한다.

## Side summary

- 기본 정보와 읽기용 맥락만 둔다.
- 긴 편집 폼을 넣지 않는다.
- 수정은 명확한 edit mode, 드로어, 모달 또는 별도 화면으로 분리한다.

## 반응형

- 좁은 폭에서 side summary를 본문 아래로 이동한다.
- summary는 1~2열로 줄인다.
- 긴 unit 목록은 `data-table.md`의 모바일 전환을 따른다.
