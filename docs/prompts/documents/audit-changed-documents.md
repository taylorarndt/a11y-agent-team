# audit-changed-documents

Delta scan — scan only the documents that changed since the last commit. Perfect for CI/CD pipelines and incremental review workflows that do not want to re-scan an entire library on every change.

## When to Use It

- You want to check only the documents someone edited in a PR
- You are running automated accessibility checks in a CI pipeline on pushes
- You updated three documents in a folder of 50 and only want to re-scan those three
- You want to compare before and after to see if the changes improved or worsened accessibility

## How to Launch It

**In GitHub Copilot Chat:**
```
/audit-changed-documents
```

**In a CI environment (shell):** The prompt is configured for use with the `setup-document-cicd` pipeline.

## What to Expect

### Step 1: Git Diff Discovery

The agent runs git to find changed documents since the last commit:

```bash
git diff --name-only HEAD~1 HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf'
```

If no changed documents are found, the agent reports "No document changes detected" and stops — no wasted work.

### Step 2: Per-File Scan

Each changed document is scanned with the strict profile and delegated to the appropriate format specialist.

### Step 3: Comparison with Previous Report

If `DOCUMENT-ACCESSIBILITY-AUDIT.md` exists from a previous run, the agent compares findings and classifies each issue:

| Classification | Meaning |
|---------------|---------|
| Fixed | In the previous report, gone now |
| New | Not in the previous report, appeared now |
| Persistent | Present in both reports |
| Regressed | Was fixed in a prior scan but has returned |

Regressions are flagged prominently — if a previously passing document now has new errors, that gets a high-priority callout.

### Step 4: Score Change Summary

```
Delta Scan Results: 3 documents changed

  📄 policy-handbook.docx     Score: 82 → 91 (+9) ▲  [2 fixed, 0 new]
  📄 expense-report.xlsx      Score: 74 → 74 (± 0)   [0 fixed, 0 new, 3 persistent]
  📄 onboarding-slides.pptx   Score: 68 → 55 (-13) ▼  [0 fixed, 4 new] ⚠️ REGRESSION
```

### Step 5: Updated Report

`DOCUMENT-ACCESSIBILITY-AUDIT.md` is updated with a "Changes Since Last Scan" section at the top, preserving the full historical findings below.

## Example Variations

```
/audit-changed-documents                          # Changes since HEAD~1 (default)
/audit-changed-documents since v2.0              # Changes since a specific tag
/audit-changed-documents since last week         # Changes in the last 7 days
```

## Output Files

| File | Contents |
|------|----------|
| `DOCUMENT-ACCESSIBILITY-AUDIT.md` | Updated report with delta section at top |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Orchestrates this prompt |
| [document-inventory](../../agents/document-inventory.md) | Runs the git diff and identifies changed files |
| [cross-document-analyzer](../../agents/cross-document-analyzer.md) | Performs Fixed/New/Persistent/Regressed classification |

## Related Prompts

- [audit-document-folder](audit-document-folder.md) — scan all files, not just changed ones
- [compare-audits](compare-audits.md) — compare two full audit reports
- [setup-document-cicd](setup-document-cicd.md) — automate this scan in your CI pipeline
