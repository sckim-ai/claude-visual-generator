#!/usr/bin/env bash
#
# Claude Visual Generator - Uninstall Script
#
# Usage: bash uninstall.sh
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SKILL_TARGET="$HOME/.claude/skills/visual-generator"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Claude Visual Generator - Uninstaller      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

read -rp "Visual Generator 스킬을 삭제하시겠습니까? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "취소되었습니다."
    exit 0
fi

# Remove skill directory
if [ -d "$SKILL_TARGET" ]; then
    rm -rf "$SKILL_TARGET"
    echo -e "${GREEN}[OK]${NC} 스킬 디렉토리 삭제: $SKILL_TARGET"
else
    echo -e "${YELLOW}[!]${NC} 스킬 디렉토리가 존재하지 않습니다: $SKILL_TARGET"
fi

# Remove CLAUDE.md entry
if [ -f "$CLAUDE_MD" ]; then
    if grep -q "## Visual Generator 스킬" "$CLAUDE_MD" 2>/dev/null; then
        # Remove the visual-generator section (from marker to next ## or EOF)
        python3 -c "
import re, sys
with open('$CLAUDE_MD', 'r', encoding='utf-8') as f:
    content = f.read()
# Remove the Visual Generator section
pattern = r'\n## Visual Generator 스킬\n.*?(?=\n## |\Z)'
content = re.sub(pattern, '', content, flags=re.DOTALL)
with open('$CLAUDE_MD', 'w', encoding='utf-8') as f:
    f.write(content.rstrip() + '\n')
" 2>/dev/null || {
            echo -e "${YELLOW}[!]${NC} CLAUDE.md에서 자동 제거 실패. 수동으로 'Visual Generator 스킬' 섹션을 삭제해주세요."
        }
        echo -e "${GREEN}[OK]${NC} CLAUDE.md에서 스킬 등록 제거"
    fi
fi

echo ""
echo -e "${GREEN}[완료]${NC} Visual Generator 스킬이 삭제되었습니다."
echo "Python 패키지(google-genai, Pillow, python-dotenv)는 수동으로 제거하세요:"
echo "  pip uninstall google-genai Pillow python-dotenv"
echo ""
