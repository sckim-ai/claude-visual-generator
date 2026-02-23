#!/usr/bin/env bash
#
# Claude Visual Generator - Install Script
#
# Usage: bash install.sh
#
set -euo pipefail

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step()  { echo -e "${BLUE}[*]${NC} $1"; }
print_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
print_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ─── Paths ───
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_TARGET="$HOME/.claude/skills/visual-generator"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Claude Visual Generator - Installer        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ─── Step 1: Check Python ───
print_step "Python 환경 확인..."
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
else
    print_error "Python이 설치되어 있지 않습니다. Python 3.8 이상을 설치해주세요."
    exit 1
fi

PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
print_ok "Python $PYTHON_VERSION 확인됨 ($PYTHON_CMD)"

# ─── Step 2: Install Python Dependencies ───
print_step "Python 의존성 설치..."
$PYTHON_CMD -m pip install -r "$SCRIPT_DIR/requirements.txt" --quiet 2>/dev/null || {
    print_warn "pip install 실패. 수동으로 실행해주세요:"
    echo "  $PYTHON_CMD -m pip install google-genai Pillow python-dotenv"
}
print_ok "Python 의존성 설치 완료"

# ─── Step 3: Create skill directory ───
print_step "스킬 디렉토리 생성..."
mkdir -p "$SKILL_TARGET"

# ─── Step 4: Copy skill files ───
print_step "스킬 파일 복사..."

# Copy skills
cp -r "$SCRIPT_DIR/skills/"* "$SKILL_TARGET/skills/" 2>/dev/null || {
    mkdir -p "$SKILL_TARGET/skills"
    cp -r "$SCRIPT_DIR/skills/"* "$SKILL_TARGET/skills/"
}

# Copy scripts
cp -r "$SCRIPT_DIR/scripts/"* "$SKILL_TARGET/scripts/" 2>/dev/null || {
    mkdir -p "$SKILL_TARGET/scripts"
    cp -r "$SCRIPT_DIR/scripts/"* "$SKILL_TARGET/scripts/"
}

# Copy references
cp -r "$SCRIPT_DIR/references/"* "$SKILL_TARGET/references/" 2>/dev/null || {
    mkdir -p "$SKILL_TARGET/references"
    cp -r "$SCRIPT_DIR/references/"* "$SKILL_TARGET/references/"
}

print_ok "스킬 파일 복사 완료: $SKILL_TARGET"

# ─── Step 5: Register in CLAUDE.md ───
MARKER="## Visual Generator 스킬"
if [ -f "$CLAUDE_MD" ]; then
    if grep -q "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
        print_warn "CLAUDE.md에 이미 등록되어 있습니다. 건너뜁니다."
    else
        print_step "CLAUDE.md에 스킬 등록..."
        cat >> "$CLAUDE_MD" << 'CLAUDEMD_ENTRY'

## Visual Generator 스킬

시각 자료 이미지 생성 스킬이 설치되어 있다.

- **스킬 위치**: `~/.claude/skills/visual-generator/`
- **하위 스킬**:
  - `visual-prompt-concept`: 기술 보고서/학술 발표용 개념 시각화 프롬프트 생성
  - `visual-prompt-gov`: 정부/공공기관 발표 자료용 인포그래픽 프롬프트 생성
  - `visual-prompt-seminar`: 사내 세미나/워크숍 발표용 프롬프트 생성
  - `visual-renderer`: 프롬프트를 Gemini API로 이미지 변환
- **필수 라이브러리**: `pip install google-genai Pillow python-dotenv`
- **API 키**: `.env` 파일에 `GEMINI_API_KEY` 설정 필요
CLAUDEMD_ENTRY
        print_ok "CLAUDE.md에 스킬 등록 완료"
    fi
else
    print_step "CLAUDE.md 생성 및 스킬 등록..."
    mkdir -p "$(dirname "$CLAUDE_MD")"
    cat > "$CLAUDE_MD" << 'CLAUDEMD_NEW'
# CLAUDE.md

## Visual Generator 스킬

시각 자료 이미지 생성 스킬이 설치되어 있다.

- **스킬 위치**: `~/.claude/skills/visual-generator/`
- **하위 스킬**:
  - `visual-prompt-concept`: 기술 보고서/학술 발표용 개념 시각화 프롬프트 생성
  - `visual-prompt-gov`: 정부/공공기관 발표 자료용 인포그래픽 프롬프트 생성
  - `visual-prompt-seminar`: 사내 세미나/워크숍 발표용 프롬프트 생성
  - `visual-renderer`: 프롬프트를 Gemini API로 이미지 변환
- **필수 라이브러리**: `pip install google-genai Pillow python-dotenv`
- **API 키**: `.env` 파일에 `GEMINI_API_KEY` 설정 필요
CLAUDEMD_NEW
    print_ok "CLAUDE.md 생성 및 스킬 등록 완료"
fi

# ─── Step 6: API Key Setup ───
echo ""
print_step "Gemini API 키 설정..."
if [ -n "${GEMINI_API_KEY:-}" ]; then
    print_ok "환경변수에서 GEMINI_API_KEY 감지됨"
else
    echo ""
    echo -e "${YELLOW}Gemini API 키가 필요합니다.${NC}"
    echo "  1) Google AI Studio에서 키 발급: https://aistudio.google.com/apikey"
    echo "  2) 프로젝트 루트에 .env 파일 생성:"
    echo "     echo 'GEMINI_API_KEY=your-api-key' > .env"
    echo "  3) 또는 환경변수로 설정:"
    echo "     export GEMINI_API_KEY='your-api-key'"
    echo ""
    read -rp "지금 API 키를 입력하시겠습니까? (y/N): " SETUP_KEY
    if [[ "$SETUP_KEY" =~ ^[Yy]$ ]]; then
        read -rp "GEMINI_API_KEY: " API_KEY
        if [ -n "$API_KEY" ]; then
            echo "GEMINI_API_KEY=$API_KEY" >> "$HOME/.env"
            print_ok "API 키가 ~/.env에 저장되었습니다."
        fi
    fi
fi

# ─── Done ───
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   설치 완료!                                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "사용법:"
echo "  1. Claude Code에서 다음 키워드로 활성화:"
echo "     - '개념 시각화 프롬프트 만들어줘'"
echo "     - '정부 보고서용 슬라이드 이미지 생성해줘'"
echo "     - '세미나 발표 자료 시각화해줘'"
echo "     - '프롬프트 이미지 렌더링해줘'"
echo ""
echo "  2. 스킬 위치: $SKILL_TARGET"
echo "  3. 문서: $SCRIPT_DIR/README.md"
echo ""
