#!/usr/bin/env bash
# safety-gate.sh
# PreToolUse hook — blocks or escalates destructive GitHub operations.
# Reads JSON from stdin, outputs JSON decision to stdout.
# NOTE: Do NOT use set -euo pipefail here — grep returns exit 1 on no-match,
# which would cause premature script termination under set -e.

input_json=$(cat)
tool=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")
tool_input=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('tool_input','')))" 2>/dev/null || echo "{}")

# If we can't parse, allow through
if [ -z "$tool" ]; then
  echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"PreToolUse"}}'
  exit 0
fi

# ─── Helper ──────────────────────────────────────────────────────────────────
deny() {
  local reason="$1"
  printf '{"continue":false,"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s","additionalContext":"SAFETY HOOK: This operation was blocked by .github/hooks/safety.json. Confirm explicitly to proceed."}}\n' "$reason"
  exit 2
}

ask() {
  local reason="$1"
  printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s","additionalContext":"SAFETY HOOK: Pausing for confirmation. %s"}}\n' "$reason" "$reason"
  exit 0
}

# ─── Deny list ───────────────────────────────────────────────────────────────
[ "$tool" = "mcp_github_github_delete_repository" ] && deny "Deleting a repository is irreversible."
[ "$tool" = "mcp_github_github_delete_branch" ]     && deny "Branch deletion cannot be undone."
[ "$tool" = "mcp_github_github_merge_pull_request" ] && deny "Merging a PR modifies the base branch permanently."

# ─── Ask list ────────────────────────────────────────────────────────────────
if [ "$tool" = "run_in_terminal" ]; then
  echo "$tool_input" | grep -q -- "--force"      && ask "Force-push detected. This rewrites history on the remote."
  echo "$tool_input" | grep -q "reset --hard"    && ask "Hard reset detected. Uncommitted changes will be lost."
  echo "$tool_input" | grep -q "rm -rf"          && ask "Recursive delete detected."
  echo "$tool_input" | grep -qi "DROP TABLE"     && ask "SQL DROP TABLE detected."
  echo "$tool_input" | grep -qi "DROP DATABASE"  && ask "SQL DROP DATABASE detected."
fi

[ "$tool" = "mcp_github_github_remove_team_member" ] && ask "Removing a team member affects their access immediately."

if [ "$tool" = "mcp_github_github_update_repository" ]; then
  echo "$tool_input" | grep -q '"archived":true' && ask "Archiving a repository makes it read-only."
fi

# ─── Safe — allow through ────────────────────────────────────────────────────
echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"PreToolUse"}}'
exit 0
