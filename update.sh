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

# Agents are auto-detected from the cached repo after clone/pull

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

# Auto-detect and copy updated agents
UPDATED=0
for SRC in "$CACHE_DIR"/.claude/agents/*.md; do
  [ -f "$SRC" ] || continue
  agent="$(basename "$SRC")"
  DST="$INSTALL_DIR/agents/$agent"
  if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
    cp "$SRC" "$DST"
    name="${agent%.md}"
    log "Updated: $name"
    UPDATED=$((UPDATED + 1))
  fi
done

# Remove agents that no longer exist in the repo
for DST in "$INSTALL_DIR"/agents/*.md; do
  [ -f "$DST" ] || continue
  agent="$(basename "$DST")"
  SRC="$CACHE_DIR/.claude/agents/$agent"
  if [ ! -f "$SRC" ]; then
    rm "$DST"
    name="${agent%.md}"
    log "Removed (no longer in repo): $name"
    UPDATED=$((UPDATED + 1))
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

# Helper: recursively sync a source directory into a destination directory.
# Updates changed files, adds new files, removes files no longer in source.
# Auto-discovered — no hardcoded file list to maintain.
sync_github_dir() {
  local src_dir="$1"
  local dst_dir="$2"
  local label="$3"
  [ -d "$src_dir" ] || return 0
  [ -d "$dst_dir" ] || return 0  # only sync if previously installed
  # Update / add (use process substitution to avoid subshell variable loss)
  while read -r src_file; do
    rel="${src_file#$src_dir/}"
    dst_file="$dst_dir/$rel"
    mkdir -p "$(dirname "$dst_file")"
    if ! cmp -s "$src_file" "$dst_file" 2>/dev/null; then
      cp "$src_file" "$dst_file"
      log "Updated $label/$rel"
      UPDATED=$((UPDATED + 1))
    fi
  done < <(find "$src_dir" -type f)
  # Remove obsolete
  while read -r dst_file; do
    rel="${dst_file#$dst_dir/}"
    src_check="$src_dir/$rel"
    if [ ! -f "$src_check" ]; then
      rm "$dst_file"
      log "Removed $label/$rel"
      UPDATED=$((UPDATED + 1))
    fi
  done < <(find "$dst_dir" -type f)
}

GITHUB_SRC="$CACHE_DIR/.github"

# Update Copilot assets for project install
if [ "$TARGET" = "project" ]; then
  PROJECT_GITHUB="$(pwd)/.github"
  if [ -d "$PROJECT_GITHUB" ]; then
    # Agents (all files: *.agent.md + AGENTS.md and support files)
    sync_github_dir "$GITHUB_SRC/agents" "$PROJECT_GITHUB/agents" "agents"
    # Config files
    for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
      SRC="$GITHUB_SRC/$config"
      DST="$PROJECT_GITHUB/$config"
      if [ -f "$SRC" ] && [ -f "$DST" ]; then
        if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
          cp "$SRC" "$DST"
          log "Updated Copilot config: $config"
          UPDATED=$((UPDATED + 1))
        fi
      fi
    done
    # Asset subdirs: skills, instructions, prompts, hooks — auto-discovered
    for subdir in skills instructions prompts hooks; do
      sync_github_dir "$GITHUB_SRC/$subdir" "$PROJECT_GITHUB/$subdir" "$subdir"
    done
  fi
fi

# Update Copilot assets for global install
if [ "$TARGET" = "global" ]; then
  CENTRAL_ROOT="$HOME/.a11y-agent-team"
  CENTRAL="$CENTRAL_ROOT/copilot-agents"
  CENTRAL_PROMPTS="$CENTRAL_ROOT/copilot-prompts"
  CENTRAL_INSTRUCTIONS="$CENTRAL_ROOT/copilot-instructions-files"
  CENTRAL_SKILLS="$CENTRAL_ROOT/copilot-skills"

  # Sync central agent store
  if [ -d "$CENTRAL" ]; then
    for SRC in "$GITHUB_SRC"/agents/*.agent.md; do
      [ -f "$SRC" ] || continue
      NAME="$(basename "$SRC")"
      DST="$CENTRAL/$NAME"
      if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
        cp "$SRC" "$DST"
        log "Updated central agent: ${NAME%.agent.md}"
        UPDATED=$((UPDATED + 1))
      fi
    done
    # Remove central agents no longer in repo
    for DST_FILE in "$CENTRAL"/*.agent.md; do
      [ -f "$DST_FILE" ] || continue
      NAME="$(basename "$DST_FILE")"
      if [ ! -f "$GITHUB_SRC/agents/$NAME" ]; then
        rm "$DST_FILE"
        log "Removed central agent: ${NAME%.agent.md}"
        UPDATED=$((UPDATED + 1))
      fi
    done
  fi

  # Sync central prompts, instructions, skills stores
  sync_github_dir "$GITHUB_SRC/prompts"      "$CENTRAL_PROMPTS"      "central-prompts"
  sync_github_dir "$GITHUB_SRC/instructions" "$CENTRAL_INSTRUCTIONS" "central-instructions"
  sync_github_dir "$GITHUB_SRC/skills"       "$CENTRAL_SKILLS"       "central-skills"

  # Config files in central store
  for config in copilot-instructions.md copilot-review-instructions.md copilot-commit-message-instructions.md; do
    SRC="$GITHUB_SRC/$config"
    DST="$CENTRAL_ROOT/$config"
    if [ -f "$SRC" ] && [ -f "$DST" ]; then
      if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
        cp "$SRC" "$DST"
        log "Updated Copilot config: $config"
        UPDATED=$((UPDATED + 1))
      fi
    fi
  done

  # Push updated agents, prompts, and instructions to VS Code User profile folders.
  # VS Code 1.110+ discovers from User/prompts/; older from User/ root.
  VSCODE_PROFILES=()
  case "$(uname -s)" in
    Darwin)
      VSCODE_PROFILES=("$HOME/Library/Application Support/Code/User" "$HOME/Library/Application Support/Code - Insiders/User")
      ;;
    Linux)
      VSCODE_PROFILES=("$HOME/.config/Code/User" "$HOME/.config/Code - Insiders/User")
      ;;
    MINGW*|MSYS*|CYGWIN*)
      [ -n "$APPDATA" ] && VSCODE_PROFILES=("$APPDATA/Code/User" "$APPDATA/Code - Insiders/User")
      ;;
  esac
  for PROFILE in "${VSCODE_PROFILES[@]}"; do
    PROMPTS_DIR="$PROFILE/prompts"
    # Only update if agents were previously installed there
    HAS_AGENTS=false
    [ -n "$(ls "$PROFILE"/*.agent.md 2>/dev/null)" ]    && HAS_AGENTS=true
    [ -d "$PROMPTS_DIR" ] && [ -n "$(ls "$PROMPTS_DIR"/*.agent.md 2>/dev/null)" ] && HAS_AGENTS=true
    [ "$HAS_AGENTS" = true ] || continue
    mkdir -p "$PROMPTS_DIR"
    # Update agents in both locations
    [ -d "$CENTRAL" ] && for f in "$CENTRAL"/*.agent.md; do
      [ -f "$f" ] || continue
      cp "$f" "$PROFILE/$(basename "$f")"
      cp "$f" "$PROMPTS_DIR/$(basename "$f")"
    done
    # Update prompts and instructions
    find "$CENTRAL_PROMPTS"      -name "*.prompt.md"      2>/dev/null -exec cp {} "$PROMPTS_DIR/" \; -exec cp {} "$PROFILE/" \;
    find "$CENTRAL_INSTRUCTIONS" -name "*.instructions.md" 2>/dev/null -exec cp {} "$PROMPTS_DIR/" \; -exec cp {} "$PROFILE/" \;
    log "Updated VS Code profile: $PROFILE"
  done
fi

# Save version
echo "$NEW_HASH" > "$VERSION_FILE"

if [ "$UPDATED" -gt 0 ]; then
  log "Update complete ($UPDATED files updated, version $NEW_HASH)."
else
  log "Files already match latest version ($NEW_HASH)."
fi
