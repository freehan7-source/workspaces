# ai workspace 에이전트 가이드

> 이 파일은 어떤 ai 도구든 이 프로젝트를 이해하기 위해 가장 먼저 읽어야 하는 파일입니다.

## 컨텍스트 로딩 순서

1. `context/project_info.md` — 프로젝트 기본 정보 (목적, 기술 스택, 팀)
2. `context/current_status.md` — 현재 진행 상황 (마지막 작업, 다음 할 일)
3. `history/index.md` — 전체 작업 이력 목록
4. `history/YYYY/MM/*.md` — 개별 작업 상세 기록
5. `jira/index.md` — Jira 태스크 목록 (open/done)

## 디렉터리 구조

```
project/
├── AGENTS.md                  ← 지금 읽고 있는 파일
├── context/
│   ├── project_info.md        ← 프로젝트 기본 정보
│   ├── current_status.md      ← 현재 상황 (자동 갱신)
│   └── prompts.md             ← 효과 좋았던 프롬프트 모음
├── history/
│   ├── index.md               ← 전체 작업 목록 (자동 갱신)
│   └── YYYY/MM/날짜-작업명.md  ← 개별 작업 기록
├── input/                     ← 작업 입력 데이터 (원본 파일, 소스 데이터)
├── jira/
│   ├── index.md               ← 태스크 목록 (자동 갱신)
│   ├── open/                  ← 진행 중 태스크
│   └── done/                  ← 완료된 태스크
├── output/                    ← 외부 출력물 (html, confluence 업로드용)
├── save                       ← 중간 저장 단축 스크립트
├── work                       ← 작업 관리 스크립트 (mac/linux)
├── start.sh                   ← 초기 설정 스크립트 (mac/linux)
└── start.ps1                  ← 초기 설정 스크립트 (windows)
```

## 작업 흐름

```
./work start "작업명"       →  history/에 로그 생성
(작업 수행)
./save "메시지"             →  중간 저장 (상태 갱신, commit 없음)
./work done "완료 메시지"   →  current_status.md 갱신 + history/index.md 갱신 + Jira 태스크 생성 + git commit/push
```

## 규칙

- 작업 기록은 history/에 날짜별로 누적됨
- current_status.md를 보면 프로젝트의 현재 상황을 즉시 파악 가능
- history/index.md를 보면 전체 작업 이력을 한눈에 파악 가능
- 새로운 사람이 이 프로젝트를 클론하면, 이 파일부터 읽고 context/ → history/ 순으로 파악

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

## Jira 태스크 생성 규칙

`./work done` 실행 전, 오늘 history 로그를 분석하여 Jira 등록이 필요한 항목을 `jira/open/` 에 태스크 파일로 생성한다.

**태스크 대상 (아래 기준에 해당하면 반드시 생성):**
- `## 이슈` 섹션 — 버그, 장애, 재발 방지 필요 사항, 미해결 문제
- `## 다음 작업` 섹션 — 후속 개선, 기능 추가, 조사 필요 항목
- 작업 중 식별된 리팩터링, 성능 개선, 보안 취약점

**파일 위치:** `jira/open/YYYY-MM-DD-태스크명.md`

**태스크 파일 규격:**

```markdown
---
date: YYYY-MM-DD
title: 태스크명
type: bug | feature | improvement | investigation
priority: high | medium | low
source: history/YYYY/MM/날짜-작업명.md
status: open
---

# 태스크명

## 배경
(어떤 작업 중 발견/도출되었는지)

## 요구사항
-

## 완료 기준
-

## 참고
-
```

**type 기준:**
- `bug` — 오류, 장애, 예상과 다른 동작
- `feature` — 새로운 기능 추가
- `improvement` — 기존 기능 개선, 최적화
- `investigation` — 원인 분석, 조사 필요

**완료 처리:** `./work jira done 파일명` → `jira/done/` 으로 이동, `jira/index.md` 자동 갱신

## 명령어

```
./work start "작업명"          작업 시작 (history/ 로그 생성)
./save "메시지"                중간 저장 (상태 갱신, commit 없음)
./work save "메시지"           중간 저장 (동일)
./work done "메시지"           작업 완료 (상태 갱신 + git commit/push)
./work status                  현재 상태 확인
./work jira list               Jira 태스크 목록
./work jira new "태스크명"     새 태스크 생성
./work jira done "파일명"      태스크 완료 처리
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
