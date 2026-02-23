#!/usr/bin/env bash
# session-summary.sh
# Stop hook — appends a structured session summary to .github/audit/sessions.log.

set -euo pipefail

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
[ -f "$today_log" ] && actions_logged=$(grep -c "$session" "$today_log" 2>/dev/null || echo 0)

TS="$timestamp" SESSION="$session" REPO="$owner_repo" BRANCH="$branch" \
  ACTIONS="$actions_logged" TODAY_LOG="$today_log" \
  python3 -c "
import json, os
entry = {
  'session_end':    os.environ['TS'],
  'session_id':     os.environ['SESSION'],
  'repository':     os.environ['REPO'],
  'branch':         os.environ['BRANCH'],
  'actions_logged': int(os.environ['ACTIONS']),
  'audit_log':      os.environ['TODAY_LOG'],
}
print(json.dumps(entry))
" >> "$log_file" 2>/dev/null || true

echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop"}}'
exit 0
