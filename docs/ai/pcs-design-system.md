# PCS Design System

이 문서는 PCS 화면 디자인의 최상위 공통 기준이다.

세부 화면 패턴은 `docs/ai/design/*.md`에 나누어 둔다. 새 화면을 만들거나 기존 화면을 수정할 때는 이 문서와 해당 화면 유형의 하위 문서를 함께 확인한다.

## 적용 대상

모든 PCS 화면에 적용한다.

- 공개 페이지
- 회사 등록 / 로그인 페이지
- 로그인 후 업무 관리 화면
- 목록, 등록, 상세, 이력 화면

## 하위 디자인 문서

```text
docs/ai/design/public-pages.md
docs/ai/design/workspace-layout.md
docs/ai/design/responsive-layout.md
docs/ai/design/dashboard.md
docs/ai/design/data-table.md
docs/ai/design/form-panel.md
docs/ai/design/workflow-panel.md
docs/ai/design/detail-page.md
docs/ai/design/history-timeline.md
```

문서 역할:

- `public-pages.md`: `/`, `/company/register`, `/w`, `/w/{companyCode}` 같은 업무공간 밖 화면
- `workspace-layout.md`: 로그인 후 좌측 사이드바 기반 업무 화면 공통 레이아웃
- `responsive-layout.md`: 업무 화면 반응형, 햄버거 사이드바, 테이블 모바일 전환
- `dashboard.md`: 운영 현황, 통계, 우선 처리 목록
- `data-table.md`: 검색/필터/목록/요약 테이블
- `form-panel.md`: 오른쪽 등록/수정 패널, 보조 메모 패널
- `workflow-panel.md`: 입고/검수/출고/이력 화면의 오른쪽 업무 흐름 보조 패널
- `detail-page.md`: 부품 상세, 사용자 상세, 거래처 상세
- `history-timeline.md`: 이력 관리, 개별 부품 타임라인

각 HTML은 자기 화면 유형에 해당하는 디자인 문서와 불일치가 없어야 한다.

## 디자인 방향

PCS는 중고 PC 부품을 관리번호 단위로 추적하는 국내 업무용 재고관리 시스템이다.

핵심은 `관리번호 기반 개별 부품 추적`, `입고`, `검수`, `재고`, `출고`, `이력`이 한눈에 이해되는 B2B SaaS 스타일이다.

현재 기준:

- 화이트/아주 밝은 블루 배경 기반의 차분한 SaaS 톤
- 포인트 컬러는 블루 계열 중심
- 제목은 명확하게, 설명문은 짧고 실무적으로 작성
- 카드, 입력창, 버튼은 8px radius를 기본으로 사용
- 그림자는 약하게만 사용하고, 섹션 구분은 배경색과 여백으로 만든다
- 상태값은 배지로 표현한다
- 관리번호, 검수상태, 판매상태, 재고, 최근이력처럼 실제 운영 데이터가 보이게 구성한다

## 색상 토큰

```css
:root {
    --page: #f7faff;
    --surface: #ffffff;
    --surface-soft: #f1f6ff;

    --navy: #071426;
    --navy-2: #0c1d33;
    --navy-3: #10263f;

    --ink: #0f172a;
    --text: #334155;
    --muted: #64748b;
    --subtle: #94a3b8;

    --line: #e2e8f0;
    --line-strong: #cbd5e1;

    --cyan: #2563eb;
    --cyan-dark: #1d4ed8;
    --cyan-soft: #eaf2ff;
    --primary-faint: #eff6ff;

    --green: #16a34a;
    --green-soft: #eaf8ef;
    --orange: #d97706;
    --orange-soft: #fff5e5;
    --blue: #2563eb;
    --blue-soft: #eef5ff;
    --gray: #64748b;
    --gray-soft: #f1f5f9;
    --red: #dc2626;
    --red-soft: #fff1f1;

    --shadow-sm: 0 1px 2px rgba(7, 20, 38, 0.06);
    --shadow-md: 0 18px 44px rgba(37, 99, 235, 0.12);
    --radius: 8px;
    --control-height: 48px;
    --content-width: 1180px;
}
```

사용 기준:

- `--page`: 전체 페이지 배경
- `--surface`: 카드, 패널, 입력 영역의 기본 표면
- `--surface-soft`: 요약 카드, 관리번호 박스, 보조 패널 배경
- `--navy`: 큰 제목, 핵심 숫자, 관리번호
- `--ink`: 일반 제목과 강한 본문
- `--text`: 본문 텍스트
- `--muted`: 설명문, 보조 텍스트
- `--subtle`: placeholder, 약한 보조 텍스트
- `--cyan`: 주요 버튼, 링크 hover, 핵심 강조
- `--line`: 기본 경계선
- `--line-strong`: 입력창, 보조 버튼 경계선

색상 사용 제한:

- 포인트 컬러는 기본적으로 블루 계열 하나만 강하게 사용한다.
- 초록, 주황, 빨강은 상태 배지에만 사용한다.
- 배경 전체를 진한 네이비로 바꾸지 않는다.
- 형광색, 강한 그라데이션, 과한 보라색 계열은 사용하지 않는다.

## 타이포그래피

기본 폰트:

```css
font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Malgun Gothic", sans-serif;
```

관리번호, 업체 코드, 내부 상태값:

```css
font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
```

기준:

- `letter-spacing`은 기본 0을 유지한다.
- 큰 제목은 굵고 명확하게 사용한다.
- 업무 화면 내부 제목은 짧게 쓴다.
- 설명문은 기능 설명보다 실제 운영 상황이 떠오르게 쓴다.
- `Dashboard`, `Parts`, `Inbound` 같은 영어 라벨보다 `운영 현황`, `부품 관리`, `입고 관리` 같은 한국어 업무 용어를 우선한다.

