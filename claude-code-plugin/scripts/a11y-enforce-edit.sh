#!/bin/bash
set -euo pipefail
# Accessibility Agents - PreToolUse enforcement hook
# ACTUALLY BLOCKS Edit/Write to UI files until accessibility-lead is consulted.
#
# How it works:
# 1. Checks if the target file is in a restricted UI directory (src, app, etc.)
# 2. If yes, checks if it is a UI file (.jsx, .tsx, .vue, .css, etc.)
# 3. If both, checks for a session marker that proves accessibility-lead was used
# 4. If no marker, DENIES the tool call -- Claude cannot proceed
# 5. The marker is created by a11y-mark-reviewed.sh (PostToolUse on Agent tool)
#
# Installed by: accessibility-agents install.sh

INPUT=$(cat)

# Require python3 before attempting JSON parsing.
# In non-interactive shells (hook context), pyenv shims may not be on PATH.
# A missing python3 would silently fall through to the allow path without this guard.
if ! command -v python3 >/dev/null 2>&1; then
  printf 'a11y-enforce-edit: python3 not found in PATH; cannot parse hook input\n' >&2
  exit 2
fi

# Extract file path and session ID.
# shlex.quote() is used instead of repr(). repr() switches to double-quote mode
# when a string contains a single quote, which allows $() and backtick expansion
# inside the eval. shlex.quote() ALWAYS produces single-quoted output, making
# eval safe regardless of path content.
# stderr is captured separately so python3 failures (malformed JSON, empty stdin,
# import error) cause exit 2, which is the Claude Code framework mechanism for
# blocking with an error message. Falling back to empty vars would silently
# disable enforcement.
_PARSE_ERR=$(mktemp)
_PARSE_OUT=$(echo "$INPUT" | python3 -c "
import sys, json, shlex
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print('FILE_PATH=' + shlex.quote(ti.get('file_path', '')))
print('SESSION_ID=' + shlex.quote(data.get('session_id', '')))
" 2>"$_PARSE_ERR") || {
  printf 'a11y-enforce-edit: python3 failed to parse hook input (exit %s): %s\n' \
    "$?" "$(cat "$_PARSE_ERR")" >&2
  rm -f "$_PARSE_ERR"
  exit 2
}
rm -f "$_PARSE_ERR"
eval "$_PARSE_OUT"

# No file path = not a file operation, allow
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# -- Resolve symlinks to prevent bypass attacks --
# A symlink like /tmp/evil.jsx -> src/button.jsx would bypass the
# directory check if we operate on the raw path. Resolve to the
# filesystem reality first. If realpath fails (file doesn't exist yet,
# which is normal for Write tool creating new files), keep original path.
if _RESOLVED_PATH=$(realpath "$FILE_PATH" 2>/dev/null); then
  FILE_PATH="$_RESOLVED_PATH"
fi

# -- Check if file is in a restricted UI directory --
# Only files inside restricted dirs require accessibility review.
# Files outside these dirs (temp, build, deps) are allowed without review.
case "$FILE_PATH" in
  */src/*|src/*|*/app/*|app/*|*/public/*|public/*) ;;
  */pages/*|pages/*|*/views/*|views/*|*/layouts/*|layouts/*|*/templates/*|templates/*|*/components/*|components/*) ;;
  */styles/*|styles/*|*/assets/*|assets/*) ;;
  */test/*|test/*|*/tests/*|tests/*|*/spec/*|spec/*) ;;
  *) exit 0 ;;  # Not a restricted UI dir -- allow silently
esac

# -- Check if this is a UI file --
IS_UI=false
case "$FILE_PATH" in
  *.jsx|*.tsx|*.vue|*.svelte|*.astro|*.html|*.ejs|*.hbs|*.leaf|*.erb|*.jinja|*.twig|*.blade.php)
    IS_UI=true
    ;;
  *.css|*.scss|*.less|*.sass)
    IS_UI=true
    ;;
esac

# Also catch .ts/.js files in UI directories
if [ "$IS_UI" = false ]; then
  case "$FILE_PATH" in
    */components/*|*/pages/*|*/views/*|*/layouts/*|*/templates/*)
      case "$FILE_PATH" in
        *.ts|*.js) IS_UI=true ;;
      esac
      ;;
  esac
fi

# Not a UI file -- allow silently
if [ "$IS_UI" = false ]; then
  exit 0
fi

# -- Check for session marker --
# Marker is created by a11y-mark-reviewed.sh when accessibility-lead completes.
# Note: The marker file is trivially creatable by AI with Bash access (can run
# `touch /tmp/a11y-reviewed-<session_id>`). This is a guardrail against accidental
# edits, not a cryptographic barrier -- cannot be secured without framework support.
# Note: The marker has no expiry. After one accessibility-lead consultation, all
# subsequent UI file edits are allowed for the remainder of the session.
MARKER="/tmp/a11y-reviewed-${SESSION_ID}"

if [ -n "$SESSION_ID" ] && [ -f "$MARKER" ]; then
  # Accessibility review was done this session -- allow
  exit 0
fi

# -- DENY the edit --
BASENAME=$(basename "$FILE_PATH")
BASENAME="$BASENAME" python3 << 'PYTHON_SCRIPT'
import json, os
basename = os.environ.get('BASENAME', '')
reason = f"BLOCKED: Cannot edit UI file '{basename}' without accessibility review. You MUST first delegate to accessibility-agents:accessibility-lead using the Agent tool (subagent_type: 'accessibility-agents:accessibility-lead'). After the accessibility review completes, this file will be unblocked automatically."
output = {
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": reason
  }
}
print(json.dumps(output))
PYTHON_SCRIPT
exit 0
