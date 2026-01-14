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
CACHE_DIR="$CLAUDE_PLUGINS_DIR/cache/ralph-wiggum-local/ralph-wiggum/latest"

echo -e "${GREEN}Installing plugin to $CACHE_DIR${NC}"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Copy plugin files
cp -r "$SCRIPT_DIR/.claude-plugin" "$CACHE_DIR/"
cp -r "$SCRIPT_DIR/commands" "$CACHE_DIR/"

# Update installed_plugins.json
INSTALLED_PLUGINS="$CLAUDE_PLUGINS_DIR/installed_plugins.json"

if [[ -f "$INSTALLED_PLUGINS" ]]; then
  # Check if already installed
  if grep -q "ralph-wiggum@ralph-wiggum-local" "$INSTALLED_PLUGINS"; then
    echo "  Plugin already registered, updating files..."
  else
    # Add to installed plugins using jq if available, otherwise manual
    if command -v jq &> /dev/null; then
      jq '.plugins["ralph-wiggum@ralph-wiggum-local"] = [{
        "scope": "user",
        "installPath": "'"$CACHE_DIR"'",
        "version": "latest",
        "installedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'",
        "lastUpdated": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
      }]' "$INSTALLED_PLUGINS" > "${INSTALLED_PLUGINS}.tmp" && mv "${INSTALLED_PLUGINS}.tmp" "$INSTALLED_PLUGINS"
      echo "  Plugin registered in installed_plugins.json"
    else
      echo -e "${YELLOW}  jq not found - please register plugin manually via /plugin${NC}"
    fi
  fi
else
  # Create new installed_plugins.json
  mkdir -p "$CLAUDE_PLUGINS_DIR"
  cat > "$INSTALLED_PLUGINS" << EOF
{
  "version": 2,
  "plugins": {
    "ralph-wiggum@ralph-wiggum-local": [
      {
        "scope": "user",
        "installPath": "$CACHE_DIR",
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
