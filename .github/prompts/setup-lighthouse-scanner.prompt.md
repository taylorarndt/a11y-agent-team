---
description: Set up Lighthouse CI accessibility scanning in your repository. Generates a workflow file, creates a lighthouserc configuration, and validates integration with the agent ecosystem.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
  - readFile
  - editFiles
  - createFile
  - listDirectory
---

# Set Up Lighthouse CI Accessibility Scanner

Add [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) to your repository for automated accessibility scoring and regression detection. This creates a GitHub Actions workflow that runs Lighthouse audits and feeds results into the agent accessibility pipeline.

## Instructions

### Step 1: Gather Configuration

Ask the user for the following information (provide smart defaults where possible):

1. **URLs to scan** -- Which pages should Lighthouse audit? (e.g., `https://example.com`, `https://example.com/about`)
2. **Number of runs** -- How many times should each URL be tested? (default: 3, recommended for stable median scores)
3. **Accessibility threshold** -- Minimum accessibility score (0-100) before the CI check fails (default: 90)
4. **Trigger event** -- When should the scan run? Options:
   - `push` to `main` branch (default)
   - `pull_request` to `main`
   - `schedule` (cron, e.g., daily)
   - `workflow_dispatch` (manual trigger)
5. **Upload target** -- Where should reports be stored?
   - `temporary-public-storage` (default, free, 7-day retention)
   - `lhci` (self-hosted LHCI server)
   - `filesystem` (local artifact storage)

### Step 2: Create the Configuration File

Generate `lighthouserc.json` in the repository root:

```json
{
  "ci": {
    "collect": {
      "url": [
        "<user-provided URLs>"
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

### Step 3: Create the Workflow File

Generate `.github/workflows/lighthouse-ci.yml`:

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

### Step 4: Validate Setup

After creating the files:

1. Verify the workflow YAML is valid
2. Verify `lighthouserc.json` parses correctly
3. Confirm the URLs are accessible
4. Explain how the agent ecosystem consumes Lighthouse data:
   - `lighthouse-bridge` agent auto-detects the config and parses results
   - `web-accessibility-wizard` correlates findings in Phase 9
   - `daily-briefing` reports Lighthouse score regressions
   - `insiders-a11y-tracker` discovers Lighthouse-related issues
5. Suggest running the workflow manually via `workflow_dispatch` to test
