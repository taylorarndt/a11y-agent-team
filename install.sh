#!/bin/bash
# A11y Agent Team Installer
# Built by Techopolis - https://techopolis.online
#
# Usage:
#   bash install.sh            Interactive mode (prompts for project or global)
#   bash install.sh --global   Install globally to ~/.claude/
#   bash install.sh --project  Install to .claude/ in the current directory

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_SRC="$SCRIPT_DIR/.claude/agents"
HOOK_SRC="$SCRIPT_DIR/.claude/hooks/a11y-team-eval.sh"

AGENTS=(
  "accessibility-lead.md"
  "aria-specialist.md"
  "modal-specialist.md"
  "contrast-master.md"
  "keyboard-navigator.md"
  "live-region-controller.md"
)

# Validate source files exist
if [ ! -d "$AGENTS_SRC" ]; then
  echo "  Error: Agents directory not found at $AGENTS_SRC"
  echo "  Make sure you are running this script from the a11y-agent-team directory."
  exit 1
fi

if [ ! -f "$HOOK_SRC" ]; then
  echo "  Error: Hook script not found at $HOOK_SRC"
  exit 1
fi

# Parse flags for non-interactive install
choice=""
if [ "$1" = "--global" ]; then
  choice="2"
elif [ "$1" = "--project" ]; then
  choice="1"
fi

if [ -z "$choice" ]; then
  echo ""
  echo "  A11y Agent Team Installer"
  echo "  Built by Techopolis"
  echo "  ========================="
  echo ""
  echo "  Where would you like to install?"
  echo ""
  echo "  1) Project   - Install to .claude/ in the current directory"
  echo "                  (recommended, check into version control)"
  echo ""
  echo "  2) Global    - Install to ~/.claude/"
  echo "                  (available in all your projects)"
  echo ""
  printf "  Choose [1/2]: "
  read -r choice
fi

case "$choice" in
  1)
    TARGET_DIR="$(pwd)/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    HOOK_CMD=".claude/hooks/a11y-team-eval.sh"
    echo ""
    echo "  Installing to project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    HOOK_CMD="$HOME/.claude/hooks/a11y-team-eval.sh"
    echo ""
    echo "  Installing globally to: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    exit 1
    ;;
esac

# Create directories
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/hooks"

# Copy agents
echo ""
echo "  Copying agents..."
for agent in "${AGENTS[@]}"; do
  if [ ! -f "$AGENTS_SRC/$agent" ]; then
    echo "    ! Missing: $agent (skipped)"
    continue
  fi
  cp "$AGENTS_SRC/$agent" "$TARGET_DIR/agents/$agent"
  name="${agent%.md}"
  echo "    + $name"
done

# Copy hook
echo ""
echo "  Copying hook..."
cp "$HOOK_SRC" "$TARGET_DIR/hooks/a11y-team-eval.sh"
chmod +x "$TARGET_DIR/hooks/a11y-team-eval.sh"
echo "    + a11y-team-eval.sh"

# Handle settings.json
echo ""

HOOK_ENTRY="{\"type\":\"command\",\"command\":\"$HOOK_CMD\"}"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if hook already exists
  if grep -q "a11y-team-eval" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  Hook already configured in settings.json. Skipping."
  else
    # Try to auto-merge with python3 (available on macOS and most Linux)
    if command -v python3 &>/dev/null; then
      MERGED=$(python3 -c "
import json, sys
try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    hook_entry = {'type': 'command', 'command': '$HOOK_CMD'}
    new_group = {'hooks': [hook_entry]}
    if 'hooks' not in settings:
        settings['hooks'] = {}
    if 'UserPromptSubmit' not in settings['hooks']:
        settings['hooks']['UserPromptSubmit'] = []
    settings['hooks']['UserPromptSubmit'].append(new_group)
    print(json.dumps(settings, indent=2))
except Exception as e:
    print('MERGE_FAILED', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) && {
        echo "$MERGED" > "$SETTINGS_FILE"
        echo "  Updated existing settings.json with hook."
      } || {
        echo "  Existing settings.json found but could not auto-merge."
        echo "  Add this hook entry to your settings.json manually:"
        echo ""
        echo "  In the \"hooks\" > \"UserPromptSubmit\" array, add:"
        echo ""
        echo "    {"
        echo "      \"hooks\": ["
        echo "        {"
        echo "          \"type\": \"command\","
        echo "          \"command\": \"$HOOK_CMD\""
        echo "        }"
        echo "      ]"
        echo "    }"
        echo ""
      }
    else
      echo "  Existing settings.json found."
      echo "  python3 not available for auto-merge."
      echo "  Add this hook entry to your settings.json manually:"
      echo ""
      echo "  In the \"hooks\" > \"UserPromptSubmit\" array, add:"
      echo ""
      echo "    {"
      echo "      \"hooks\": ["
      echo "        {"
      echo "          \"type\": \"command\","
      echo "          \"command\": \"$HOOK_CMD\""
      echo "        }"
      echo "      ]"
      echo "    }"
      echo ""
    fi
  fi
else
  # Create settings.json with hook
  cat > "$SETTINGS_FILE" << SETTINGS
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_CMD"
          }
        ]
      }
    ]
  }
}
SETTINGS
  echo "  Created settings.json with hook configured."
fi

# Verify installation
echo ""
echo "  ========================="
echo "  Installation complete!"
echo ""
echo "  Agents installed:"
for agent in "${AGENTS[@]}"; do
  name="${agent%.md}"
  if [ -f "$TARGET_DIR/agents/$agent" ]; then
    echo "    [x] $name"
  else
    echo "    [ ] $name (missing)"
  fi
done
echo ""
echo "  Hook installed:"
if [ -f "$TARGET_DIR/hooks/a11y-team-eval.sh" ]; then
  echo "    [x] a11y-team-eval.sh"
else
  echo "    [ ] a11y-team-eval.sh (missing)"
fi
echo ""
echo "  Settings:"
if grep -q "a11y-team-eval" "$SETTINGS_FILE" 2>/dev/null; then
  echo "    [x] Hook configured in settings.json"
else
  echo "    [ ] Hook NOT configured -- add it manually (see above)"
fi
echo ""
echo "  If agents do not load, increase the character budget:"
echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000"
echo ""
echo "  Start Claude Code and try: \"Build a login form\""
echo "  The accessibility-lead should activate automatically."
echo ""
