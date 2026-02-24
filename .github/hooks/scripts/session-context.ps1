#!/usr/bin/env pwsh
# session-context.ps1
# SessionStart hook — injects live workspace/org context into every new agent session.

$input_json = $input | Out-String

# ─── Gather git context ───────────────────────────────────────────────────────
$branch      = if ($null -eq (git rev-parse --abbrev-ref HEAD 2>$null)) { "unknown" } else { git rev-parse --abbrev-ref HEAD 2>$null }
$remote_url  = if ($null -eq (git remote get-url origin 2>$null)) { "unknown" } else { git remote get-url origin 2>$null }
$git_user    = if ($null -eq (git config user.name 2>$null)) { "unknown" } else { git config user.name 2>$null }
$git_email   = if ($null -eq (git config user.email 2>$null)) { "unknown" } else { git config user.email 2>$null }
$today       = Get-Date -Format "yyyy-MM-dd"
$time        = Get-Date -Format "HH:mm"

# Parse GitHub owner/repo from remote URL
$owner_repo = "unknown/unknown"
if ($remote_url -match "github\.com[:/](.+?)(?:\.git)?$") {
    $owner_repo = $Matches[1]
}

# Count agent/prompt files for quick inventory
$agent_count  = (Get-ChildItem ".github/agents/*.agent.md" -ErrorAction SilentlyContinue | Measure-Object).Count
$prompt_count = (Get-ChildItem ".github/prompts/*.prompt.md" -ErrorAction SilentlyContinue | Measure-Object).Count

# Count recent audit entries (today's actions)
$audit_dir    = ".github/audit"
$audit_today  = Join-Path $audit_dir "$today.log"
$actions_today = 0
if (Test-Path $audit_today) {
    $actions_today = (Get-Content $audit_today | Measure-Object -Line).Lines
}

# ─── Detect active accessibility scan configs ─────────────────────────────────
$a11y_configs = @()
if (Test-Path ".a11y-web-config.json")    { $a11y_configs += "  .a11y-web-config.json (web scan active)" }
if (Test-Path ".a11y-office-config.json") { $a11y_configs += "  .a11y-office-config.json (Office doc scan active)" }
if (Test-Path ".a11y-pdf-config.json")    { $a11y_configs += "  .a11y-pdf-config.json (PDF scan active)" }
if ($a11y_configs.Count -eq 0) { $a11y_configs = @("  None (run VS Code tasks 'A11y: Init' to create one)") }
$a11y_config_text = $a11y_configs -join "`n"

# ─── Detect previous audit reports ───────────────────────────────────────────
$audit_reports = @()
$latest_web = Get-ChildItem "WEB-ACCESSIBILITY-AUDIT*.md" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
if ($latest_web) { $audit_reports += "  Last web audit:      $($latest_web.Name)" }
$latest_doc = Get-ChildItem "DOCUMENT-ACCESSIBILITY-AUDIT*.md" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
if ($latest_doc) { $audit_reports += "  Last document audit: $($latest_doc.Name)" }
$latest_md = Get-ChildItem "MARKDOWN-ACCESSIBILITY-AUDIT*.md" -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
if ($latest_md) { $audit_reports += "  Last markdown audit: $($latest_md.Name)" }
if ($audit_reports.Count -eq 0) { $audit_reports = @("  No previous audit reports found in workspace root.") }
$audit_report_text = $audit_reports -join "`n"

# ─── Build context string ─────────────────────────────────────────────────────
$context = "[SESSION CONTEXT — injected automatically by .github/hooks/context.json]
Date: $today at $time
Repository: $owner_repo (branch: $branch)
Git user: $git_user <$git_email>
Agents: $agent_count agents, $prompt_count prompts loaded from .github/
Actions logged today: $actions_today

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

── Markdown Accessibility Agents ─────────────────────────────────────────────
  @markdown-a11y-assistant (orchestrator — links, alt text, headings, tables, emoji, diagrams)
  Sub-agents: @markdown-scanner (per-file scanning), @markdown-fixer (fix application)

── GitHub Workflow Agents ────────────────────────────────────────────────────
  @github-hub (orchestrator — confirms before routing to sub-agents)
  @repo-admin, @team-manager, @contributions-hub, @template-builder
  @issue-tracker, @pr-review, @analytics, @daily-briefing, @insiders-a11y-tracker

── Active scan configs ────────────────────────────────────────────────────────
$a11y_config_text

── Previous audit reports ────────────────────────────────────────────────────
$audit_report_text

All destructive GitHub operations require explicit confirmation via safety hook."

@{
    continue           = $true
    hookSpecificOutput = @{
        hookEventName     = "SessionStart"
        additionalContext = $context
    }
} | ConvertTo-Json -Depth 5 -Compress

exit 0
