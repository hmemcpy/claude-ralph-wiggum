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

CLAUDE_PLUGINS_DIR="$HOME/.claude/plugins"
INSTALLED_PLUGINS="$CLAUDE_PLUGINS_DIR/installed_plugins.json"

# Update marketplace version if it exists
MARKETPLACE_CACHE=$(ls -d "$CLAUDE_PLUGINS_DIR/cache/ralph-wiggum/ralph-wiggum"/*/ 2>/dev/null | head -1)
if [[ -n "$MARKETPLACE_CACHE" && -d "$MARKETPLACE_CACHE" ]]; then
  echo -e "${GREEN}Updating marketplace cache at $MARKETPLACE_CACHE${NC}"
  cp -r "$SCRIPT_DIR/.claude-plugin" "$MARKETPLACE_CACHE/"
  mkdir -p "$MARKETPLACE_CACHE/skills"
  cp -r "$SCRIPT_DIR/skills/ralph-claude" "$MARKETPLACE_CACHE/skills/"
fi

# Update local version (always)
LOCAL_CACHE="$CLAUDE_PLUGINS_DIR/cache/ralph-wiggum-local/ralph-wiggum/latest"
echo -e "${GREEN}Updating local install at $LOCAL_CACHE${NC}"
mkdir -p "$LOCAL_CACHE"
cp -r "$SCRIPT_DIR/.claude-plugin" "$LOCAL_CACHE/"
mkdir -p "$LOCAL_CACHE/skills"
cp -r "$SCRIPT_DIR/skills/ralph-claude" "$LOCAL_CACHE/skills/"

# Register local plugin in installed_plugins.json
if [[ -f "$INSTALLED_PLUGINS" ]]; then
  if command -v jq &> /dev/null; then
    jq '.plugins["ralph-wiggum@ralph-wiggum-local"] = [{
      "scope": "user",
      "installPath": "'"$LOCAL_CACHE"'",
      "version": "latest",
      "installedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'",
      "lastUpdated": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
    }]' "$INSTALLED_PLUGINS" > "${INSTALLED_PLUGINS}.tmp" && mv "${INSTALLED_PLUGINS}.tmp" "$INSTALLED_PLUGINS"
    echo "  Plugin registered in installed_plugins.json"
  else
    echo -e "${YELLOW}  jq not found - please register plugin manually via /plugin${NC}"
  fi
else
  mkdir -p "$CLAUDE_PLUGINS_DIR"
  cat > "$INSTALLED_PLUGINS" << EOF
{
  "version": 2,
  "plugins": {
    "ralph-wiggum@ralph-wiggum-local": [
      {
        "scope": "user",
        "installPath": "$LOCAL_CACHE",
        "version": "latest",
        "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
        "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
      }
    ]
  }
}
EOF
  echo "  Created installed_plugins.json"
fi

echo -e "${GREEN}Done!${NC}"
echo ""

# Amp skill installation
AMP_SKILL_DIR="$HOME/.config/agents/skills/ralph-wiggum"
echo -e "${CYAN}=== Amp ===${NC}"
echo -e "${GREEN}Installing Amp skill to $AMP_SKILL_DIR${NC}"
mkdir -p "$AMP_SKILL_DIR"
# Copy the Amp skill
cp "$SCRIPT_DIR/agents/ralph-amp/SKILL.md" "$AMP_SKILL_DIR/"
cp "$SCRIPT_DIR/README.md" "$AMP_SKILL_DIR/"
echo "  Done!"
echo ""

echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Restart Claude Code / Amp for changes to take effect."
echo ""
echo "Usage:"
echo "  Claude Code: /skill ralph-claude"
echo "  Amp:         /skill ralph-amp"
