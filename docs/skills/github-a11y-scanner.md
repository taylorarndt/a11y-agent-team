# github-a11y-scanner Skill

> Integration patterns for the GitHub Accessibility Scanner Action (`github/accessibility-scanner`). Teaches agents how to detect scanner presence, parse scanner-created issues, map severity to the standard model, correlate with local axe-core scans, cache and deduplicate findings, track Copilot fix lifecycle, and produce structured JSON output.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [scanner-bridge](../agents/scanner-bridge.md) | Primary consumer -- bridges scanner data into the agent ecosystem |
| [web-accessibility-wizard](../agents/web-accessibility-wizard.md) | Auto-detects scanner in Phase 0, correlates findings in Phase 9 |
| [insiders-a11y-tracker](../agents/insiders-a11y-tracker.md) | Discovers scanner-created issues in search patterns |
| [daily-briefing](../agents/daily-briefing.md) | Surfaces scanner findings in daily CI Scanner report section |
| [issue-tracker](../agents/issue-tracker.md) | Recognizes scanner-created issues in Scanner Triage mode |

## What the Skill Covers

### Scanner Detection

How to check if a repository uses the GitHub Accessibility Scanner:
- Grep `.github/workflows/` for `github/accessibility-scanner`
- Parse workflow YAML for configured URLs, trigger events, and Copilot assignment settings

### Issue Body Parsing

Scanner-created issues follow a structured format. The skill teaches agents to extract:
- Rule ID and description
- Affected URL and element selector
- WCAG criterion reference
- Severity (mapped to Critical/Serious/Moderate/Minor)

### Severity Mapping

Maps scanner severity levels to the standard agent severity model:

| Scanner Severity | Agent Severity | Weight |
|-----------------|---------------|--------|
| critical | Critical | 10 |
| serious | Serious | 5 |
| moderate | Moderate | 2 |
| minor | Minor | 1 |

### axe-core Rule Correlation

Maps scanner findings to axe-core rule IDs for deduplication. Covers the most common violations:
- `image-alt`, `color-contrast`, `label`, `button-name`, `link-name`
- `html-has-lang`, `landmark-one-main`, `region`, `heading-order`, `list`

### Confidence Boosting

Issues found by multiple sources get confidence upgrades:
- Scanner + local axe-core = High confidence
- Scanner + agent review = High confidence
- Scanner + axe-core + agent review = Highest confidence
- Scanner only = Medium confidence

### Copilot Fix Tracking

Tracks the lifecycle of Copilot-assigned fixes:
- Issue assigned to Copilot
- Fix PR created
- Fix PR merged
- Issue closed

## Full Skill Reference

See the complete skill file: [`.github/skills/github-a11y-scanner/SKILL.md`](../../.github/skills/github-a11y-scanner/SKILL.md)
