#!/bin/bash
# A11y Agent Team Installer
# Built by Taylor Arndt - https://github.com/taylorarndt
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
  read -r auto_update

  if [ "$auto_update" = "y" ] || [ "$auto_update" = "Y" ]; then
    UPDATE_SCRIPT="$TARGET_DIR/.a11y-agent-team-update.sh"

    # Write a self-contained update script
    cat > "$UPDATE_SCRIPT" << 'UPDATESCRIPT'
#!/bin/bash
set -e
REPO_URL="https://github.com/taylorarndt/a11y-agent-team.git"
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
  [ -f "$SRC" ] && [ -f "$DST" ] && ! cmp -s "$SRC" "$DST" && {
    cp "$SRC" "$DST"
    log "Updated: ${NAME%.md}"
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

echo "$HASH" > "$INSTALL_DIR/.a11y-agent-team-version"
log "Check complete: $UPDATED files updated (version $HASH)."
UPDATESCRIPT
    chmod +x "$UPDATE_SCRIPT"

    # Detect platform and set up scheduler
    if [ "$(uname)" = "Darwin" ]; then
      # macOS: LaunchAgent
      PLIST_DIR="$HOME/Library/LaunchAgents"
      PLIST_FILE="$PLIST_DIR/com.taylorarndt.a11y-agent-team-update.plist"
      mkdir -p "$PLIST_DIR"
      cat > "$PLIST_FILE" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.taylorarndt.a11y-agent-team-update</string>
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

echo ""
echo "  If agents do not load, increase the character budget:"
echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000"
echo ""
echo "  Start Claude Code and try: \"Build a login form\""
echo "  The accessibility-lead should activate automatically."
echo ""
