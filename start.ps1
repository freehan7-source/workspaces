# ai workspace 초기 설정 스크립트 (Windows PowerShell)
# 사용법: .\start.ps1 [프로젝트명] [git-remote-url]

$ErrorActionPreference = "Stop"

function Write-C([string]$Text, [string]$Color = "White") {
    Write-Host $Text -ForegroundColor $Color
}

Clear-Host
Write-C @"
   ___   ____  _       __           __
  / _ | /  _/ | |     / /__  ____  / /____ ___  ___ _______ ___
 / __ |_/ /   | | /| / / _ \/ __/ /  '_(-<  _ \/ _ ``/ __/ -_)
/_/ |_/___/   |_|/ |_/ \___|/_/   /_/\_\/__/_/_|\_,_/\__/\__/

"@ "Blue"

# 1. 프로젝트명
if ($args.Count -gt 0) {
    $ProjectName = $args[0]
} else {
    Write-C "프로젝트명을 입력하세요:" "Yellow"
    $ProjectName = Read-Host "> "
}

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    Write-C "프로젝트명이 필요합니다." "Red"; exit 1
}

Write-C "✅ $ProjectName`n" "Green"

# 2. 업무 프리셋
Write-C "업무 유형을 선택하세요:`n" "Blue"
Write-Host "  1) 정보보안       (siem, soar, lambda, pipeline)"
Write-Host "  2) 소프트웨어 개발 (src, tests, docs, ci)"
Write-Host "  3) 인프라/devops   (terraform, ansible, docker, k8s)"
Write-Host "  4) 데이터 분석     (notebooks, datasets, models)"
Write-Host "  5) 문서/기획       (drafts, reviews, references)"
Write-Host "  6) 커스텀          (기본 구조만)"
Write-Host ""
$Preset = Read-Host "  선택 (1-6, 기본=6)"
if ([string]::IsNullOrWhiteSpace($Preset)) { $Preset = "6" }

$PresetName       = "커스텀"
$PresetComponents = "- 필요에 따라 디렉터리를 추가하세요"
$PresetTree       = ""

switch ($Preset) {
    "1" {
        $PresetName = "정보보안"
        @("config/lambda","config/pipeline","config/opensearch","policy/siem","policy/soar","evidence","output/reports","output/presentations") |
            ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
        $PresetComponents = "- config/lambda, config/pipeline, config/opensearch, policy/siem, policy/soar, evidence/, output/"
        $PresetTree = "├── config/`n│   ├── lambda/            ← 탐지/대응 lambda 함수`n│   ├── pipeline/          ← 로그 수집 파이프라인`n│   └── opensearch/        ← 인덱스 템플릿/쿼리`n├── policy/`n│   ├── siem/              ← 탐지 룰`n│   └── soar/              ← 자동 대응 플레이북`n├── evidence/              ← 분석 대상 (로그 샘플, ioc, 타임라인)"
    }
    "2" {
        $PresetName = "소프트웨어 개발"
        @("src/main","src/lib","tests/unit","tests/integration","docs","ci","output") |
            ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
        $PresetComponents = "- src/, tests/, docs/, ci/, output/"
        $PresetTree = "├── src/`n│   ├── main/              ← 메인 코드`n│   └── lib/               ← 라이브러리`n├── tests/`n│   ├── unit/              ← 단위 테스트`n│   └── integration/       ← 통합 테스트`n├── docs/                  ← 기술 문서`n├── ci/                    ← ci/cd 설정"
    }
    "3" {
        $PresetName = "인프라/devops"
        @("terraform/modules","terraform/envs","ansible/roles","ansible/playbooks","docker","k8s/manifests","k8s/helm","scripts","output") |
            ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
        $PresetComponents = "- terraform/, ansible/, docker/, k8s/, scripts/"
        $PresetTree = "├── terraform/`n│   ├── modules/           ← terraform 모듈`n│   └── envs/              ← 환경별 설정`n├── ansible/`n│   ├── roles/             ← ansible 역할`n│   └── playbooks/         ← 플레이북`n├── docker/                ← dockerfile, compose`n├── k8s/`n│   ├── manifests/         ← k8s 매니페스트`n│   └── helm/              ← helm 차트`n├── scripts/               ← 운영 스크립트"
    }
    "4" {
        $PresetName = "데이터 분석"
        @("notebooks","datasets/raw","datasets/processed","models/trained","models/configs","output/reports","output/visualizations","scripts") |
            ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
        $PresetComponents = "- notebooks/, datasets/, models/, output/, scripts/"
        $PresetTree = "├── notebooks/             ← jupyter/분석 노트북`n├── datasets/`n│   ├── raw/               ← 원본 데이터`n│   └── processed/         ← 가공 데이터`n├── models/`n│   ├── trained/           ← 학습된 모델`n│   └── configs/           ← 하이퍼파라미터`n├── scripts/               ← etl/전처리"
    }
    "5" {
        $PresetName = "문서/기획"
        @("drafts","reviews","references","output/final","output/presentations","templates") |
            ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
        $PresetComponents = "- drafts/, reviews/, references/, templates/, output/"
        $PresetTree = "├── drafts/                ← 작성 중인 문서`n├── reviews/               ← 리뷰 피드백`n├── references/            ← 참고자료`n├── templates/             ← 문서 템플릿"
    }
}

