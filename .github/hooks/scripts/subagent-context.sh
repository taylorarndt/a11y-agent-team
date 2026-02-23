#!/usr/bin/env bash
# subagent-context.sh
# SubagentStart hook — passes established context to any spawned subagent.

input_json=$(cat)
agent_type=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('agent_type','unknown'))" 2>/dev/null || echo "unknown")

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
today=$(date +%Y-%m-%d)
owner_repo=$(echo "$remote_url" | sed -E 's|.*github\.com[:/](.+?)(\.git)?$|\1|' 2>/dev/null || echo "unknown/unknown")

context="[SUBAGENT CONTEXT — injected by .github/hooks/context.json]
You were spawned as a subagent of type: ${agent_type}
Repository context inherited from parent session: ${owner_repo} (branch: ${branch})
Date: ${today}

Operate within the scope established by the parent agent. Do not re-ask for
information the parent agent already collected (repo name, org name, username).
Report completion clearly so the parent agent can continue orchestration.
Safety hooks are still active — destructive operations require confirmation."

context_escaped=$(printf '%s' "$context" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$context")

printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":%s}}\n' "$context_escaped"
exit 0
