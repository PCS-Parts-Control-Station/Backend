# PCS Design System

이 문서는 PCS 화면 디자인의 현재 기준이다.

초기 외부 디자인 문서를 그대로 쓰지 않고, 현재 `/` 메인 페이지에 맞게 조정한 PCS 전용 기준만 남긴다.
새 화면을 만들거나 기존 화면을 수정할 때는 이 문서를 먼저 기준으로 삼는다.
디자인 방향을 바꿀 때는 개별 화면을 먼저 수정하지 말고 이 문서를 먼저 수정한 뒤 화면에 반영한다.

## 디자인 방향

PCS는 중고 PC 부품을 관리하는 관리자용 업무 시스템이다.
따라서 화면은 마케팅 랜딩처럼 과장되기보다, 반복 업무를 빠르게 처리하는 운영 도구처럼 보여야 한다.

현재 기준:

- 밝은 블루그레이 계열의 업무 도구 톤
- 흰색 카드와 얇은 경계선 중심의 정돈된 화면
- 과한 그림자, 과한 애니메이션, 강한 형광색 사용 금지
- 입고 -> 검수 -> 재고 -> 출고 -> 이력 흐름이 화면 구조의 중심
- 관리번호, 검수 결과, 재고 수량, 상태 이력처럼 관리자 판단에 필요한 정보를 전면 배치

## 색상 토큰

현재 메인 페이지의 색상 기준이다.
새 페이지도 이 토큰을 우선 사용한다.

```css
:root {
    --page: #f5f7fb;
    --page-soft: #e8edf5;
    --surface: #ffffff;
    --surface-soft: #eef3f8;
    --surface-muted: #e3ebf5;

    --ink: #243142;
    --text: #344256;
    --body: #56667a;
    --mute: #728095;

    --line: #d7dee9;
    --line-strong: #b4c0d2;

    --primary: #5578a6;
    --primary-dark: #45648c;
    --primary-soft: #e6eef8;

    --accent: #7f98b6;
    --accent-soft: #edf3fa;

    --shadow: 0 18px 42px rgba(43, 60, 84, 0.1);
}
```

사용 기준:

- `--page`: 전체 배경
- `--surface`: 카드, 패널, 입력 영역의 기본 표면
- `--surface-soft`: 패널 요약 영역, 코드형 chip, 상태 보조 배경
- `--ink`: 가장 중요한 제목과 핵심 텍스트
- `--body`: 설명문
- `--mute`: 보조 설명, 캡션
- `--primary`: 주요 버튼, 핵심 상태 표시
- `--primary-dark`: hover, 강조 텍스트
- `--accent`: 현재 진행 상태 같은 보조 포인트
- `--line`: 기본 경계선
- `--line-strong`: 입력창, 보조 버튼 경계선

강한 노랑, 형광 초록, 검정 배경은 기본 디자인에서 사용하지 않는다.
필요하면 먼저 이 문서의 토큰을 조정한 뒤 사용한다.

## 타이포그래피

기본 폰트:

```css
font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Malgun Gothic", sans-serif;
```

보조 코드형 텍스트:

```css
font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
```

기준:

- 큰 제목은 강하게 보이되 과하게 크지 않게 한다.
- 업무 화면 안의 제목은 스캔하기 쉽게 짧고 명확하게 쓴다.
- 메인 페이지와 입력 페이지의 제목 크기는 같지 않아도 된다. 페이지 목적에 맞춰 단계적으로 낮춘다.
- `letter-spacing`은 기본 0을 유지한다.
- 작은 eyebrow 라벨은 13px, 굵게, 약간의 자간만 사용한다.

메인 히어로 제목 기준:

```css
h1 {
    max-width: 700px;
    font-size: clamp(36px, 4.4vw, 54px);
    font-weight: 700;
    line-height: 1.16;
}
```

등록/입력 페이지 제목 기준:

```css
h1 {
    font-size: clamp(32px, 3vw, 42px);
    font-weight: 700;
    line-height: 1.22;
}
```

