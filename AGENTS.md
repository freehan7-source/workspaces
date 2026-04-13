# ai workspace 에이전트 가이드

> 이 파일은 어떤 ai 도구든 이 프로젝트를 이해하기 위해 가장 먼저 읽어야 하는 파일입니다.

## 컨텍스트 로딩 순서

1. `context/project_info.md` — 프로젝트 기본 정보
2. `context/current_status.md` — 현재 진행 상황
3. `context/prompts.md` — 효과 좋았던 프롬프트 모음
4. `history/index.md` — 전체 작업 이력 목록
5. `history/YYYY/MM/*.md` — 개별 작업 상세 기록

## 디렉터리 구조

```
project/
├── AGENTS.md
├── context/
│   ├── project_info.md
│   ├── current_status.md
│   └── prompts.md
├── history/
│   ├── index.md
│   └── YYYY/MM/날짜-작업명.md
├── output/
├── work
├── start.sh
└── (업무별 폴더)
```

### 1. context/ — AI가 상황을 파악하기 위한 '전제 조건'

AI가 오판하지 않도록 만드는 배경지식입니다.

- `project_info.md`: 프로젝트 목적, 기술 스택, 팀 구성, 주요 컴포넌트 등 기본 정보.
  한 번 작성하면 거의 바뀌지 않는 고정 정보.

- `current_status.md`: 지금 프로젝트가 어디까지 진행됐는지.
  `./work done` 실행 시 자동으로 갱신됨. AI가 "지금 뭐 하고 있지?"를 파악하는 핵심 파일.

- `prompts.md`: 효과가 좋았던 프롬프트(명령어)를 보관하는 곳.
  예: "이 로그에서 c2 통신 의심 패턴을 추출해줘"라는 명령이 잘 먹혔다면 여기에 기록.
  다음 담당자가 같은 유형의 작업을 할 때 바로 활용 가능.
  팀 전체의 프롬프트 엔지니어링 자산이 됨.

### 2. history/ — 가장 중요한 부분. 의사결정 기록.

AI 채팅 내역 전체를 저장하는 게 아니라, '무엇을 했고 어떤 결과가 나왔는지' 위주로 정리합니다.

- `index.md`: 전체 작업 목록 테이블. `./work done` 시 자동 갱신.
  AI가 "과거에 뭐 했지?"를 빠르게 파악하는 인덱스.

- `YYYY/MM/날짜-작업명.md`: 개별 작업 상세 기록.
  목표, 작업 내용, 성과 포인트, 변경 사항, 이슈, 다음 작업이 구조화되어 있음.
  담당자가 바뀌어도 이 파일들만 읽으면 어떤 작업을 했고 어떤 결과를 얻었는지 추적 가능.

### 3. output/ — 외부 공유용 산출물

history에 쌓인 내부 기록을 외부 공유 가능한 형태로 변환한 결과물.
html 형식(confluence 업로드 호환)으로 생성됨.

### 4. (업무별 폴더) — 실제 작업 파일

start.sh 프리셋으로 생성되는 업무별 디렉터리.
보안 운영이면 config/, policy/, 개발이면 src/, tests/ 등.

## 이 구조의 장점

- **인수인계 즉시 가능**: 담당자가 바뀌어도 git clone 받으면 AI에게 "이 프로젝트 설명해줘" 한마디로 전체 파악
- **프롬프트 자산화**: 특정 업무에 최적화된 프롬프트를 팀 전체가 재사용
- **성과 추적**: history의 성과 포인트를 모아서 보고서 자동 생성
- **검토 가능**: 과거 작업의 의사결정 과정을 코드 리뷰하듯 검토 가능

## 작업 흐름

```
./work start "작업명"  →  history/에 로그 생성
(작업 수행)
./work done "완료 메시지"  →  current_status.md 갱신 + history/index.md 갱신 + git commit/push
```

## 작업 로그 규격

각 history 로그는 프론트매터 + 본문 구조:

```markdown
---
date: 2026-04-13
title: 작업명
tags: [태그1, 태그2]
---

# 날짜 작업명
> (한 줄 요약)

## 목표
## 작업 내용
## 성과 포인트    ← 성과가 될 만한 내용을 기록
## 변경 사항
## 이슈
## 다음 작업
```

- `tags`: 작업 분류용. 나중에 태그별 필터링/검색에 활용
- `성과 포인트`: 수치, 개선율, 해결한 문제 등 성과로 활용 가능한 내용
- 성과 정리 요청 시: 모든 history에서 `## 성과 포인트` 섹션을 모아서 요약

## 프롬프트 기록 규격

`context/prompts.md`에 효과 좋았던 프롬프트를 누적:

```markdown
## [업무 유형] 프롬프트 제목
- **상황**: 어떤 상황에서 사용했는지
- **프롬프트**: 실제 사용한 명령
- **결과**: 어떤 효과가 있었는지
- **태그**: #태그1 #태그2
```

## 명령어

```
./work start "작업명"     작업 시작 (history/ 로그 생성)
./work done  "메시지"     작업 완료 (상태 갱신 + git commit/push)
./work status             현재 상태 확인
```

## 출력 규격

### 내부 문서 (history, context)
- 형식: markdown
- 모든 문서 최상단에 1-3줄 요약을 반드시 포함

### 외부 출력 (보고서, 성과 정리, 업로드용)
- 형식: html (confluence 업로드 호환)
- confluence storage format 기준
- 출력 위치: `output/` 디렉터리
- 파일명: `output/YYYY-MM-DD-제목.html`

### 요약 규칙
- history 로그: 제목 바로 아래 `>` 인용문으로 1줄 요약
- 성과 보고서: 최상단에 핵심 수치 요약 테이블
- 월간/분기 정리: 최상단에 전체 요약 → 상세 내용 순서

## 파일 저장 규칙

파일을 생성하거나 저장할 때 반드시 이 구조를 따른다:

| 파일 유형 | 저장 위치 | 형식 |
|----------|----------|------|
| 프로젝트 정보 | `context/project_info.md` | markdown |
| 현재 상황 | `context/current_status.md` | markdown (자동) |
| 효과 좋은 프롬프트 | `context/prompts.md` | markdown |
| 작업 기록 | `history/YYYY/MM/날짜-작업명.md` | markdown |
| 작업 목록 | `history/index.md` | markdown (자동) |
| 외부 보고서/성과 | `output/YYYY-MM-DD-제목.html` | html |
| 업무별 파일 | 해당 업무 폴더 | 원본 형식 |

- 위 표에 없는 파일은 해당 업무 폴더에 저장
- output/에는 markdown이 아닌 html만 저장
- history/에는 작업 로그 규격을 따르는 markdown만 저장
