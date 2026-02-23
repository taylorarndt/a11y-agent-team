#!/usr/bin/env bash
# session-summary.sh
# Stop hook — appends a structured session summary to .github/audit/sessions.log.
# NOTE: Do NOT use set -euo pipefail here — grep returning exit 1 on no-match
# would cause premature script termination under set -e.

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

python3 -c "
import json
entry = {
  'session_end': '${timestamp}',
  'session_id': '${session}',
  'repository': '${owner_repo}',
  'branch': '${branch}',
  'actions_logged': ${actions_logged},
  'audit_log': '${today_log}'
}
print(json.dumps(entry))
" >> "$log_file" 2>/dev/null || true

echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"Stop"}}'
exit 0
