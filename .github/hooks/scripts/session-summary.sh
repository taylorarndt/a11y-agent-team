#!/usr/bin/env bash
# session-summary.sh
# Stop hook — appends a structured session summary to .github/audit/sessions.log.
# NOTE: Do NOT use set -euo pipefail here — grep/python3 failures would cause
# premature script termination and no JSON output to the hook runner.

input_json=$(cat)

# Don't loop if we're already in a stop hook continuation
stop_active=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(str(d.get('stop_hook_active',False)).lower())" 2>/dev/null || echo "false")
if [ "$stop_active" = "true" ]; then
  echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop"}}'
  exit 0
fi

session=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sessionId','unknown'))" 2>/dev/null || echo "unknown")

today=$(date +%Y-%m-%d)
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
audit_dir=".github/audit"
log_file="${audit_dir}/sessions.log"
today_log="${audit_dir}/${today}.log"

mkdir -p "$audit_dir"

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
remote=$(git remote get-url origin 2>/dev/null || echo "unknown")
owner_repo=$(echo "$remote" | sed -E 's|.*github\.com[:/](.+?)(\.git)?$|\1|' 2>/dev/null || echo "unknown")

actions_logged=0
[ -f "$today_log" ] && actions_logged=$(grep -cF "$session" "$today_log" 2>/dev/null || echo 0)

ENTRY_TS="$timestamp" ENTRY_SESSION="$session" ENTRY_REPO="$owner_repo" \
  ENTRY_BRANCH="$branch" ENTRY_ACTIONS="$actions_logged" ENTRY_LOG="$today_log" \
  python3 - << 'PYEOF' >> "$log_file" 2>/dev/null || true
import json, os
entry = {
  'session_end':    os.environ.get('ENTRY_TS', ''),
  'session_id':     os.environ.get('ENTRY_SESSION', ''),
  'repository':     os.environ.get('ENTRY_REPO', ''),
  'branch':         os.environ.get('ENTRY_BRANCH', ''),
  'actions_logged': int(os.environ.get('ENTRY_ACTIONS', '0') or '0'),
  'audit_log':      os.environ.get('ENTRY_LOG', ''),
}
print(json.dumps(entry))
PYEOF

echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop"}}'
exit 0
