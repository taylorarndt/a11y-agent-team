#!/bin/bash
# Accessibility Agents Installer
# Started by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash install.sh                    Interactive mode (prompts for project or global)
#   bash install.sh --global           Install globally to ~/.claude/
#   bash install.sh --global --copilot Also install Copilot agents to VS Code
#   bash install.sh --global --codex   Also install Codex CLI support to ~/.codex/
#   bash install.sh --project          Install to .claude/ in the current directory
#   bash install.sh --project --copilot Also install Copilot agents to project
#   bash install.sh --project --codex  Also install Codex CLI support to .codex/
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.sh | bash

set -e

# Determine source: running from repo clone or piped from curl?
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
DOWNLOADED=false

if [ ! -d "$SCRIPT_DIR/claude-code-plugin/agents" ] && [ ! -d "$SCRIPT_DIR/.claude/agents" ]; then
  # Running from curl pipe or without repo — download first
  DOWNLOADED=true
  TMPDIR_DL="$(mktemp -d)"
  echo ""
  echo "  Downloading Accessibility Agents..."

  if ! command -v git &>/dev/null; then
    echo "  Error: git is required. Install git and try again."
    rm -rf "$TMPDIR_DL"
    exit 1
  fi

  git clone --quiet https://github.com/Community-Access/accessibility-agents.git "$TMPDIR_DL/accessibility-agents" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "  Error: git clone failed. Check your network connection and try again."
    rm -rf "$TMPDIR_DL"
    exit 1
  fi
  SCRIPT_DIR="$TMPDIR_DL/accessibility-agents"
  echo "  Downloaded."
fi

# Prefer claude-code-plugin/ as distribution source, fall back to .claude/agents/
if [ -d "$SCRIPT_DIR/claude-code-plugin/agents" ]; then
  AGENTS_SRC="$SCRIPT_DIR/claude-code-plugin/agents"
else
  AGENTS_SRC="$SCRIPT_DIR/.claude/agents"
fi

if [ -d "$SCRIPT_DIR/claude-code-plugin/commands" ]; then
  COMMANDS_SRC="$SCRIPT_DIR/claude-code-plugin/commands"
else
  COMMANDS_SRC=""
fi

PLUGIN_CLAUDE_MD=""
if [ -f "$SCRIPT_DIR/claude-code-plugin/CLAUDE.md" ]; then
  PLUGIN_CLAUDE_MD="$SCRIPT_DIR/claude-code-plugin/CLAUDE.md"
fi

# Plugin source and version for global installs
PLUGIN_SRC=""
PLUGIN_VERSION="1.0.0"
if [ -d "$SCRIPT_DIR/claude-code-plugin/.claude-plugin" ]; then
  PLUGIN_SRC="$SCRIPT_DIR/claude-code-plugin"
  if command -v python3 &>/dev/null && [ -f "$PLUGIN_SRC/.claude-plugin/plugin.json" ]; then
    PLUGIN_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_SRC/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "1.0.0")
  fi
fi

COPILOT_AGENTS_SRC="$SCRIPT_DIR/.github/agents"
COPILOT_CONFIG_SRC="$SCRIPT_DIR/.github"

