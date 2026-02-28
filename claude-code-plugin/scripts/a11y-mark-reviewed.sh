#!/bin/bash
# Accessibility Agents - PostToolUse hook for Agent tool
# Creates a session marker when accessibility-lead has been consulted.
# This marker unlocks the a11y-enforce-edit.sh PreToolUse block.
#
# Installed by: accessibility-agents install.sh

INPUT=$(cat)

# Extract session ID and check if this was an accessibility-lead agent call
eval "$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
# Agent tool uses 'subagent_type' parameter
subagent = ti.get('subagent_type', '')
session_id = data.get('session_id', '')
print('SUBAGENT=' + repr(subagent))
print('SESSION_ID=' + repr(session_id))
" 2>/dev/null || echo "SUBAGENT=''; SESSION_ID=''")"

# If this was an accessibility-lead agent call, create the marker
if [ -n "$SESSION_ID" ]; then
  case "$SUBAGENT" in
    *accessibility-lead*|*accessibility-agents:accessibility-lead*)
      touch "/tmp/a11y-reviewed-${SESSION_ID}"
      ;;
  esac
fi

exit 0
