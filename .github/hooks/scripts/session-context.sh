#!/usr/bin/env bash
# session-context.sh
# SessionStart hook — injects live workspace/org context into every new agent session.

set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
remote_url=$(git remote get-url origin 2>/dev/null || echo "unknown")
git_user=$(git config user.name 2>/dev/null || echo "unknown")
git_email=$(git config user.email 2>/dev/null || echo "unknown")
today=$(date +%Y-%m-%d)
time_now=$(date +%H:%M)

# Parse GitHub owner/repo
owner_repo=$(echo "$remote_url" | sed -E 's|.*github\.com[:/](.+?)(\.git)?$|\1|' 2>/dev/null || echo "unknown/unknown")

# Count agent/prompt files
agent_count=$(ls .github/agents/*.agent.md 2>/dev/null | wc -l | tr -d ' ')
prompt_count=$(ls .github/prompts/*.prompt.md 2>/dev/null | wc -l | tr -d ' ')

# Count today's audit entries
audit_file=".github/audit/${today}.log"
actions_today=0
[ -f "$audit_file" ] && actions_today=$(wc -l < "$audit_file")

context="[SESSION CONTEXT — injected automatically by .github/hooks/context.json]
Date: ${today} at ${time_now}
Repository: ${owner_repo} (branch: ${branch})
Git user: ${git_user} <${git_email}>
Agents available: ${agent_count} agents, ${prompt_count} prompts in .github/
Actions logged today: ${actions_today} in .github/audit/${today}.log

Available agents: @nexus or @github-hub (orchestrators), @repo-admin, @team-manager,
@contributions-hub, @template-builder, @issue-tracker, @pr-review,
@analytics, @daily-briefing, @insiders-a11y-tracker

Use @nexus (auto-routes to subagents) or @github-hub (confirms before routing) as entry points.
All destructive operations require explicit confirmation via safety hook."

# Escape for JSON
context_escaped=$(printf '%s' "$context" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$context")

printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$context_escaped"
exit 0
