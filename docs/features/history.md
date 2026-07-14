# History Compatibility Guide

독립 `history` 도메인이나 `/api/**/history` API는 사용하지 않는다.

- 입출고 전표와 재고 변화 이력: `docs/features/stock.md`
- 검수·정정·재검수 이력: `docs/features/inspection-history.md`
- 개별 관리번호 통합 조회: `docs/features/part-unit.md`

하네스와 기존 링크에서 `history` 이름이 필요한 경우 위 기능을 묶는 호환 라우팅 이름으로만 사용한다. 새 규칙이나 API를 이 문서에 추가하지 않는다.
