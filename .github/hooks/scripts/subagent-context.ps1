#!/usr/bin/env pwsh
# subagent-context.ps1
# SubagentStart hook — passes established context from the parent session
# to any subagent spawned by @nexus, @github-hub, or another orchestrating agent.

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

$context = @"
[SUBAGENT CONTEXT — injected by .github/hooks/context.json]
You were spawned as a subagent of type: $agent_type
Repository context inherited from parent session: $owner_repo (branch: $branch)
Date: $today

Operate within the scope established by the parent agent. Do not re-ask for
information the parent agent already collected (repo name, org name, username).
Report completion clearly so the parent agent can continue orchestration.
Safety hooks are still active — destructive operations require confirmation.
"@

@{
    hookSpecificOutput = @{
        hookEventName     = "SubagentStart"
        additionalContext = $context
    }
} | ConvertTo-Json -Depth 5 -Compress

exit 0
