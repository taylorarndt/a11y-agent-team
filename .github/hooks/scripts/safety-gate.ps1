#!/usr/bin/env pwsh
# safety-gate.ps1
# PreToolUse hook — blocks or escalates destructive GitHub operations.
# Reads JSON from stdin, outputs JSON decision to stdout.

$input_json = $input | Out-String
try {
    $payload = $input_json | ConvertFrom-Json
} catch {
    # If we can't parse, allow through — don't block on hook failure
    @{ continue = $true; hookSpecificOutput = @{ hookEventName = "PreToolUse" } } | ConvertTo-Json -Depth 3 -Compress
    exit 0
}

$tool = $payload.tool_name
$tool_input = $payload.tool_input | ConvertTo-Json -Depth 10

# ─── Destructive patterns that require explicit user confirmation ────────────
$deny_patterns = @(
    # GitHub repo-level destructive actions
    @{ tool = "mcp_github_github_delete_repository";       reason = "Deleting a repository is irreversible." },
    @{ tool = "mcp_github_github_delete_branch";           reason = "Branch deletion cannot be undone." },
    @{ tool = "mcp_github_github_merge_pull_request";      reason = "Merging a PR modifies the base branch permanently." }
)

$ask_patterns = @(
    # Force-push / hard reset patterns (look for these in tool input)
    @{ tool = "run_in_terminal";    match = "--force";        reason = "Force-push detected. This rewrites history on the remote." },
    @{ tool = "run_in_terminal";    match = "reset --hard";   reason = "Hard reset detected. Uncommitted changes will be lost." },
    @{ tool = "run_in_terminal";    match = "rm -rf";         reason = "Recursive delete detected." },
    @{ tool = "run_in_terminal";    match = "DROP TABLE";     reason = "SQL DROP TABLE detected." },
    @{ tool = "run_in_terminal";    match = "DROP DATABASE";  reason = "SQL DROP DATABASE detected." },
    # Removing a team member from an org
    @{ tool = "mcp_github_github_remove_team_member";      match = $null; reason = "Removing a team member affects their access immediately." },
    # Archiving a repo
    @{ tool = "mcp_github_github_update_repository";       match = '"archived":true'; reason = "Archiving a repository makes it read-only." }
)

# ─── Check deny list ─────────────────────────────────────────────────────────
foreach ($pattern in $deny_patterns) {
    if ($tool -eq $pattern.tool) {
        @{
            continue = $false
            hookSpecificOutput = @{
                hookEventName        = "PreToolUse"
                permissionDecision   = "deny"
                permissionDecisionReason = $pattern.reason
                additionalContext    = "SAFETY HOOK: This operation was blocked by .github/hooks/safety.json. To proceed, confirm explicitly: 'I confirm I want to $tool — I understand this is irreversible.'"
            }
        } | ConvertTo-Json -Depth 5 -Compress
        exit 2
    }
}

# ─── Check ask list ──────────────────────────────────────────────────────────
foreach ($pattern in $ask_patterns) {
    $tool_matches = ($tool -eq $pattern.tool)
    $content_matches = ($null -eq $pattern.match) -or ($tool_input -match [regex]::Escape($pattern.match))

    if ($tool_matches -and $content_matches) {
        @{
            continue = $true
            hookSpecificOutput = @{
                hookEventName        = "PreToolUse"
                permissionDecision   = "ask"
                permissionDecisionReason = $pattern.reason
                additionalContext    = "SAFETY HOOK: Pausing for confirmation. $($pattern.reason) Please confirm intent before proceeding."
            }
        } | ConvertTo-Json -Depth 5 -Compress
        exit 0
    }
}

# ─── Safe — allow through ────────────────────────────────────────────────────
@{ continue = $true; hookSpecificOutput = @{ hookEventName = "PreToolUse" } } | ConvertTo-Json -Depth 3 -Compress
exit 0