@("context","history","input","jira/open","jira/done",".kiro/steering") |
    ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
Write-C "✅ [$PresetName] 구조 생성`n" "Green"

# 3. context 파일 생성
$Today = Get-Date -Format "yyyy-MM-dd"

@"
# $ProjectName

> 프로젝트 기본 정보

## 개요
- **목적**: [한 문장으로]
- **유형**: $PresetName
- **기술 스택**: [주요 기술]
- **팀**: [팀 구성]

## 주요 컴포넌트
$PresetComponents

---
**생성일**: $Today
"@ | Set-Content "context/project_info.md" -Encoding UTF8

@"
# 현재 진행 상황

## 마지막 완료
- 초기 설정 ($Today)

## 다음 작업
- [ ] context/project_info.md 작성
- [ ] ./work start "첫 작업"
"@ | Set-Content "context/current_status.md" -Encoding UTF8

# 3.5 아키텍처 문서
Write-C "아키텍처 문서(context/architecture.md)를 포함할까요?" "Blue"
Write-Host "  (네트워크 구성, 자산 목록, 시스템 흐름 등 - 보안/인프라 업무에 권장)"
$ArchChoice = Read-Host "  포함 (y/n, 기본=n)"
if ($ArchChoice -eq "y" -or $ArchChoice -eq "Y") {
    @'
# 아키텍처

> 시스템/네트워크 아키텍처 현재 상태. 변경 시 history/에 변경 사유와 함께 기록.

## 네트워크 구성
- [네트워크 구성도 또는 설명]

## 주요 자산
| 자산 | 용도 | 위치 |
|------|------|------|
| | | |

## 로그 흐름
- [로그 수집 → 전처리 → 저장 → 분석 흐름]

## 변경 이력
| 날짜 | 변경 내용 | 사유 |
|------|----------|------|
| | | |
'@ | Set-Content "context/architecture.md" -Encoding UTF8
    Write-C "✅ context/architecture.md 생성`n" "Green"
}

# 4. AI 도구 선택
Write-C "`n사용할 AI 도구를 선택하세요:`n" "Blue"
Write-Host "  1) kiro"
Write-Host "  2) cursor"
Write-Host "  3) github copilot"
Write-Host "  4) 전부"
Write-Host "  5) 없음 (AGENTS.md만 사용)"
Write-Host ""
$AiChoice = Read-Host "  선택 (1-5, 기본=4)"
if ([string]::IsNullOrWhiteSpace($AiChoice)) { $AiChoice = "4" }

$PointerContent = @"
Read AGENTS.md first. It defines the project structure, context loading order, and workflow.
Then read context/project_info.md and context/current_status.md.
"@

function Setup-Kiro {
    New-Item -ItemType Directory -Force -Path ".kiro/steering" | Out-Null
    @'
---
inclusion: auto
---

이 프로젝트의 에이전트 가이드는 `AGENTS.md`에 정의되어 있습니다.
반드시 `AGENTS.md`를 먼저 읽고, 그 안의 컨텍스트 로딩 순서를 따르세요.

#[[file:AGENTS.md]]
#[[file:context/project_info.md]]
#[[file:context/current_status.md]]
#[[file:context/prompts.md]]
'@ | Set-Content ".kiro/steering/context.md" -Encoding UTF8
    Write-C "  ✅ kiro → .kiro/steering/context.md" "Green"
}
function Setup-Cursor {
    $PointerContent | Set-Content ".cursorrules" -Encoding UTF8
    Write-C "  ✅ cursor → .cursorrules" "Green"
}
function Setup-Copilot {
    New-Item -ItemType Directory -Force -Path ".github" | Out-Null
    $PointerContent | Set-Content ".github/copilot-instructions.md" -Encoding UTF8
    Write-C "  ✅ copilot → .github/copilot-instructions.md" "Green"
}

