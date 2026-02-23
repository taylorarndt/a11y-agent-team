# setup-document-cicd

Configure an automated CI/CD pipeline that scans documents for accessibility issues on every push or PR that modifies document files. Generates pipeline configuration files, scan config, and setup instructions for your team.

## When to Use It

- You want document accessibility to be automatically checked on every PR
- You want to prevent accessibility regressions from being merged
- You are setting up a new project and want accessibility gates from day one
- You need to demonstrate to auditors that accessibility is enforced in your development process

## How to Launch It

**In GitHub Copilot Chat:**
```
/setup-document-cicd
```

The agent collects your preferences interactively.

## What to Expect

### Step 1: Platform Selection

The agent asks which CI/CD platform to target:
- **GitHub Actions** — generates `.github/workflows/document-a11y.yml`
- **Azure DevOps Pipelines** — generates `azure-pipelines.yml`
- **Generic CI** — generates shell scripts compatible with any platform

### Step 2: Scan Profile

| Profile | Rules | Severities | Best For |
|---------|-------|-----------|----------|
| Strict | All rules | All severities | Public/government documents |
| Moderate | All rules | Errors and warnings | Good default for most teams |
| Minimal | Core rules | Errors only | Initial adoption, reducing noise |

### Step 3: Notification Preferences

- **PR comment** — post a summary as a PR comment so reviewers see it inline
- **Build artifact** — upload the full report as a downloadable artifact
- **Fail the build** — block merges when errors are found
- **Slack/Teams notification** — post to a channel when issues are found

### Step 4: Pipeline Generation

**GitHub Actions example** (generated automatically):

```yaml
name: Document Accessibility Check

on:
  pull_request:
    paths:
      - '**/*.docx'
      - '**/*.xlsx'
      - '**/*.pptx'
      - '**/*.pdf'
  schedule:
    - cron: '0 9 * * 1'  # Weekly Monday 9am

jobs:
  a11y-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 2

      - name: Find changed documents
        run: git diff --name-only HEAD~1 HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf' > changed-docs.txt

      - name: Run accessibility scan
        uses: taylorarndt/a11y-agent-team@main

      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: document-accessibility-report
          path: DOCUMENT-ACCESSIBILITY-AUDIT.md
```

### Step 5: Config File Generation

The agent generates starter scan configuration files:

- `.a11y-office-config.json` — Office document scan configuration
- `.a11y-pdf-config.json` — PDF scan configuration

Both use the selected profile.

### Step 6: Team Setup Instructions

The agent provides:
- How to trigger the first scan
- How to configure the fail threshold
- How to handle pre-existing issues (suppress baseline, only fail on new)
- How to update the scan configuration over time

## Example Variations

```
/setup-document-cicd
→ Platform: GitHub Actions
→ Profile: Moderate
→ Notify: PR comment + fail on critical errors
→ Schedule: Weekly full scan on Mondays
```

## Output Files

| File | Contents |
|------|----------|
| `.github/workflows/document-a11y.yml` | GitHub Actions pipeline (or Azure DevOps equivalent) |
| `.a11y-office-config.json` | Office scan configuration |
| `.a11y-pdf-config.json` | PDF scan configuration |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Generates all pipeline and config files |
| [document-inventory](../../agents/document-inventory.md) | Used to understand the document structure for CI config |

## Related Prompts

- [audit-changed-documents](audit-changed-documents.md) — the prompt this pipeline runs on each commit
- [audit-document-folder](audit-document-folder.md) — the first full scan to establish your baseline
