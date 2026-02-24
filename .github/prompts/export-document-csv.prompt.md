---
description: Export document accessibility audit findings to a CSV file with Microsoft Office and Adobe PDF help links for each issue.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
---

# Export Document Audit to CSV

Export findings from a document accessibility audit report to CSV format with Microsoft Office and Adobe PDF help documentation links for every issue.

## Instructions

Use the **document-csv-reporter** sub-agent workflow:

1. Use askQuestions to ask:
   - "What is the path to the audit report?" - default: `DOCUMENT-ACCESSIBILITY-AUDIT.md`
   - "Which CSV files do you want?"
     - **All three** - findings, scorecard, and remediation tracker (default)
     - **Findings only** - one row per issue with help links
     - **Scorecard only** - per-document scores and grades
     - **Remediation tracker only** - prioritized fix list with effort estimates

2. Read the audit report and extract all findings.

3. Generate CSV file(s) with these conventions:
   - UTF-8 encoding with BOM (Excel compatibility)
   - CRLF line endings
   - Double-quote all text fields
   - Escape internal quotes by doubling them

4. For each finding, include:
   - Document filename and location within document
   - Rule ID (DOCX-E/W/T*, XLSX-E/W/T*, PPTX-E/W/T*, PDFUA.*, PDFBP.*, PDFQ.*)
   - Rule description
   - WCAG success criterion
   - Severity (Error / Warning / Tip)
   - Confidence level (High / Medium / Low)
   - Help URL (Microsoft support for Office, Adobe for PDF)
   - Application-specific fix steps

5. Save CSV files alongside the audit report:
   - `document-findings.csv` - all issues with help links
   - `document-scorecard.csv` - per-document scores and grades
   - `document-remediation.csv` - prioritized action items

6. Announce the output file paths and row counts.
