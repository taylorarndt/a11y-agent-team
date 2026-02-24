#!/bin/bash
# A11y Agent Team Installer
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash install.sh                    Interactive mode (prompts for project or global)
#   bash install.sh --global           Install globally to ~/.claude/
#   bash install.sh --global --copilot Also install Copilot agents to VS Code
#   bash install.sh --project          Install to .claude/ in the current directory
#   bash install.sh --project --copilot Also install Copilot agents to project
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/community-access/accessibility-agents/main/install.sh | bash

set -e

# Determine source: running from repo clone or piped from curl?
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
DOWNLOADED=false

if [ ! -d "$SCRIPT_DIR/.claude/agents" ]; then
  # Running from curl pipe or without repo — download first
  DOWNLOADED=true
  TMPDIR_DL="$(mktemp -d)"
  echo ""
  echo "  Downloading A11y Agent Team..."

  if ! command -v git &>/dev/null; then
    echo "  Error: git is required. Install git and try again."
    rm -rf "$TMPDIR_DL"
    exit 1
  fi

  git clone --quiet https://github.com/community-access/accessibility-agents.git "$TMPDIR_DL/a11y-agent-team" 2>/dev/null
  SCRIPT_DIR="$TMPDIR_DL/a11y-agent-team"
  echo "  Downloaded."
fi

AGENTS_SRC="$SCRIPT_DIR/.claude/agents"
HOOK_SRC="$SCRIPT_DIR/.claude/hooks/a11y-team-eval.sh"
COPILOT_AGENTS_SRC="$SCRIPT_DIR/.github/agents"
COPILOT_CONFIG_SRC="$SCRIPT_DIR/.github"

