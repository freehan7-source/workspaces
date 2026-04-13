#!/bin/bash
# ai workspace 초기 설정 스크립트

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
   ___   ____  _       __           __                          
  / _ | /  _/ | |     / /__  ____  / /____ ___  ___ _______ ___
 / __ |_/ /   | | /| / / _ \/ __/ /  '_(_-< __ \/ _ '/ __/ -_)
/_/ |_/___/   |_|/ |_/ \___|/_/   /_/\_\/__/_/_|\_,_/\__/\__/ 
                                                                
EOF
echo -e "${NC}"

# 1. 프로젝트명
if [ -z "$1" ]; then
    echo -e "${YELLOW}프로젝트명을 입력하세요:${NC}"
    read -p "> " PROJECT_NAME
else
    PROJECT_NAME="$1"
fi

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}프로젝트명이 필요합니다.${NC}"; exit 1
fi

PROJECT_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
echo -e "${GREEN}✅ $PROJECT_NAME${NC}\n"

# 2. 업무 프리셋
echo -e "${BLUE}업무 유형을 선택하세요:${NC}\n"
echo -e "  ${CYAN}1)${NC} 🔒 정보보안 ${DIM}(siem, soar, lambda, pipeline)${NC}"
echo -e "  ${CYAN}2)${NC} 💻 소프트웨어 개발 ${DIM}(src, tests, docs, ci)${NC}"
echo -e "  ${CYAN}3)${NC} 🏗️ 인프라/devops  ${DIM}(terraform, ansible, docker, k8s)${NC}"
echo -e "  ${CYAN}4)${NC} 📊 데이터 분석    ${DIM}(notebooks, datasets, models)${NC}"
echo -e "  ${CYAN}5)${NC} 📝 문서/기획      ${DIM}(drafts, reviews, references)${NC}"
echo -e "  ${CYAN}6)${NC} ⚙️  커스텀        ${DIM}(기본 구조만)${NC}"
echo ""
read -p "  선택 (1-6, 기본=6): " PRESET
PRESET="${PRESET:-6}"

PRESET_NAME="커스텀"
PRESET_COMPONENTS="- 필요에 따라 디렉터리를 추가하세요"
PRESET_TREE=""

case "$PRESET" in
    1) PRESET_NAME="정보보안"
       mkdir -p config/{lambda,pipeline,opensearch} policy/{siem,soar} evidence output/{reports,presentations}
       PRESET_COMPONENTS="- config/lambda, config/pipeline, config/opensearch, policy/siem, policy/soar, evidence/, output/"
       PRESET_TREE="├── config/
│   ├── lambda/            ← 탐지/대응 lambda 함수
│   ├── pipeline/          ← 로그 수집 파이프라인
│   └── opensearch/        ← 인덱스 템플릿/쿼리
├── policy/
│   ├── siem/              ← 탐지 룰
│   └── soar/              ← 자동 대응 플레이북
├── evidence/              ← 분석 대상 (로그 샘플, ioc, 타임라인)" ;;
    2) PRESET_NAME="소프트웨어 개발"
       mkdir -p src/{main,lib} tests/{unit,integration} docs ci output
       PRESET_COMPONENTS="- src/, tests/, docs/, ci/, output/"
       PRESET_TREE="├── src/
│   ├── main/              ← 메인 코드
│   └── lib/               ← 라이브러리
├── tests/
│   ├── unit/              ← 단위 테스트
│   └── integration/       ← 통합 테스트
├── docs/                  ← 기술 문서
├── ci/                    ← ci/cd 설정" ;;
    3) PRESET_NAME="인프라/devops"
       mkdir -p terraform/{modules,envs} ansible/{roles,playbooks} docker k8s/{manifests,helm} scripts output
       PRESET_COMPONENTS="- terraform/, ansible/, docker/, k8s/, scripts/"
       PRESET_TREE="├── terraform/
│   ├── modules/           ← terraform 모듈
│   └── envs/              ← 환경별 설정
├── ansible/
│   ├── roles/             ← ansible 역할
│   └── playbooks/         ← 플레이북
├── docker/                ← dockerfile, compose
├── k8s/
│   ├── manifests/         ← k8s 매니페스트
│   └── helm/              ← helm 차트
├── scripts/               ← 운영 스크립트" ;;
    4) PRESET_NAME="데이터 분석"
       mkdir -p notebooks datasets/{raw,processed} models/{trained,configs} output/{reports,visualizations} scripts
       PRESET_COMPONENTS="- notebooks/, datasets/, models/, output/, scripts/"
       PRESET_TREE="├── notebooks/             ← jupyter/분석 노트북
├── datasets/
│   ├── raw/               ← 원본 데이터
│   └── processed/         ← 가공 데이터
├── models/
│   ├── trained/           ← 학습된 모델
│   └── configs/           ← 하이퍼파라미터
├── scripts/               ← etl/전처리" ;;
    5) PRESET_NAME="문서/기획"
       mkdir -p drafts reviews references output/{final,presentations} templates
       PRESET_COMPONENTS="- drafts/, reviews/, references/, templates/, output/"
       PRESET_TREE="├── drafts/                ← 작성 중인 문서