# Auto-detect agents from source directory
AGENTS=()
if [ -d "$AGENTS_SRC" ]; then
  for f in "$AGENTS_SRC"/*.md; do
    [ -f "$f" ] && AGENTS+=("$(basename "$f")")
  done
fi

# Auto-detect commands from source directory
COMMANDS=()
if [ -n "$COMMANDS_SRC" ] && [ -d "$COMMANDS_SRC" ]; then
  for f in "$COMMANDS_SRC"/*.md; do
    [ -f "$f" ] && COMMANDS+=("$(basename "$f")")
  done
fi

# Validate source files exist
if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "  Error: No agents found in $AGENTS_SRC"
  echo "  Make sure you are running this script from the a11y-agent-team directory."
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

# Parse flags for non-interactive install
choice=""
COPILOT_FLAG=false
CODEX_FLAG=false
for arg in "$@"; do
  case "$arg" in
    --global) choice="2" ;;
    --project) choice="1" ;;
    --copilot) COPILOT_FLAG=true ;;
    --codex) CODEX_FLAG=true ;;
  esac
done

if [ -z "$choice" ]; then
  echo ""
  echo "  Accessibility Agents Installer"
  echo "  Started by Taylor Arndt"
  echo "  ================================"
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
  read -r choice < /dev/tty
fi

case "$choice" in
  1)
    TARGET_DIR="$(pwd)/.claude"
    echo ""
    echo "  Installing to project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    echo ""
    echo "  Installing globally to: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
    exit 1
    ;;
esac

# ---------------------------------------------------------------------------
# merge_config_file src dst label
# Appends/updates our section in a config markdown file using section markers.
# Never overwrites user content above or below our section.
# ---------------------------------------------------------------------------
merge_config_file() {
  local src="$1" dst="$2" label="$3"
  local start="<!-- a11y-agent-team: start -->"
  local end="<!-- a11y-agent-team: end -->"
  if [ ! -f "$dst" ]; then
    { printf '%s\n' "$start"; cat "$src"; printf '%s\n' "$end"; } > "$dst"
    echo "    + $label (created)"
    return
  fi
  if grep -qF "$start" "$dst" 2>/dev/null; then
    if command -v python3 &>/dev/null; then
      python3 - "$src" "$dst" << 'PYEOF'
import re, sys
src_text = open(sys.argv[1]).read().rstrip()
dst_path = sys.argv[2]
dst_text = open(dst_path).read()
start = "<!-- a11y-agent-team: start -->"
end   = "<!-- a11y-agent-team: end -->"
block = start + "\n" + src_text + "\n" + end
updated = re.sub(re.escape(start) + r".*?" + re.escape(end), block, dst_text, flags=re.DOTALL)
open(dst_path, "w").write(updated)
PYEOF
      echo "    ~ $label (updated our existing section)"
    else
      echo "    ! $label (section exists; python3 unavailable to update - edit manually)"
    fi
  else
    { printf '\n%s\n' "$start"; cat "$src"; printf '%s\n' "$end"; echo; } >> "$dst"
    echo "    + $label (merged into your existing file)"
  fi
}

# ---------------------------------------------------------------------------
# register_plugin src_dir
# Registers a11y-agent-team as a Claude Code plugin for global installs.
# Copies to plugin cache, updates installed_plugins.json and settings.json.
# ---------------------------------------------------------------------------
register_plugin() {
  local src="$1"
  local namespace="community-access"
  local name="a11y-agent-team"
  local default_key="${name}@${namespace}"
  local plugins_json="$HOME/.claude/plugins/installed_plugins.json"
  local settings_json="$HOME/.claude/settings.json"

  echo ""
  echo "  Registering Claude Code plugin..."

  # Ensure plugins directory exists
  mkdir -p "$HOME/.claude/plugins"

  # Detect existing registration under any namespace
  local actual_key="$default_key"
  if [ -f "$plugins_json" ] && command -v python3 &>/dev/null; then
    local found_key
    found_key=$(python3 -c "
import json
data = json.load(open('$plugins_json'))
for k in data.get('plugins', {}):
    if k.startswith('a11y-agent-team@'):
        print(k)
        break
" 2>/dev/null)
    if [ -n "$found_key" ]; then
      actual_key="$found_key"
      namespace="${actual_key#a11y-agent-team@}"
    fi
  fi

  local cache="$HOME/.claude/plugins/cache/${namespace}/${name}/${PLUGIN_VERSION}"

  # Copy plugin to cache
  mkdir -p "$cache"
  cp -R "$src/." "$cache/"
  chmod +x "$cache/scripts/"*.sh 2>/dev/null || true
  echo "    + Plugin cached"

  # Update installed_plugins.json
  if [ ! -f "$plugins_json" ]; then
    echo '{"version": 2, "plugins": {}}' > "$plugins_json"
  fi

  python3 - "$plugins_json" "$actual_key" "$cache" "$PLUGIN_VERSION" << 'PYEOF'
import json, sys, datetime
path, key, install_path, version = sys.argv[1:5]
with open(path) as f:
    data = json.load(f)
now = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z')
data.setdefault('version', 2)
data.setdefault('plugins', {})[key] = [{
    "scope": "user",
    "installPath": install_path,
    "version": version,
    "installedAt": now,
    "lastUpdated": now
}]
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
  echo "    + Registered in installed_plugins.json ($actual_key)"

  # Update settings.json enabledPlugins
  if [ ! -f "$settings_json" ]; then
    echo '{}' > "$settings_json"
  fi

  python3 - "$settings_json" "$actual_key" << 'PYEOF'
import json, sys
path, key = sys.argv[1:3]
with open(path) as f:
    data = json.load(f)
data.setdefault('enabledPlugins', {})[key] = True
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
  echo "    + Enabled in settings.json"

  # Summary
  local agent_count cmd_count
  agent_count=$(ls "$cache/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
  cmd_count=$(ls "$cache/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo ""
  echo "  Plugin registered: $actual_key (v${PLUGIN_VERSION})"
  echo "    $agent_count agents"
  echo "    $cmd_count slash commands"
  echo "    4 enforcement hooks (UserPromptSubmit, PreToolUse, SubagentStart, SubagentStop)"
}

# ---------------------------------------------------------------------------
# cleanup_old_install
# Removes agents/commands from ~/.claude/ that were installed by a previous
# non-plugin install (using the manifest file).
# ---------------------------------------------------------------------------
cleanup_old_install() {
  local manifest="$HOME/.claude/.a11y-agent-manifest"
  [ -f "$manifest" ] || return 0

  echo ""
  echo "  Cleaning up previous non-plugin install..."
  local removed=0
  while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    local file="$HOME/.claude/$entry"
    if [ -f "$file" ]; then
      rm "$file"
      removed=$((removed + 1))
    fi
  done < "$manifest"
  rm -f "$manifest"
  rmdir "$HOME/.claude/agents" 2>/dev/null || true
  rmdir "$HOME/.claude/commands" 2>/dev/null || true
  if [ "$removed" -gt 0 ]; then
    echo "    Removed $removed files from previous install"
  fi
}

# ---------------------------------------------------------------------------
# Installation: plugin (global) vs file-copy (project)
# ---------------------------------------------------------------------------
PLUGIN_INSTALL=false

if [ "$choice" = "2" ] && [ -n "$PLUGIN_SRC" ] && command -v python3 &>/dev/null; then
  # Global install: register as a Claude Code plugin
  register_plugin "$PLUGIN_SRC"
  cleanup_old_install
  PLUGIN_INSTALL=true
else
  # Project install (or global without plugin support): copy agents/commands directly

# Create directories
mkdir -p "$TARGET_DIR/agents"
if [ ${#COMMANDS[@]} -gt 0 ]; then
  mkdir -p "$TARGET_DIR/commands"
fi

# Manifest: track which files we install so updates never touch user-created files
MANIFEST_FILE="$TARGET_DIR/.a11y-agent-manifest"
touch "$MANIFEST_FILE"

# Copy agents — skip any file that already exists (preserves user customisations)
echo ""
echo "  Copying agents..."
SKIPPED_AGENTS=0
for agent in "${AGENTS[@]}"; do
  if [ ! -f "$AGENTS_SRC/$agent" ]; then
    echo "    ! Missing: $agent (skipped)"
    continue
  fi
  dst_agent="$TARGET_DIR/agents/$agent"
  name="${agent%.md}"
  if [ -f "$dst_agent" ]; then
    echo "    ~ $name (skipped - already exists)"
    SKIPPED_AGENTS=$((SKIPPED_AGENTS + 1))
  else
    cp "$AGENTS_SRC/$agent" "$dst_agent"
    grep -qxF "agents/$agent" "$MANIFEST_FILE" 2>/dev/null || echo "agents/$agent" >> "$MANIFEST_FILE"
    echo "    + $name"
  fi
done
if [ "$SKIPPED_AGENTS" -gt 0 ]; then
  echo "      $SKIPPED_AGENTS agent(s) skipped. Delete them first to reinstall."
fi

# Copy commands — skip any file that already exists (preserves user customisations)
if [ ${#COMMANDS[@]} -gt 0 ]; then
  echo ""
  echo "  Copying commands..."
  SKIPPED_COMMANDS=0
  for cmd in "${COMMANDS[@]}"; do
    if [ ! -f "$COMMANDS_SRC/$cmd" ]; then
      echo "    ! Missing: $cmd (skipped)"
      continue
    fi
    dst_cmd="$TARGET_DIR/commands/$cmd"
    name="${cmd%.md}"
    if [ -f "$dst_cmd" ]; then
      echo "    ~ /$name (skipped - already exists)"
      SKIPPED_COMMANDS=$((SKIPPED_COMMANDS + 1))
    else
      cp "$COMMANDS_SRC/$cmd" "$dst_cmd"
      grep -qxF "commands/$cmd" "$MANIFEST_FILE" 2>/dev/null || echo "commands/$cmd" >> "$MANIFEST_FILE"
      echo "    + /$name"
    fi
  done
  if [ "$SKIPPED_COMMANDS" -gt 0 ]; then
    echo "      $SKIPPED_COMMANDS command(s) skipped. Delete them first to reinstall."
  fi
fi

fi  # end of project/fallback install path

# Merge CLAUDE.md snippet (optional)
if [ -n "$PLUGIN_CLAUDE_MD" ]; then
  echo ""
  MERGE_CLAUDE=false
  if { true < /dev/tty; } 2>/dev/null; then
    echo "  Would you like to merge accessibility rules into your project CLAUDE.md?"
    echo "  This adds the decision matrix and non-negotiable standards."
    echo ""
    printf "  Merge CLAUDE.md rules? [y/N]: "
    read -r claude_choice < /dev/tty
    if [ "$claude_choice" = "y" ] || [ "$claude_choice" = "Y" ]; then
      MERGE_CLAUDE=true
    fi
  fi
  if [ "$MERGE_CLAUDE" = true ]; then
    if [ "$choice" = "1" ]; then
      CLAUDE_DST="$(pwd)/CLAUDE.md"
    else
      CLAUDE_DST="$HOME/CLAUDE.md"
    fi
    merge_config_file "$PLUGIN_CLAUDE_MD" "$CLAUDE_DST" "CLAUDE.md (accessibility rules)"
  fi
fi

# Copilot agents
COPILOT_INSTALLED=false
COPILOT_DESTINATIONS=()
install_copilot=false

if [ "$COPILOT_FLAG" = true ]; then
  install_copilot=true
elif { true < /dev/tty; } 2>/dev/null; then
  echo ""
  echo "  Would you also like to install GitHub Copilot agents?"
  echo "  This adds accessibility agents for Copilot Chat in VS Code/GitHub."
  echo ""
  printf "  Install Copilot agents? [y/N]: "
  read -r copilot_choice < /dev/tty
  if [ "$copilot_choice" = "y" ] || [ "$copilot_choice" = "Y" ]; then
    install_copilot=true
  fi
fi

if [ "$install_copilot" = true ]; then

    if [ "$choice" = "1" ]; then
      # Project install: put agents in .github/agents/
      PROJECT_DIR="$(pwd)"
      COPILOT_DST="$PROJECT_DIR/.github/agents"
      mkdir -p "$COPILOT_DST"
      COPILOT_DESTINATIONS+=("$COPILOT_DST")

      # Copy Copilot agents — skip files that already exist
      echo ""
      echo "  Copying Copilot agents..."
      if [ -d "$COPILOT_AGENTS_SRC" ]; then
        for f in "$COPILOT_AGENTS_SRC"/*; do
          [ -f "$f" ] || continue
          dst_f="$COPILOT_DST/$(basename "$f")"
          if [ -f "$dst_f" ]; then
            echo "    ~ $(basename "$f") (skipped - already exists)"
          else
            cp "$f" "$COPILOT_DST/"
            echo "    + $(basename "$f")"
          fi
        done
      fi

      # Merge Copilot config files — appends our section, never overwrites
      echo ""
      echo "  Merging Copilot config..."
      for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
        SRC="$COPILOT_CONFIG_SRC/$config"
        DST="$PROJECT_DIR/.github/$config"
        if [ -f "$SRC" ]; then
          merge_config_file "$SRC" "$DST" "$config"
        fi
      done

      # Copy asset subdirs — file-by-file, skip files that already exist
      for subdir in skills instructions prompts; do
        SRC_DIR="$COPILOT_CONFIG_SRC/$subdir"
        DST_DIR="$PROJECT_DIR/.github/$subdir"
        if [ -d "$SRC_DIR" ]; then
          mkdir -p "$DST_DIR"
          added=0; skipped=0
          while IFS= read -r -d '' src_file; do
            rel="${src_file#$SRC_DIR/}"
            dst_file="$DST_DIR/$rel"
            mkdir -p "$(dirname "$dst_file")"
            if [ -f "$dst_file" ]; then
              skipped=$((skipped + 1))
            else
              cp "$src_file" "$dst_file"
              added=$((added + 1))
            fi
          done < <(find "$SRC_DIR" -type f -print0)
          echo "    + $subdir/ ($added new, $skipped skipped)"
        fi
      done

      COPILOT_INSTALLED=true

    else
      # Global install: copy .agent.md files directly into VS Code user profile folders.
      # This is the documented way to make agents available across all workspaces.
      COPILOT_CENTRAL="$HOME/.a11y-agent-team/copilot-agents"
      COPILOT_CENTRAL_PROMPTS="$HOME/.a11y-agent-team/copilot-prompts"
      COPILOT_CENTRAL_INSTRUCTIONS="$HOME/.a11y-agent-team/copilot-instructions-files"
      COPILOT_CENTRAL_SKILLS="$HOME/.a11y-agent-team/copilot-skills"
      mkdir -p "$COPILOT_CENTRAL" "$COPILOT_CENTRAL_PROMPTS" "$COPILOT_CENTRAL_INSTRUCTIONS" "$COPILOT_CENTRAL_SKILLS"

      # Store a central copy for updates and a11y-copilot-init
      echo ""
      echo "  Storing Copilot agents centrally..."
      if [ -d "$COPILOT_AGENTS_SRC" ]; then
        for f in "$COPILOT_AGENTS_SRC"/*.agent.md; do
          [ -f "$f" ] || continue
          agent="$(basename "$f")"
          cp "$f" "$COPILOT_CENTRAL/$agent"
          name="${agent%.agent.md}"
          echo "    + $name"
        done
      fi

      # Store prompts, instructions, and skills centrally
      [ -d "$COPILOT_CONFIG_SRC/prompts" ]      && cp -r "$COPILOT_CONFIG_SRC/prompts/."      "$COPILOT_CENTRAL_PROMPTS/"
      [ -d "$COPILOT_CONFIG_SRC/instructions" ] && cp -r "$COPILOT_CONFIG_SRC/instructions/." "$COPILOT_CENTRAL_INSTRUCTIONS/"
      [ -d "$COPILOT_CONFIG_SRC/skills" ]       && cp -r "$COPILOT_CONFIG_SRC/skills/."       "$COPILOT_CENTRAL_SKILLS/"

      # Copy Copilot config files to central store
      for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
        SRC="$COPILOT_CONFIG_SRC/$config"
        if [ -f "$SRC" ]; then
          cp "$SRC" "$HOME/.a11y-agent-team/$config"
        fi
      done

      # Copy .agent.md files into VS Code user profile folders.
      # VS Code discovers agents from User/prompts/.
      copy_to_vscode_profile() {
        local profile_dir="$1"
        local label="$2"
        local prompts_dir="$profile_dir/prompts"

        if [ ! -d "$profile_dir" ]; then
          return
        fi

        mkdir -p "$prompts_dir"
        echo "  [found] $label"

        # Copy agents to prompts/
        for f in "$COPILOT_CENTRAL"/*.agent.md; do
          [ -f "$f" ] || continue
          cp "$f" "$prompts_dir/"
        done

        # Copy prompts and instructions to prompts/
        [ -d "$COPILOT_CENTRAL_PROMPTS" ]      && cp -r "$COPILOT_CENTRAL_PROMPTS/."      "$prompts_dir/"
        [ -d "$COPILOT_CENTRAL_INSTRUCTIONS" ] && cp -r "$COPILOT_CENTRAL_INSTRUCTIONS/." "$prompts_dir/"

        echo "    Copied $(ls "$COPILOT_CENTRAL"/*.agent.md 2>/dev/null | wc -l | tr -d ' ') agents"

        # Disable .claude/agents in VS Code so Claude Code agents
        # don't appear in the Copilot agent picker
        local settings_file="$profile_dir/settings.json"
        if command -v python3 &>/dev/null; then
          A11Y_SF="$settings_file" \
          python3 - << 'PYEOF' 2>/dev/null && echo "    Configured agent discovery (disabled .claude/agents)"
import json, os
sf = os.environ['A11Y_SF']
try:
    with open(sf, 'r') as f:
        s = json.load(f)
except:
    s = {}
loc = s.get('chat.agentFilesLocations', {})
loc['.github/agents'] = True
loc['.claude/agents'] = False
s['chat.agentFilesLocations'] = loc
with open(sf, 'w') as f:
    json.dump(s, f, indent=4)
PYEOF
        fi

        COPILOT_DESTINATIONS+=("$prompts_dir")
      }

      # Detect installed VS Code editions
      echo ""
      VSCODE_STABLE=""
      VSCODE_INSIDERS=""
      case "$(uname -s)" in
        Darwin)
          [ -d "$HOME/Library/Application Support/Code/User" ] && VSCODE_STABLE="$HOME/Library/Application Support/Code/User"
          [ -d "$HOME/Library/Application Support/Code - Insiders/User" ] && VSCODE_INSIDERS="$HOME/Library/Application Support/Code - Insiders/User"
          ;;
        Linux)
          [ -d "$HOME/.config/Code/User" ] && VSCODE_STABLE="$HOME/.config/Code/User"
          [ -d "$HOME/.config/Code - Insiders/User" ] && VSCODE_INSIDERS="$HOME/.config/Code - Insiders/User"
          ;;
        MINGW*|MSYS*|CYGWIN*)
          if [ -n "$APPDATA" ]; then
            [ -d "$APPDATA/Code/User" ] && VSCODE_STABLE="$APPDATA/Code/User"
            [ -d "$APPDATA/Code - Insiders/User" ] && VSCODE_INSIDERS="$APPDATA/Code - Insiders/User"
          fi
          ;;
      esac

      # If both editions are found, ask which ones to install to
      if [ -n "$VSCODE_STABLE" ] && [ -n "$VSCODE_INSIDERS" ]; then
        if { true < /dev/tty; } 2>/dev/null; then
          echo "  Found both VS Code and VS Code Insiders."
          echo ""
          echo "  Install Copilot agents to:"
          echo "  1) VS Code only"
          echo "  2) VS Code Insiders only"
          echo "  3) Both"
          echo ""
          printf "  Choose [1/2/3]: "
          read -r vscode_choice < /dev/tty
          case "$vscode_choice" in
            1) VSCODE_INSIDERS="" ;;
            2) VSCODE_STABLE="" ;;
            3) ;; # keep both
            *) ;; # default to both
          esac
        fi
      fi

      [ -n "$VSCODE_STABLE" ] && copy_to_vscode_profile "$VSCODE_STABLE" "VS Code"
      [ -n "$VSCODE_INSIDERS" ] && copy_to_vscode_profile "$VSCODE_INSIDERS" "VS Code Insiders"

      if [ -z "$VSCODE_STABLE" ] && [ -z "$VSCODE_INSIDERS" ]; then
        echo "  No VS Code installation found. Copilot agents stored centrally only."
        echo "  Use 'a11y-copilot-init' to copy agents into individual projects."
      fi

      # Also create a11y-copilot-init for per-project use (repos to check into git)
      mkdir -p "$HOME/.a11y-agent-team"
      INIT_SCRIPT="$HOME/.a11y-agent-team/a11y-copilot-init"
      cat > "$INIT_SCRIPT" << 'INITSCRIPT'
#!/bin/bash
# Accessibility Agents - Copy Copilot agents into the current project
# Usage: a11y-copilot-init
#
# Copies .agent.md files into .github/agents/ for this project.
# Merges copilot-instructions.md rather than overwriting it.
# Skips any file that already exists to preserve your customisations.

CENTRAL="$HOME/.a11y-agent-team/copilot-agents"
TARGET=".github/agents"

if [ ! -d "$CENTRAL" ] || [ -z "$(ls "$CENTRAL"/*.agent.md 2>/dev/null)" ]; then
  echo "  Error: No Copilot agents found in $CENTRAL"
  echo "  Run the a11y-agent-team installer first."
  exit 1
fi

mkdir -p "$TARGET"
ADDED=0; SKIPPED=0
for f in "$CENTRAL"/*.agent.md; do
  [ -f "$f" ] || continue
  dst="$TARGET/$(basename "$f")"
  if [ -f "$dst" ]; then SKIPPED=$((SKIPPED+1))
  else cp "$f" "$dst"; ADDED=$((ADDED+1)); fi
done
echo "  Agents: $ADDED added, $SKIPPED skipped (already exist)"

# Merge config files using a11y-agent-team section markers — never overwrites user content
merge_config() {
  local src="$1" dst="$2" label="$3"
  local start="<!-- a11y-agent-team: start -->"
  local end="<!-- a11y-agent-team: end -->"
  [ -f "$src" ] || return
  if [ ! -f "$dst" ]; then
    { printf '%s\n' "$start"; cat "$src"; printf '%s\n' "$end"; } > "$dst"
    echo "  + $label (created)"
    return
  fi
  if grep -qF "$start" "$dst" 2>/dev/null; then
    if command -v python3 &>/dev/null; then
      python3 - "$src" "$dst" << 'PYEOF'
import re, sys
src_text = open(sys.argv[1]).read().rstrip()
dst_path = sys.argv[2]
dst_text = open(dst_path).read()
start = "<!-- a11y-agent-team: start -->"
end   = "<!-- a11y-agent-team: end -->"
block = start + "\n" + src_text + "\n" + end
updated = re.sub(re.escape(start) + r".*?" + re.escape(end), block, dst_text, flags=re.DOTALL)
open(dst_path, "w").write(updated)
PYEOF
      echo "  ~ $label (updated our existing section)"
    else
      echo "  ! $label (section exists; python3 unavailable to update)"
    fi
  else
    { printf '\n%s\n' "$start"; cat "$src"; printf '%s\n' "$end"; echo; } >> "$dst"
    echo "  + $label (merged into your existing file)"
  fi
}

for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
  merge_config "$HOME/.a11y-agent-team/$config" ".github/$config" "$config"
done

# Copy prompts, instructions, and skills — skip existing files
for pair in "copilot-prompts:prompts" "copilot-instructions-files:instructions" "copilot-skills:skills"; do
  SRC="$HOME/.a11y-agent-team/${pair%%:*}"
  DST=".github/${pair##*:}"
  if [ -d "$SRC" ] && [ -n "$(ls "$SRC" 2>/dev/null)" ]; then
    mkdir -p "$DST"
    added=0; skipped=0
    while IFS= read -r -d '' src_file; do
      rel="${src_file#$SRC/}"
      dst_file="$DST/$rel"
      mkdir -p "$(dirname "$dst_file")"
      if [ -f "$dst_file" ]; then skipped=$((skipped+1))
      else cp "$src_file" "$dst_file"; added=$((added+1)); fi
    done < <(find "$SRC" -type f -print0)
    echo "  ${pair##*:}/: $added added, $skipped skipped"
  fi
done

echo ""
echo "  Done. Your existing files were preserved."
echo "  These are now in your project for version control."
INITSCRIPT
      chmod +x "$INIT_SCRIPT"

      # Add to PATH if not already present
      SHELL_RC=""
      if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
      elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
      fi

      if [ -n "$SHELL_RC" ]; then
        if ! grep -q "a11y-copilot-init" "$SHELL_RC" 2>/dev/null; then
          echo "" >> "$SHELL_RC"
          echo "# Accessibility Agents - Copilot init command" >> "$SHELL_RC"
          echo "export PATH=\"\$HOME/.a11y-agent-team:\$PATH\"" >> "$SHELL_RC"
          echo "  Added 'a11y-copilot-init' command to your PATH via $SHELL_RC"
        else
          echo "  'a11y-copilot-init' already in PATH."
        fi
      fi

      COPILOT_INSTALLED=true
      COPILOT_DESTINATIONS+=("$COPILOT_CENTRAL")
    fi
fi

# ---------------------------------------------------------------------------
# Codex CLI support
# ---------------------------------------------------------------------------
CODEX_SRC="$SCRIPT_DIR/.codex/AGENTS.md"
CODEX_INSTALLED=false

install_codex=false
if [ "$CODEX_FLAG" = true ]; then
  install_codex=true
elif [ -f "$CODEX_SRC" ] && { true < /dev/tty; } 2>/dev/null; then
  echo ""
  echo "  Would you also like to install Codex CLI support?"
  echo "  This merges accessibility rules into your project's AGENTS.md"
  echo "  so Codex automatically applies them to all UI code."
  echo ""
  printf "  Install Codex CLI support? [y/N]: "
  read -r codex_choice < /dev/tty
  if [ "$codex_choice" = "y" ] || [ "$codex_choice" = "Y" ]; then
    install_codex=true
  fi
fi

if [ "$install_codex" = true ] && [ -f "$CODEX_SRC" ]; then
  echo ""
  echo "  Installing Codex CLI support..."

  if [ "$choice" = "1" ]; then
    # Project install: copy to .codex/AGENTS.md in the current project
    CODEX_TARGET_DIR="$(pwd)/.codex"
    mkdir -p "$CODEX_TARGET_DIR"
    CODEX_DST="$CODEX_TARGET_DIR/AGENTS.md"
  else
    # Global install: copy to ~/.codex/AGENTS.md
    CODEX_TARGET_DIR="$HOME/.codex"
    mkdir -p "$CODEX_TARGET_DIR"
    CODEX_DST="$CODEX_TARGET_DIR/AGENTS.md"
  fi

  merge_config_file "$CODEX_SRC" "$CODEX_DST" "AGENTS.md (Codex)"
  CODEX_INSTALLED=true

  echo ""
  echo "  Codex will now enforce WCAG AA rules on all UI code in this project."
  echo "  Run: codex \"Build a login form\" — accessibility rules apply automatically."
fi

# Verify installation
echo ""
echo "  ========================="
echo "  Installation complete!"

if [ "$PLUGIN_INSTALL" = true ]; then
  # Plugin-based verification
  CACHE_CHECK="$HOME/.claude/plugins/cache"
  PLUGIN_DIR=""
  # Find the actual cache dir (could be community-access or taylor-plugins etc)
  for ns_dir in "$CACHE_CHECK"/*/a11y-agent-team; do
    [ -d "$ns_dir" ] && PLUGIN_DIR="$ns_dir/$PLUGIN_VERSION" && break
  done

  if [ -n "$PLUGIN_DIR" ] && [ -d "$PLUGIN_DIR" ]; then
    echo ""
    echo "  Claude Code plugin installed:"
    echo ""
    echo "  Agents:"
    for agent in "$PLUGIN_DIR/agents/"*.md; do
      [ -f "$agent" ] || continue
      name="$(basename "${agent%.md}")"
      echo "    [x] $name"
    done
    echo ""
    echo "  Slash commands:"
    for cmd in "$PLUGIN_DIR/commands/"*.md; do
      [ -f "$cmd" ] || continue
      name="$(basename "${cmd%.md}")"
      echo "    [x] /$name"
    done
    echo ""
    echo "  Enforcement hooks:"
    echo "    [x] UserPromptSubmit  - Injects accessibility-lead instruction"
    echo "    [x] PreToolUse        - Blocks UI file edits without a11y review"
    echo "    [x] SubagentStart     - Creates session marker"
    echo "    [x] SubagentStop      - Logs agent activity"
  fi
