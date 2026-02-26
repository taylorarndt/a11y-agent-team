#!/bin/bash
# A11y Agent Team - SubagentStop hook
# Logs agent completions.

INPUT=$(cat)

AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty' 2>/dev/null)

LOG_DIR="$HOME/.claude"
mkdir -p "$LOG_DIR"
echo "[AGENT STOP]  $(date '+%Y-%m-%d %H:%M:%S') $AGENT_TYPE" >> "$LOG_DIR/agent-activity.log"

exit 0
