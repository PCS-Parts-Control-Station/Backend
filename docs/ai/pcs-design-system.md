# PCS Design System

이 문서는 PCS 화면 디자인의 현재 기준이다.

현재 기준은 `/` 메인 페이지의 실제 구현을 기준으로 정리한다. 새 화면을 만들거나 기존 화면을 수정할 때는 이 문서를 먼저 확인한다. 디자인 방향을 바꿀 때는 개별 화면을 먼저 수정하지 말고 이 문서를 먼저 갱신한 뒤 화면에 반영한다.

## 디자인 방향

PCS는 중고 PC 부품을 관리번호 단위로 추적하는 국내 업무용 재고관리 시스템이다.

메인 화면은 단순한 관리자 페이지보다 한 단계 더 소개성이 있어야 한다. 하지만 과장된 마케팅 페이지처럼 보이면 안 된다. 핵심은 `관리번호 기반 개별 부품 추적`, `입고`, `검수`, `재고`, `출고`, `이력`이 한눈에 이해되는 B2B SaaS 스타일이다.

현재 기준:

- 화이트/아주 밝은 블루 배경 기반의 차분한 SaaS 톤
- 포인트 컬러는 블루 계열 중심
- 제목은 크고 명확하게, 설명문은 짧고 실무적으로 작성
- 전체 레이아웃은 중앙 콘텐츠 폭을 유지하되 핵심 섹션은 풀블리드 밴드로 전환
- 카드, 입력창, 버튼은 8px radius를 기본으로 사용
- 그림자는 약하게만 사용하고, 섹션 구분은 배경색과 여백으로 만든다
- 상태값은 배지로 표현한다
- 메인 화면에서는 `관리번호`, `검수등급`, `검수상태`, `판매상태`, `보관위치`, `최근이력` 같은 실제 운영 데이터를 보여준다

## 색상 토큰

현재 메인 페이지의 색상 기준이다. 새 페이지도 이 토큰을 우선 사용한다.

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
- `--surface-soft`: 미리보기 요약 카드, 관리번호 박스, 부드러운 강조 배경
- `--navy`: 큰 제목, 핵심 숫자, 관리번호
- `--ink`: 일반 제목과 강한 본문
- `--text`: 본문 텍스트
- `--muted`: 설명문, 보조 텍스트
- `--subtle`: placeholder, 약한 보조 텍스트
- `--cyan`: 주요 버튼, 링크 hover, 핵심 강조
- `--primary-faint`: Hero 상단의 아주 연한 배경 그라데이션
- `--line`: 기본 경계선
- `--line-strong`: 입력창, 보조 버튼 경계선

색상 사용 제한:

- 포인트 컬러는 기본적으로 블루 계열 하나만 강하게 사용한다.
- 초록, 주황, 빨강은 상태 배지에만 사용한다.
- 배경 전체를 진한 네이비로 바꾸지 않는다.
- 형광색, 강한 그라데이션, 과한 보라색 계열은 사용하지 않는다.

## 상태 배지

상태값은 텍스트만 쓰지 않고 배지로 표현한다.

현재 메인 화면 기준:

```text
검수완료: green
검수대기: orange
판매가능: blue
판매보류: orange
불량: red
출고차단: red
```

기본 스타일:

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

상태 배지는 한 화면에서 너무 크게 보이면 안 된다. 관리자가 빠르게 스캔할 수 있는 작은 pill 형태를 유지한다.

## 타이포그래피

기본 폰트:

```css
font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Malgun Gothic", sans-serif;
```

관리번호, 코드형 값:

```css
font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
```

기준:

- `letter-spacing`은 기본 0을 유지한다.
- 큰 제목은 굵고 명확하게 사용한다.
- 업무 화면 내부의 제목은 짧게 쓴다.
- 설명문은 기능 설명보다 실제 운영 상황이 떠오르게 쓴다.
- `Dashboard`, `Parts`, `Inbound` 같은 영어 라벨보다 `운영 현황`, `부품 관리`, `입고 관리` 같은 한국어 업무 용어를 우선한다.

메인 Hero 제목:

```css
h1 {
    max-width: 900px;
    margin: 0 auto;
    font-size: clamp(42px, 5.7vw, 68px);
    font-weight: 800;
    line-height: 1.1;
}
```

섹션 제목:

```css
.section-heading h2 {
    font-size: clamp(32px, 4vw, 48px);
    font-weight: 800;
    line-height: 1.18;
}
```

대형 강조 섹션:

