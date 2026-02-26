#!/bin/bash
# Accessibility Agents Uninstaller
# Started by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash uninstall.sh            Interactive mode
#   bash uninstall.sh --global   Uninstall from ~/.claude/
#   bash uninstall.sh --project  Uninstall from .claude/ in the current directory
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/uninstall.sh | bash
#   curl -fsSL ... | bash -s -- --global   (non-interactive)

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
  # Verify terminal is available (required when piped via curl)
  if ! { true < /dev/tty; } 2>/dev/null; then
    echo "  Error: No terminal available for interactive mode."
    echo "  Use: curl ... | bash -s -- --global"
    echo "    or: curl ... | bash -s -- --project"
    exit 1
  fi
  echo ""
  echo "  Accessibility Agents Uninstaller"
  echo "  ================================"
  echo ""
  echo "  Where would you like to uninstall from?"
  echo ""
  echo "  1) Project   - Remove from .claude/ in the current directory"
  echo "  2) Global    - Remove from ~/.claude/"
  echo ""
  printf "  Choose [1/2]: "
  read -r choice < /dev/tty
fi

case "$choice" in
  1)
    TARGET_DIR="$(pwd)/.claude"
    echo ""
    echo "  Uninstalling from project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    echo ""
    echo "  Uninstalling from: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    exit 1
    ;;
esac

# ---------------------------------------------------------------------------
# unregister_plugin
# Removes a11y-agent-team from Claude Code plugin system.
# ---------------------------------------------------------------------------
unregister_plugin() {
  local plugins_json="$HOME/.claude/plugins/installed_plugins.json"
  local settings_json="$HOME/.claude/settings.json"

  # Find and remove plugin registration under any namespace
  if [ -f "$plugins_json" ] && command -v python3 &>/dev/null; then
    local removed_key
    removed_key=$(python3 - "$plugins_json" << 'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
removed = None
for k in list(data.get('plugins', {})):
    if k.startswith('a11y-agent-team@'):
        removed = k
        del data['plugins'][k]
        break
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
if removed:
    print(removed)
PYEOF
    )
    if [ -n "$removed_key" ]; then
      echo "    - Removed from installed_plugins.json ($removed_key)"

      # Remove from enabledPlugins in settings.json
      if [ -f "$settings_json" ]; then
        python3 - "$settings_json" "$removed_key" << 'PYEOF'
import json, sys
path, key = sys.argv[1:3]
with open(path) as f:
    data = json.load(f)
data.get('enabledPlugins', {}).pop(key, None)
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
        echo "    - Removed from settings.json enabledPlugins"
      fi

      # Remove plugin cache
      local namespace="${removed_key#a11y-agent-team@}"
      local cache_dir="$HOME/.claude/plugins/cache/${namespace}/a11y-agent-team"
      if [ -d "$cache_dir" ]; then
        rm -rf "$cache_dir"
        echo "    - Removed plugin cache"
      fi
      # Clean up empty namespace directory
      local ns_dir="$HOME/.claude/plugins/cache/${namespace}"
      rmdir "$ns_dir" 2>/dev/null || true
    fi
  fi
}

# Load manifest to only remove files we installed
MANIFEST_FILE="$TARGET_DIR/.a11y-agent-manifest"
MANIFEST_ENTRIES=()
if [ -f "$MANIFEST_FILE" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && MANIFEST_ENTRIES+=("$line")
  done < "$MANIFEST_FILE"
fi

# Unregister plugin (global uninstall only)
if [ "$choice" = "2" ]; then
  echo ""
  echo "  Removing Claude Code plugin..."
  unregister_plugin
fi

echo ""
echo "  Removing agents..."
AGENTS_DIR="$TARGET_DIR/agents"
if [ -d "$AGENTS_DIR" ]; then
  if [ ${#MANIFEST_ENTRIES[@]} -gt 0 ]; then
    for entry in "${MANIFEST_ENTRIES[@]}"; do
      case "$entry" in
        agents/*)
          agent_file="$TARGET_DIR/$entry"
          if [ -f "$agent_file" ]; then
            name="$(basename "${agent_file%.md}")"
            rm "$agent_file"
            echo "    - $name"
          fi
          ;;
      esac
    done
  else
    echo "    (no manifest found — skipping to avoid removing user-created files)"
  fi
fi

# Remove commands
echo ""
echo "  Removing commands..."
COMMANDS_DIR="$TARGET_DIR/commands"
if [ -d "$COMMANDS_DIR" ]; then
  if [ ${#MANIFEST_ENTRIES[@]} -gt 0 ]; then
    for entry in "${MANIFEST_ENTRIES[@]}"; do
      case "$entry" in
        commands/*)
          cmd_file="$TARGET_DIR/$entry"
          if [ -f "$cmd_file" ]; then
            name="$(basename "${cmd_file%.md}")"
            rm "$cmd_file"
            echo "    - /$name"
          fi
          ;;
      esac
    done
  else
    echo "    (no manifest found — skipping to avoid removing user-created files)"
  fi
  rmdir "$COMMANDS_DIR" 2>/dev/null || true
fi

# Remove Copilot agents if installed (project uninstall only)
if [ "$choice" = "1" ]; then
  COPILOT_DIR="$(pwd)/.github/agents"
  if [ -d "$COPILOT_DIR" ]; then
    echo ""
    echo "  Removing Copilot agents..."
    # Only remove agents listed in manifest to avoid deleting user-created files
    has_copilot_entries=false
    for entry in "${MANIFEST_ENTRIES[@]}"; do
      case "$entry" in
        copilot-agents/*)
          has_copilot_entries=true
          agent_name="${entry#copilot-agents/}"
          agent_file="$COPILOT_DIR/$agent_name"
          if [ -f "$agent_file" ]; then
            name="$(basename "${agent_file%.md}")"
            rm "$agent_file"
            echo "    - $name"
          fi
          ;;
      esac
    done
    if [ "$has_copilot_entries" = false ]; then
      echo "    (no manifest entries for copilot-agents — skipping)"
    fi
    rmdir "$COPILOT_DIR" 2>/dev/null || true
  fi

  # Remove Copilot config files — only those with our section markers
  for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
    CONFIG_FILE="$(pwd)/.github/$config"
    if [ -f "$CONFIG_FILE" ]; then
      if grep -qF '<!-- a11y-agent-team: start -->' "$CONFIG_FILE" 2>/dev/null; then
        rm "$CONFIG_FILE"
        echo "    - $config"
      else
        echo "    ~ $config (has user content — skipped)"
      fi
    fi
  done
fi

# Remove Codex CLI support
if [ "$choice" = "1" ]; then
  CODEX_DIR="$(pwd)/.codex"
else
  CODEX_DIR="$HOME/.codex"
fi

CODEX_FILE="$CODEX_DIR/AGENTS.md"
if [ -f "$CODEX_FILE" ]; then
  if grep -qF '<!-- a11y-agent-team: start -->' "$CODEX_FILE" 2>/dev/null; then
    echo ""
    echo "  Removing Codex CLI support..."
    rm "$CODEX_FILE"
    rmdir "$CODEX_DIR" 2>/dev/null || true
    echo "    - AGENTS.md (Codex)"
  else
    echo ""
    echo "    ~ .codex/AGENTS.md (has user content — skipped)"
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

# Clean up manifest and empty directories
rm -f "$TARGET_DIR/.a11y-agent-manifest"
rmdir "$TARGET_DIR/agents" 2>/dev/null || true
rmdir "$TARGET_DIR/commands" 2>/dev/null || true

echo ""
echo "  Uninstall complete."
echo ""
