---
description: Export markdown accessibility audit findings to a CSV file with WCAG understanding document links for each issue.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
---

# Export Markdown Audit to CSV

Export findings from a markdown accessibility audit report to CSV format with WCAG understanding document links and markdownlint rule references for every issue.

## Instructions

Use the **markdown-csv-reporter** sub-agent workflow:

1. Use askQuestions to ask:
   - "What is the path to the audit report?" - default: `MARKDOWN-ACCESSIBILITY-AUDIT.md`
   - "Which CSV files do you want?"
     - **All three** - findings, scorecard, and remediation tracker (default)
     - **Findings only** - one row per issue with help links
     - **Scorecard only** - file-level scores and grades
     - **Remediation tracker only** - prioritized fix list with effort estimates

2. Read the audit report and extract all findings.

3. Generate CSV file(s) with these conventions:
   - UTF-8 encoding with BOM (Excel compatibility)
   - CRLF line endings
   - Double-quote all text fields
   - Escape internal quotes by doubling them

4. For each finding, include:
   - File path and line number
   - Domain (links, alt text, headings, tables, emoji, diagrams, formatting, anchors)
   - Markdownlint rule ID or custom rule ID
   - WCAG success criterion
   - Severity (Critical / Serious / Moderate / Minor)
   - Confidence level (High / Medium / Low)
   - WCAG understanding document URL
   - Suggested remediation and auto-fixability

5. Save CSV files alongside the audit report:
   - `MARKDOWN-ACCESSIBILITY-FINDINGS.csv` - all issues with help links
   - `MARKDOWN-ACCESSIBILITY-SCORECARD.csv` - file scores and grades
   - `MARKDOWN-ACCESSIBILITY-REMEDIATION.csv` - prioritized action items

6. Announce the output file paths and row counts.

## Handoff Transparency

This workflow delegates to the `markdown-csv-reporter` sub-agent:
- **Start:** "Generating CSV export from markdown audit report: [N] findings across [N] files"
- **Completion:** "CSV export complete: [file paths] with [N] rows each"
- **On failure:** "CSV export failed: [reason]. No files written."
