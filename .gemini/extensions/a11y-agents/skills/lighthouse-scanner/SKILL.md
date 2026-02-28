---
name: lighthouse-scanner
description: Integration patterns for Lighthouse CI accessibility auditing. Teaches agents how to detect Lighthouse CI configuration, parse accessibility audit results, map findings to the standard severity model, correlate with local axe-core scans, and track score regressions.
---

# Lighthouse CI Accessibility Integration

## What Is Lighthouse CI?

[Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) is a suite of tools for running Google Lighthouse audits in CI pipelines. The most common GitHub Actions integration uses [`treosh/lighthouse-ci-action`](https://github.com/treosh/lighthouse-ci-action).

Lighthouse provides:

- Performance, accessibility, best practices, and SEO scoring (0-100)
- Individual audit results with pass/fail status and detailed findings
- Score budgets and assertions to fail builds on regressions
- HTML and JSON report artifacts
- Score comparison across runs for trend tracking

**Accessibility focus:** The Lighthouse accessibility category runs a subset of axe-core rules and reports a weighted score from 0-100 along with individual audit violations.

## Detecting Lighthouse CI Presence

### Workflow File Detection

Search for workflow files referencing Lighthouse CI:

```bash
# Search for the treosh Lighthouse CI action
grep -rl "treosh/lighthouse-ci-action" .github/workflows/

# Search for official Lighthouse CI CLI usage
grep -rl "lhci autorun\|lighthouse-ci" .github/workflows/
```

**Patterns to match in YAML:**
```yaml
- uses: treosh/lighthouse-ci-action@v12
```

### Configuration File Detection

Lighthouse CI uses configuration files in the repository root:

```bash
# Check for Lighthouse CI config files
ls lighthouserc.js lighthouserc.json .lighthouserc.js .lighthouserc.json .lighthouserc.yml 2>/dev/null
```

| Config File | Format |
|------------|--------|
| `lighthouserc.js` | JavaScript module |
| `lighthouserc.json` | JSON |
| `.lighthouserc.js` | JavaScript module (dotfile) |
| `.lighthouserc.json` | JSON (dotfile) |
| `.lighthouserc.yml` | YAML (dotfile) |

### Configuration Structure

Key fields in Lighthouse CI config:

```json
{
  "ci": {
    "collect": {
      "url": ["https://example.com", "https://example.com/about"],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:accessibility": ["error", {"minScore": 0.9}]
      }
    },
    "upload": {
      "target": "temporary-public-storage"
    }
  }
}
```

| Section | Purpose | Agent Use |
|---------|---------|-----------|
| `ci.collect.url` | URLs to audit | Scope of CI scanning |
| `ci.collect.numberOfRuns` | How many times to run each URL | Reliability indicator |
| `ci.assert.assertions` | Score budgets and thresholds | Regression detection |
| `ci.upload.target` | Where to store reports | Report retrieval |

## Parsing Lighthouse Accessibility Results

### Accessibility Score

Lighthouse computes a weighted accessibility score from 0-100 based on individual audit results.

| Score Range | Grade | Interpretation |
|-------------|-------|---------------|
| 90-100 | A | Good accessibility |
| 70-89 | B-C | Some issues to address |
| 50-69 | D | Significant issues |
| 0-49 | F | Critical accessibility failures |

### Individual Audit Results

Each Lighthouse accessibility audit corresponds to an axe-core rule:

| Audit ID | axe-core Rule | WCAG Criterion | Weight |
|----------|--------------|----------------|--------|
| `image-alt` | `image-alt` | 1.1.1 | 10 |
| `color-contrast` | `color-contrast` | 1.4.3 | 7 |
| `label` | `label` | 1.3.1 | 7 |
| `button-name` | `button-name` | 4.1.2 | 7 |
| `link-name` | `link-name` | 2.4.4 | 7 |
| `html-has-lang` | `html-has-lang` | 3.1.1 | 7 |
| `document-title` | `document-title` | 2.4.2 | 7 |
| `heading-order` | `heading-order` | 1.3.1 | 3 |
| `meta-viewport` | `meta-viewport` | 1.4.4 | 10 |
| `bypass` | `bypass` | 2.4.1 | 7 |
| `tabindex` | `tabindex` | 2.4.3 | 7 |
| `aria-allowed-attr` | `aria-allowed-attr` | 4.1.2 | 10 |
| `aria-hidden-body` | `aria-hidden-body` | 4.1.2 | 10 |
| `aria-required-attr` | `aria-required-attr` | 4.1.2 | 10 |
| `aria-roles` | `aria-roles` | 4.1.2 | 7 |
| `aria-valid-attr-value` | `aria-valid-attr-value` | 4.1.2 | 7 |
| `aria-valid-attr` | `aria-valid-attr` | 4.1.2 | 10 |

### Severity Mapping

Lighthouse uses weights rather than impact levels. Map to the agent severity model based on weight and audit pass/fail:

| Lighthouse Weight | Audit Status | Agent Severity |
|------------------|-------------|---------------|
| 10 | Fail | Critical |
| 7 | Fail | Serious |
| 3 | Fail | Moderate |
| 1 | Fail | Minor |
| Any | Pass | N/A (not reported) |

## Correlation with Local Scans

### Lighthouse-to-axe-core Mapping

Since Lighthouse uses axe-core under the hood, correlation is straightforward:

1. **Match by audit/rule ID:** Lighthouse audit IDs correspond directly to axe-core rule IDs
2. **Match by URL:** Compare scanned URLs from Lighthouse config with local scan targets
3. **Boost confidence:** Findings confirmed by both Lighthouse CI and local axe-core scan receive `high` confidence

### Source Comparison

| Scenario | Interpretation | Action |
|----------|---------------|--------|
| Found by Lighthouse AND local scan | High confidence | Report as high confidence, full severity weight |
| Found by Lighthouse only | Environment-specific | Report as medium confidence, note "CI-only finding" |
| Found by local scan only | Not covered by Lighthouse subset | Report as medium confidence, note "local-only finding" |
| Lighthouse score regressed | New accessibility issues introduced | Flag as regression, prioritize in report |

## Score Regression Detection

Track Lighthouse accessibility scores across runs to detect regressions:

### Comparing Scores

```json
{
  "url": "https://example.com",
  "previousScore": 95,
  "currentScore": 87,
  "delta": -8,
  "status": "regressed",
  "newFailures": ["color-contrast", "image-alt"],
  "newPasses": []
}
```

### Regression Thresholds

| Delta | Severity | Action |
|-------|----------|--------|
| Score drops 10+ points | Critical | Immediate attention, likely multiple new violations |
| Score drops 5-9 points | Serious | New violations introduced, review before merge |
| Score drops 1-4 points | Moderate | Minor regression, track for follow-up |
| Score unchanged or improved | N/A | No regression detected |

## Structured Output Format

When `lighthouse-bridge` normalizes Lighthouse data, it produces findings in this format:

```json
{
  "source": "lighthouse-ci",
  "ruleId": "color-contrast",
  "wcagCriterion": "1.4.3",
  "wcagLevel": "AA",
  "severity": "serious",
  "confidence": "high",
  "url": "https://example.com/login",
  "element": "button.submit-btn",
  "description": "Element has insufficient color contrast ratio",
  "lighthouseWeight": 7,
  "lighthouseScore": {
    "overall": 87,
    "previousOverall": 95,
    "delta": -8,
    "status": "regressed"
  }
}
```

## GitHub Actions Integration

### treosh/lighthouse-ci-action

The most common Lighthouse CI GitHub Action:

```yaml
- name: Run Lighthouse CI
  uses: treosh/lighthouse-ci-action@v12
  with:
    urls: |
      https://example.com
      https://example.com/about
    uploadArtifacts: true
    configPath: ./lighthouserc.json
```

### Action Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `urls` | Yes (or in config) | Newline-separated URLs to audit |
| `configPath` | No | Path to Lighthouse CI config file |
| `uploadArtifacts` | No | Upload HTML reports as workflow artifacts |
| `temporaryPublicStorage` | No | Upload to temporary public storage for sharing |
| `runs` | No | Number of runs per URL (default: 1) |
| `budgetPath` | No | Path to a Lighthouse budget JSON file |

### Extracting Results from Artifacts

Lighthouse CI uploads results as workflow artifacts. To retrieve scores:

1. Download the artifact from the workflow run
2. Parse the JSON report files
3. Extract `categories.accessibility.score` for the overall score
4. Extract individual `audits.{audit-id}` results for violations
