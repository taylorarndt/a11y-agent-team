# audit-single-document

Run a full accessibility audit on a single Office document or PDF. Uses the strict scan profile (all rules, all severities) and produces a detailed scored report.

## When to Use It

- You want a complete audit of one document before publishing or distributing it
- You need to document the accessibility state of a specific file
- You are checking a document someone else created
- You want to establish a baseline before remediation work

## How to Launch It

**In GitHub Copilot Chat:**
```
/audit-single-document
```

Then provide the file path when prompted. Or specify directly:

```
/audit-single-document C:\reports\annual-report-2026.docx
/audit-single-document /Users/name/docs/training-module.pptx
```

## What to Expect

### Step 1: File Type Identification

The agent reads the file extension:
- `.docx` → delegates to [word-accessibility](../../agents/word-accessibility.md)
- `.xlsx` → delegates to [excel-accessibility](../../agents/excel-accessibility.md)
- `.pptx` → delegates to [powerpoint-accessibility](../../agents/powerpoint-accessibility.md)
- `.pdf` → delegates to [pdf-accessibility](../../agents/pdf-accessibility.md)

### Step 2: Strict Profile Scan

The strict profile runs all rules at all severity levels and reports every finding — including tips and informational notices. Unlike the moderate or minimal profiles, nothing is filtered out.

### Step 3: Scoring

The document receives a 0–100 severity score and A–F grade based on the weighted findings. See [cross-document-analyzer](../../agents/cross-document-analyzer.md) for the scoring formula.

### Step 4: Report Generation

The full audit is written to `DOCUMENT-ACCESSIBILITY-AUDIT.md` with:

- **Metadata dashboard** — document title, language, author, template, modification date
- **Score and grade** — 0–100 with letter grade and trend arrow
- **Findings organized by severity** — Errors first, then Warnings, then Tips
- **Each finding:** Rule ID, description, location, WCAG criterion, confidence level, fix steps
- **Remediation priority list** — ordered by impact

### Step 5: Follow-Up Offers

After the report is written, the agent offers:
- Run a VPAT from these results (→ `generate-vpat`)
- Generate batch remediation scripts (→ `generate-remediation-scripts`)
- Re-scan after fixing

## Example Variations

```
/audit-single-document path/to/policy-document.docx
/audit-single-document path/to/quarterly-data.xlsx
/audit-single-document path/to/board-presentation.pptx
/audit-single-document path/to/published-report.pdf
```

## Output Files

| File | Contents |
|------|----------|
| `DOCUMENT-ACCESSIBILITY-AUDIT.md` | Full report with findings, score, metadata, and fix guidance |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Orchestrates this prompt |
| [word-accessibility](../../agents/word-accessibility.md) | Handles `.docx` files |
| [excel-accessibility](../../agents/excel-accessibility.md) | Handles `.xlsx` files |
| [powerpoint-accessibility](../../agents/powerpoint-accessibility.md) | Handles `.pptx` files |
| [pdf-accessibility](../../agents/pdf-accessibility.md) | Handles `.pdf` files |

## Related Prompts

- [quick-document-check](quick-document-check.md) — faster triage, no report file
- [audit-document-folder](audit-document-folder.md) — audit all documents in a folder
- [generate-vpat](generate-vpat.md) — export findings as a VPAT conformance report