등록/입력 페이지의 상단 문구는 짧게 둔다.
사용자가 정보를 입력하는 화면에서는 폼이 화면의 중심이어야 하므로, 메인 페이지처럼 큰 소개형 문장을 쓰지 않는다.

## 버튼

버튼은 8px radius를 사용한다.
텍스트가 긴 버튼도 높이와 폭이 안정적으로 보이게 한다.

Primary button:

```css
background: var(--primary);
color: #ffffff;
border-color: var(--primary);
```

Hover:

```css
background: var(--primary-dark);
border-color: var(--primary-dark);
```

Secondary button:

```css
background: rgba(255, 255, 255, 0.72);
color: var(--ink);
border-color: var(--line-strong);
```

사용 기준:

- 주요 행동: 회사 등록, 저장, 등록, 확정
- 보조 행동: 로그인, 목록 이동, 취소, 뒤로가기
- 버튼을 과하게 많이 배치하지 않는다.
- 한 화면에서 primary button은 핵심 행동 1개를 우선한다.

## 카드와 패널

PCS 화면은 카드 기반이지만 카드가 과하게 많아 보이면 안 된다.
반복 항목, 입력 패널, 요약 패널에만 카드 형태를 쓴다.

기본 카드:

```css
border: 1px solid var(--line);
border-radius: 8px;
background: var(--surface);
```

강조 카드:

```css
box-shadow: var(--shadow);
```

사용 기준:

- 사용자 입력 패널
- 업무 상태 요약 패널
- 반복되는 업무 카드
- 부품 상태 흐름 카드

금지:

- 큰 섹션 전체를 의미 없이 카드로 감싸기
- 카드 안에 또 카드 넣기
- 진한 그림자 남발
- 색상만 다른 카드 여러 종류를 즉흥적으로 만들기

## 입력 폼

입력창은 밝은 흰색 배경과 블루그레이 포커스 링을 사용한다.

```css
input {
    height: 48px;
    border: 1px solid var(--line-strong);
    border-radius: 8px;
    background: #ffffff;
    line-height: 20px;
}

input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(85, 120, 166, 0.18);
}
```

입력 화면 기준:

- 한 줄에 여러 정보를 입력하게 만들지 않는다.
- 입력 항목은 위에서 아래로 세로 배치한다.
- 데스크톱에서는 `라벨 + 입력창`을 같은 행에 두어 정돈감을 준다.
- 입력창은 카드 전체 폭을 무조건 채우지 않는다.
- 회사명, 이메일처럼 긴 값은 조금 넓게 두고, 코드, 연락처, 비밀번호처럼 짧은 값은 적정 폭으로 제한한다.
- 선택 입력값은 작은 `선택` 배지로 표시한다.
- 필드 설명 문구 때문에 행 높이가 깨지면 설명을 섹션 설명으로 옮기거나, 라벨/입력 행 아래에 정렬한다.
- 모바일에서는 라벨과 입력창을 세로로 쌓아 읽기 쉽게 만든다.

등록/입력 페이지 레이아웃 기준:

- 상단 제목과 폼 카드는 같은 기준선에 맞춘다.
- 폼 카드 폭은 입력 구조에 맞게 잡고, 불필요한 빈 공간이 크게 남지 않게 한다.
- 오른쪽 보조 패널은 핵심 정보만 보여준다.
- 회사 등록처럼 미리보기 패널이 필요한 경우 `접속 주소`, `회사명`, `Owner 로그인 ID`, 짧은 안내문 정도만 둔다.
- 진행 순서 박스나 설명 카드를 과하게 넣어 폼 입력을 방해하지 않는다.

## 메인 페이지 구조

현재 `/` 메인 페이지는 이 구조를 기준으로 한다.
다른 랜딩성 화면도 이 리듬을 참고한다.

```text
Header
- 로고
- 업체 로그인
- 회사 등록

Hero
- 짧은 eyebrow
- 핵심 문구
- 설명문
- 회사 등록 / 업체 로그인 버튼
- 업체 코드 접속 카드

Operation Panel
- 관리번호 요약
- 입고 / 검수 / 재고 / 출고 상태 흐름

Workflow Section
- 입고
- 검수
- 재고
- 출고
- 이력

Focus Section
- 관리번호 기준 추적
- 검수 결과 반영
- 재고 정합성
- 상태 변경 이력
```

