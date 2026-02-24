#!/usr/bin/env pwsh
# session-summary.ps1
# Stop hook — appends a structured session summary to .github/audit/sessions.log
# before the agent session ends. Does NOT block the agent from stopping.

$input_json = $input | Out-String
try {
    $payload = $input_json | ConvertFrom-Json
} catch {
    @{ continue = $true } | ConvertTo-Json -Compress
    exit 0
}

# Don't trigger a loop if we're already in a stop hook continuation
if ($payload.stop_hook_active -eq $true) {
    @{ continue = $true } | ConvertTo-Json -Compress
    exit 0
}

$today      = Get-Date -Format "yyyy-MM-dd"
$timestamp  = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$session    = if ($null -eq $payload.sessionId) { "unknown" } else { $payload.sessionId }
$audit_dir  = ".github/audit"
$log_file   = Join-Path $audit_dir "sessions.log"
$today_log  = Join-Path $audit_dir "$today.log"

if (-not (Test-Path $audit_dir)) {
    New-Item -ItemType Directory -Path $audit_dir -Force | Out-Null
}

# Count actions taken this session from today's audit log
$session_actions = 0
if (Test-Path $today_log) {
    $session_actions = (Get-Content $today_log | Where-Object { $_ -match [regex]::Escape($session) } | Measure-Object).Count
}

$branch    = if ($null -eq (git rev-parse --abbrev-ref HEAD 2>$null)) { "unknown" } else { git rev-parse --abbrev-ref HEAD 2>$null }
$remote    = if ($null -eq (git remote get-url origin 2>$null)) { "unknown" } else { git remote get-url origin 2>$null }
$owner_repo = "unknown"
if ($remote -match "github\.com[:/](.+?)(?:\.git)?$") {
    $owner_repo = $Matches[1]
}

$summary_entry = [PSCustomObject]@{
    session_end    = $timestamp
    session_id     = $session
    repository     = $owner_repo
    branch         = $branch
    actions_logged = $session_actions
    audit_log      = $today_log
} | ConvertTo-Json -Compress

Add-Content -Path $log_file -Value $summary_entry -Encoding UTF8

# Allow session to end normally
@{ continue = $true } | ConvertTo-Json -Compress
exit 0
