---
description: Audit a single Office document or PDF for accessibility issues. Runs the document accessibility wizard in focused single-file mode with strict scanning.
mode: agent
tools:
  - askQuestions
---

# Single Document Accessibility Audit

Run a full accessibility audit on the document at the path below. Use the **document-accessibility-wizard** agent with these settings:

- **Scan mode:** Single file
- **Scan profile:** Strict (all rules, all severities)
- **Report path:** `DOCUMENT-ACCESSIBILITY-AUDIT.md`
- **Organization:** By severity (errors first)
- **Remediation steps:** Yes (detailed)
- **Include:** Severity scoring, metadata dashboard, confidence levels

## Document to audit

**Path:** `${input:documentPath}`

## Instructions

1. Identify the file type (.docx, .xlsx, .pptx, or .pdf) from the path
2. Delegate to the appropriate sub-agent (word-accessibility, excel-accessibility, powerpoint-accessibility, or pdf-accessibility)
3. Collect findings with confidence levels
4. Compute the severity score (0-100) and letter grade
5. Generate the full audit report
6. Offer follow-up actions (fix, re-scan, export)

## Handoff Transparency

This workflow delegates to a format-specific sub-agent. Announce transitions:
- **Before delegation:** "Scanning [filename] using [word/excel/powerpoint/pdf]-accessibility agent..."
- **After completion:** "Scan complete: [N] findings ([N] critical, [N] serious). Score: [score]/100 ([grade])"
- **On failure:** "Scan failed for [filename]: [reason]. Check the file path and format."