메인 페이지의 현재 핵심 문구:

```text
관리번호로 부품 상태를 한눈에 확인합니다.
```

## 회사 등록 페이지 구조

현재 `/company/register` 페이지는 등록/입력 화면의 기준이다.
다른 등록 화면도 이 구조를 우선 참고한다.

```text
Header
- 로고
- 메인
- 업체 로그인

Page Hero
- 짧은 eyebrow
- 짧은 제목
- 한 줄 수준의 설명

Register Layout
- 왼쪽: 입력 폼 카드
- 오른쪽: 등록 후 접속 정보 패널

Form Sections
- 회사 정보
- 대표 연락처
- 최고 관리자 계정
```

회사 등록 페이지의 현재 핵심 문구:

```text
업체 작업공간을 생성합니다.
```

## 업무 흐름 표현

PCS에서 가장 중요한 시각 구조는 부품 상태 흐름이다.

기본 흐름:

```text
입고 -> 검수 -> 재고 -> 출고 -> 이력
```

화면에서 표현할 때:

- 현재 상태는 `--accent` 또는 `--primary`로 약하게 표시한다.
- 완료 상태는 `--primary`로 표시한다.
- 대기 상태는 회색 계열로 둔다.
- 모든 상태는 개별 부품 관리번호와 연결되어 보여야 한다.

## 코드형 Chip

관리자 화면이더라도 시스템 값이나 내부 기준값은 작은 chip으로 표시할 수 있다.

예:

```text
unit.serial
inspection.result
stock.quantity
status.history
```

스타일:

```css
background: var(--surface-soft);
color: var(--primary-dark);
font-family: var(--ff-mono);
font-size: 12px;
border-radius: 6px;
```

## 스크롤 동작

현재 메인 페이지는 과하지 않은 reveal 동작만 사용한다.

사용 기준:

- 스크롤 시 섹션 제목과 카드가 살짝 아래에서 올라오며 나타난다.
- 요소가 다시 화면 밖으로 나가면 자연스럽게 빠지고, 다시 들어오면 나타난다.
- 움직임은 500ms 안팎으로 짧게 유지한다.
- `prefers-reduced-motion: reduce` 환경에서는 애니메이션을 끈다.

기본 CSS:

```css
.reveal {
    opacity: 0;
    transform: translateY(16px);
    transition: opacity 520ms ease, transform 520ms ease;
}

.reveal.is-visible {
    opacity: 1;
    transform: translateY(0);
}
```

금지:

- 큰 scale 애니메이션
- 회전, 과한 parallax
- 카드가 튀는 듯한 움직임
- 업무 화면에서 집중을 방해하는 반복 애니메이션

## 로고

로고 파일:

```text
src/main/resources/static/images/parts-control-station-icon.svg
```

로고 색상도 화면 팔레트와 맞춘 블루그레이 계열을 사용한다.
로고만 다른 강한 색을 쓰지 않는다.

## 새 페이지 작성 규칙

새 HTML 페이지를 만들 때:

- `src/main/resources/static/{page}.html`
- `src/main/resources/static/css/{page}.css`
- `src/main/resources/static/js/{page}.js`

기준:

- 전체 배경은 `--page`
- 주요 표면은 `--surface`
- 경계선은 `--line`
- 주요 버튼은 `--primary`
- 설명문은 `--body` 또는 `--mute`
- 반복 항목은 8px radius 카드
- 상태 흐름은 입고 -> 검수 -> 재고 -> 출고 -> 이력 순서를 우선한다.

## 디자인 변경 규칙

화면별로 즉흥적으로 색, 버튼, 카드 스타일을 바꾸지 않는다.

디자인을 바꾸려면:

1. 이 문서의 기준을 먼저 수정한다.
2. 수정된 기준에 맞춰 화면을 수정한다.
3. 기존 화면과 새 화면이 같은 톤인지 확인한다.

이 문서가 현재 PCS 화면 디자인의 기준이다.
