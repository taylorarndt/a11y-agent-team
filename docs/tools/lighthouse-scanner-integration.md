# Lighthouse CI Scanner Integration

[Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) runs Google Lighthouse audits in your CI pipeline and reports accessibility scores per URL. The agent ecosystem integrates with Lighthouse CI to provide score regression tracking, finding correlation with local axe-core scans, and unified accessibility reporting.

## How It Works

1. Lighthouse CI runs as a GitHub Actions workflow on push, PR, or schedule
2. It audits configured URLs across multiple categories (performance, accessibility, best practices, SEO)
3. The accessibility category produces a 0-100 score and individual audit results (powered by axe-core)
4. The agent ecosystem detects the Lighthouse configuration and parses results
5. Findings are correlated with local scans for multi-source confidence boosting

## Setup

Use the `setup-lighthouse-scanner` prompt to configure Lighthouse CI in your repository:

**In Copilot Chat:** Select the `setup-lighthouse-scanner` prompt from the prompt picker.

Or manually create the configuration:

### 1. Create `lighthouserc.json`

```json
{
  "ci": {
    "collect": {
      "url": [
        "https://your-site.com",
        "https://your-site.com/about"
      ],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:accessibility": ["error", { "minScore": 0.9 }]
      }
    },
    "upload": {
      "target": "temporary-public-storage"
    }
  }
}
```

### 2. Create `.github/workflows/lighthouse-ci.yml`

```yaml
name: Lighthouse CI

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    name: Run Lighthouse CI
    steps:
      - uses: actions/checkout@v4
      - name: Run Lighthouse CI
        uses: treosh/lighthouse-ci-action@v12
        with:
          configPath: ./lighthouserc.json
          uploadArtifacts: true
```

### Lighthouse CI Action Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `configPath` | No | Path to `lighthouserc.json` config file |
| `urls` | No | Newline-separated URLs (alternative to config file) |
| `runs` | No | Number of runs per URL (default: from config or 1) |
| `uploadArtifacts` | No | Upload HTML reports as workflow artifacts |
| `temporaryPublicStorage` | No | Upload to temporary public storage for PR comments |
| `budgetPath` | No | Path to performance budget JSON |

## Agent Integration Points

### lighthouse-bridge Agent

The `lighthouse-bridge` is a hidden helper agent that bridges Lighthouse CI data into the agent ecosystem. It is not user-invokable -- other agents call it automatically.

**What it does:**
- Detects Lighthouse CI workflows and `lighthouserc.*` config files
- Parses Lighthouse accessibility reports (overall score and individual audit failures)
- Maps Lighthouse weight-based severity to the agent model (Critical/Serious/Moderate/Minor)
- Tracks score regressions across runs (delta tracking with severity thresholds)
- Deduplicates against local axe-core scan results

### web-accessibility-wizard

The wizard automatically detects Lighthouse CI during Phase 0 and correlates findings in Phase 9:

- **Phase 0 Step 0:** Silently checks for Lighthouse CI workflows and config files, dispatches lighthouse-bridge
- **Phase 9:** Merges Lighthouse findings with local axe-core scan results; issues found by both sources get upgraded to high confidence
- **Phase 10:** Reports Lighthouse metrics, score history, and Lighthouse-only findings

### insiders-a11y-tracker

Discovers Lighthouse-related issues and tracks Lighthouse accessibility score changes across commits.

### daily-briefing

Reports Lighthouse score regressions in the CI Scanner section and surfaces new Lighthouse-identified issues.

## Confidence Model

| Sources | Confidence |
|---------|------------|
| Lighthouse + local axe-core + agent review | Highest |
| Lighthouse + local axe-core | High |
| Lighthouse + agent review | High |
| Lighthouse only | Medium |
| Local axe-core only | Medium |

## Score Regression Tracking

The lighthouse-bridge tracks accessibility score changes:

| Delta | Status | Severity |
|-------|--------|----------|
| Score drops 10+ points | `regressed-critical` | Critical |
| Score drops 5-9 points | `regressed-serious` | Serious |
| Score drops 1-4 points | `regressed-moderate` | Moderate |
| Score unchanged | `stable` | N/A |
| Score improved | `improved` | N/A |

## Lighthouse Accessibility Audits

Lighthouse runs a subset of axe-core rules for its accessibility category. Key audits with their weights:

| Audit ID | WCAG | Weight | Agent Severity |
|----------|------|--------|---------------|
| `color-contrast` | 1.4.3 AA | 7 | Serious |
| `image-alt` | 1.1.1 A | 10 | Critical |
| `label` | 1.3.1 A | 7 | Serious |
| `button-name` | 4.1.2 A | 7 | Serious |
| `link-name` | 2.4.4 A | 7 | Serious |
| `html-has-lang` | 3.1.1 A | 7 | Serious |
| `document-title` | 2.4.2 A | 7 | Serious |
| `meta-viewport` | 1.4.4 AA | 10 | Critical |
| `heading-order` | 1.3.1 A | 3 | Moderate |
| `list` | 1.3.1 A | 3 | Moderate |
| `tabindex` | 2.4.3 A | 7 | Serious |

## Related

- [Lighthouse CI GitHub Action](https://github.com/treosh/lighthouse-ci-action) -- the CI action
- [lighthouse-scanner Skill](../skills/lighthouse-scanner.md) -- knowledge domain reference
- [lighthouse-bridge Agent](../agents/lighthouse-bridge.md) -- agent documentation
- [web-accessibility-wizard](../agents/web-accessibility-wizard.md) -- primary consumer of lighthouse-bridge data
