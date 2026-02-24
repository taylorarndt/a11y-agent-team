---
description: Scan only documents that changed since the last commit, tag, or audit. Perfect for CI workflows and incremental reviews.
mode: agent
tools:
  - askQuestions
---

# Delta Document Accessibility Scan

Run an incremental accessibility audit - scan only documents that have changed since the last audit or git reference.

## Settings

- **Scan mode:** Changed files only (delta scan)
- **Delta method:** Git diff
- **Git reference:** Last commit (HEAD~1)
- **Document types:** All supported (.docx, .xlsx, .pptx, .pdf)
- **Scan profile:** Strict
- **Report path:** `DOCUMENT-ACCESSIBILITY-AUDIT.md`
- **Remediation steps:** Yes (detailed)

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Run `git diff --name-only HEAD~1 HEAD` filtered to document extensions (.docx, .xlsx, .pptx, .pdf)
2. If no changed documents are found, report "No document changes detected" and stop
3. For each changed document, delegate to the appropriate sub-agent
4. If a previous audit report exists (`DOCUMENT-ACCESSIBILITY-AUDIT.md`), compare findings:
   - Mark issues as **Fixed**, **New**, **Persistent**, or **Regressed**
   - Show the score change (previous vs. current)
5. Generate an updated report with the comparison section
6. Highlight any regressions prominently

## Handoff Transparency

This workflow delegates to format-specific sub-agents for each changed document. Announce transitions:
- **Start:** "Found [N] changed documents since last commit"
- **Per file:** "Scanning [filename] using [agent-name]..."
- **After completion:** "Delta scan complete: [N] files scanned, [N] regressions, [N] improvements"
- **On failure:** "Scan failed for [filename]: [reason]. Continuing with remaining files."
