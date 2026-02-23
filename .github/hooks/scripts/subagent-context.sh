#!/usr/bin/env bash
# subagent-context.sh
# SubagentStart hook — injects scope-specific context into spawned subagents.

input_json=$(cat)
agent_type=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('agent_type','unknown'))" 2>/dev/null || echo "unknown")

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
today=$(date +%Y-%m-%d)
owner_repo=$(echo "$remote_url" | sed -E 's|.*github\.com[:/](.+?)(\.git)?$|\1|' 2>/dev/null || echo "unknown/unknown")

# ─── Determine subagent scope from its type ───────────────────────────────────
agent_lower=$(echo "$agent_type" | tr '[:upper:]' '[:lower:]')

if echo "$agent_lower" | grep -qiE '(document|word|excel|powerpoint|pdf|cross.document|document.inventory)'; then
  scope="Scope: Document accessibility subagent.
Scan Office/PDF documents against WCAG 2.2 and PDF/UA rules.
Return structured findings (rule ID, severity, WCAG criterion, element) for the orchestrator to aggregate.
Use the document-scanning and accessibility-rules skills to guide your analysis."
elif echo "$agent_lower" | grep -qiE '(web|aria|keyboard|modal|contrast|forms|live.region|alt.text|tables|link|testing|wcag|accessibility|cross.page|issue.fixer)'; then
  scope="Scope: Web accessibility subagent.
Evaluate HTML/CSS/JS/component code against WCAG 2.2 AA standards.
Reference axe-core results alongside manual code review.
Return structured findings with WCAG criterion, impact level, element selector, and recommended fix.
Use the framework-accessibility skill for framework-specific patterns."
elif echo "$agent_lower" | grep -qiE '(repo|team|pr|issue|analytics|briefing|tracker|contributions|template|admin)'; then
  scope="Scope: GitHub workflow subagent.
Use GitHub MCP tools for read operations; escalate all write/delete operations via safety hook confirmation.
Report completion with structured summaries the orchestrator can relay to the user."
else
  scope="Scope: Operate within the boundaries established by the parent agent."
fi

context="[SUBAGENT CONTEXT — injected by .github/hooks/context.json]
Subagent type: ${agent_type}
Parent session: ${owner_repo} (branch: ${branch}) | Date: ${today}

${scope}

Do not re-ask for information the parent already collected.
Report completion clearly so the orchestrator can continue.
Safety hooks are active — destructive operations require explicit confirmation."

context_escaped=$(printf '%s' "$context" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
if [ -z "$context_escaped" ]; then
  echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"SubagentStart"}}'
  exit 0
fi

printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":%s}}\n' "$context_escaped"
exit 0
