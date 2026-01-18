#!/bin/bash
# Install ralph-wiggum for Claude Code and Amp

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "ralph-wiggum installer"
echo ""

# Claude Code plugin installation
echo -e "${CYAN}=== Claude Code ===${NC}"

if command -v claude &> /dev/null; then
  echo -e "${GREEN}Installing plugin via Claude CLI...${NC}"

  # Add local directory as marketplace (idempotent - safe to run multiple times)
  if claude plugin marketplace add "$SCRIPT_DIR" 2>/dev/null; then
    echo "  Marketplace registered: $SCRIPT_DIR"
  else
    echo "  Marketplace already registered or updated"
  fi

  # Install the plugin to user scope
  if claude plugin install ralph-wiggum@ralph-wiggum --scope user 2>/dev/null; then
    echo -e "${GREEN}  Plugin installed successfully!${NC}"
  else
    echo -e "${YELLOW}  Plugin may already be installed, or installation failed${NC}"
    echo "  Try manually: /plugin install ralph-wiggum@ralph-wiggum"
  fi
else
  echo -e "${YELLOW}Claude CLI not found. Manual installation required:${NC}"
  echo ""
  echo "  1. Start Claude Code"
  echo "  2. Run: /plugin marketplace add $SCRIPT_DIR"
  echo "  3. Run: /plugin install ralph-wiggum@ralph-wiggum"
  echo ""
  echo "  Or for testing without installing:"
  echo "  claude --plugin-dir $SCRIPT_DIR"
fi

echo ""

# Amp skill installation
AMP_SKILL_DIR="$HOME/.config/agents/skills/ralph-wiggum"
echo -e "${CYAN}=== Amp ===${NC}"
echo -e "${GREEN}Installing Amp skill to $AMP_SKILL_DIR${NC}"
mkdir -p "$AMP_SKILL_DIR"
# Copy the detailed SKILL.md (from skills/ralph/) as the main skill file
cp "$SCRIPT_DIR/skills/ralph/SKILL.md" "$AMP_SKILL_DIR/"
cp "$SCRIPT_DIR/README.md" "$AMP_SKILL_DIR/"
echo "  Done!"
echo ""

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Restart Claude Code / Amp for changes to take effect."
echo ""
echo "Usage:"
echo "  Claude Code: /ralph-wiggum:ralph"
echo "  Amp:         /skill ralph"