├── reviews/               ← 리뷰 피드백
├── references/            ← 참고자료
├── templates/             ← 문서 템플릿" ;;
esac

mkdir -p context history .kiro/steering
echo -e "${GREEN}✅ [$PRESET_NAME] 구조 생성${NC}\n"

# 3. context 파일 생성
cat > context/project_info.md << EOF
# $PROJECT_NAME

> 프로젝트 기본 정보

## 개요
- **목적**: [한 문장으로]
- **유형**: $PRESET_NAME
- **기술 스택**: [주요 기술]
- **팀**: [팀 구성]

## 주요 컴포넌트
$PRESET_COMPONENTS

---
**생성일**: $(date +%Y-%m-%d)
EOF

cat > context/current_status.md << EOF
# 현재 진행 상황

## 마지막 완료
- 초기 설정 ($(date '+%Y-%m-%d'))

## 다음 작업
- [ ] context/project_info.md 작성
- [ ] ./work start "첫 작업"
EOF

# 3.5 아키텍처 문서 포함 여부
echo -e "${BLUE}아키텍처 문서(context/architecture.md)를 포함할까요?${NC}"
echo -e "  ${DIM}(네트워크 구성, 자산 목록, 시스템 흐름 등 - 보안/인프라 업무에 권장)${NC}"
read -p "  포함 (y/n, 기본=n): " ARCH_CHOICE
ARCH_CHOICE="${ARCH_CHOICE:-n}"

if [ "$ARCH_CHOICE" = "y" ] || [ "$ARCH_CHOICE" = "Y" ]; then
    cat > context/architecture.md << 'EOF'
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
EOF
    echo -e "${GREEN}✅ context/architecture.md 생성${NC}\n"
else
    echo ""
fi

# 4. AI 도구 선택 → 포인터 파일 생성
echo -e "${BLUE}사용할 AI 도구를 선택하세요 (복수 선택 가능):${NC}\n"
echo -e "  ${CYAN}1)${NC} kiro"
echo -e "  ${CYAN}2)${NC} cursor"
echo -e "  ${CYAN}3)${NC} github copilot"
echo -e "  ${CYAN}4)${NC} 전부"
echo -e "  ${CYAN}5)${NC} 없음 ${DIM}(AGENTS.md만 사용)${NC}"
echo ""
read -p "  선택 (1-5, 기본=4): " AI_CHOICE
AI_CHOICE="${AI_CHOICE:-4}"

POINTER_CONTENT="Read AGENTS.md first. It defines the project structure, context loading order, and workflow.
Then read context/project_info.md and context/current_status.md."

setup_kiro() {
    mkdir -p .kiro/steering
    cat > .kiro/steering/context.md << 'KIROEOF'
---
inclusion: auto
---

이 프로젝트의 에이전트 가이드는 `AGENTS.md`에 정의되어 있습니다.
반드시 `AGENTS.md`를 먼저 읽고, 그 안의 컨텍스트 로딩 순서를 따르세요.

#[[file:AGENTS.md]]
#[[file:context/project_info.md]]
#[[file:context/current_status.md]]
#[[file:context/prompts.md]]
KIROEOF
    echo -e "  ${GREEN}✅ kiro${NC} → .kiro/steering/context.md"
}

setup_cursor() {
    echo "$POINTER_CONTENT" > .cursorrules
    echo -e "  ${GREEN}✅ cursor${NC} → .cursorrules"
}

setup_copilot() {
    mkdir -p .github
    echo "$POINTER_CONTENT" > .github/copilot-instructions.md
    echo -e "  ${GREEN}✅ copilot${NC} → .github/copilot-instructions.md"
}

case "$AI_CHOICE" in
    1) setup_kiro ;;
    2) setup_cursor ;;
    3) setup_copilot ;;
    4) setup_kiro; setup_cursor; setup_copilot ;;
    5) echo -e "  ${DIM}포인터 파일 없음 (AGENTS.md 직접 사용)${NC}" ;;
esac
echo ""

# 5. history/index.md 초기화
cat > history/index.md << 'EOF'
# 작업 이력

| 날짜 | 작업 | 파일 |
|------|------|------|
EOF

# 5.5 민감정보 필터링 설정
echo -e "${BLUE}외부 출력(output/) 시 민감정보 자동 필터링을 적용할까요?${NC}"
echo -e "  ${DIM}(api 키, ip 주소, 개인정보 등을 [REDACTED]로 대체)${NC}"
read -p "  적용 (y/n, 기본=y): " REDACT_CHOICE
REDACT_CHOICE="${REDACT_CHOICE:-y}"

