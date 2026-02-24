---
description: Export web accessibility audit findings to a CSV file with Deque University help links for each issue.
mode: agent
tools:
  - askQuestions
  - runInTerminal
  - getTerminalOutput
---

# Export Web Audit to CSV

Export findings from a web accessibility audit report to CSV format with Deque University help documentation links for every issue.

## Instructions

Use the **web-csv-reporter** sub-agent workflow:

1. Use askQuestions to ask:
   - "What is the path to the audit report?" - default: `ACCESSIBILITY-AUDIT.md`
   - "Which CSV files do you want?"
     - **All three** - findings, scorecard, and remediation tracker (default)
     - **Findings only** - one row per issue with help links
     - **Scorecard only** - page-level scores and grades
     - **Remediation tracker only** - prioritized fix list with effort estimates

2. Read the audit report and extract all findings.

3. Generate CSV file(s) with these conventions:
   - UTF-8 encoding with BOM (Excel compatibility)
   - CRLF line endings
   - Double-quote all text fields
   - Escape internal quotes by doubling them

4. For each finding, include:
   - Page URL and element location
   - axe-core rule ID and description
   - WCAG success criterion
   - Severity (Critical / Serious / Moderate / Minor)
   - Confidence level (High / Medium / Low)
   - Deque University help URL for the rule
   - Suggested remediation

5. Save CSV files alongside the audit report:
   - `web-findings.csv` - all issues with help links
   - `web-scorecard.csv` - page scores and grades
   - `web-remediation.csv` - prioritized action items

6. Announce the output file paths and row counts.
