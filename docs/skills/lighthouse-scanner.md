# lighthouse-scanner Skill

> Integration patterns for Lighthouse CI accessibility auditing (`treosh/lighthouse-ci-action`). Teaches agents how to detect Lighthouse CI configuration, parse accessibility reports, map Lighthouse weight-based severity to the standard model, correlate with local axe-core scans, track score regressions, and produce structured JSON output.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [lighthouse-bridge](../agents/lighthouse-bridge.md) | Primary consumer -- bridges Lighthouse CI data into the agent ecosystem |
| [web-accessibility-wizard](../agents/web-accessibility-wizard.md) | Auto-detects Lighthouse in Phase 0, correlates findings in Phase 9 |
| [insiders-a11y-tracker](../agents/insiders-a11y-tracker.md) | Discovers Lighthouse-related issues and score regressions |
| [daily-briefing](../agents/daily-briefing.md) | Surfaces Lighthouse score regressions in daily CI Scanner report section |
| [issue-tracker](../agents/issue-tracker.md) | Recognizes Lighthouse CI issues in Scanner Triage mode |

## What the Skill Covers

### Lighthouse CI Detection

How to check if a repository uses Lighthouse CI:
- Grep `.github/workflows/` for `treosh/lighthouse-ci-action` or `lhci autorun`
- Check for config files: `lighthouserc.js`, `lighthouserc.json`, `.lighthouserc.js`, `.lighthouserc.json`, `.lighthouserc.yml`
- Parse config for URLs, numberOfRuns, score thresholds, and upload targets

### Accessibility Score Interpretation

Lighthouse produces a 0-100 accessibility score per URL. The skill maps scores to grades:

| Score Range | Grade |
|------------|-------|
| 90-100 | A |
| 80-89 | B |
| 70-79 | C |
| 60-69 | D |
| 0-59 | F |

### Severity Mapping

Maps Lighthouse audit weights to the standard agent severity model:

| Lighthouse Weight | Agent Severity | Weight |
|-------------------|---------------|--------|
| 10 | Critical | 10 |
| 7 | Serious | 5 |
| 3 | Moderate | 2 |
| 1 | Minor | 1 |

### axe-core Rule Correlation

Lighthouse accessibility audits are powered by a subset of axe-core. The skill maps Lighthouse audit IDs directly to axe-core rule IDs for deduplication with local scans. Key mappings include:
- `image-alt`, `color-contrast`, `label`, `button-name`, `link-name`
- `html-has-lang`, `document-title`, `meta-viewport`, `heading-order`, `tabindex`

### Score Regression Detection

Tracks accessibility scores across CI runs and classifies changes:
- Score drops of 10+ points: Critical regression
- Score drops of 5-9 points: Serious regression
- Score drops of 1-4 points: Moderate regression
- Score improvements are also tracked for positive trend reporting

### Confidence Boosting

Findings confirmed by multiple sources get confidence upgrades:
- Lighthouse + local axe-core = High confidence
- Lighthouse + agent review = High confidence
- Lighthouse + axe-core + agent review = Highest confidence
- Lighthouse only = Medium confidence

## Full Skill Reference

See the complete skill file: [`.github/skills/lighthouse-scanner/SKILL.md`](../../.github/skills/lighthouse-scanner/SKILL.md)
