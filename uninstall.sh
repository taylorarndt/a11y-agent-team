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

# Parse flags
choice=""
for arg in "$@"; do
  case "$arg" in
    --global)  choice="2" ;;
    --project) choice="1" ;;
  esac
done

if [ -z "$choice" ]; then
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
    PROJECT_DIR="$(pwd)"
    echo ""
    echo "  Uninstalling from project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    PROJECT_DIR=""
    echo ""
    echo "  Uninstalling from: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    exit 1
    ;;
esac

# ---------------------------------------------------------------------------
# Load manifest — if missing, build a fallback list from the repo
# ---------------------------------------------------------------------------
MANIFEST_FILE="$TARGET_DIR/.a11y-agent-manifest"
MANIFEST_ENTRIES=()
FALLBACK_USED=false

if [ -f "$MANIFEST_FILE" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && MANIFEST_ENTRIES+=("$line")
  done < "$MANIFEST_FILE"
  echo "  Loaded manifest with ${#MANIFEST_ENTRIES[@]} entries."
else
  echo "  No manifest found — building fallback list from repo..."
  FALLBACK_USED=true
  TMPDIR_REPO="$(mktemp -d)"
  if git clone --quiet --depth 1 https://github.com/Community-Access/accessibility-agents.git "$TMPDIR_REPO/repo" 2>/dev/null; then
    REPO="$TMPDIR_REPO/repo"

    # Claude agents
    for f in "$REPO"/.claude/agents/*.md; do
      [ -f "$f" ] && MANIFEST_ENTRIES+=("agents/$(basename "$f")")
    done

    # Copilot agents
    for f in "$REPO"/.github/agents/*; do
      [ -f "$f" ] && MANIFEST_ENTRIES+=("copilot-agents/$(basename "$f")")
    done

    # Copilot assets
    for subdir in skills instructions prompts; do
      src_dir="$REPO/.github/$subdir"
      if [ -d "$src_dir" ]; then
        while IFS= read -r -d '' src_file; do
          rel="${src_file#$src_dir/}"
          MANIFEST_ENTRIES+=("copilot-$subdir/$rel")
        done < <(find "$src_dir" -type f -print0)
      fi
    done

    # Copilot config
    for cfg in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
      [ -f "$REPO/.github/$cfg" ] && MANIFEST_ENTRIES+=("copilot-config/$cfg")
    done

    # Codex
    [ -f "$REPO/.codex/AGENTS.md" ] && MANIFEST_ENTRIES+=("codex/project") && MANIFEST_ENTRIES+=("codex/global")

    # Gemini
    [ -d "$REPO/.gemini/extensions/a11y-agents" ] && MANIFEST_ENTRIES+=("gemini/project") && MANIFEST_ENTRIES+=("gemini/global")

    rm -rf "$TMPDIR_REPO"
    echo "  Built fallback manifest with ${#MANIFEST_ENTRIES[@]} entries."
  else
    rm -rf "$TMPDIR_REPO"
    echo "  Warning: Could not download repo for fallback. Will use file-pattern matching."
  fi
fi

# ---------------------------------------------------------------------------
# Helper: remove our section markers from a config file.
# If no user content remains, delete the file. Otherwise keep user content.
# Returns: deleted | cleaned | skipped | absent
# ---------------------------------------------------------------------------
remove_our_section() {
  local filepath="$1"
  [ -f "$filepath" ] || { echo "absent"; return; }
  if grep -qF '<!-- a11y-agent-team: start -->' "$filepath" 2>/dev/null; then
    if command -v python3 &>/dev/null; then
      local result
      result=$(A11Y_PATH="$filepath" python3 - << 'PYEOF'
import re, os
path = os.environ['A11Y_PATH']
content = open(path).read()
cleaned = re.sub(r'(?s)<!-- a11y-agent-team: start -->.*?<!-- a11y-agent-team: end -->', '', content).strip()
if not cleaned:
    os.remove(path)
    print("deleted")
else:
    open(path, 'w').write(cleaned)
    print("cleaned")
PYEOF
      )
      echo "$result"
    else
      # No python3: delete only if file is entirely our content
      local start_count end_count
      start_count=$(grep -c '<!-- a11y-agent-team: start -->' "$filepath" 2>/dev/null || echo 0)
      if [ "$start_count" -gt 0 ]; then
        rm "$filepath"
        echo "deleted"
      else
        echo "skipped"
      fi
    fi
  else
    echo "skipped"
  fi
}

# =============================================
# 1. Remove Claude Code agents
# =============================================
echo ""
echo "  Removing Claude Code agents..."
AGENTS_DIR="$TARGET_DIR/agents"
REMOVED_AGENTS=0
if [ -d "$AGENTS_DIR" ]; then
  has_agent_entries=false
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    case "$entry" in
      agents/*)
        has_agent_entries=true
        agent_file="$TARGET_DIR/$entry"
        if [ -f "$agent_file" ]; then
          name="$(basename "${agent_file%.md}")"
          rm "$agent_file"
          echo "    - $name"
          REMOVED_AGENTS=$((REMOVED_AGENTS + 1))
        fi
        ;;
    esac
  done
  if [ "$has_agent_entries" = false ] && [ "$FALLBACK_USED" = true ]; then
    # Last resort: remove all .md files in agents dir
    for agent_file in "$AGENTS_DIR"/*.md; do
      [ -f "$agent_file" ] || continue
      name="$(basename "${agent_file%.md}")"
      rm "$agent_file"
      echo "    - $name"
      REMOVED_AGENTS=$((REMOVED_AGENTS + 1))
    done
  fi
fi
if [ "$REMOVED_AGENTS" -eq 0 ]; then
  echo "    (no agents found to remove)"
fi

# =============================================
# 2. Remove Copilot agents — project
# =============================================
if [ "$choice" = "1" ] && [ -n "$PROJECT_DIR" ]; then
  COPILOT_DIR="$PROJECT_DIR/.github/agents"
  if [ -d "$COPILOT_DIR" ]; then
    echo ""
    echo "  Removing Copilot agents..."
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
    if [ "$has_copilot_entries" = false ] && [ "$FALLBACK_USED" = true ]; then
      for f in "$COPILOT_DIR"/*.agent.md; do
        [ -f "$f" ] || continue
        name="$(basename "${f%.agent.md}")"
        rm "$f"
        echo "    - $name"
      done
    fi
    rmdir "$COPILOT_DIR" 2>/dev/null || true
  fi

  # Remove Copilot config files — removes our section markers, preserves user content
  GITHUB_DIR="$PROJECT_DIR/.github"
  for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
    config_path="$GITHUB_DIR/$config"
    result=$(remove_our_section "$config_path")
    case "$result" in
      deleted) echo "    - $config" ;;
      cleaned) echo "    ~ $config (removed our section, kept your content)" ;;
    esac
  done

  # Remove Copilot asset subdirs (skills, instructions, prompts)
  for subdir in skills instructions prompts; do
    asset_dir="$GITHUB_DIR/$subdir"
    [ -d "$asset_dir" ] || continue
    removed=0
    for entry in "${MANIFEST_ENTRIES[@]}"; do
      case "$entry" in
        copilot-$subdir/*)
          rel="${entry#copilot-$subdir/}"
          target_file="$asset_dir/$rel"
          if [ -f "$target_file" ]; then
            rm "$target_file"
            removed=$((removed + 1))
          fi
          ;;
      esac
    done
    # Clean up empty directories bottom-up
    find "$asset_dir" -type d -empty -delete 2>/dev/null || true
    [ "$removed" -gt 0 ] && echo "    - $subdir/ ($removed files)"
  done
fi

# =============================================
# 3. Remove Copilot agents — global
# =============================================
if [ "$choice" = "2" ]; then
  # Detect VS Code profile directories
  VSCODE_PROFILES=()
  case "$(uname -s)" in
    Darwin)
      VSCODE_PROFILES=(
        "$HOME/Library/Application Support/Code/User"
        "$HOME/Library/Application Support/Code - Insiders/User"
      )
      ;;
    Linux)
      VSCODE_PROFILES=(
        "$HOME/.config/Code/User"
        "$HOME/.config/Code - Insiders/User"
      )
      ;;
    MINGW*|MSYS*|CYGWIN*)
      [ -n "$APPDATA" ] && VSCODE_PROFILES=(
        "$APPDATA/Code/User"
        "$APPDATA/Code - Insiders/User"
      )
      ;;
  esac

  for profile_dir in "${VSCODE_PROFILES[@]}"; do
    [ -d "$profile_dir" ] || continue
    prompts_dir="$profile_dir/prompts"

    # Remove agent, prompt, and instruction files
    for dir in "$profile_dir" "$prompts_dir"; do
      [ -d "$dir" ] || continue
      found=false
      for pattern in "*.agent.md" "*.prompt.md" "*.instructions.md"; do
        for f in "$dir"/$pattern; do
          [ -f "$f" ] || continue
          if [ "$found" = false ]; then
            echo ""
            echo "  Removing files from: $dir"
            found=true
          fi
          echo "    - $(basename "$f")"
          rm "$f"
        done
      done
    done

    # Remove prompts/ subdirectories that match our asset folders
    for subfolder in skills instructions; do
      subpath="$prompts_dir/$subfolder"
      if [ -d "$subpath" ]; then
        rm -rf "$subpath"
        echo "    - prompts/$subfolder/"
      fi
    done

    # Restore settings.json — remove our chat.agentFilesLocations override
    settings_file="$profile_dir/settings.json"
    if [ -f "$settings_file" ] && command -v python3 &>/dev/null; then
      A11Y_SF="$settings_file" python3 - << 'PYEOF' 2>/dev/null && echo "    - Restored VS Code settings"
import json, os
sf = os.environ['A11Y_SF']
try:
    with open(sf, 'r') as f:
        s = json.load(f)
except:
    exit(1)
loc = s.get('chat.agentFilesLocations', {})
changed = False
for key in ['.claude/agents', '.github/agents']:
    if key in loc:
        del loc[key]
        changed = True
if not loc and 'chat.agentFilesLocations' in s:
    del s['chat.agentFilesLocations']
    changed = True
if changed:
    with open(sf, 'w') as f:
        json.dump(s, f, indent=4)
else:
    exit(1)
PYEOF
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

  # Remove a11y-copilot-init from PATH (shell rc)
  for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rc_file" ] && grep -q "a11y-copilot-init\|a11y-agent-team" "$rc_file" 2>/dev/null; then
      if command -v python3 &>/dev/null; then
        A11Y_RC="$rc_file" python3 - << 'PYEOF' 2>/dev/null
import os
rc = os.environ['A11Y_RC']
lines = open(rc).readlines()
cleaned = [l for l in lines if 'a11y-copilot-init' not in l and 'a11y-agent-team' not in l]
# Remove trailing blank lines left behind
while cleaned and cleaned[-1].strip() == '':
    cleaned.pop()
cleaned.append('\n')
open(rc, 'w').writelines(cleaned)
PYEOF
        echo "    - Removed a11y-copilot-init from $rc_file"
      else
        echo "    ! Could not clean $rc_file (python3 unavailable — remove manually)"
      fi
    fi
  done
fi

# =============================================
# 4. Remove Codex CLI support
# =============================================
if [ "$choice" = "1" ]; then
  CODEX_DIR="$(pwd)/.codex"
else
  CODEX_DIR="$HOME/.codex"
fi
CODEX_FILE="$CODEX_DIR/AGENTS.md"
if [ -f "$CODEX_FILE" ]; then
  result=$(remove_our_section "$CODEX_FILE")
  case "$result" in
    deleted)
      echo ""
      echo "  Removing Codex CLI support..."
      rmdir "$CODEX_DIR" 2>/dev/null || true
      echo "    - AGENTS.md (Codex removed)"
      ;;
    cleaned)
      echo ""
      echo "  Codex CLI:"
      echo "    ~ AGENTS.md (removed our section, kept your content)"
      ;;
  esac
fi

# =============================================
# 5. Remove Gemini CLI extension
# =============================================
GEMINI_PATHS=()
# Check manifest for Gemini path
for entry in "${MANIFEST_ENTRIES[@]}"; do
  case "$entry" in
    gemini/path:*)
      GEMINI_PATHS+=("${entry#gemini/path:}")
      ;;
  esac
done
# Also check default locations
if [ "$choice" = "1" ]; then
  GEMINI_PATHS+=("$(pwd)/.gemini/extensions/a11y-agents")
else
  GEMINI_PATHS+=("$HOME/.gemini/extensions/a11y-agents")
fi

GEMINI_REMOVED=false
# Deduplicate paths
declare -A seen_paths
for gemini_dir in "${GEMINI_PATHS[@]}"; do
  [ -n "${seen_paths[$gemini_dir]+x}" ] && continue
  seen_paths[$gemini_dir]=1
  if [ -d "$gemini_dir" ]; then
    echo ""
    echo "  Removing Gemini CLI extension..."
    rm -rf "$gemini_dir"
    echo "    - $gemini_dir"
    GEMINI_REMOVED=true
    # Clean up empty parent dirs
    parent="$(dirname "$gemini_dir")"
    while [ -n "$parent" ] && [ -d "$parent" ] && [ -z "$(ls -A "$parent" 2>/dev/null)" ]; do
      rmdir "$parent" 2>/dev/null || break
      parent="$(dirname "$parent")"
    done
  fi
done

# =============================================
# 6. Remove auto-update (global only)
# =============================================
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

# =============================================
# 7. Clean up manifest and empty directories
# =============================================
rm -f "$MANIFEST_FILE"
rm -f "$TARGET_DIR/.a11y-agent-team-version"
rmdir "$TARGET_DIR/agents" 2>/dev/null || true

# =============================================
# Done
# =============================================
echo ""
echo "  ========================="
echo "  Uninstall complete!"
echo ""
echo "  What was removed:"
echo "    - Claude Code agents from $TARGET_DIR"
if [ "$choice" = "1" ]; then
  echo "    - Copilot agents, config, skills, instructions, prompts from .github/"
else
  echo "    - Copilot agents from VS Code profiles"
  echo "    - Copilot central store (~/.a11y-agent-team/)"
fi
if [ "$GEMINI_REMOVED" = true ]; then
  echo "    - Gemini CLI extension"
fi
echo ""
echo "  Next steps:"
echo "    1. Restart Claude Code, VS Code, and any open terminals"
echo "    2. Verify agents are gone: type '@' in Copilot Chat or '/agents' in Claude"
echo ""
echo "  If something was missed, see the manual uninstall guide:"
echo "    https://github.com/Community-Access/accessibility-agents/blob/main/UNINSTALL.md"
echo ""
