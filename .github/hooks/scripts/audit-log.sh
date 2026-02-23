#!/usr/bin/env bash
# audit-log.sh
# PostToolUse hook — appends every successfully completed tool call to a
# date-stamped append-only audit log in .github/audit/YYYY-MM-DD.log

input_json=$(cat)

tool=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")
session=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sessionId','unknown'))" 2>/dev/null || echo "unknown")
tool_input=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('tool_input',{})))" 2>/dev/null || echo "{}")
tool_response=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); r=str(d.get('tool_response','')); print(r[:200]+'...' if len(r)>200 else r)" 2>/dev/null || echo "")

# Only audit GitHub-touching and terminal tools
case "$tool" in
  mcp_github_*|run_in_terminal|create_file|replace_string_in_file|multi_replace_string_in_file)
    ;;
  *)
    echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"PostToolUse"}}'
    exit 0
    ;;
esac

today=$(date +%Y-%m-%d)
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
audit_dir=".github/audit"
log_file="${audit_dir}/${today}.log"

mkdir -p "$audit_dir"
chmod 700 "$audit_dir" 2>/dev/null || true

# Redact tokens from input
tool_input_safe=$(echo "$tool_input" | sed \
  -e 's/ghp_[A-Za-z0-9_]*/[REDACTED_TOKEN]/g' \
  -e 's/gho_[A-Za-z0-9_]*/[REDACTED_TOKEN]/g' \
  -e 's/github_pat_[A-Za-z0-9_]*/[REDACTED_TOKEN]/g' \
  -e 's/"password":"[^"]*"/"password":"[REDACTED]"/g' \
  -e 's/"token":"[^"]*"/"token":"[REDACTED]"/g' \
  -e 's/"secret":"[^"]*"/"secret":"[REDACTED]"/g')

# Build log entry as a single JSON line
log_entry=$(ENTRY_TS="$timestamp" ENTRY_SESSION="$session" ENTRY_TOOL="$tool" \
  ENTRY_INPUT="$tool_input_safe" ENTRY_RESULT="$tool_response" \
  python3 - << 'PYEOF'
import json, os
try:
  input_val = json.loads(os.environ.get('ENTRY_INPUT', '{}'))
except Exception:
  input_val = {}
entry = {
  'ts':             os.environ.get('ENTRY_TS', ''),
  'session':        os.environ.get('ENTRY_SESSION', ''),
  'tool':           os.environ.get('ENTRY_TOOL', ''),
  'input':          input_val,
  'result_summary': os.environ.get('ENTRY_RESULT', ''),
}
print(json.dumps(entry))
PYEOF
) 2>/dev/null || printf '{"ts":"%s","session":"%s","tool":"%s","note":"log_parse_error"}\n' "$timestamp" "$session" "$tool"

echo "$log_entry" >> "$log_file"
chmod 600 "$log_file" 2>/dev/null || true

ENTRY_TOOL="$tool" ENTRY_TS="$timestamp" ENTRY_LOGFILE="$log_file" \
  python3 - << 'PYEOF' 2>/dev/null || echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"PostToolUse"}}'
import json, os
print(json.dumps({
  'continue': True,
  'hookSpecificOutput': {
    'hookEventName': 'PostToolUse',
    'additionalContext': 'Audit logged: ' + os.environ.get('ENTRY_TOOL','') +
                        ' at ' + os.environ.get('ENTRY_TS','') +
                        ' → ' + os.environ.get('ENTRY_LOGFILE',''),
  }
}))
PYEOF
