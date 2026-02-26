---
description: Set up the GitHub Accessibility Scanner in your repository. Generates a workflow file, configures scan URLs, and validates the integration with the agent ecosystem.
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

# Set Up GitHub Accessibility Scanner

Add the [GitHub Accessibility Scanner](https://github.com/marketplace/actions/accessibility-scanner) to your repository. This creates a GitHub Actions workflow that scans your deployed pages for accessibility violations and creates issues automatically.

## Instructions

### Step 1: Gather Configuration

Ask the user for the following information (provide smart defaults where possible):

1. **URLs to scan** -- Which pages should the scanner check? (e.g., `https://example.com`, `https://example.com/about`)
2. **Trigger event** -- When should the scan run? Options:
   - `push` to `main` branch (default)
   - `pull_request` to `main`
   - `schedule` (cron, e.g., daily)
   - `workflow_dispatch` (manual trigger)
3. **Copilot assignment** -- Should detected issues be assigned to GitHub Copilot for automatic fix PRs? (default: yes)
4. **Login URL** -- Does the site require authentication? If so, what is the login URL?

### Step 2: Create the Workflow File

Generate `.github/workflows/accessibility-scanner.yml` with the following structure:

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
            <user-provided URLs, one per line>
          token: ${{ secrets.GITHUB_TOKEN }}
          # skip_copilot_assignment: false
```

Adjust the `on` trigger, `urls`, and optional inputs based on user responses.

### Step 3: Validate the Setup

1. Check that the workflow file is valid YAML.
2. Verify the `permissions` block includes `issues: write`.
3. If the user wants Copilot assignment, confirm their repo has Copilot enabled.
4. Explain that scanner-created issues will automatically be picked up by:
   - The **web-accessibility-wizard** (Phase 0 auto-detection and Phase 9 correlation)
   - The **insiders-a11y-tracker** (CI Scanner Issue Discovery)
   - The **daily-briefing** (CI Scanner Findings in accessibility updates)
   - The **issue-tracker** (Scanner Triage mode)

### Step 4: Confirm Success

Tell the user:

> The GitHub Accessibility Scanner is now configured. On the next push to main (or manual trigger), it will scan your pages and create issues for any accessibility violations found.
>
> The agent ecosystem will automatically detect these scanner-created issues and incorporate them into audits, briefings, and triage workflows. No additional configuration needed.
>
> To run a scan now, go to Actions > Accessibility Scanner > Run workflow.
