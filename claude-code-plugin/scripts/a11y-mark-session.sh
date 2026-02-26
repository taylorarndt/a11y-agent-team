#!/bin/bash
# A11y Agent Team - SubagentStart hook
# Writes a session marker when accessibility-lead starts,
# so the PreToolUse hook knows the agent has been consulted.
# Also logs all agent activity.

INPUT=$(cat)

AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

# Log all agent activity
LOG_DIR="$HOME/.claude"
mkdir -p "$LOG_DIR"
echo "[AGENT START] $(date '+%Y-%m-%d %H:%M:%S') $AGENT_TYPE" >> "$LOG_DIR/agent-activity.log"

# Mark session when accessibility-lead fires
if [ "$AGENT_TYPE" = "Accessibility Lead" ] && [ -n "$SESSION_ID" ]; then
  mkdir -p /tmp/a11y-agent-sessions
  echo "$AGENT_TYPE" > "/tmp/a11y-agent-sessions/$SESSION_ID"
fi

exit 0