if [ "$REDACT_CHOICE" = "y" ] || [ "$REDACT_CHOICE" = "Y" ]; then
    SECURITY_RULE=$(cat << 'SECEOF'

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
SECEOF
)
    echo -e "${GREEN}✅ 민감정보 필터링 적용${NC}"
else
    SECURITY_RULE=""
    echo -e "${YELLOW}민감정보 필터링 미적용${NC}"
fi

# 5.6 AGENTS.md 생성
cat > AGENTS.md << AGENTSEOF
# ai workspace 에이전트 가이드

> 이 파일은 어떤 ai 도구든 이 프로젝트를 이해하기 위해 가장 먼저 읽어야 하는 파일입니다.

## 컨텍스트 로딩 순서

1. \`context/project_info.md\` — 프로젝트 기본 정보 (목적, 기술 스택, 팀)
2. \`context/current_status.md\` — 현재 진행 상황 (마지막 작업, 다음 할 일)
3. \`history/index.md\` — 전체 작업 이력 목록
4. \`history/YYYY/MM/*.md\` — 개별 작업 상세 기록

## 디렉터리 구조

\`\`\`
project/
├── AGENTS.md                  ← 지금 읽고 있는 파일
├── context/
│   ├── project_info.md        ← 프로젝트 기본 정보
│   ├── current_status.md      ← 현재 상황 (자동 갱신)
│   └── prompts.md             ← 효과 좋았던 프롬프트 모음
├── history/
│   ├── index.md               ← 전체 작업 목록 (자동 갱신)
│   └── YYYY/MM/날짜-작업명.md  ← 개별 작업 기록
├── output/                    ← 외부 출력물 (html, confluence 업로드용)
$PRESET_TREE
├── work                       ← 작업 관리 스크립트
└── start.sh                   ← 초기 설정 스크립트
\`\`\`

## 작업 흐름

\`\`\`
./work start "작업명"  →  history/에 로그 생성
(작업 수행)
./work done "완료 메시지"  →  current_status.md 갱신 + history/index.md 갱신 + git commit/push
\`\`\`

## 규칙

- 작업 기록은 history/에 날짜별로 누적됨
- current_status.md를 보면 프로젝트의 현재 상황을 즉시 파악 가능
- history/index.md를 보면 전체 작업 이력을 한눈에 파악 가능
- 새로운 사람이 이 프로젝트를 클론하면, 이 파일부터 읽고 context/ → history/ 순으로 파악

## 작업 로그 규격

각 history 로그는 프론트매터 + 본문 구조:

\`\`\`markdown
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
\`\`\`

- \`tags\`: 작업 분류용. 나중에 태그별 필터링/검색에 활용
- \`성과 포인트\`: 수치, 개선율, 해결한 문제 등 성과로 활용 가능한 내용
- 성과 정리 요청 시: 모든 history에서 \`## 성과 포인트\` 섹션을 모아서 요약

## 명령어

\`\`\`
./work start "작업명"     작업 시작 (history/ 로그 생성)
./work done  "메시지"     작업 완료 (상태 갱신 + git commit/push)
./work status             현재 상태 확인
\`\`\`

## 출력 규격

### 내부 문서 (history, context)
- 형식: markdown
- 모든 문서 최상단에 1-3줄 요약을 반드시 포함

### 외부 출력 (보고서, 성과 정리, 업로드용)
- 형식: html (confluence 업로드 호환)
- confluence storage format 기준
- 출력 위치: \`output/\` 디렉터리
- 파일명: \`output/YYYY-MM-DD-제목.html\`

### 요약 규칙
- history 로그: 제목 바로 아래 \`>\` 인용문으로 1줄 요약
- 성과 보고서: 최상단에 핵심 수치 요약 테이블
- 월간/분기 정리: 최상단에 전체 요약 → 상세 내용 순서
$SECURITY_RULE
AGENTSEOF

echo -e "${GREEN}✅ AGENTS.md 생성${NC}"

# 6. git 초기화
echo -e "${BLUE}git 초기화...${NC}"
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "init: $PROJECT_NAME ($PRESET_NAME)"
    echo -e "${GREEN}✅ git 초기화${NC}"
else
    echo -e "${YELLOW}git 이미 초기화됨${NC}"
fi

[ -n "$2" ] && git remote add origin "$2" 2>/dev/null && echo -e "${GREEN}✅ remote: $2${NC}"

chmod +x work 2>/dev/null || true

# 7. 완료
echo ""
echo -e "${GREEN}✅ ai workspace 준비 완료 [$PRESET_NAME]${NC}"
echo ""
echo -e "  ${GREEN}./work start${NC} \"작업명\"     작업 시작"
echo -e "  ${GREEN}./work done${NC}  \"메시지\"     작업 완료 (git commit/push)"
echo -e "  ${GREEN}./work status${NC}             현재 상태"
echo ""
echo -e "  먼저: ${GREEN}vim context/project_info.md${NC}"
echo ""