else
  echo ""
  echo "  Claude Code agents installed:"
  for agent in "${AGENTS[@]}"; do
    name="${agent%.md}"
    if [ -f "$TARGET_DIR/agents/$agent" ]; then
      echo "    [x] $name"
    else
      echo "    [ ] $name (missing)"
    fi
  done
  if [ ${#COMMANDS[@]} -gt 0 ]; then
    echo ""
    echo "  Slash commands installed:"
    for cmd in "${COMMANDS[@]}"; do
      name="${cmd%.md}"
      if [ -f "$TARGET_DIR/commands/$cmd" ]; then
        echo "    [x] /$name"
      else
        echo "    [ ] /$name (missing)"
      fi
    done
  fi
fi
if [ "$COPILOT_INSTALLED" = true ]; then
  echo ""
  echo "  Copilot agents installed to:"
  for dest in "${COPILOT_DESTINATIONS[@]}"; do
    echo "    -> $dest"
  done
  echo ""
  echo "  Copilot agents:"
  for f in "${COPILOT_DESTINATIONS[0]}"/*.agent.md; do
    [ -f "$f" ] || continue
    name="$(basename "${f%.agent.md}")"
    echo "    [x] $name"
  done
fi
if [ "$CODEX_INSTALLED" = true ]; then
  echo ""
  echo "  Codex CLI support installed to:"
  echo "    -> $CODEX_DST"
fi
# Save current version hash
if command -v git &>/dev/null && [ -d "$SCRIPT_DIR/.git" ]; then
  if [ "$PLUGIN_INSTALL" = true ]; then
    mkdir -p "$HOME/.claude"
    git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$HOME/.claude/.a11y-agent-team-version"
  else
    git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$TARGET_DIR/.a11y-agent-team-version"
  fi
fi

# Auto-update setup (global install only, interactive only)
if [ "$choice" = "2" ] && { true < /dev/tty; } 2>/dev/null; then
  echo ""
  echo "  Would you like to enable auto-updates?"
  echo "  This checks GitHub daily for new agents and improvements."
  echo ""
  printf "  Enable auto-updates? [y/N]: "
  read -r auto_update < /dev/tty

  if [ "$auto_update" = "y" ] || [ "$auto_update" = "Y" ]; then
    UPDATE_SCRIPT="$TARGET_DIR/.a11y-agent-team-update.sh"

    # Write a self-contained update script
    cat > "$UPDATE_SCRIPT" << 'UPDATESCRIPT'
#!/bin/bash
set -e
REPO_URL="https://github.com/Community-Access/accessibility-agents.git"
CACHE_DIR="$HOME/.claude/.a11y-agent-team-repo"
INSTALL_DIR="$HOME/.claude"
LOG_FILE="$HOME/.claude/.a11y-agent-team-update.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

command -v git &>/dev/null || { log "git not found"; exit 1; }

if [ -d "$CACHE_DIR/.git" ]; then
  cd "$CACHE_DIR" || exit 1
  git fetch origin main --quiet 2>/dev/null
  LOCAL=$(git rev-parse HEAD 2>/dev/null)
  REMOTE=$(git rev-parse origin/main 2>/dev/null)
  [ "$LOCAL" = "$REMOTE" ] && { log "Already up to date."; exit 0; }
  git reset --hard origin/main --quiet 2>/dev/null
else
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --quiet "$REPO_URL" "$CACHE_DIR" 2>/dev/null
fi

cd "$CACHE_DIR" || exit 1
HASH=$(git rev-parse --short HEAD 2>/dev/null)
UPDATED=0

# Update plugin cache if installed as plugin
PLUGIN_CACHE=""
for ns_dir in "$HOME/.claude/plugins/cache"/*/a11y-agent-team; do
  [ -d "$ns_dir" ] || continue
  for ver_dir in "$ns_dir"/*/; do
    [ -d "$ver_dir" ] && PLUGIN_CACHE="$ver_dir" && break
  done
  [ -n "$PLUGIN_CACHE" ] && break
done

if [ -n "$PLUGIN_CACHE" ] && [ -d "$CACHE_DIR/claude-code-plugin" ]; then
  # Update plugin cache from repo
  PLUGIN_SRC="$CACHE_DIR/claude-code-plugin"
  for subdir in agents commands scripts hooks .claude-plugin; do
    [ -d "$PLUGIN_SRC/$subdir" ] || continue
    mkdir -p "$PLUGIN_CACHE/$subdir"
    for SRC in "$PLUGIN_SRC/$subdir"/*; do
      [ -f "$SRC" ] || continue
      NAME=$(basename "$SRC")
      DST="$PLUGIN_CACHE/$subdir/$NAME"
      if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
        cp "$SRC" "$DST"
        log "Updated plugin: $subdir/$NAME"
        UPDATED=$((UPDATED + 1))
      fi
    done
  done
  # Update CLAUDE.md and README.md at plugin root
  for rootfile in CLAUDE.md README.md; do
    SRC="$PLUGIN_SRC/$rootfile"
    DST="$PLUGIN_CACHE/$rootfile"
    [ -f "$SRC" ] && ! cmp -s "$SRC" "$DST" 2>/dev/null && {
      cp "$SRC" "$DST"
      log "Updated plugin: $rootfile"
      UPDATED=$((UPDATED + 1))
    }
  done
  chmod +x "$PLUGIN_CACHE/scripts/"*.sh 2>/dev/null || true
  log "Plugin cache updated."
else
  # Legacy: update agents/commands in ~/.claude/ directly
  if [ -d "$CACHE_DIR/claude-code-plugin/agents" ]; then
    AGENT_SRC_DIR="$CACHE_DIR/claude-code-plugin/agents"
  else
    AGENT_SRC_DIR="$CACHE_DIR/.claude/agents"
  fi

  if [ -d "$INSTALL_DIR/agents" ]; then
    for agent in "$AGENT_SRC_DIR"/*.md; do
      [ -f "$agent" ] || continue
      NAME=$(basename "$agent")
      DST="$INSTALL_DIR/agents/$NAME"
      if ! cmp -s "$agent" "$DST" 2>/dev/null; then
        cp "$agent" "$DST"
        log "Updated: ${NAME%.md}"
        UPDATED=$((UPDATED + 1))
      fi
    done
  fi

  if [ -d "$CACHE_DIR/claude-code-plugin/commands" ] && [ -d "$INSTALL_DIR/commands" ]; then
    CMD_SRC_DIR="$CACHE_DIR/claude-code-plugin/commands"
    for cmd in "$CMD_SRC_DIR"/*.md; do
      [ -f "$cmd" ] || continue
      NAME=$(basename "$cmd")
      DST="$INSTALL_DIR/commands/$NAME"
      if ! cmp -s "$cmd" "$DST" 2>/dev/null; then
        cp "$cmd" "$DST"
        log "Updated command: ${NAME%.md}"
        UPDATED=$((UPDATED + 1))
      fi
    done
  fi
fi

# Update Copilot agents in central store and VS Code profile folders
CENTRAL="$HOME/.a11y-agent-team/copilot-agents"
if [ -d "$CENTRAL" ]; then
  for SRC in "$CACHE_DIR"/.github/agents/*.agent.md; do
    [ -f "$SRC" ] || continue
    NAME=$(basename "$SRC")
    DST="$CENTRAL/$NAME"
    if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
      cp "$SRC" "$DST"
      log "Updated Copilot agent: ${NAME%.agent.md}"
      UPDATED=$((UPDATED + 1))
    fi
  done
fi

# Push updated Copilot agents to VS Code profile prompts folders
PROFILES=()
case "$(uname -s)" in
  Darwin)
    PROFILES=("$HOME/Library/Application Support/Code/User" "$HOME/Library/Application Support/Code - Insiders/User")
    ;;
  Linux)
    PROFILES=("$HOME/.config/Code/User" "$HOME/.config/Code - Insiders/User")
    ;;
  MINGW*|MSYS*|CYGWIN*)
    [ -n "$APPDATA" ] && PROFILES=("$APPDATA/Code/User" "$APPDATA/Code - Insiders/User")
    ;;
esac
for PROFILE in "${PROFILES[@]}"; do
  PROMPTS_DIR="$PROFILE/prompts"
  [ -d "$PROMPTS_DIR" ] && [ -n "$(ls "$PROMPTS_DIR"/*.agent.md 2>/dev/null)" ] || continue
  for SRC in "$CENTRAL"/*.agent.md; do
    [ -f "$SRC" ] || continue
    cp "$SRC" "$PROMPTS_DIR/"
  done
  log "Updated VS Code profile: $PROFILE"
done

echo "$HASH" > "$INSTALL_DIR/.a11y-agent-team-version"
log "Check complete: $UPDATED files updated (version $HASH)."
UPDATESCRIPT
    chmod +x "$UPDATE_SCRIPT"

    # Detect platform and set up scheduler
    if [ "$(uname)" = "Darwin" ]; then
      # macOS: LaunchAgent
      PLIST_DIR="$HOME/Library/LaunchAgents"
      PLIST_FILE="$PLIST_DIR/com.community-access.accessibility-agents-update.plist"
      mkdir -p "$PLIST_DIR"
      cat > "$PLIST_FILE" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.community-access.accessibility-agents-update</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${UPDATE_SCRIPT}</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${HOME}/.claude/.a11y-agent-team-update.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/.claude/.a11y-agent-team-update.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST
      launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null
      echo "  Auto-updates enabled (daily at 9:00 AM via launchd)."
    else
      # Linux: cron job
      CRON_CMD="0 9 * * * /bin/bash $UPDATE_SCRIPT"
      (crontab -l 2>/dev/null | grep -v "a11y-agent-team-update"; echo "$CRON_CMD") | crontab -
      echo "  Auto-updates enabled (daily at 9:00 AM via cron)."
    fi
    echo "  Update log: ~/.claude/.a11y-agent-team-update.log"
  else
    echo "  Auto-updates skipped. You can run update.sh manually anytime."
  fi
fi

# Clean up temp download
[ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"

echo ""
if [ "$PLUGIN_INSTALL" = true ]; then
  echo "  Restart Claude Code for the plugin to take effect."
  echo ""
  echo "  The plugin will:"
  echo "    - Inject accessibility instructions into every prompt"
  echo "    - Block UI file edits until accessibility-lead reviews"
  echo "    - Log all agent activity"
else
  echo "  If agents do not load, increase the character budget:"
  echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000"
fi
echo ""
echo "  Start Claude Code and try: \"Build a login form\""
echo "  The accessibility-lead should activate automatically."
echo ""
