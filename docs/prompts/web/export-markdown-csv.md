# export-markdown-csv

Export markdown accessibility audit findings to CSV files with WCAG understanding document links and markdownlint rule references. Opens in Excel, Google Sheets, or any spreadsheet tool. Import into issue trackers for team-based remediation workflows.

## When to Use It

- You have a completed markdown audit report and need to share findings with stakeholders who prefer spreadsheets
- You want to import accessibility issues into Jira, GitHub Issues, or Azure DevOps as work items
- You need a prioritized remediation tracker with effort estimates and ROI scores
- You want every issue linked to its WCAG understanding document for quick reference

## How to Launch It

**In GitHub Copilot Chat:**

```text
/export-markdown-csv
```

Or specify the report path:

```text
/export-markdown-csv MARKDOWN-ACCESSIBILITY-AUDIT.md
```

## What to Expect

### Step 1: Configuration

The agent asks two questions:

1. **Report path** - which audit report to export (default: `MARKDOWN-ACCESSIBILITY-AUDIT.md`)
2. **Which CSV files** - all three, or just findings, scorecard, or remediation tracker

### Step 2: Export

The agent reads the audit report, extracts all findings, and generates CSV files with:

- UTF-8 encoding with BOM for Excel compatibility
- Markdownlint rule ID or custom domain-based rule ID for every issue
- WCAG success criterion mapping
- Severity and confidence levels
- Auto-fixability indicator
- WCAG understanding document URL
- Suggested remediation text

### Step 3: Output

Files are saved alongside the audit report:

- `MARKDOWN-ACCESSIBILITY-FINDINGS.csv` - all issues with help links (one row per finding)
- `MARKDOWN-ACCESSIBILITY-SCORECARD.csv` - file-level scores and grades
- `MARKDOWN-ACCESSIBILITY-REMEDIATION.csv` - prioritized action items sorted by ROI

## Example Workflow

```text
1. Run: /audit-markdown
2. Review: MARKDOWN-ACCESSIBILITY-AUDIT.md
3. Run: /export-markdown-csv
4. Import: MARKDOWN-ACCESSIBILITY-FINDINGS.csv into Jira
5. Fix issues, then run /compare-markdown-audits to track progress
```

## Related Prompts

- [audit-markdown](../web/audit-markdown.md) - run a full markdown audit first
- [fix-markdown-issues](../web/fix-markdown-issues.md) - interactive fix mode from audit report
- [compare-markdown-audits](../web/compare-markdown-audits.md) - track remediation progress
- [export-web-csv](export-web-csv.md) - equivalent CSV export for web audits
