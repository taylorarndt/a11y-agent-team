# lighthouse-bridge - Lighthouse CI Data Bridge

> Hidden helper agent that bridges Lighthouse CI accessibility audit data into the agent ecosystem. Parses Lighthouse reports, normalizes findings, tracks score regressions, and deduplicates against local scans.

## When to Use It

You do not invoke this agent directly. It is called automatically by:

- **web-accessibility-wizard** -- during Phase 0 (auto-detection) and Phase 9 (correlation)
- **insiders-a11y-tracker** -- when discovering Lighthouse-related issues and score regressions
- **daily-briefing** -- when collecting CI scanner accessibility updates

## What It Does

1. **Detects Lighthouse CI configuration** -- Reads `.github/workflows/` for `treosh/lighthouse-ci-action` and checks for `lighthouserc.*` config files
2. **Parses Lighthouse reports** -- Extracts accessibility score (0-100) and individual audit failures from Lighthouse JSON reports
3. **Normalizes findings** -- Maps Lighthouse weight-based severity to the standard model (Critical/Serious/Moderate/Minor)
4. **Tracks score regressions** -- Compares current vs previous accessibility scores, classifies delta as critical/serious/moderate regression or improvement
5. **Deduplicates** -- Correlates Lighthouse audit IDs with local axe-core rule IDs to avoid double-counting
6. **Generates structured output** -- Returns JSON with score, delta, findings, and regression status

## Output Contract

The lighthouse-bridge returns structured JSON:

```json
{
  "lighthouseDetected": true,
  "overallScore": 87,
  "previousScore": 95,
  "scoreDelta": -8,
  "totalFindings": 8,
  "bySeverity": {
    "critical": 1,
    "serious": 3,
    "moderate": 3,
    "minor": 1
  },
  "regressionStatus": "regressed-serious",
  "findings": [
    {
      "source": "lighthouse-ci",
      "ruleId": "color-contrast",
      "wcagCriterion": "1.4.3",
      "severity": "serious",
      "confidence": "medium",
      "url": "https://example.com",
      "element": ".header-text",
      "description": "Elements must meet minimum color contrast ratio thresholds",
      "lighthouseWeight": 7
    }
  ],
  "scoreHistory": [
    { "run": "2025-01-15", "score": 95 },
    { "run": "2025-01-22", "score": 87 }
  ]
}
```

## Behavioral Rules

1. **Read-only** -- Never creates, edits, or closes issues. Only reads reports and returns data.
2. **Structured output** -- Always returns JSON matching the output contract.
3. **Fail gracefully** -- If no Lighthouse CI is configured or no reports are available, returns `lighthouseDetected: false` with empty findings.
4. **Progress announcements** -- Announces each phase of work as it proceeds.
5. **No user interaction** -- Never prompts the user. Works silently as a subagent.
6. **Score context** -- Always includes score context (previous score, delta, regression status) when available.

## Platform Availability

| Platform | File | Tools |
|----------|------|-------|
| GitHub Copilot | `.github/agents/lighthouse-bridge.agent.md` | `github/*`, fetch, readFile, textSearch |
| Claude Code | `.claude/agents/lighthouse-bridge.md` | Read, Grep, Glob, WebFetch, GitHub |

## Related

- [Lighthouse CI Scanner Integration](../tools/lighthouse-scanner-integration.md) -- full setup and configuration guide
- [lighthouse-scanner Skill](../skills/lighthouse-scanner.md) -- knowledge domain reference
- [web-accessibility-wizard](web-accessibility-wizard.md) -- the primary consumer of lighthouse-bridge data
