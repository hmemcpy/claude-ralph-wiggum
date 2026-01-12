#!/bin/bash
# Install ralph-wiggum for Claude Code and Amp

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "ralph-wiggum installer"
echo ""

# Claude Code plugin installation
echo -e "${CYAN}=== Claude Code ===${NC}"
echo ""
echo "Option 1: Install from GitHub (recommended)"
echo "  /plugin marketplace add hmemcpy/ralph-wiggum"
echo "  /plugin install ralph-wiggum@ralph-wiggum"
echo ""
echo "Option 2: Test locally without installing"
echo "  claude --plugin-dir $SCRIPT_DIR"
echo ""

# Amp skill installation
AMP_SKILL_DIR="$HOME/.config/agents/skills/ralph-wiggum"
echo -e "${CYAN}=== Amp ===${NC}"
echo -e "${GREEN}Installing Amp skill to $AMP_SKILL_DIR${NC}"
mkdir -p "$AMP_SKILL_DIR/skills/ralph"
cp -r "$SCRIPT_DIR/skills/ralph/"* "$AMP_SKILL_DIR/skills/ralph/"
cp -r "$SCRIPT_DIR/common" "$AMP_SKILL_DIR/"
cp -r "$SCRIPT_DIR/agents" "$AMP_SKILL_DIR/"
cp "$SCRIPT_DIR/SKILL.md" "$AMP_SKILL_DIR/"
cp "$SCRIPT_DIR/README.md" "$AMP_SKILL_DIR/"
echo "  Done!"
echo ""

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Usage:"
echo "  Claude Code: /ralph-wiggum:ralph"
echo "  Amp:         /skill ralph"
