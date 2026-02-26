#!/bin/bash
# A11y Agent Team - PreToolUse enforcement hook
# Blocks Edit/Write on UI files unless accessibility-lead has been called.
#
# How it works:
# 1. Reads the file path from the tool input JSON on stdin
# 2. Checks if it's a UI file (.html, .jsx, .tsx, .vue, .svelte, .astro, .css)
# 3. Checks if accessibility-lead has already run this session (via marker file)
# 4. If UI file + no agent yet → blocks the edit (exit 2)
# 5. If not a UI file or agent already ran → allows (exit 0)

INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

# If no file path found, allow
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Check if it's a UI file
case "$FILE_PATH" in
  *.html|*.htm|*.jsx|*.tsx|*.vue|*.svelte|*.astro)
    IS_UI=true
    ;;
  *.css|*.scss|*.less)
    IS_UI=true
    ;;
  *)
    IS_UI=false
    ;;
esac

# Not a UI file — allow
if [ "$IS_UI" = false ]; then
  exit 0
fi

# Check session marker — has accessibility-lead already been called?
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
MARKER_DIR="/tmp/a11y-agent-sessions"
MARKER_FILE="$MARKER_DIR/$SESSION_ID"

if [ -n "$SESSION_ID" ] && [ -f "$MARKER_FILE" ]; then
  # Agent already ran this session — allow
  exit 0
fi

# Block the edit — force Claude to use accessibility-lead first
echo "BLOCKED: You must delegate to the accessibility-lead agent before editing UI files ($FILE_PATH). Use the accessibility-lead agent to review accessibility requirements first, then retry this edit." >&2
exit 2