## 버튼

버튼은 `8px` radius와 `48px` 기본 높이를 사용한다.

```css
.btn {
    min-height: var(--control-height);
    padding: 0 18px;
    border: 1px solid transparent;
    border-radius: var(--radius);
    font-size: 15px;
    font-weight: 800;
}
```

Primary:

```css
.btn-primary {
    border-color: var(--cyan);
    background: var(--cyan);
    color: #ffffff;
    box-shadow: 0 8px 20px rgba(37, 99, 235, 0.18);
}
```

Secondary:

```css
.btn-secondary {
    border-color: var(--line-strong);
    background: rgba(255, 255, 255, 0.86);
    color: var(--ink);
}
```

사용 기준:

- Primary: 회사 등록, 저장, 생성, 확정, 검색
- Secondary: 업체 로그인, 취소, 보조 이동, 초기화
- 한 화면에서 primary는 핵심 행동 1개를 우선한다.

## 입력 요소

입력창은 버튼과 같은 높이를 사용한다.

```css
input,
select {
    height: var(--control-height);
    border: 1px solid var(--line-strong);
    border-radius: var(--radius);
    background: var(--surface);
}

input:focus,
select:focus,
textarea:focus {
    border-color: var(--cyan);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
}
```

기준:

- 입력창과 버튼 높이는 맞춘다.
- placeholder는 `--subtle`을 사용한다.
- 입력 패널은 흰색 표면과 얇은 경계선을 사용한다.
- 폼 설명은 짧게 쓴다.

## 카드와 패널

기본 카드:

```css
border: 1px solid var(--line);
border-radius: var(--radius);
background: rgba(255, 255, 255, 0.92);
box-shadow: var(--shadow-sm);
```

사용 기준:

- 반복되는 현장 사용 사례
- 문제 카드
- 기능 카드
- 입력 패널
- 목록/요약/보조 패널

금지:

- 페이지 섹션 전체를 의미 없이 카드로 감싸기
- 카드 안에 또 카드 넣기
- 큰 그림자 남발
- 카드마다 다른 radius를 즉흥적으로 사용하기

## 상태 배지

상태값은 텍스트만 쓰지 않고 배지로 표현한다.

```css
.badge {
    display: inline-flex;
    justify-content: center;
    min-height: 26px;
    padding: 0 9px;
    border: 1px solid transparent;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 800;
    line-height: 24px;
    white-space: nowrap;
}
```

상태 기준:

- 검수완료: green
- 검수대기: orange
- 판매가능: blue
- 판매보류: orange
- 불량: red
- 출고차단: red
- 사용 중: green
- 사용 안 함: gray

상태 배지는 한 화면에서 너무 크게 보이면 안 된다. 관리자가 빠르게 스캔할 수 있는 작은 pill 형태를 유지한다.

## 코드형 Chip

관리번호, 업체 코드, 내부 상태값처럼 시스템 기준값은 작은 chip으로 표현할 수 있다.

```css
.code-chip {
    display: inline-flex;
    align-items: center;
    min-height: 28px;
    padding: 0 9px;
    border-radius: 6px;
    background: var(--surface-soft);
    color: var(--cyan-dark);
    font-family: var(--ff-mono);
    font-size: 12px;
    font-weight: 800;
}
```

예:

```text
PCS-CPU-000124
pcs-seoul
unit.serial
status.history
```

## 접근성

기준:

- 의미 있는 섹션에는 `aria-labelledby`를 사용한다.
- 장식 이미지는 빈 `alt`를 사용한다.
- 자동 움직임은 hover/focus에서 멈출 수 있어야 한다.
- `prefers-reduced-motion: reduce`를 지원한다.
- 버튼과 링크 텍스트는 목적이 명확해야 한다.

## 문구 기준

PCS 화면은 추상적인 표현보다 현장 상황을 직접 떠올릴 수 있는 문구를 사용한다.

좋은 방향:

```text
입고부터 출고까지, 부품 하나의 이력을 놓치지 마세요.
RAM, SSD, GPU가 한 번에 들어오는 날
같은 모델인데 상태가 다른 부품을 판매할 때
수리 후 남은 부품을 다시 보관할 때
```

피해야 할 방향:

```text
비즈니스의 혁신을 시작하세요.
효율적인 운영을 경험하세요.
새로운 재고관리 패러다임.
```

## 로고

로고 파일:

```text
src/main/resources/static/images/parts-control-station-icon.svg
```

로고는 현재 블루 기반 팔레트와 맞춰 사용한다. 로고만 별도의 강한 색상으로 튀게 만들지 않는다.

## 새 페이지 작성 규칙

공개 페이지 또는 독립 화면:

```text
src/main/resources/static/{page}.html
src/main/resources/static/css/{page}.css
src/main/resources/static/js/{page}.js
```

업무 관리 화면:

```text
src/main/resources/static/{page}.html
src/main/resources/static/css/admin.css
```

업무 화면은 `admin.css` 공통 레이아웃을 우선 사용한다. 개별 CSS는 해당 화면에만 필요한 복잡한 예외가 있을 때만 만든다. JS 파일은 실제 상호작용이나 API 연동이 있을 때만 만든다.

## 디자인 변경 규칙

화면별로 즉흥적으로 색, 버튼, 카드 스타일을 바꾸지 않는다.

디자인을 바꿀 때:

1. 해당 화면 유형의 디자인 문서를 먼저 수정한다.
2. 수정된 기준에 맞춰 화면을 수정한다.
3. 완성된 화면에서 반복 가능한 패턴이 생기면 다시 디자인 문서에 반영한다.
4. 데스크톱과 모바일에서 텍스트가 잘리지 않는지 확인한다.

이 문서와 하위 디자인 문서가 현재 PCS 화면 디자인의 기준이다.
