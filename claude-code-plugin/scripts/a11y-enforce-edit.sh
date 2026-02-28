#!/bin/bash
# Accessibility Agents - PreToolUse enforcement hook
# ACTUALLY BLOCKS Edit/Write to UI files until accessibility-lead is consulted.
#
# How it works:
# 1. Checks if the target file is a UI file (.jsx, .tsx, .vue, .css, etc.)
# 2. If yes, checks for a session marker that proves accessibility-lead was used
# 3. If no marker, DENIES the tool call — Claude cannot proceed
# 4. The marker is created by a11y-mark-reviewed.sh (PostToolUse on Agent tool)
#
# Installed by: accessibility-agents install.sh

INPUT=$(cat)

# Extract file path and session ID
eval "$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print('FILE_PATH=' + repr(ti.get('file_path', '')))
print('SESSION_ID=' + repr(data.get('session_id', '')))
" 2>/dev/null || echo "FILE_PATH=''; SESSION_ID=''")"

# No file path = not a file operation, allow
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# ── Check if this is a UI file ──
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

# Not a UI file — allow silently
if [ "$IS_UI" = false ]; then
  exit 0
fi

# ── Check for session marker ──
# Marker is created by a11y-mark-reviewed.sh when accessibility-lead completes
MARKER="/tmp/a11y-reviewed-${SESSION_ID}"

if [ -n "$SESSION_ID" ] && [ -f "$MARKER" ]; then
  # Accessibility review was done this session — allow
  exit 0
fi

# ── DENY the edit ──
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