```css
.use-case-section .section-heading h2 {
    font-size: clamp(38px, 4.6vw, 58px);
}

.cta-box h2 {
    font-size: clamp(40px, 4.8vw, 60px);
}
```

## 레이아웃

기본 콘텐츠 폭:

```css
--content-width: 1180px;
```

일반 섹션은 중앙 콘텐츠 폭 안에 둔다.

```css
.section,
.section-inner {
    width: min(var(--content-width), calc(100% - 48px));
    margin: 0 auto;
}
```

모바일에서는 좌우 여백을 16px씩 유지한다.

```css
@media (max-width: 720px) {
    .section,
    .section-inner {
        width: min(calc(100% - 32px), var(--content-width));
    }
}
```

## 풀블리드 섹션

메인 화면에는 중간중간 화면 양옆을 꽉 채우는 풀블리드 밴드를 사용한다.

현재 풀블리드 대상:

- `현장 사용 사례`
- `업무공간 만들기`

풀블리드 섹션의 목적:

- 페이지 리듬을 만든다
- 핵심 메시지를 강하게 보여준다
- 일반 카드 나열 구간과 CTA 구간을 명확히 분리한다

기본 구조:

```html
<section class="full-bleed-section">
    <div class="section-inner">
        ...
    </div>
</section>
```

기준:

- 배경은 화면 전체 폭을 채운다.
- 텍스트와 버튼은 중앙 콘텐츠 폭 안에 둔다.
- 너무 많은 섹션을 풀블리드로 만들지 않는다.
- 한 페이지에서 1~3개 정도만 사용한다.
- 현재 메인에서는 `현장 사용 사례`, `업무공간 만들기`만 풀블리드로 유지한다.

## 섹션 리듬

현재 메인 화면의 섹션 흐름:

```text
Header
Hero
관리자 화면 미리보기
현장 사용 사례
현장에서 자주 생기는 문제
PCS 핵심 기능
업무공간 만들기
Footer
```

역할:

- `Hero`: 서비스 정체성과 핵심 메시지 전달
- `관리자 화면 미리보기`: PCS가 실제 업무 시스템이라는 인상 제공
- `현장 사용 사례`: PCS가 쓰이는 구체적인 현장 설명
- `현장에서 자주 생기는 문제`: 도입 필요성 제기
- `PCS 핵심 기능`: 문제에 대한 해결 방식 설명
- `업무공간 만들기`: 최종 행동 유도

크기 기준:

- Hero는 이미 충분히 크므로 강제로 `100vh`를 만들지 않는다.
- `현장 사용 사례`는 대형 풀블리드 섹션으로 둔다.
- `현장에서 자주 생기는 문제`는 보조 섹션이므로 과하게 키우지 않는다.
- `PCS 핵심 기능`은 문제 제기 다음에 오되, 충분한 위 여백으로 분리한다.
- `업무공간 만들기`는 하단 대형 CTA 밴드로 둔다.

현재 여백 기준:

```css
.use-case-section {
    min-height: clamp(640px, 82svh, 820px);
    padding: 112px 0;
}

.question-section {
    padding-top: 84px;
}

.features-section {
    padding-top: 124px;
}

.cta-section {
    min-height: clamp(540px, 72svh, 720px);
    padding: 112px 0;
}
```

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

- Primary: 회사 등록, 저장, 생성, 확정
- Secondary: 업체 로그인, 취소, 보조 이동
- 한 화면에서 primary는 핵심 행동 1개를 우선한다.
- CTA 영역에서는 primary와 secondary를 한 쌍으로 둘 수 있다.

## 입력 폼

입력창은 버튼과 같은 높이를 사용한다.

```css
input {
    height: var(--control-height);
    border: 1px solid var(--line-strong);
    border-radius: var(--radius);
    background: var(--surface);
}

input:focus {
    border-color: var(--cyan);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
}
```

입력 폼 기준:

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
- 미리보기 내부 요약 카드

금지:

- 페이지 섹션 전체를 의미 없이 카드로 감싸기
- 카드 안에 또 카드 넣기
- 큰 그림자 남발
- 카드마다 다른 radius를 즉흥적으로 사용하기

## 관리자 화면 미리보기

메인 화면의 미리보기는 실제 PCS 관리자 화면처럼 보여야 한다.

포함 정보:

- 관리번호
- 부품명
- 검수등급
- 검수상태
- 판매상태
- 보관위치
- 최근이력

미리보기 구조:

```text
상단 툴바
사이드 메뉴
요약 숫자
관리번호 박스
상태 테이블
```

사이드 메뉴 라벨은 한국어 업무 용어를 사용한다.

