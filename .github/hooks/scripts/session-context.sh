#!/usr/bin/env bash
# session-context.sh
# SessionStart hook — injects live workspace/org context into every new agent session.

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

# ─── Detect active accessibility scan configs ──────────────────────────────
a11y_configs=""
[ -f ".a11y-web-config.json" ]    && a11y_configs="${a11y_configs}  .a11y-web-config.json (web scan active)\n"
[ -f ".a11y-office-config.json" ] && a11y_configs="${a11y_configs}  .a11y-office-config.json (Office doc scan active)\n"
[ -f ".a11y-pdf-config.json" ]    && a11y_configs="${a11y_configs}  .a11y-pdf-config.json (PDF scan active)\n"
[ -z "$a11y_configs" ] && a11y_configs="  None (run VS Code tasks 'A11y: Init' to create one)\n"

# ─── Detect previous audit reports ─────────────────────────────────────────
audit_reports=""
latest_web=$(ls WEB-ACCESSIBILITY-AUDIT*.md 2>/dev/null | sort | tail -1)
[ -n "$latest_web" ] && audit_reports="${audit_reports}  Last web audit:      ${latest_web}\n"
latest_doc=$(ls DOCUMENT-ACCESSIBILITY-AUDIT*.md 2>/dev/null | sort | tail -1)
[ -n "$latest_doc" ] && audit_reports="${audit_reports}  Last document audit: ${latest_doc}\n"
[ -z "$audit_reports" ] && audit_reports="  No previous audit reports found in workspace root.\n"

context="[SESSION CONTEXT — injected automatically by .github/hooks/context.json]
Date: ${today} at ${time_now}
Repository: ${owner_repo} (branch: ${branch})
Git user: ${git_user} <${git_email}>
Agents: ${agent_count} agents, ${prompt_count} prompts loaded from .github/
Actions logged today: ${actions_today}

── Web Accessibility Agents ──────────────────────────────────────────────────
  @accessibility-lead (orchestrator — coordinates all web a11y specialists)
  @aria-specialist, @keyboard-navigator, @modal-specialist, @contrast-master
  @forms-specialist, @live-region-controller, @alt-text-headings
  @tables-data-specialist, @link-checker, @testing-coach, @wcag-guide
  @accessibility-wizard (full guided audit), @web-issue-fixer (automated fixes)
  Sub-agents: @cross-page-analyzer

── Document Accessibility Agents ─────────────────────────────────────────────
  @document-accessibility-wizard (orchestrator — Word, Excel, PowerPoint, PDF)
  @word-accessibility, @excel-accessibility, @powerpoint-accessibility, @pdf-accessibility
  Sub-agents: @document-inventory, @cross-document-analyzer

── GitHub Workflow Agents ────────────────────────────────────────────────────
  @github-hub (orchestrator — confirms before routing to sub-agents)
  @repo-admin, @team-manager, @contributions-hub, @template-builder
  @issue-tracker, @pr-review, @analytics, @daily-briefing, @insiders-a11y-tracker

── Active scan configs ────────────────────────────────────────────────────────
$(printf '%b' "$a11y_configs")
── Previous audit reports ────────────────────────────────────────────────────
$(printf '%b' "$audit_reports")
All destructive GitHub operations require explicit confirmation via safety hook."

# Escape for JSON
context_escaped=$(printf '%s' "$context" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
if [ -z "$context_escaped" ]; then
  echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"SessionStart"}}'
  exit 0
fi

printf '{"continue":true,"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$context_escaped"
exit 0
