#!/bin/bash
# A11y Agent Team Uninstaller
# Built by Techopolis - https://techopolis.online
#
# Usage:
#   bash uninstall.sh            Interactive mode
#   bash uninstall.sh --global   Uninstall from ~/.claude/
#   bash uninstall.sh --project  Uninstall from .claude/ in the current directory

set -e

AGENTS=(
  "accessibility-lead.md"
  "aria-specialist.md"
  "modal-specialist.md"
  "contrast-master.md"
  "keyboard-navigator.md"
  "live-region-controller.md"
)

# Parse flags for non-interactive uninstall
choice=""
if [ "$1" = "--global" ]; then
  choice="2"
elif [ "$1" = "--project" ]; then
  choice="1"
fi

if [ -z "$choice" ]; then
  echo ""
  echo "  A11y Agent Team Uninstaller"
  echo "  ==========================="
  echo ""
  echo "  Where would you like to uninstall from?"
  echo ""
  echo "  1) Project   - Remove from .claude/ in the current directory"
  echo "  2) Global    - Remove from ~/.claude/"
  echo ""
  printf "  Choose [1/2]: "
  read -r choice
fi

case "$choice" in
  1)
    TARGET_DIR="$(pwd)/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    echo ""
    echo "  Uninstalling from project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    echo ""
    echo "  Uninstalling from: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""
echo "  Removing agents..."
for agent in "${AGENTS[@]}"; do
  if [ -f "$TARGET_DIR/agents/$agent" ]; then
    rm "$TARGET_DIR/agents/$agent"
    name="${agent%.md}"
    echo "    - $name"
  fi
done

echo ""
echo "  Removing hook..."
if [ -f "$TARGET_DIR/hooks/a11y-team-eval.sh" ]; then
  rm "$TARGET_DIR/hooks/a11y-team-eval.sh"
  echo "    - a11y-team-eval.sh"
fi

# Try to remove hook from settings.json
echo ""
if [ -f "$SETTINGS_FILE" ] && grep -q "a11y-team-eval" "$SETTINGS_FILE" 2>/dev/null; then
  if command -v python3 &>/dev/null; then
    CLEANED=$(python3 -c "
import json, sys
try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    if 'hooks' in settings and 'UserPromptSubmit' in settings['hooks']:
        groups = settings['hooks']['UserPromptSubmit']
        settings['hooks']['UserPromptSubmit'] = [
            g for g in groups
            if not any('a11y-team-eval' in h.get('command', '') for h in g.get('hooks', []))
        ]
        if not settings['hooks']['UserPromptSubmit']:
            del settings['hooks']['UserPromptSubmit']
        if not settings['hooks']:
            del settings['hooks']
    print(json.dumps(settings, indent=2))
except Exception as e:
    print('CLEAN_FAILED', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) && {
      echo "$CLEANED" > "$SETTINGS_FILE"
      echo "  Removed hook from settings.json."
    } || {
      echo "  Could not auto-remove hook from settings.json."
      echo "  Remove the UserPromptSubmit hook referencing a11y-team-eval manually."
    }
  else
    echo "  NOTE: The hook entry in settings.json was not removed."
    echo "  Remove the UserPromptSubmit hook referencing a11y-team-eval.sh"
    echo "  from your settings.json manually."
  fi
fi

# Clean up empty directories
rmdir "$TARGET_DIR/hooks" 2>/dev/null || true
rmdir "$TARGET_DIR/agents" 2>/dev/null || true

echo ""
echo "  Uninstall complete."
echo ""
