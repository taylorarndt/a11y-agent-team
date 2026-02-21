#!/bin/bash
# A11y Agent Team - Update Script
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Checks for updates from GitHub and installs them.
# Can be run manually or automatically via LaunchAgent/cron.
#
# Usage:
#   bash update.sh              Update global install
#   bash update.sh --project    Update project install in current directory
#   bash update.sh --silent     Suppress output (for scheduled runs)

set -e

REPO_URL="https://github.com/taylorarndt/a11y-agent-team.git"
CACHE_DIR="$HOME/.claude/.a11y-agent-team-repo"
VERSION_FILE="$HOME/.claude/.a11y-agent-team-version"
LOG_FILE="$HOME/.claude/.a11y-agent-team-update.log"

AGENTS=(
  "accessibility-lead.md"
  "aria-specialist.md"
  "modal-specialist.md"
  "contrast-master.md"
  "keyboard-navigator.md"
  "live-region-controller.md"
)

# Parse flags
SILENT=false
TARGET="global"
for arg in "$@"; do
  case "$arg" in
    --silent) SILENT=true ;;
    --project) TARGET="project" ;;
  esac
done

log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  echo "$msg" >> "$LOG_FILE"
  if [ "$SILENT" = false ]; then
    echo "  $1"
  fi
}

if [ "$TARGET" = "project" ]; then
  INSTALL_DIR="$(pwd)/.claude"
else
  INSTALL_DIR="$HOME/.claude"
fi

# Check for git
if ! command -v git &>/dev/null; then
  log "Error: git is not installed. Cannot check for updates."
  exit 1
fi

# Clone or pull the repo
if [ -d "$CACHE_DIR/.git" ]; then
  cd "$CACHE_DIR"
  git fetch origin main --quiet 2>/dev/null
  LOCAL_HASH=$(git rev-parse HEAD 2>/dev/null)
  REMOTE_HASH=$(git rev-parse origin/main 2>/dev/null)

  if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
    log "Already up to date."
    exit 0
  fi

  git reset --hard origin/main --quiet 2>/dev/null
  log "Pulled latest changes."
else
  log "Downloading a11y-agent-team..."
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --quiet "$REPO_URL" "$CACHE_DIR" 2>/dev/null
  log "Repository cloned."
fi

cd "$CACHE_DIR"
NEW_HASH=$(git rev-parse --short HEAD 2>/dev/null)

# Check if install directory exists
if [ ! -d "$INSTALL_DIR/agents" ]; then
  log "Install directory not found at $INSTALL_DIR/agents. Run install.sh first."
  exit 1
fi

# Copy updated agents
UPDATED=0
for agent in "${AGENTS[@]}"; do
  SRC="$CACHE_DIR/.claude/agents/$agent"
  DST="$INSTALL_DIR/agents/$agent"
  if [ -f "$SRC" ]; then
    if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
      cp "$SRC" "$DST"
      name="${agent%.md}"
      log "Updated: $name"
      UPDATED=$((UPDATED + 1))
    fi
  fi
done

# Copy updated hook
HOOK_SRC="$CACHE_DIR/.claude/hooks/a11y-team-eval.sh"
HOOK_DST="$INSTALL_DIR/hooks/a11y-team-eval.sh"
if [ -f "$HOOK_SRC" ] && [ -f "$HOOK_DST" ]; then
  if ! cmp -s "$HOOK_SRC" "$HOOK_DST" 2>/dev/null; then
    cp "$HOOK_SRC" "$HOOK_DST"
    chmod +x "$HOOK_DST"
    log "Updated: hook script"
    UPDATED=$((UPDATED + 1))
  fi
fi

# Save version
echo "$NEW_HASH" > "$VERSION_FILE"

if [ "$UPDATED" -gt 0 ]; then
  log "Update complete ($UPDATED files updated, version $NEW_HASH)."
else
  log "Files already match latest version ($NEW_HASH)."
fi
