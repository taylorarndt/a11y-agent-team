#!/bin/bash
# Accessibility Agents Installer
# Started by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash install.sh                    Interactive mode (prompts for project or global)
#   bash install.sh --global           Install globally to ~/.claude/
#   bash install.sh --global --copilot Also install Copilot agents to VS Code
#   bash install.sh --global --codex   Also install Codex CLI support to ~/.codex/
#   bash install.sh --global --gemini  Also install Gemini CLI extension
#   bash install.sh --project          Install to .claude/ in the current directory
#   bash install.sh --project --copilot Also install Copilot agents to project
#   bash install.sh --project --codex  Also install Codex CLI support to .codex/
#   bash install.sh --project --gemini Also install Gemini CLI extension
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

if [ -d "$SCRIPT_DIR/claude-code-plugin/skills" ]; then
  SKILLS_SRC="$SCRIPT_DIR/claude-code-plugin/skills"
elif [ -d "$SCRIPT_DIR/claude-code-plugin/commands" ]; then
  # Backwards compat: old repos may still have commands/
  SKILLS_SRC="$SCRIPT_DIR/claude-code-plugin/commands"
else
  SKILLS_SRC=""
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

# Auto-detect skills from source directory
SKILLS=()
if [ -n "$SKILLS_SRC" ] && [ -d "$SKILLS_SRC" ]; then
  for f in "$SKILLS_SRC"/*.md; do
    [ -f "$f" ] && SKILLS+=("$(basename "$f")")
  done
fi

# Validate source files exist
if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "  Error: No agents found in $AGENTS_SRC"
  echo "  Make sure you are running this script from the accessibility-agents directory."
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

# Parse flags for non-interactive install
choice=""
COPILOT_FLAG=false
CODEX_FLAG=false
GEMINI_FLAG=false
for arg in "$@"; do
  case "$arg" in
    --global) choice="2" ;;
    --project) choice="1" ;;
    --copilot) COPILOT_FLAG=true ;;
    --codex) CODEX_FLAG=true ;;
    --gemini) GEMINI_FLAG=true ;;
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
  local start="<!-- accessibility-agents: start -->"
  local end="<!-- accessibility-agents: end -->"
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
start = "<!-- accessibility-agents: start -->"
end   = "<!-- accessibility-agents: end -->"
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
# Registers accessibility-agents as a Claude Code plugin for global installs.
# Copies to plugin cache, updates installed_plugins.json and settings.json.
# ---------------------------------------------------------------------------
register_plugin() {
  local src="$1"
  local namespace="community-access"
  local name="accessibility-agents"
  local default_key="${name}@${namespace}"
  local plugins_json="$HOME/.claude/plugins/installed_plugins.json"
  local settings_json="$HOME/.claude/settings.json"

  echo ""
  echo "  Registering Claude Code plugin..."

  # Ensure plugins directory exists
  mkdir -p "$HOME/.claude/plugins"

  local known_json="$HOME/.claude/plugins/known_marketplaces.json"
  local actual_key="$default_key"

  # ---- Step 1: Register the community-access marketplace ----
  # Claude Code only loads plugins from known marketplaces.
  # Without this, the plugin is silently skipped.
  if command -v python3 &>/dev/null; then
    python3 - "$known_json" "$namespace" "$src" << 'PYEOF'
import json, sys, os, datetime
known_path, ns, plugin_src = sys.argv[1:4]

# Read existing or create new
if os.path.isfile(known_path):
    with open(known_path) as f:
        data = json.load(f)
else:
    data = {}

if ns not in data:
    # Create a marketplace directory alongside the plugin source
    marketplace_dir = os.path.join(os.path.dirname(plugin_src), ns + "-plugins")
    plugin_dir = os.path.join(marketplace_dir, "plugins")
    manifest_dir = os.path.join(marketplace_dir, ".claude-plugin")

    os.makedirs(plugin_dir, exist_ok=True)
    os.makedirs(manifest_dir, exist_ok=True)

    # Create marketplace.json if missing
    manifest_path = os.path.join(manifest_dir, "marketplace.json")
    if not os.path.isfile(manifest_path):
        manifest = {
            "name": ns,
            "owner": {"name": "Community Access"},
            "metadata": {"description": "Accessibility-focused Claude Code plugins"},
            "plugins": [{
                "name": "accessibility-agents",
                "source": "./plugins/accessibility-agents",
                "description": "WCAG AA accessibility enforcement with 49 agents and enforcement hooks.",
                "version": "1.0.0"
            }]
        }
        with open(manifest_path, 'w') as f:
            json.dump(manifest, f, indent=2)

    # Symlink the plugin source into the marketplace
    link_target = os.path.join(plugin_dir, "accessibility-agents")
    if not os.path.exists(link_target):
        os.symlink(plugin_src, link_target)

    # Register marketplace
    now = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z')
    data[ns] = {
        "source": {"source": "directory", "path": marketplace_dir},
        "installLocation": marketplace_dir,
        "lastUpdated": now
    }
    with open(known_path, 'w') as f:
        json.dump(data, f, indent=2)
    print("    + Registered community-access marketplace")
else:
    print("    ~ community-access marketplace already registered")
PYEOF
  else
    echo "    ! python3 required for marketplace registration"
  fi

  # ---- Step 2: Detect existing registration (for upgrades) ----
  if [ -f "$plugins_json" ] && command -v python3 &>/dev/null; then
    local found_key
    found_key=$(python3 -c "
import json
data = json.load(open('$plugins_json'))
for k in data.get('plugins', {}):
    if k.startswith('accessibility-agents@'):
        print(k)
        break
" 2>/dev/null)
    if [ -n "$found_key" ]; then
      actual_key="$found_key"
      namespace="${actual_key#accessibility-agents@}"
    fi
  fi

  local cache="$HOME/.claude/plugins/cache/${namespace}/${name}/${PLUGIN_VERSION}"

  # ---- Step 3: Copy plugin to cache ----
  mkdir -p "$cache"
  cp -R "$src/." "$cache/"
  chmod +x "$cache/scripts/"*.sh 2>/dev/null || true
  echo "    + Plugin cached"

  # ---- Step 4: Register in installed_plugins.json ----
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

  # ---- Step 5: Enable in settings.json ----
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

  # ---- Step 6: Clean up stale skills/ directory from previous installs ----
  if [ -d "$cache/skills" ]; then
    rm -rf "$cache/skills"
    echo "    ~ Removed stale skills/ directory"
  fi

  # Summary
  local agent_count cmd_count
  agent_count=$(ls "$cache/agents/"*.md 2>/dev/null | wc -l)
  cmd_count=$(ls "$cache/commands/"*.md 2>/dev/null | wc -l)
  echo ""
  echo "  Plugin registered: $actual_key (v${PLUGIN_VERSION})"
  echo "    $agent_count agents"
  echo "    $cmd_count commands"
  echo "    3 enforcement hooks (UserPromptSubmit, PreToolUse, PostToolUse)"
}

# ---------------------------------------------------------------------------
# cleanup_old_install
# Removes agents/commands/skills from ~/.claude/ that were installed by a
# previous non-plugin install (using the manifest file).
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
  rmdir "$HOME/.claude/skills" 2>/dev/null || true
  if [ "$removed" -gt 0 ]; then
    echo "    Removed $removed files from previous install"
  fi
}

# ---------------------------------------------------------------------------
# install_global_hooks
# Installs three enforcement hooks:
#   1. a11y-team-eval.sh     (UserPromptSubmit) — Proactive web project detection
#   2. a11y-enforce-edit.sh  (PreToolUse)       — Blocks UI file edits without review
#   3. a11y-mark-reviewed.sh (PostToolUse)      — Creates session marker after review
# Merges all three into ~/.claude/settings.json.
# ---------------------------------------------------------------------------
install_global_hooks() {
  local hooks_dir="$HOME/.claude/hooks"
  local settings_json="$HOME/.claude/settings.json"

  mkdir -p "$hooks_dir"

  # ── Hook 1: Proactive web project detection (UserPromptSubmit) ──
  cat > "$hooks_dir/a11y-team-eval.sh" << 'HOOKSCRIPT'
#!/bin/bash
# Accessibility Agents - UserPromptSubmit hook
# Two detection modes:
#   1. PROACTIVE: Detects web projects by checking for framework files
#   2. KEYWORD: Falls back to keyword matching for non-web projects
# Installed by: accessibility-agents install.sh

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt','').lower())" 2>/dev/null || echo "")

# ── PROACTIVE DETECTION ──
IS_WEB_PROJECT=false

if [ -f "package.json" ]; then
  if grep -qiE '"(react|next|vue|nuxt|svelte|sveltekit|astro|angular|gatsby|remix|solid|qwik|vite|webpack|parcel|tailwindcss|@emotion|styled-components|sass|less)"' package.json 2>/dev/null; then
    IS_WEB_PROJECT=true
  fi
fi

if [ "$IS_WEB_PROJECT" = false ]; then
  for f in next.config.js next.config.mjs next.config.ts nuxt.config.ts vite.config.ts vite.config.js svelte.config.js astro.config.mjs angular.json tailwind.config.js tailwind.config.ts postcss.config.js postcss.config.mjs tsconfig.json; do
    if [ -f "$f" ]; then
      IS_WEB_PROJECT=true
      break
    fi
  done
fi

if [ "$IS_WEB_PROJECT" = false ]; then
  if find . -maxdepth 3 -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.astro" \) -print -quit 2>/dev/null | grep -q .; then
    IS_WEB_PROJECT=true
  fi
fi

if [ "$IS_WEB_PROJECT" = false ]; then
  if find . -maxdepth 3 -type f \( -name "*.html" -o -name "*.ejs" -o -name "*.hbs" -o -name "*.leaf" -o -name "*.erb" -o -name "*.jinja" -o -name "*.twig" -o -name "*.blade.php" \) -print -quit 2>/dev/null | grep -q .; then
    IS_WEB_PROJECT=true
  fi
fi

# ── KEYWORD DETECTION ──
KEYWORDS="html|jsx|tsx|css|tailwind|react|next\.?js|vue|svelte|astro|angular|component|widget|form|modal|dialog|popover|drawer|toast|notification|aria|wcag|a11y|accessibility|accessible|contrast|focus|keyboard|tab order|tabindex|screen ?reader|voiceover|nvda|jaws|talkback|heading|alt text|alt=|landmark|template|leaf|ejs|erb|hbs|jinja|twig|blade|vapor|render|view|page|button|input|select|checkbox|radio|label|dropdown|menu|accordion|carousel|slider|tooltip|card|sidebar|navbar|layout|grid|flex|responsive|theme|dark mode|color|style|font|image|img|svg|icon|video|audio|link|href|navigation|breadcrumb|pagination|loading|spinner|progress|alert|banner|role=|tabpanel|tablist|listbox|combobox|live region|aria-live|aria-label|aria-hidden|sr-only|visually-hidden|skip link|ui|ux|front.?end|client.?side|browser|dom|hydrat|ssr|ssg|not announcing|not reading|not saying|cannot hear|broken announce|announce"
KEYWORD_MATCH=false
if echo "$PROMPT" | grep -qiE "$KEYWORDS"; then
  KEYWORD_MATCH=true
fi

# ── OUTPUT ──
if [ "$IS_WEB_PROJECT" = true ] || [ "$KEYWORD_MATCH" = true ]; then
  if [ "$IS_WEB_PROJECT" = true ]; then
    PROJECT_NOTE="DETECTED: This is a web project. Accessibility agents are ALWAYS required here."
  else
    PROJECT_NOTE="DETECTED: UI-related keywords found in prompt."
  fi

  cat <<HOOK_OUTPUT
INSTRUCTION: MANDATORY ACCESSIBILITY CHECK — YOU MUST FOLLOW THIS
${PROJECT_NOTE}

This is a NON-OPTIONAL instruction. You MUST use the accessibility agents
for ANY task in this project that touches user-facing code. This is proactive —
do not wait for the user to ask. If there is ANY chance the task involves UI,
delegate to the accessibility-lead FIRST.

REQUIRED ACTIONS:
1. Use the Agent tool to delegate to accessibility-agents:accessibility-lead
   (subagent_type: "accessibility-agents:accessibility-lead")
2. The accessibility-lead will coordinate specialist agents as needed
3. Do NOT write or edit UI code without accessibility-lead review FIRST
4. Do NOT skip this step even if you think you can handle it yourself
5. Be PROACTIVE: if the user asks to fix a bug, add a feature, or change
   anything in a web project, assume it involves UI until proven otherwise

This applies to ALL web projects, not just the accessibility-agents repo.

CROSS-TEAM COORDINATION:
- Swift/iOS code -> swift-agent-team:swift-lead handles Swift
- HTML/templates/components -> accessibility-agents:accessibility-lead handles web
- Both leads can run in parallel via separate Agent tool calls.
HOOK_OUTPUT
fi
HOOKSCRIPT

  # ── Hook 2: Edit gate (PreToolUse on Edit|Write) ──
  cat > "$hooks_dir/a11y-enforce-edit.sh" << 'HOOKSCRIPT'
#!/bin/bash
# Accessibility Agents - PreToolUse enforcement hook
# BLOCKS Edit/Write to UI files until accessibility-lead is consulted.
# Uses permissionDecision: "deny" to reject the tool call.
# Installed by: accessibility-agents install.sh

INPUT=$(cat)

eval "$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print('FILE_PATH=' + repr(ti.get('file_path', '')))
print('SESSION_ID=' + repr(data.get('session_id', '')))
" 2>/dev/null || echo "FILE_PATH=''; SESSION_ID=''")"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

IS_UI=false
case "$FILE_PATH" in
  *.jsx|*.tsx|*.vue|*.svelte|*.astro|*.html|*.ejs|*.hbs|*.leaf|*.erb|*.jinja|*.twig|*.blade.php)
    IS_UI=true ;;
  *.css|*.scss|*.less|*.sass)
    IS_UI=true ;;
esac

if [ "$IS_UI" = false ]; then
  case "$FILE_PATH" in
    */components/*|*/pages/*|*/views/*|*/layouts/*|*/templates/*)
      case "$FILE_PATH" in
        *.ts|*.js) IS_UI=true ;;
      esac ;;
  esac
fi

if [ "$IS_UI" = false ]; then
  exit 0
fi

MARKER="/tmp/a11y-reviewed-${SESSION_ID}"
if [ -n "$SESSION_ID" ] && [ -f "$MARKER" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "BLOCKED: Cannot edit UI file '${BASENAME}' without accessibility review. You MUST first delegate to accessibility-agents:accessibility-lead using the Agent tool (subagent_type: 'accessibility-agents:accessibility-lead'). After the accessibility review completes, this file will be unblocked automatically."
  }
}
EOF
exit 0
HOOKSCRIPT

  # ── Hook 3: Session marker (PostToolUse on Agent) ──
  cat > "$hooks_dir/a11y-mark-reviewed.sh" << 'HOOKSCRIPT'
#!/bin/bash
# Accessibility Agents - PostToolUse hook for Agent tool
# Creates a session marker when accessibility-lead has been consulted.
# This marker unlocks the a11y-enforce-edit.sh PreToolUse block.
# Installed by: accessibility-agents install.sh

INPUT=$(cat)

eval "$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
subagent = ti.get('subagent_type', '')
session_id = data.get('session_id', '')
print('SUBAGENT=' + repr(subagent))
print('SESSION_ID=' + repr(session_id))
" 2>/dev/null || echo "SUBAGENT=''; SESSION_ID=''")"

if [ -n "$SESSION_ID" ]; then
  case "$SUBAGENT" in
    *accessibility-lead*|*accessibility-agents:accessibility-lead*)
      touch "/tmp/a11y-reviewed-${SESSION_ID}" ;;
  esac
fi

exit 0
HOOKSCRIPT

  chmod +x "$hooks_dir/a11y-team-eval.sh"
  chmod +x "$hooks_dir/a11y-enforce-edit.sh"
  chmod +x "$hooks_dir/a11y-mark-reviewed.sh"

  # ── Register all three hooks in settings.json ──
  if [ ! -f "$settings_json" ]; then
    echo '{}' > "$settings_json"
  fi

  python3 - "$settings_json" "$hooks_dir" << 'PYEOF'
import json, sys

settings_path = sys.argv[1]
hooks_dir = sys.argv[2]

with open(settings_path) as f:
    data = json.load(f)

hooks = data.setdefault("hooks", {})

# --- Helper: upsert a hook entry by matching a substring in the command ---
def upsert_hook(event_name, match_substr, new_entry):
    event_hooks = hooks.setdefault(event_name, [])
    replaced = False
    for i, entry in enumerate(event_hooks):
        for h in entry.get("hooks", []):
            if match_substr in h.get("command", ""):
                event_hooks[i] = new_entry
                replaced = True
                break
        if replaced:
            break
    if not replaced:
        event_hooks.append(new_entry)

# Hook 1: UserPromptSubmit — a11y-team-eval.sh
upsert_hook("UserPromptSubmit", "a11y-team-eval", {
    "hooks": [{"type": "command", "command": hooks_dir + "/a11y-team-eval.sh"}]
})

# Hook 2: PreToolUse — a11y-enforce-edit.sh (matcher: Edit|Write)
upsert_hook("PreToolUse", "a11y-enforce-edit", {
    "matcher": "Edit|Write",
    "hooks": [{"type": "command", "command": hooks_dir + "/a11y-enforce-edit.sh"}]
})

# Hook 3: PostToolUse — a11y-mark-reviewed.sh (matcher: Agent)
upsert_hook("PostToolUse", "a11y-mark-reviewed", {
    "matcher": "Agent",
    "hooks": [{"type": "command", "command": hooks_dir + "/a11y-mark-reviewed.sh"}]
})

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
PYEOF

  echo "    + Hook 1: a11y-team-eval.sh (UserPromptSubmit — proactive web detection)"
  echo "    + Hook 2: a11y-enforce-edit.sh (PreToolUse — blocks UI edits without review)"
  echo "    + Hook 3: a11y-mark-reviewed.sh (PostToolUse — unlocks after review)"
  echo "    + All 3 hooks registered in settings.json"
}

# ---------------------------------------------------------------------------
# Installation: plugin (global) vs file-copy (project)
# ---------------------------------------------------------------------------
PLUGIN_INSTALL=false

if [ "$choice" = "2" ] && [ -n "$PLUGIN_SRC" ] && command -v python3 &>/dev/null; then
  # Global install: register as a Claude Code plugin
  INSTALL_PLUGIN=true
  if { true < /dev/tty; } 2>/dev/null; then
    echo ""
    printf "  Would you like to install the Claude Code plugin? [Y/n]: "
    read -r plugin_choice < /dev/tty
    if [ "$plugin_choice" = "n" ] || [ "$plugin_choice" = "N" ]; then
      INSTALL_PLUGIN=false
    fi
  fi

  if [ "$INSTALL_PLUGIN" = true ]; then
    register_plugin "$PLUGIN_SRC"
    cleanup_old_install
    install_global_hooks
    PLUGIN_INSTALL=true
  fi
else
  # Project install (or global without plugin support): copy agents/skills directly

# Create directories
mkdir -p "$TARGET_DIR/agents"
if [ ${#SKILLS[@]} -gt 0 ]; then
  mkdir -p "$TARGET_DIR/skills"
fi

# Manifest: track which files we install so updates never touch user-created files
MANIFEST_FILE="$TARGET_DIR/.a11y-agent-manifest"
touch "$MANIFEST_FILE"

add_manifest_entry() {
  local entry="$1"
  grep -qxF "$entry" "$MANIFEST_FILE" 2>/dev/null || echo "$entry" >> "$MANIFEST_FILE"
}

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
    add_manifest_entry "agents/$agent"
    echo "    + $name"
  fi
done
if [ "$SKIPPED_AGENTS" -gt 0 ]; then
  echo "      $SKIPPED_AGENTS agent(s) skipped. Delete them first to reinstall."
fi

# Copy skills — skip any file that already exists (preserves user customisations)
if [ ${#SKILLS[@]} -gt 0 ]; then
  echo ""
  echo "  Copying skills..."
  SKIPPED_SKILLS=0
  for skill in "${SKILLS[@]}"; do
    if [ ! -f "$SKILLS_SRC/$skill" ]; then
      echo "    ! Missing: $skill (skipped)"
      continue
    fi
    dst_skill="$TARGET_DIR/skills/$skill"
    name="${skill%.md}"
    if [ -f "$dst_skill" ]; then
      echo "    ~ /$name (skipped - already exists)"
      SKIPPED_SKILLS=$((SKIPPED_SKILLS + 1))
    else
      cp "$SKILLS_SRC/$skill" "$dst_skill"
      grep -qxF "skills/$skill" "$MANIFEST_FILE" 2>/dev/null || echo "skills/$skill" >> "$MANIFEST_FILE"
      echo "    + /$name"
    fi
  done
  if [ "$SKIPPED_SKILLS" -gt 0 ]; then
    echo "      $SKIPPED_SKILLS skill(s) skipped. Delete them first to reinstall."
  fi
  # Clean up stale commands/ directory from previous installs
  if [ -d "$TARGET_DIR/commands" ]; then
    rm -rf "$TARGET_DIR/commands"
    echo "    ~ Removed stale commands/ directory"
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
            add_manifest_entry "copilot-agents/$(basename "$f")"
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
          add_manifest_entry "copilot-config/$config"
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
              add_manifest_entry "copilot-$subdir/$rel"
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
      COPILOT_CENTRAL="$HOME/.accessibility-agents/copilot-agents"
      COPILOT_CENTRAL_PROMPTS="$HOME/.accessibility-agents/copilot-prompts"
      COPILOT_CENTRAL_INSTRUCTIONS="$HOME/.accessibility-agents/copilot-instructions-files"
      COPILOT_CENTRAL_SKILLS="$HOME/.accessibility-agents/copilot-skills"
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
          cp "$SRC" "$HOME/.accessibility-agents/$config"
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
      mkdir -p "$HOME/.accessibility-agents"
      INIT_SCRIPT="$HOME/.accessibility-agents/a11y-copilot-init"
      cat > "$INIT_SCRIPT" << 'INITSCRIPT'
#!/bin/bash
# Accessibility Agents - Copy Copilot agents into the current project
# Usage: a11y-copilot-init
#
# Copies .agent.md files into .github/agents/ for this project.
# Merges copilot-instructions.md rather than overwriting it.
# Skips any file that already exists to preserve your customisations.

CENTRAL="$HOME/.accessibility-agents/copilot-agents"
TARGET=".github/agents"

if [ ! -d "$CENTRAL" ] || [ -z "$(ls "$CENTRAL"/*.agent.md 2>/dev/null)" ]; then
  echo "  Error: No Copilot agents found in $CENTRAL"
  echo "  Run the accessibility-agents installer first."
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

# Merge config files using accessibility-agents section markers — never overwrites user content
merge_config() {
  local src="$1" dst="$2" label="$3"
  local start="<!-- accessibility-agents: start -->"
  local end="<!-- accessibility-agents: end -->"
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
start = "<!-- accessibility-agents: start -->"
end   = "<!-- accessibility-agents: end -->"
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
  merge_config "$HOME/.accessibility-agents/$config" ".github/$config" "$config"
done

# Copy prompts, instructions, and skills — skip existing files
for pair in "copilot-prompts:prompts" "copilot-instructions-files:instructions" "copilot-skills:skills"; do
  SRC="$HOME/.accessibility-agents/${pair%%:*}"
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
          echo "export PATH=\"\$HOME/.accessibility-agents:\$PATH\"" >> "$SHELL_RC"
          echo "  Added 'a11y-copilot-init' command to your PATH via $SHELL_RC"
        else
          echo "  'a11y-copilot-init' already in PATH."
        fi
      fi

      COPILOT_INSTALLED=true
      add_manifest_entry "copilot-global/central-store"
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
  if [ "$choice" = "1" ]; then
    add_manifest_entry "codex/project"
  else
    add_manifest_entry "codex/global"
  fi
  add_manifest_entry "codex/path:$CODEX_DST"

  echo ""
  echo "  Codex will now enforce WCAG AA rules on all UI code in this project."
  echo "  Run: codex \"Build a login form\" — accessibility rules apply automatically."
fi

# ---------------------------------------------------------------------------
# Gemini CLI extension
# ---------------------------------------------------------------------------
GEMINI_SRC="$SCRIPT_DIR/.gemini/extensions/a11y-agents"
GEMINI_INSTALLED=false

install_gemini=false
if [ "$GEMINI_FLAG" = true ]; then
  install_gemini=true
elif [ -d "$GEMINI_SRC" ] && { true < /dev/tty; } 2>/dev/null; then
  echo ""
  echo "  Would you also like to install Gemini CLI support?"
  echo "  This installs accessibility skills as a Gemini CLI extension"
  echo "  so Gemini automatically applies WCAG AA rules to all UI code."
  echo ""
  printf "  Install Gemini CLI support? [y/N]: "
  read -r gemini_choice < /dev/tty
  if [ "$gemini_choice" = "y" ] || [ "$gemini_choice" = "Y" ]; then
    install_gemini=true
  fi
fi

if [ "$install_gemini" = true ] && [ -d "$GEMINI_SRC" ]; then
  echo ""
  echo "  Installing Gemini CLI extension..."

  if [ "$choice" = "1" ]; then
    # Project install: copy to .gemini/extensions/a11y-agents/ in the current project
    GEMINI_TARGET="$(pwd)/.gemini/extensions/a11y-agents"
  else
    # Global install: copy to ~/.gemini/extensions/a11y-agents/
    GEMINI_TARGET="$HOME/.gemini/extensions/a11y-agents"
  fi

  mkdir -p "$GEMINI_TARGET"

  # Copy extension manifest and context file
  for f in gemini-extension.json GEMINI.md; do
    if [ -f "$GEMINI_SRC/$f" ]; then
      cp "$GEMINI_SRC/$f" "$GEMINI_TARGET/$f"
      echo "    + $f"
    fi
  done

  # Copy skills — directory by directory, skip existing
  if [ -d "$GEMINI_SRC/skills" ]; then
    ADDED=0; SKIPPED=0
    for skill_dir in "$GEMINI_SRC/skills"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_name="$(basename "$skill_dir")"
      dst_skill="$GEMINI_TARGET/skills/$skill_name"
      mkdir -p "$dst_skill"
      for src_file in "$skill_dir"*; do
        [ -f "$src_file" ] || continue
        dst_file="$dst_skill/$(basename "$src_file")"
        if [ -f "$dst_file" ]; then
          SKIPPED=$((SKIPPED + 1))
        else
          cp "$src_file" "$dst_file"
          ADDED=$((ADDED + 1))
        fi
      done
    done
    echo "    + skills/ ($ADDED new, $SKIPPED skipped)"
  fi

  GEMINI_INSTALLED=true
  GEMINI_DST="$GEMINI_TARGET"
  if [ "$choice" = "1" ]; then
    add_manifest_entry "gemini/project"
  else
    add_manifest_entry "gemini/global"
  fi
  add_manifest_entry "gemini/path:$GEMINI_DST"

  echo ""
  echo "  Gemini CLI will now enforce WCAG AA rules on all UI code."
  echo "  Run: gemini \"Build a login form\" — accessibility skills apply automatically."
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
  for ns_dir in "$CACHE_CHECK"/*/accessibility-agents; do
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
    echo "  Skills:"
    for skill in "$PLUGIN_DIR/skills/"*.md; do
      [ -f "$skill" ] || continue
      name="$(basename "${skill%.md}")"
      echo "    [x] /$name"
    done
    echo ""
    echo "  Enforcement hooks (three-hook gate):"
    if [ -f "$HOME/.claude/hooks/a11y-team-eval.sh" ]; then
      echo "    [x] UserPromptSubmit  - Proactive web project detection"
    else
      echo "    [ ] UserPromptSubmit  - Proactive web project detection (not installed)"
    fi
    if [ -f "$HOME/.claude/hooks/a11y-enforce-edit.sh" ]; then
      echo "    [x] PreToolUse        - Blocks UI file edits until accessibility-lead reviewed"
    else
      echo "    [ ] PreToolUse        - Blocks UI file edits (not installed)"
    fi
    if [ -f "$HOME/.claude/hooks/a11y-mark-reviewed.sh" ]; then
      echo "    [x] PostToolUse       - Unlocks edit gate after accessibility-lead completes"
    else
      echo "    [ ] PostToolUse       - Unlocks edit gate (not installed)"
    fi
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
  if [ ${#SKILLS[@]} -gt 0 ]; then
    echo ""
    echo "  Skills installed:"
    for skill in "${SKILLS[@]}"; do
      name="${skill%.md}"
      if [ -f "$TARGET_DIR/skills/$skill" ]; then
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
    git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$HOME/.claude/.accessibility-agents-version"
  else
    git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$TARGET_DIR/.accessibility-agents-version"
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
    UPDATE_SCRIPT="$TARGET_DIR/.accessibility-agents-update.sh"

    # Write a self-contained update script
    cat > "$UPDATE_SCRIPT" << 'UPDATESCRIPT'
#!/bin/bash
set -e
REPO_URL="https://github.com/Community-Access/accessibility-agents.git"
CACHE_DIR="$HOME/.claude/.accessibility-agents-repo"
INSTALL_DIR="$HOME/.claude"
LOG_FILE="$HOME/.claude/.accessibility-agents-update.log"

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
for ns_dir in "$HOME/.claude/plugins/cache"/*/accessibility-agents; do
  [ -d "$ns_dir" ] || continue
  for ver_dir in "$ns_dir"/*/; do
    [ -d "$ver_dir" ] && PLUGIN_CACHE="$ver_dir" && break
  done
  [ -n "$PLUGIN_CACHE" ] && break
done

if [ -n "$PLUGIN_CACHE" ] && [ -d "$CACHE_DIR/claude-code-plugin" ]; then
  # Update plugin cache from repo
  PLUGIN_SRC="$CACHE_DIR/claude-code-plugin"
  for subdir in agents skills scripts hooks .claude-plugin; do
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

  # Update skills (check both skills/ and legacy commands/ in source)
  SKILL_SRC_DIR=""
  if [ -d "$CACHE_DIR/claude-code-plugin/skills" ]; then
    SKILL_SRC_DIR="$CACHE_DIR/claude-code-plugin/skills"
  elif [ -d "$CACHE_DIR/claude-code-plugin/commands" ]; then
    SKILL_SRC_DIR="$CACHE_DIR/claude-code-plugin/commands"
  fi
  # Install to skills/ dir, migrate from commands/ if needed
  SKILL_DST_DIR="$INSTALL_DIR/skills"
  [ -d "$INSTALL_DIR/commands" ] && [ ! -d "$SKILL_DST_DIR" ] && mv "$INSTALL_DIR/commands" "$SKILL_DST_DIR"
  if [ -n "$SKILL_SRC_DIR" ] && [ -d "$SKILL_DST_DIR" ]; then
    for skill in "$SKILL_SRC_DIR"/*.md; do
      [ -f "$skill" ] || continue
      NAME=$(basename "$skill")
      DST="$SKILL_DST_DIR/$NAME"
      if ! cmp -s "$skill" "$DST" 2>/dev/null; then
        cp "$skill" "$DST"
        log "Updated skill: ${NAME%.md}"
        UPDATED=$((UPDATED + 1))
      fi
    done
  fi
fi

# Update Copilot agents in central store and VS Code profile folders
CENTRAL="$HOME/.accessibility-agents/copilot-agents"
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

echo "$HASH" > "$INSTALL_DIR/.accessibility-agents-version"
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
  <string>${HOME}/.claude/.accessibility-agents-update.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/.claude/.accessibility-agents-update.log</string>
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
      (crontab -l 2>/dev/null | grep -v "accessibility-agents-update"; echo "$CRON_CMD") | crontab -
      echo "  Auto-updates enabled (daily at 9:00 AM via cron)."
    fi
    echo "  Update log: ~/.claude/.accessibility-agents-update.log"
  else
    echo "  Auto-updates skipped. You can run update.sh manually anytime."
  fi
fi

# Record install scope for uninstaller (only for file-copy installs that have a manifest)
if command -v add_manifest_entry &>/dev/null 2>&1 || type add_manifest_entry &>/dev/null 2>&1; then
  if [ "$choice" = "1" ]; then
    add_manifest_entry "scope:project"
  else
    add_manifest_entry "scope:global"
  fi
fi

# Clean up temp download
[ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"

echo ""
if [ "$PLUGIN_INSTALL" = true ]; then
  echo "  Restart Claude Code for the plugin to take effect."
  echo ""
  echo "  The plugin will:"
  echo "    - Inject accessibility-lead delegation instruction into every UI prompt"
  echo "    - Remind to consult accessibility-lead before editing UI files"
  echo "    - accessibility-lead delegates to specialists via Task tool"
else
  echo "  If agents do not load, increase the character budget:"
  echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000"
fi
echo ""
echo "  To uninstall, run:"
echo "    curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/uninstall.sh | bash"
echo ""
echo "  For manual uninstall instructions, see: UNINSTALL.md"
echo ""
echo "  Start Claude Code and try: \"Build a login form\""
echo "  The accessibility-lead should activate automatically."
echo ""
