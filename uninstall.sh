#!/bin/bash
# A11y Agent Team Uninstaller
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash uninstall.sh            Interactive mode
#   bash uninstall.sh --global   Uninstall from ~/.claude/
#   bash uninstall.sh --project  Uninstall from .claude/ in the current directory

set -e

# Auto-detect installed agents rather than using a hardcoded list

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
AGENTS_DIR="$TARGET_DIR/agents"
if [ -d "$AGENTS_DIR" ]; then
  for agent in "$AGENTS_DIR"/*.md; do
    [ -f "$agent" ] || continue
    name="$(basename "${agent%.md}")"
    rm "$agent"
    echo "    - $name"
  done
fi

echo ""
echo "  Removing hook..."
if [ -f "$TARGET_DIR/hooks/a11y-team-eval.sh" ]; then
  rm "$TARGET_DIR/hooks/a11y-team-eval.sh"
  echo "    - a11y-team-eval.sh"
fi

# Remove Copilot agents if installed (project uninstall only)
if [ "$choice" = "1" ]; then
  COPILOT_DIR="$(pwd)/.github/agents"
  if [ -d "$COPILOT_DIR" ]; then
    echo ""
    echo "  Removing Copilot agents..."
    for agent in "$COPILOT_DIR"/*.agent.md; do
      [ -f "$agent" ] || continue
      name="$(basename "${agent%.md}")"
      rm "$agent"
      echo "    - $name"
    done
    rmdir "$COPILOT_DIR" 2>/dev/null || true
  fi

  # Remove Copilot config files
  for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
    CONFIG_FILE="$(pwd)/.github/$config"
    if [ -f "$CONFIG_FILE" ]; then
      rm "$CONFIG_FILE"
      echo "    - $config"
    fi
  done
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

# Remove Copilot agents from VS Code profile folders (global uninstall only)
if [ "$choice" = "2" ]; then
  if [ "$(uname)" = "Darwin" ]; then
    VSCODE_PROFILES=(
      "$HOME/Library/Application Support/Code/User"
      "$HOME/Library/Application Support/Code - Insiders/User"
    )
  else
    VSCODE_PROFILES=(
      "$HOME/.config/Code/User"
      "$HOME/.config/Code - Insiders/User"
    )
  fi

  for PROFILE_DIR in "${VSCODE_PROFILES[@]}"; do
    if ls "$PROFILE_DIR"/*.agent.md 1>/dev/null 2>&1; then
      echo ""
      echo "  Removing Copilot agents from VS Code profile: $PROFILE_DIR"
      for agent in "$PROFILE_DIR"/*.agent.md; do
        [ -f "$agent" ] || continue
        name="$(basename "${agent%.agent.md}")"
        rm "$agent"
        echo "    - $name"
      done
    fi
  done

  # Remove central Copilot store
  COPILOT_CENTRAL="$HOME/.a11y-agent-team"
  if [ -d "$COPILOT_CENTRAL" ]; then
    echo ""
    echo "  Removing Copilot central store..."
    rm -rf "$COPILOT_CENTRAL"
    echo "    - $COPILOT_CENTRAL"
  fi

  # Remove a11y-copilot-init command
  if [ -f "/usr/local/bin/a11y-copilot-init" ]; then
    rm -f "/usr/local/bin/a11y-copilot-init"
    echo "    - a11y-copilot-init command"
  fi
fi

# Remove auto-update (global uninstall only)
if [ "$choice" = "2" ]; then
  echo ""
  echo "  Removing auto-update..."

  # Remove LaunchAgent (macOS)
  PLIST_FILE="$HOME/Library/LaunchAgents/com.community-access.accessibility-agents-update.plist"
  if [ -f "$PLIST_FILE" ]; then
    launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
    rm "$PLIST_FILE"
    echo "    - LaunchAgent removed"
  fi

  # Remove cron job (Linux)
  if crontab -l 2>/dev/null | grep -q "a11y-agent-team-update"; then
    crontab -l 2>/dev/null | grep -v "a11y-agent-team-update" | crontab -
    echo "    - Cron job removed"
  fi

  # Remove update script, cache, version file, and log
  rm -f "$TARGET_DIR/.a11y-agent-team-update.sh"
  rm -f "$TARGET_DIR/.a11y-agent-team-version"
  rm -f "$TARGET_DIR/.a11y-agent-team-update.log"
  rm -rf "$TARGET_DIR/.a11y-agent-team-repo"
  echo "    - Update files cleaned up"
fi

# Clean up empty directories
rmdir "$TARGET_DIR/hooks" 2>/dev/null || true
rmdir "$TARGET_DIR/agents" 2>/dev/null || true

echo ""
echo "  Uninstall complete."
echo ""
