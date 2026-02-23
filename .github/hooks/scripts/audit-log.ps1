#!/usr/bin/env pwsh
# audit-log.ps1
# PostToolUse hook — appends every successfully completed tool call to a
# date-stamped append-only audit log in .github/audit/YYYY-MM-DD.log
#
# Log format (one JSON line per action):
# {"ts":"2026-02-20T14:32:00Z","session":"abc123","tool":"mcp_github_...","input":{...},"result_summary":"..."}

$input_json = $input | Out-String
try {
    $payload = $input_json | ConvertFrom-Json
} catch {
    @{ continue = $true; hookSpecificOutput = @{ hookEventName = 'PostToolUse' } } | ConvertTo-Json -Compress
    exit 0
}

# ─── Only audit GitHub-touching and terminal tools ────────────────────────────
$audit_tools = @(
    "mcp_github_",        # All GitHub MCP tools
    "run_in_terminal",    # Terminal commands
    "create_file",        # File creation
    "replace_string_in_file",  # File edits
    "multi_replace_string_in_file"
)

$tool = $payload.tool_name ?? ""
$should_audit = $audit_tools | Where-Object { $tool.StartsWith($_) }

if (-not $should_audit) {
    @{ continue = $true; hookSpecificOutput = @{ hookEventName = 'PostToolUse' } } | ConvertTo-Json -Compress
    exit 0
}

# ─── Build log directory and file ─────────────────────────────────────────────
$today     = Get-Date -Format "yyyy-MM-dd"
$audit_dir = ".github/audit"
$log_file  = Join-Path $audit_dir "$today.log"

if (-not (Test-Path $audit_dir)) {
    New-Item -ItemType Directory -Path $audit_dir -Force | Out-Null
}

# ─── Build log entry ──────────────────────────────────────────────────────────
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$session   = $payload.sessionId ?? "unknown"

# Summarize the result without storing full output (can be large)
$result_raw    = $payload.tool_response ?? ""
$result_summary = if ($result_raw.Length -gt 200) {
    $result_raw.Substring(0, 200) + "..."
} else {
    $result_raw
}

# Sanitize input for logging — remove any token-like values
$input_obj = $payload.tool_input
$input_str = ($input_obj | ConvertTo-Json -Compress -Depth 5) ?? "{}"
# Redact anything that looks like a token/secret
$input_str = $input_str -replace '(ghp_|gho_|github_pat_)[A-Za-z0-9_]+', '[REDACTED_TOKEN]'
$input_str = $input_str -replace '"password"\s*:\s*"[^"]+"', '"password":"[REDACTED]"'
$input_str = $input_str -replace '"token"\s*:\s*"[^"]+"', '"token":"[REDACTED]"'
$input_str = $input_str -replace '"secret"\s*:\s*"[^"]+"', '"secret":"[REDACTED]"'

$log_entry = [PSCustomObject]@{
    ts             = $timestamp
    session        = $session
    tool           = $tool
    input          = $input_str
    result_summary = $result_summary -replace '"', "'"
} | ConvertTo-Json -Compress

# Append to log file
Add-Content -Path $log_file -Value $log_entry -Encoding UTF8

# ─── Return context to agent about what was logged ───────────────────────────
@{
    continue = $true
    hookSpecificOutput = @{
        hookEventName    = "PostToolUse"
        additionalContext = "Audit logged: $tool at $timestamp → $log_file"
    }
} | ConvertTo-Json -Depth 5 -Compress

exit 0
