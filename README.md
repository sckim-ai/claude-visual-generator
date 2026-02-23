# Claude Visual Generator

> Claude Code용 시각 자료 이미지 생성 스킬 플러그인

연구 계획서, 기술 보고서, 세미나 발표 자료 등의 문서에서 핵심 메시지를 추출하고, Gemini API를 통해 **고품질 인포그래픽/다이어그램 이미지**를 자동 생성합니다.

## 주요 기능

| 스킬 | 용도 | 텍스트 밀도 |
|------|------|-----------|
| `visual-prompt-concept` | 기술 보고서/학술 발표용 개념 시각화 | 12-15개 |
| `visual-prompt-gov` | 정부/공공기관 발표 자료 | ~25개 |
| `visual-prompt-seminar` | 사내 세미나/워크숍 발표 | 20-30개 |
| `visual-renderer` | 프롬프트 → 이미지 변환 (Gemini API) | - |

### 24종 레이아웃

Flow, Structure, Network, Contrast, Evolution, Central, Cycle, Group, Concentric, Swimlane, Strategy Map, Funnel, Hub-Network, Section-Flow, Card-Grid, Pyramid, Exploded View, Horizontal Timeline, Org-Network, Bento Grid, Sankey, Z-Pattern, Mind Map, Stacked Progress

### 9종 색상 테마

| 테마 | 주조색 | 적합 분야 |
|------|--------|----------|
| `technical-report` | Navy #2C3E50 | 국책과제, 연구논문, 학술발표 |
| `clarity` | Charcoal #2D3436 | 설명, 정의, 구조 |
| `tech-focus` | Blue #0984E3 | AI, 데이터, 디지털 |
| `growth` | Mint #00B894 | 발전, 학습, 진화 |
| `connection` | Purple #6C5CE7 | 네트워크, 관계, 협력 |
| `innovation` | Coral #E17055 | 변화, 창조, 돌파 |
| `knowledge` | Deep Blue #1E3A5F | 큐레이션, 학습, 교육 |
| `presentation` | Dark Teal #0D4F4F | 세미나, 강연 |
| `workshop` | Forest Green #2D5A3D | 협업, 실습 |

## 설치

### 요구사항

- [Claude Code](https://claude.ai/code) (CLI)
- Python 3.8+
- Gemini API Key ([Google AI Studio](https://aistudio.google.com/apikey)에서 발급)

### 설치 방법

```bash
git clone https://github.com/YOUR_USERNAME/claude-visual-generator.git
cd claude-visual-generator
bash install.sh
```

설치 스크립트가 자동으로:
1. Python 의존성 설치 (`google-genai`, `Pillow`, `python-dotenv`)
2. 스킬 파일을 `~/.claude/skills/visual-generator/`에 복사
3. `~/.claude/CLAUDE.md`에 스킬 등록
4. Gemini API 키 설정 안내

### 수동 설치

```bash
# 1. 의존성 설치
pip install google-genai Pillow python-dotenv

# 2. 스킬 복사
mkdir -p ~/.claude/skills/visual-generator
cp -r skills/ scripts/ references/ ~/.claude/skills/visual-generator/

# 3. API 키 설정
echo 'GEMINI_API_KEY=your-key' > .env
```

## 사용법

### 1. 프롬프트 생성

Claude Code에서 자연어로 요청합니다:

```
"이 연구 계획서로 정부 보고서용 슬라이드 이미지 프롬프트를 만들어줘"
```

```
"머신러닝 학습 파이프라인을 개념 시각화해줘"
```

```
"이 내용으로 세미나 발표 자료 시각화 프롬프트 생성해줘"
```

### 2. 이미지 렌더링

생성된 프롬프트를 이미지로 변환합니다:

```
"프롬프트 이미지 렌더링해줘"
```

또는 Python 스크립트를 직접 실행:

```bash
python ~/.claude/skills/visual-generator/scripts/generate_slide_images.py \
  --prompts-dir ./slide_image_gen/prompts/ \
  --output-dir ./slide_image_gen/figures/
```

### 출력 구조

```
slide_image_gen/
├── prompts/           # 생성된 프롬프트 (.md)
│   ├── 01_연구비전.md
│   ├── 02_핵심기술.md
│   └── prompt_index.md
├── figures/           # 생성된 이미지 (.png)
│   ├── 01_연구비전.png
│   └── 02_핵심기술.png
└── slide_generation_report.md
```

## 프롬프트 구조 (4-Block Format)

모든 프롬프트는 표준 4블록 구조를 따릅니다:

```
[INSTRUCTION BLOCK - DO NOT RENDER]     ← AI 지시사항 (영어)
[CONFIGURATION BLOCK - DO NOT RENDER]   ← 레이아웃/텍스트 설정 (영어)
[CONTENT BLOCK - FOR IMAGE RENDERING]   ← 실제 이미지 콘텐츠 (단일 언어)
[FORBIDDEN ELEMENTS - DO NOT RENDER]    ← 금지 요소 목록 (영어)
```

### 핵심 렌더링 규칙

- 배경: 순백색 (#FFFFFF) 고정
- 해상도: 4K (3840x2160), 16:9
- 대제목/슬라이드 타이틀: 이미지에 포함 금지
- 폰트 크기 숫자 (pt/px): 프롬프트에 포함 금지
- 언어 병기: 금지 (단일 언어만 사용)
- 도메인 키워드: 원문 보존 필수

## 스킬별 상세

### prompt-concept (기술 보고서)
- **텍스트 요소**: 12-15개
- **원칙**: "한 이미지, 한 메시지"
- **스타일**: 3D 렌더링 / 플랫 아이콘 / 사진

### prompt-gov (정부/공공)
- **텍스트 요소**: ~25개
- **원칙**: 신뢰감, 공공성, 원문 충실성
- **넘버링 뱃지**: 사용 금지 (공간 배치로 순서 전달)

### prompt-seminar (세미나/워크숍)
- **텍스트 요소**: 20-30개
- **복합 레이아웃**: 최대 3개 조합 지원
- **언어**: 단일 언어 엄격 적용

### renderer (이미지 변환)
- **모델**: gemini-3-pro-image-preview
- **해상도**: 4K, 16:9
- **재시도**: 최대 3회

## 제거

```bash
bash uninstall.sh
```

## 라이선스

MIT License

## 기여

이슈와 PR을 환영합니다.
