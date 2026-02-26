---
name: github-a11y-scanner
description: Integration patterns for the GitHub Accessibility Scanner Action (github/accessibility-scanner). Teaches agents how to detect scanner presence, parse scanner-created issues, correlate findings with local scans, and track Copilot-assigned fix status.
---

# GitHub Accessibility Scanner Integration

## What Is the GitHub Accessibility Scanner?

The [GitHub Accessibility Scanner](https://github.com/github/accessibility-scanner) (`github/accessibility-scanner@v2`) is an official GitHub Action that:

- Scans live URLs for accessibility barriers using axe-core in a headless browser
- Creates trackable GitHub Issues for each finding, with affected element, WCAG criterion, and remediation guidance
- Optionally assigns issues to GitHub Copilot for AI-powered fix suggestions and PR creation
- Caches results across runs for delta detection (new, fixed, persistent findings)
- Supports authenticated scanning (login flows, SSO, passkeys via Playwright auth context)
- Optionally captures screenshots and attaches them to filed issues

**Current version:** v2 (public preview)

## Detecting Scanner Presence

To determine whether a repository has the GitHub Accessibility Scanner configured:

### Workflow File Detection

Search for workflow files referencing the scanner action:

```bash
# Search in .github/workflows/ for the scanner action reference
grep -rl "github/accessibility-scanner" .github/workflows/
```

**Pattern to match in YAML:**
```yaml
- uses: github/accessibility-scanner@v2
```

### Workflow Inputs

When a scanner workflow is found, extract its configuration:

| Input | Required | Description |
|-------|----------|-------------|
| `urls` | Yes | Newline-delimited list of URLs to scan |
| `repository` | Yes | Repository (owner/name) where issues and PRs are created |
| `token` | Yes | Fine-grained PAT with write access (contents, issues, PRs, metadata) |
| `cache_key` | Yes | Filename for caching results across runs (e.g., `cached_results-mysite.json`) |
| `login_url` | No | Login page URL for authenticated scanning |
| `username` | No | Username for authentication |
| `password` | No | Password for authentication (via repository secret) |
| `auth_context` | No | Stringified JSON for complex authentication (Playwright session state) |
| `skip_copilot_assignment` | No | Set `true` to skip assigning issues to Copilot |
| `include_screenshots` | No | Set `true` to capture screenshots (stored on `gh-cache` branch) |

## Parsing Scanner-Created Issues

The scanner creates GitHub Issues with a structured format. Agents should parse these fields:

### Issue Identification

Scanner-created issues can be identified by:

1. **Author:** The GitHub Actions bot that runs the workflow
2. **Labels:** The scanner applies labels to categorize findings (typically accessibility-related labels)
3. **Body structure:** Issues contain structured sections with violation details

### Issue Body Structure

Scanner issues typically contain:

| Section | Content | Agent Use |
|---------|---------|-----------|
| Violation title | The axe-core rule that was violated | Map to `help-url-reference` for remediation docs |
| WCAG criterion | The specific WCAG success criterion | Used for severity scoring and compliance mapping |
| Affected element | CSS selector or HTML snippet of the failing element | Used by `scanner-bridge` to map to source code |
| Impact level | Critical, Serious, Moderate, or Minor | Direct mapping to agent severity model |
| Remediation guidance | How to fix the issue | Enriched by agent specialists with framework-specific fixes |
| URL | The page URL where the issue was found | Used for cross-referencing with local axe-core scans |
| Screenshot link | Link to screenshot on `gh-cache` branch (if enabled) | Included in audit reports |

### Severity Mapping

The scanner uses axe-core impact levels that map directly to the agent severity model:

| Scanner Impact | Agent Severity | Score Weight |
|---------------|---------------|-------------|
| Critical | Critical | -15 (both sources) / -10 (single source) |
| Serious | Serious | -7 (high confidence) |
| Moderate | Moderate | -3 (high confidence) |
| Minor | Minor | -1 |

### axe-core Rule Correlation

The scanner uses axe-core under the hood. Scanner issue titles and violation IDs correspond to axe-core rules already cataloged in `help-url-reference`. Common scanner-reported rules:

| axe-core Rule ID | WCAG Criterion | Common Description |
|-------------------|----------------|-------------------|
| `image-alt` | 1.1.1 | Images must have alternate text |
| `label` | 1.3.1 | Form elements must have labels |
| `color-contrast` | 1.4.3 | Elements must have sufficient color contrast |
| `link-name` | 2.4.4 | Links must have discernible text |
| `html-has-lang` | 3.1.1 | `<html>` element must have a lang attribute |
| `button-name` | 4.1.2 | Buttons must have discernible text |
| `document-title` | 2.4.2 | Documents must have `<title>` element |
| `bypass` | 2.4.1 | Page must have means to bypass repeated blocks |
| `heading-order` | 1.3.1 | Heading levels should increase by one |
| `aria-allowed-attr` | 4.1.2 | ARIA attributes must be allowed for element role |

## Caching and Delta Detection

The scanner uses a `cache_key` to persist results across workflow runs. This enables delta tracking:

| Status | Meaning |
|--------|---------|
| **New** | Issue found in current scan but not in cached results |
| **Fixed** | Issue in cached results but not found in current scan (issue auto-closed) |
| **Persistent** | Issue found in both current scan and cached results |

### Cache Key Conventions

When setting up scanner integration, align the cache key with agent conventions:
- Use a descriptive name: `cached_results-{domain}-{branch}.json`
- Include branch context for branch-specific scanning
- The cache is stored as a GitHub Actions artifact

## Correlation with Local Scans

### Dual-Source Confidence Boosting

When both the GitHub Accessibility Scanner (CI) and a local axe-core scan (agent) find the same issue:

1. **Match by rule ID:** Both sources use axe-core rule IDs (e.g., `color-contrast`, `image-alt`)
2. **Match by URL:** Compare the scanned URL from the scanner issue with the local scan target
3. **Match by element:** Compare CSS selectors or HTML paths for the affected element
4. **Boost confidence:** Findings confirmed by both sources automatically receive `high` confidence

### Source Comparison Analysis

| Scenario | Interpretation | Action |
|----------|---------------|--------|
| Found by scanner AND local scan | High confidence -- confirmed by both | Report as high confidence, full severity weight |
| Found by scanner only | Environment-specific or intermittent | Report as medium confidence, note "CI-only finding" |
| Found by local scan only | New since last CI scan, or local-only condition | Report as medium confidence, note "local-only finding" |
| In scanner cache as "fixed" | Recently remediated | Track in delta section as resolved |

## Copilot Fix Tracking

When the scanner assigns issues to GitHub Copilot:

### Fix Lifecycle

| Stage | GitHub State | How to Detect |
|-------|-------------|---------------|
| Issue created | Open issue, assigned to Copilot | `assignee` includes Copilot bot |
| Fix proposed | Open PR linked to issue | PR references issue number, author is Copilot |
| Fix reviewed | PR has review comments | PR review state is `CHANGES_REQUESTED` or `APPROVED` |
| Fix merged | PR merged, issue closed | Issue state is `closed`, linked PR is merged |
| Fix rejected | PR closed without merge | PR state is `closed`, not merged |

### Querying Copilot Fix Status

```text
# Find scanner issues assigned to Copilot
repo:{REPO} is:issue is:open assignee:copilot label:accessibility

# Find Copilot PRs from scanner issues
repo:{REPO} is:pr author:copilot-swe-agent label:accessibility

# Find merged scanner fixes
repo:{REPO} is:pr is:merged author:copilot-swe-agent label:accessibility
```

## Structured Output Format

When `scanner-bridge` normalizes scanner issue data, it produces findings in this format:

```json
{
  "source": "github-a11y-scanner",
  "ruleId": "color-contrast",
  "wcagCriterion": "1.4.3",
  "wcagLevel": "AA",
  "severity": "serious",
  "confidence": "high",
  "url": "https://example.com/login",
  "element": "button.submit-btn",
  "description": "Element has insufficient color contrast ratio of 3.2:1 (expected 4.5:1)",
  "remediation": "Change the text color or background to achieve at least 4.5:1 contrast ratio",
  "githubIssue": {
    "number": 42,
    "url": "https://github.com/owner/repo/issues/42",
    "state": "open",
    "copilotAssigned": true,
    "fixPR": null
  },
  "screenshot": "https://github.com/owner/repo/blob/gh-cache/screenshots/login-contrast.png"
}
```

## Search Patterns for Scanner Issues

### By Repository

```text
repo:{OWNER}/{REPO} is:issue label:accessibility created:>{YYYY-MM-DD}
```

### By Scan Run

Issues from a specific scan run share the same creation timestamp and batch pattern. Filter by:
- Creation date matching the workflow run date
- Common label set applied by the scanner

### Cross-Repository Scanner Discovery

```text
user:{USERNAME} is:issue label:accessibility sort:created-desc
org:{ORGNAME} is:issue label:accessibility sort:created-desc
```
