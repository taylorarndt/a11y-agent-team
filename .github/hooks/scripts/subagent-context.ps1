#!/usr/bin/env pwsh
# subagent-context.ps1
# SubagentStart hook — injects scope-specific context into spawned subagents.

$input_json = $input | Out-String
try {
    $payload = $input_json | ConvertFrom-Json
} catch {
    @{ continue = $true } | ConvertTo-Json -Compress
    exit 0
}

$agent_type = $payload.agent_type ?? "unknown"
$branch     = (git rev-parse --abbrev-ref HEAD 2>$null) ?? "unknown"
$remote_url = (git remote get-url origin 2>$null) ?? ""
$today      = Get-Date -Format "yyyy-MM-dd"

$owner_repo = "unknown/unknown"
if ($remote_url -match "github\.com[:/](.+?)(?:\.git)?$") {
    $owner_repo = $Matches[1]
}

# ─── Determine scope from agent type ────────────────────────────────────────
$agent_lower = $agent_type.ToLower()

$scope = if ($agent_lower -match 'document|word|excel|powerpoint|pdf|cross.document|document.inventory') {
    "Scope: Document accessibility subagent.`nScan Office/PDF documents against WCAG 2.2 and PDF/UA rules.`nReturn structured findings (rule ID, severity, WCAG criterion, element) for the orchestrator to aggregate.`nUse the document-scanning and accessibility-rules skills to guide your analysis."
} elseif ($agent_lower -match 'web|aria|keyboard|modal|contrast|forms|live.region|alt.text|tables|link|testing|wcag|accessibility|cross.page|issue.fixer') {
    "Scope: Web accessibility subagent.`nEvaluate HTML/CSS/JS/component code against WCAG 2.2 AA standards.`nReference axe-core results alongside manual code review.`nReturn structured findings with WCAG criterion, impact level, element selector, and recommended fix.`nUse the framework-accessibility skill for framework-specific patterns."
} elseif ($agent_lower -match 'repo|team|pr|issue|analytics|briefing|tracker|contributions|template|admin') {
    "Scope: GitHub workflow subagent.`nUse GitHub MCP tools for read operations; escalate all write/delete operations via safety hook confirmation.`nReport completion with structured summaries the orchestrator can relay to the user."
} else {
    "Scope: Operate within the boundaries established by the parent agent."
}

$context = "[SUBAGENT CONTEXT — injected by .github/hooks/context.json]
Subagent type: $agent_type
Parent session: $owner_repo (branch: $branch) | Date: $today

$scope

Do not re-ask for information the parent already collected.
Report completion clearly so the orchestrator can continue.
Safety hooks are active — destructive operations require explicit confirmation."

@{
    continue           = $true
    hookSpecificOutput = @{
        hookEventName     = "SubagentStart"
        additionalContext = $context
    }
} | ConvertTo-Json -Depth 5 -Compress

exit 0
