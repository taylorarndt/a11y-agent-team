# quick-document-check

Fast triage of a single document - errors only, high-confidence findings only, no saved report file. Get a pass/fail verdict in seconds.

## When to Use It

- You want a fast yes/no answer before publishing or sharing a document
- You are checking many documents quickly and will do deep dives on the ones that fail
- You don't need the full report overhead - just need to know if there are blockers
- You are doing a first-pass review before sending to legal or communications for final approval

## How to Launch It

**In GitHub Copilot Chat:**

```text
/quick-document-check
```

Provide the file path when prompted. Or specify directly:

```text
/quick-document-check C:\documents\policy-brief.docx
/quick-document-check /Users/name/presentations/board-deck.pptx
```

## What to Expect

The agent scans with the minimal profile (errors only) and filters to high-confidence findings. Output appears inline in chat - no file is saved.

```text
Quick Check: policy-brief.docx
Score: 78 (C)

Errors Found: 3
  1. DOCX-E001 - Missing document title (File > Properties > Title) - High confidence
  2. DOCX-E010 - Image on page 3 has no alt text - High confidence
  3. DOCX-E020 - Heading styles not used - paragraph text formatted manually - High confidence

Verdict: NEEDS WORK - 3 errors found
```

**Verdict thresholds:**

| Verdict | Condition |
|---------|-----------|
| PASS | Zero errors |
| NEEDS WORK | 1-3 errors |
| FAIL | 4+ errors |

## The Escalation Offer

If errors are found, the agent asks: "Want to run a full audit with detailed remediation steps?" - launching [audit-single-document](audit-single-document.md) on the same file.

## Example Variations

```text
/quick-document-check path/to/report.docx         # Word document
/quick-document-check path/to/data-table.xlsx     # Excel workbook
/quick-document-check path/to/slides.pptx         # PowerPoint
/quick-document-check path/to/published.pdf       # PDF
```

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Runs the minimal-profile scan and formats the result |

## Related Prompts

- [audit-single-document](audit-single-document.md) - full strict audit with saved report
- [audit-document-folder](audit-document-folder.md) - quick-check all documents in a folder
