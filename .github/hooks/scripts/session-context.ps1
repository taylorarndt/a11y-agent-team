#!/usr/bin/env pwsh
# session-context.ps1
# SessionStart hook — injects live workspace/org context into every new agent session.
# Agents start aware of: git remote, current branch, open PRs count, git user.

$input_json = $input | Out-String

# ─── Gather git context ───────────────────────────────────────────────────────
$branch      = (git rev-parse --abbrev-ref HEAD 2>$null) ?? "unknown"
$remote_url  = (git remote get-url origin 2>$null) ?? "unknown"
$git_user    = (git config user.name 2>$null) ?? "unknown"
$git_email   = (git config user.email 2>$null) ?? "unknown"
$today       = Get-Date -Format "yyyy-MM-dd"
$time        = Get-Date -Format "HH:mm"

# Parse GitHub owner/repo from remote URL
$owner_repo = "unknown/unknown"
if ($remote_url -match "github\.com[:/](.+?)(?:\.git)?$") {
    $owner_repo = $Matches[1]
}
$owner = ($owner_repo -split "/")[0]
$repo  = ($owner_repo -split "/")[1]

# Count agent/prompt files for quick inventory
$agent_count  = (Get-ChildItem ".github/agents/*.agent.md" -ErrorAction SilentlyContinue | Measure-Object).Count
$prompt_count = (Get-ChildItem ".github/prompts/*.prompt.md" -ErrorAction SilentlyContinue | Measure-Object).Count

# Count recent audit entries (today's actions)
$audit_dir = ".github/audit"
$audit_today = Join-Path $audit_dir "$today.log"
$actions_today = 0
if (Test-Path $audit_today) {
    $actions_today = (Get-Content $audit_today | Measure-Object -Line).Lines
}

# ─── Build context string ─────────────────────────────────────────────────────
$context = @"
[SESSION CONTEXT — injected automatically by .github/hooks/context.json]
Date: $today at $time
Repository: $owner_repo (branch: $branch)
Git user: $git_user <$git_email>
Agents available: $agent_count agents, $prompt_count prompts in .github/
Actions logged today: $actions_today in .github/audit/$today.log

Available agents: @nexus or @github-hub (orchestrators), @repo-admin, @team-manager,
@contributions-hub, @template-builder, @issue-tracker, @pr-review,
@analytics, @daily-briefing, @insiders-a11y-tracker

Use @nexus (auto-routes to subagents) or @github-hub (confirms before routing) as entry points.
All destructive operations (delete branch, merge PR, remove team member) require
explicit confirmation — a safety hook will pause them automatically.
"@

@{
    continue          = $true
    hookSpecificOutput = @{
        hookEventName    = "SessionStart"
        additionalContext = $context
    }
} | ConvertTo-Json -Depth 5 -Compress

exit 0