```text
운영 현황
부품 관리
입고 관리
검수 관리
출고 관리
이력 관리
```

미리보기는 실제 기능이 아니라 메인 화면의 제품 이해를 돕는 시각 자료다. 따라서 너무 많은 데이터를 넣지 말고, PCS의 핵심인 `개별 부품 상태 추적`만 드러낸다.

## 현장 사용 사례 카드

현장 사용 사례는 자동으로 흐르는 카드 트랙을 사용한다.

기준:

- CSS 기반 marquee 애니메이션
- 같은 카드 묶음을 한 번 복제해 끊김 없이 반복
- hover 또는 focus 시 애니메이션 일시 정지
- `prefers-reduced-motion: reduce`에서는 애니메이션 제거 후 일반 그리드로 표시

카드 예시:

```text
PC방 일괄 매입
RAM, SSD, GPU가 한 번에 들어오는 날
거래처 전표로 묶고, 부품마다 관리번호를 발급해 검수 대기와 판매 가능 수량을 나눠 봅니다.
```

애니메이션 기준:

```css
.use-case-track {
    display: flex;
    width: max-content;
    gap: 14px;
    animation: useCaseMarquee 34s linear infinite;
}
```

금지:

- 빠르게 튀는 슬라이드
- 카드가 갑자기 사라지는 전환
- 사용자가 읽기 어려울 정도로 빠른 속도
- JS가 꼭 필요하지 않은 단순 애니메이션에 JS 추가

## 장식 요소

PCS는 관리번호와 부품 추적을 강조하기 위해 은은한 바코드/관리번호 느낌의 장식을 사용할 수 있다.

사용 기준:

- opacity는 낮게 유지한다.
- 카드 우측 상단, Hero 주변, CTA 주변에만 제한적으로 사용한다.
- 장식은 콘텐츠보다 눈에 띄면 안 된다.
- 장식만으로 화면을 채우지 않는다.

## 반응형 기준

모바일 기준:

- Header nav는 2열 버튼형으로 전환한다.
- Hero CTA 버튼은 세로로 쌓는다.
- 미리보기 테이블은 카드형 행으로 전환한다.
- 사용 사례 카드 애니메이션은 유지하되, 텍스트가 잘리지 않게 카드 폭을 확보한다.
- 긴 섹션 제목은 모바일에서 `29px` 전후로 낮춘다.

현재 기준:

```css
@media (max-width: 720px) {
    .section-heading h2,
    .cta-box h2 {
        font-size: 29px;
        line-height: 1.24;
    }

    .section-heading.center {
        max-width: 330px;
    }
}
```

## 접근성

기준:

- 의미 있는 섹션에는 `aria-labelledby`를 사용한다.
- 장식 이미지는 빈 `alt`를 사용한다.
- 자동 움직임은 hover/focus에서 멈출 수 있어야 한다.
- `prefers-reduced-motion: reduce`를 지원한다.
- 버튼과 링크 텍스트는 목적이 명확해야 한다.

`prefers-reduced-motion` 기준:

```css
@media (prefers-reduced-motion: reduce) {
    .use-case-grid {
        overflow: visible;
        -webkit-mask-image: none;
        mask-image: none;
    }

    .use-case-track {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        width: auto;
        animation: none;
    }
}
```

## 문구 기준

PCS 메인 화면은 추상적인 표현보다 현장 상황을 직접 떠올릴 수 있는 문구를 사용한다.

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

새 정적 페이지를 만들 때:

```text
src/main/resources/static/{page}.html
src/main/resources/static/css/{page}.css
src/main/resources/static/js/{page}.js
```

기준:

- 전체 배경은 `--page`
- 주요 표면은 `--surface`
- 경계선은 `--line`
- 주요 버튼은 `--cyan`
- 설명문은 `--muted`
- 반복 항목은 8px radius 카드
- 상태값은 badge로 표현
- 업무 화면에서는 한국어 업무 용어를 우선 사용
- 관리번호, 상태, 이력 등 실제 운영 데이터가 보이게 구성

## 디자인 변경 규칙

화면별로 즉흥적으로 색, 버튼, 카드 스타일을 바꾸지 않는다.

디자인을 바꿀 때:

1. 이 문서의 기준을 먼저 수정한다.
2. 수정된 기준에 맞춰 화면을 수정한다.
3. `/` 메인 화면과 새 화면이 같은 톤인지 확인한다.
4. 데스크톱과 모바일에서 텍스트가 잘리지 않는지 확인한다.

이 문서가 현재 PCS 화면 디자인의 기준이다.
