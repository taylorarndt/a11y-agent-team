# GitHub Accessibility Scanner Integration

The [GitHub Accessibility Scanner](https://github.com/marketplace/actions/accessibility-scanner) is an official GitHub Action that scans web pages for accessibility violations and creates GitHub issues for each finding. The agent ecosystem integrates with scanner-created issues to provide a unified view of accessibility across automated CI scanning and manual agent-driven audits.

## How It Works

1. The scanner runs as a GitHub Actions workflow on push, PR, or schedule
2. It scans configured URLs using browser-based accessibility testing
3. For each violation, it creates a GitHub issue with structured details
4. Optionally, it assigns issues to GitHub Copilot for automated fix PRs
5. The agent ecosystem detects these issues and incorporates them into audits and reports

## Setup

Use the `setup-github-scanner` prompt to configure the scanner in your repository:

**In Copilot Chat:** Select the `setup-github-scanner` prompt from the prompt picker.

Or manually create `.github/workflows/accessibility-scanner.yml`:

```yaml
name: Accessibility Scanner

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  issues: write
  contents: read

jobs:
  scan:
    runs-on: ubuntu-latest
    name: Scan for accessibility violations
    steps:
      - name: Run accessibility scanner
        uses: github/accessibility-scanner@v2
        with:
          urls: |
            https://your-site.com
            https://your-site.com/about
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Scanner Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `urls` | Yes | Newline-separated list of URLs to scan |
| `token` | Yes | GitHub token with issues:write permission |
| `repository` | No | Target repository for issues (default: current) |
| `cache_key` | No | Custom cache key for deduplication |
| `login_url` | No | Login URL if authentication is required |
| `skip_copilot_assignment` | No | Set to `true` to disable Copilot auto-assignment |
| `include_screenshots` | No | Set to `true` to attach screenshots to issues |

## Agent Integration Points

### scanner-bridge Agent

The `scanner-bridge` is a hidden helper agent that bridges CI scanner data into the agent ecosystem. It is not user-invokable -- other agents call it automatically.

**What it does:**
- Detects scanner workflows in `.github/workflows/`
- Fetches scanner-created issues from the GitHub API
- Normalizes findings into the standard severity model (Critical/Serious/Moderate/Minor)
- Deduplicates against local axe-core scan results
- Tracks Copilot fix assignment status

### web-accessibility-wizard

The wizard automatically detects the scanner during Phase 0 and correlates findings in Phase 9:

- **Phase 0 Step 0:** Silently checks for scanner workflows and dispatches scanner-bridge
- **Phase 9:** Merges scanner findings with local axe-core scan results; issues found by both sources get upgraded to high confidence
- **Phase 10:** Reports scanner metrics, correlation data, and scanner-only findings

### insiders-a11y-tracker

The tracker includes CI Scanner Issue Discovery in its search patterns:

- Searches for `author:app/github-actions label:accessibility` to find scanner-created issues
- Tracks Copilot fix lifecycle (assigned, PR open, PR merged)
- Tags findings with `[CI Scanner]` prefix in reports

### daily-briefing

The briefing includes a CI Scanner section in accessibility updates:

- Lists scanner-created issues with severity and Copilot fix status
- Adds a CI scanner issues row to the Dashboard Summary

### issue-tracker

The issue tracker recognizes scanner-created issues:

- Scanner Triage mode for listing and triaging CI accessibility findings
- Tags scanner issues with `[CI Scanner]` for easy filtering

## Confidence Model

Issues are scored with confidence levels based on how many sources detected them:

| Sources | Confidence | Description |
|---------|-----------|-------------|
| Agent review + axe-core + CI scanner | Highest | Triple-source confirmation |
| Agent review + CI scanner | High | Dual-source confirmation |
| axe-core + CI scanner | High | Dual automated confirmation |
| CI scanner only | Medium | Single automated source |

## Delta Tracking

Scanner findings are tracked across runs using the standard delta model:

| Status | Meaning |
|--------|---------|
| Fixed | Was in previous scan, not in current |
| New | Not in previous scan, now detected |
| Persistent | Detected in both scans |
| Regressed | Was marked fixed, now reappeared |
