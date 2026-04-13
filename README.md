# ai workspace

> 사람과 AI가 함께 만든 맥락을 git으로 구조화하는 워크스페이스.

## 왜 만들었나

- AI 세션이 끝나면 맥락이 날아감
- AI와 함께 만든 의사결정이 채팅창에만 남아있음
- 잘 먹혔던 프롬프트, 분석 방법이 공유 안 됨

인수인계의 대상이 사람이 아니라 정제된 맥락이 되어야 하는 시대.
결과물만 넘기는 게 아니라, 맥락 + 과정 + 도구를 통째로 git에 쌓습니다.

## 시작

```bash
git clone https://kcd.codes/security/ai-workspace.git my-project
cd my-project
./start.sh
```

## 명령어

```bash
./work start "작업명"       # history/ 로그 생성
./work done  "메시지"       # 상태 갱신 + git commit/push
./work status               # 현재 상태
```

## 구조

```
project/
├── AGENTS.md               # 모든 AI가 이것부터 읽음
├── context/
│   ├── project_info.md     # 프로젝트 정보
│   ├── current_status.md   # 현재 상황 (자동 갱신)
│   ├── prompts.md          # 검증된 프롬프트 모음
│   └── architecture.md     # 아키텍처 (선택)
├── history/
│   ├── index.md            # 전체 작업 목록 (자동 갱신)
│   └── YYYY/MM/*.md        # 개별 작업 기록 + 성과 포인트
├── output/                 # 외부 출력물 (html)
└── (업무별 폴더)            # start.sh 프리셋으로 생성
```

## 예시: 침해사고 대응

```
incident-response-2026/
├── context/
│   ├── project_info.md          # 대응 체계, 팀 구성, SOP
│   ├── prompts.md               # "c2 통신 패턴 추출해줘" 등
│   └── architecture.md          # 네트워크 구성, 자산 목록, 로그 흐름
├── history/
│   └── 2026/04/
│       ├── 2026-04-10-webshell-탐지-분석.md
│       └── 2026-04-13-c2-통신-차단.md
├── config/lambda/               # 탐지/대응 lambda
├── policy/siem/                 # 탐지 룰
├── evidence/                    # 로그 샘플, ioc, 타임라인
└── output/
    └── 2026-04-13-침해사고-보고서.html
```