# Auto-detect agents from source directory
AGENTS=()
if [ -d "$AGENTS_SRC" ]; then
  for f in "$AGENTS_SRC"/*.md; do
    [ -f "$f" ] && AGENTS+=("$(basename "$f")")
  done
fi

# Validate source files exist
if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "  Error: No agents found in $AGENTS_SRC"
  echo "  Make sure you are running this script from the a11y-agent-team directory."
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

if [ ! -f "$HOOK_SRC" ]; then
  echo "  Error: Hook script not found at $HOOK_SRC"
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

# Parse flags for non-interactive install
choice=""
COPILOT_FLAG=false
for arg in "$@"; do
  case "$arg" in
    --global) choice="2" ;;
    --project) choice="1" ;;
    --copilot) COPILOT_FLAG=true ;;
  esac
done

if [ -z "$choice" ]; then
  echo ""
  echo "  A11y Agent Team Installer"
  echo "  Built by Taylor Arndt"
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
  read -r choice < /dev/tty
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

# Create directories
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/hooks"

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

# Copy hook — skip if already exists
echo ""
echo "  Copying hook..."
if [ -f "$TARGET_DIR/hooks/a11y-team-eval.sh" ]; then
  echo "    ~ a11y-team-eval.sh (skipped - already exists)"
else
  cp "$HOOK_SRC" "$TARGET_DIR/hooks/a11y-team-eval.sh"
  chmod +x "$TARGET_DIR/hooks/a11y-team-eval.sh"
  grep -qxF "hooks/a11y-team-eval.sh" "$MANIFEST_FILE" 2>/dev/null || echo "hooks/a11y-team-eval.sh" >> "$MANIFEST_FILE"
  echo "    + a11y-team-eval.sh"
fi

# Copilot agents
COPILOT_INSTALLED=false
COPILOT_DESTINATIONS=()
install_copilot=false

if [ "$COPILOT_FLAG" = true ]; then
  install_copilot=true
elif [ -t 0 ]; then
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
      for subdir in skills instructions prompts hooks; do
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
      # VS Code 1.110+ discovers agents from User/prompts/.
      # VS Code 1.109 and older need agents in User/ root plus
      # the chat.agentFilesLocations setting pointing there.
      # We install to both locations for full compatibility.
      copy_to_vscode_profile() {
        local profile_dir="$1"
        local label="$2"
        local prompts_dir="$profile_dir/prompts"
        local settings_file="$profile_dir/settings.json"

        if [ ! -d "$profile_dir" ]; then
          return
        fi

        mkdir -p "$prompts_dir"
        echo "  [found] $label"

        # Copy to prompts/ (VS Code 1.110+)
        for f in "$COPILOT_CENTRAL"/*.agent.md; do
          [ -f "$f" ] || continue
          cp "$f" "$prompts_dir/"
        done

        # Copy to root User/ (VS Code 1.109 and older)
        for f in "$COPILOT_CENTRAL"/*.agent.md; do
          [ -f "$f" ] || continue
          cp "$f" "$profile_dir/"
        done

        # Copy prompts and instructions to profile (both root and prompts/ for full compatibility)
        [ -d "$COPILOT_CENTRAL_PROMPTS" ]      && cp -r "$COPILOT_CENTRAL_PROMPTS/."      "$prompts_dir/"
        [ -d "$COPILOT_CENTRAL_INSTRUCTIONS" ] && cp -r "$COPILOT_CENTRAL_INSTRUCTIONS/." "$prompts_dir/"
        # Flat copies to root User/ for older VS Code versions
        find "$COPILOT_CENTRAL_PROMPTS"      -name "*.prompt.md"      2>/dev/null -exec cp {} "$profile_dir/" \;
        find "$COPILOT_CENTRAL_INSTRUCTIONS" -name "*.instructions.md" 2>/dev/null -exec cp {} "$profile_dir/" \;

        echo "    Copied $(ls "$COPILOT_CENTRAL"/*.agent.md 2>/dev/null | wc -l | tr -d ' ') agents"

        # Add chat.agentFilesLocations to VS Code settings for older versions
        if command -v python3 &>/dev/null; then
          if [ -f "$settings_file" ]; then
            A11Y_SF="$settings_file" A11Y_PD="$profile_dir" A11Y_PMD="$prompts_dir" \
            python3 - << 'PYEOF' 2>/dev/null && echo "    Updated VS Code settings for agent discovery"
import json, os
try:
    sf = os.environ['A11Y_SF']
    with open(sf, 'r') as f:
        s = json.load(f)
    loc = s.get('chat.agentFilesLocations', {})
    loc[os.environ['A11Y_PD']] = True
    loc[os.environ['A11Y_PMD']] = True
    s['chat.agentFilesLocations'] = loc
    with open(sf, 'w') as f:
        json.dump(s, f, indent=4)
except:
    pass
PYEOF
          else
            A11Y_SF="$settings_file" A11Y_PD="$profile_dir" A11Y_PMD="$prompts_dir" \
            python3 - << 'PYEOF' 2>/dev/null && echo "    Created VS Code settings for agent discovery"
import json, os
s = {'chat.agentFilesLocations': {os.environ['A11Y_PD']: True, os.environ['A11Y_PMD']: True}}
with open(os.environ['A11Y_SF'], 'w') as f:
    json.dump(s, f, indent=4)
PYEOF
          fi
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
        if [ -t 0 ]; then
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
# A11y Agent Team - Copy Copilot agents into the current project
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
          echo "# A11y Agent Team - Copilot init command" >> "$SHELL_RC"
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
      MERGED=$(A11Y_SF="$SETTINGS_FILE" A11Y_HC="$HOOK_CMD" \
        python3 - << 'PYEOF' 2>/dev/null
import json, sys, os
try:
    with open(os.environ['A11Y_SF'], 'r') as f:
        settings = json.load(f)
    hook_entry = {'type': 'command', 'command': os.environ['A11Y_HC']}
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
PYEOF
) && {
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
echo "  Claude Code agents installed:"
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
# Save current version hash
if command -v git &>/dev/null && [ -d "$SCRIPT_DIR/.git" ]; then
  git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$TARGET_DIR/.a11y-agent-team-version"
fi

# Auto-update setup (global install only, interactive only)
if [ "$choice" = "2" ] && [ -t 0 ]; then
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
REPO_URL="https://github.com/community-access/accessibility-agents.git"
CACHE_DIR="$HOME/.claude/.a11y-agent-team-repo"
INSTALL_DIR="$HOME/.claude"
LOG_FILE="$HOME/.claude/.a11y-agent-team-update.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

command -v git &>/dev/null || { log "git not found"; exit 1; }

if [ -d "$CACHE_DIR/.git" ]; then
  cd "$CACHE_DIR"
  git fetch origin main --quiet 2>/dev/null
  LOCAL=$(git rev-parse HEAD 2>/dev/null)
  REMOTE=$(git rev-parse origin/main 2>/dev/null)
  [ "$LOCAL" = "$REMOTE" ] && { log "Already up to date."; exit 0; }
  git reset --hard origin/main --quiet 2>/dev/null
else
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --quiet "$REPO_URL" "$CACHE_DIR" 2>/dev/null
fi

cd "$CACHE_DIR"
HASH=$(git rev-parse --short HEAD 2>/dev/null)
UPDATED=0

for agent in .claude/agents/*.md; do
  NAME=$(basename "$agent")
  SRC="$CACHE_DIR/$agent"
  DST="$INSTALL_DIR/agents/$NAME"
  [ -f "$SRC" ] || continue
  if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
    cp "$SRC" "$DST"
    log "Updated: ${NAME%.md}"
    UPDATED=$((UPDATED + 1))
  fi
done

# Remove agents no longer in repo
for DST in "$INSTALL_DIR"/agents/*.md; do
  [ -f "$DST" ] || continue
  NAME=$(basename "$DST")
  [ ! -f "$CACHE_DIR/.claude/agents/$NAME" ] && {
    rm "$DST"
    log "Removed: ${NAME%.md}"
    UPDATED=$((UPDATED + 1))
  }
done

SRC="$CACHE_DIR/.claude/hooks/a11y-team-eval.sh"
DST="$INSTALL_DIR/hooks/a11y-team-eval.sh"
[ -f "$SRC" ] && [ -f "$DST" ] && ! cmp -s "$SRC" "$DST" && {
  cp "$SRC" "$DST"
  chmod +x "$DST"
  log "Updated: hook script"
  UPDATED=$((UPDATED + 1))
}

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
  # Only update if agents were previously installed there
  [ -d "$PROMPTS_DIR" ] && [ -n "$(ls "$PROMPTS_DIR"/*.agent.md 2>/dev/null)" ] || continue
  for SRC in "$CENTRAL"/*.agent.md; do
    [ -f "$SRC" ] || continue
    cp "$SRC" "$PROMPTS_DIR/"
    cp "$SRC" "$PROFILE/"
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
echo "  If agents do not load, increase the character budget:"
echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000"
echo ""
echo "  Start Claude Code and try: \"Build a login form\""
echo "  The accessibility-lead should activate automatically."
echo ""