switch ($AiChoice) {
    "1" { Setup-Kiro }
    "2" { Setup-Cursor }
    "3" { Setup-Copilot }
    "4" { Setup-Kiro; Setup-Cursor; Setup-Copilot }
    "5" { Write-Host "  포인터 파일 없음 (AGENTS.md 직접 사용)" -ForegroundColor DarkGray }
}
Write-Host ""

# 5. 인덱스 파일 초기화
@"
# 작업 이력

| 날짜 | 작업 | 파일 |
|------|------|------|
"@ | Set-Content "history/index.md" -Encoding UTF8

@"
# Jira 태스크 목록

## 진행 중 (open)

| 날짜 | 제목 | 유형 | 우선순위 |
|------|------|------|---------|

## 완료 (done)

| 날짜 | 제목 | 유형 |
|------|------|------|
"@ | Set-Content "jira/index.md" -Encoding UTF8

"" | Set-Content "input/.gitkeep"     -Encoding UTF8
"" | Set-Content "jira/open/.gitkeep" -Encoding UTF8
"" | Set-Content "jira/done/.gitkeep" -Encoding UTF8
"" | Set-Content "output/.gitkeep"    -Encoding UTF8

# 5.5 민감정보 필터링
Write-C "외부 출력(output/) 시 민감정보 자동 필터링을 적용할까요?" "Blue"
Write-Host "  (api 키, ip 주소, 개인정보 등을 [REDACTED]로 대체)"
$RedactChoice = Read-Host "  적용 (y/n, 기본=y)"
if ([string]::IsNullOrWhiteSpace($RedactChoice)) { $RedactChoice = "y" }

$SecurityRule = ""
if ($RedactChoice -eq "y" -or $RedactChoice -eq "Y") {
    $SecurityRule = @'

### 보안 규칙 (외부 출력 시 필수)
output/ 에 생성하는 외부 문서에는 다음 정보를 절대 포함하지 않는다:
- api 키, 토큰, 비밀번호, 시크릿
- aws account id, access key, arn
- ip 주소, 내부 도메인, 엔드포인트 url
- 개인정보 (이메일, 전화번호, 실명 등)
- 내부 시스템 경로, 서버명, db 접속 정보
- .env, credentials, config 파일의 실제 값

위 정보가 포함된 경우 `[REDACTED]` 로 대체한다.
history 내부 문서에는 작업 기록 목적으로 포함 가능하나, output 변환 시 반드시 제거한다.
'@
    Write-C "✅ 민감정보 필터링 적용" "Green"
} else {
    Write-C "민감정보 필터링 미적용" "Yellow"
}

# 5.6 AGENTS.md 생성
$AgentsPart1 = @'
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
'@

$AgentsPart2 = @'
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
./work done "완료 메시지"   →  current_status.md 갱신 + Jira 태스크 생성 + git commit/push
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

**완료 처리:** `./work jira done 파일명` → `jira/done/` 으로 이동

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
'@

($AgentsPart1 + $PresetTree + "`n" + $AgentsPart2 + $SecurityRule) |
    Set-Content "AGENTS.md" -Encoding UTF8
Write-C "✅ AGENTS.md 생성" "Green"

# 6. git 초기화
Write-C "git 초기화..." "Blue"
if (-not (Test-Path ".git")) {
    git init
    git add .
    git commit -m "init: $ProjectName ($PresetName)"
    Write-C "✅ git 초기화" "Green"
} else {
    Write-C "git 이미 초기화됨" "Yellow"
}

if ($args.Count -gt 1) {
    git remote add origin $args[1] 2>$null
    Write-C "✅ remote: $($args[1])" "Green"
}

# 7. 완료
Write-Host ""
Write-C "✅ ai workspace 준비 완료 [$PresetName]" "Green"
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "./work start " -ForegroundColor Green -NoNewline; Write-Host '"작업명"     작업 시작'
Write-Host "  " -NoNewline; Write-Host "./save       " -ForegroundColor Green -NoNewline; Write-Host '"메시지"     중간 저장'
Write-Host "  " -NoNewline; Write-Host "./work done  " -ForegroundColor Green -NoNewline; Write-Host '"메시지"     작업 완료 (git commit/push)'
Write-Host "  " -NoNewline; Write-Host "./work status" -ForegroundColor Green -NoNewline; Write-Host "             현재 상태"
Write-Host ""
Write-Host "  먼저: " -NoNewline; Write-Host "notepad context/project_info.md" -ForegroundColor Green
Write-Host ""
