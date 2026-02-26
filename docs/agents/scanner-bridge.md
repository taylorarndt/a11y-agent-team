# scanner-bridge - CI Scanner Data Bridge

> Hidden helper agent that bridges GitHub Accessibility Scanner CI data into the agent ecosystem. Fetches scanner-created issues, normalizes findings, deduplicates against local scans, and tracks Copilot fix status.

## When to Use It

You do not invoke this agent directly. It is called automatically by:

- **web-accessibility-wizard** -- during Phase 0 (auto-detection) and Phase 9 (correlation)
- **insiders-a11y-tracker** -- when discovering CI scanner issues
- **daily-briefing** -- when collecting accessibility updates

## What It Does

1. **Detects scanner configuration** -- Reads `.github/workflows/` to find `github/accessibility-scanner` usage and parse configured URLs
2. **Fetches scanner issues** -- Searches GitHub for issues created by `author:app/github-actions` with accessibility labels
3. **Normalizes findings** -- Maps scanner severity to the standard model (Critical/Serious/Moderate/Minor)
4. **Deduplicates** -- Correlates scanner findings with local axe-core results to avoid double-counting
5. **Tracks Copilot fixes** -- Monitors whether scanner issues are assigned to Copilot and whether fix PRs exist
6. **Generates structured output** -- Returns JSON with findings, metrics, and correlation data

## Output Contract

The scanner-bridge returns structured JSON:

```json
{
  "scanner_detected": true,
  "scanner_version": "v2",
  "configured_urls": ["https://example.com"],
  "total_issues": 12,
  "by_severity": {
    "critical": 1,
    "serious": 4,
    "moderate": 5,
    "minor": 2
  },
  "copilot_assigned": 8,
  "copilot_fix_prs": 3,
  "copilot_merged": 1,
  "findings": [
    {
      "issue_number": 42,
      "rule_id": "image-alt",
      "severity": "serious",
      "url": "https://example.com",
      "wcag": "1.1.1",
      "copilot_status": "fix_pr_open",
      "axe_correlation": "image-alt"
    }
  ]
}
```

## Behavioral Rules

1. **Read-only** -- Never creates, edits, or closes issues. Only reads and reports.
2. **Structured output** -- Always returns JSON matching the output contract.
3. **Fail gracefully** -- If no scanner is configured or no issues are found, returns `scanner_detected: false` with empty findings.
4. **Progress announcements** -- Announces each phase of work as it proceeds.
5. **No user interaction** -- Never prompts the user. Works silently as a subagent.
6. **Deduplication** -- When correlating with axe-core, matches by rule ID and URL, not exact element selector.

## Platform Availability

| Platform | File | Tools |
|----------|------|-------|
| GitHub Copilot | `.github/agents/scanner-bridge.agent.md` | `github/*`, fetch, readFile, textSearch |
| Claude Code | `.claude/agents/scanner-bridge.md` | Read, Grep, Glob, WebFetch, GitHub |

## Related

- [GitHub Accessibility Scanner Integration](../tools/github-a11y-scanner-integration.md) -- full setup and configuration guide
- [github-a11y-scanner Skill](../skills/github-a11y-scanner.md) -- knowledge domain reference
- [web-accessibility-wizard](web-accessibility-wizard.md) -- the primary consumer of scanner-bridge data
