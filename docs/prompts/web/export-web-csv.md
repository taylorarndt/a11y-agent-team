# export-web-csv

Export web accessibility audit findings to CSV files with Deque University help documentation links. Opens in Excel, Google Sheets, or any spreadsheet tool. Import into issue trackers for team-based remediation workflows.

## When to Use It

- You have a completed web audit report and need to share findings with stakeholders who prefer spreadsheets
- You want to import accessibility issues into Jira, GitHub Issues, or Azure DevOps as work items
- You need a prioritized remediation tracker with effort estimates and ROI scores
- You want every issue linked to its Deque University help page for quick reference

## How to Launch It

**In GitHub Copilot Chat:**

```text
/export-web-csv
```

Or specify the report path:

```text
/export-web-csv ACCESSIBILITY-AUDIT.md
```

## What to Expect

### Step 1: Configuration

The agent asks two questions:

1. **Report path** - which audit report to export (default: `ACCESSIBILITY-AUDIT.md`)
2. **Which CSV files** - all three, or just findings, scorecard, or remediation tracker

### Step 2: Export

The agent reads the audit report, extracts all findings, and generates CSV files with:

- UTF-8 encoding with BOM for Excel compatibility
- Deque University help URL for every axe-core rule ID
- WCAG success criterion mapping
- Severity and confidence levels
- Suggested remediation text

### Step 3: Output

Files are saved alongside the audit report.

## Output Files

| File | Contents |
|------|----------|
| `web-findings.csv` | One row per issue - rule ID, element, WCAG SC, severity, help URL, remediation |
| `web-scorecard.csv` | One row per page - score (0-100), grade (A-F), issue counts by severity |
| `web-remediation.csv` | Prioritized action items with effort estimates and ROI scores |

## Connected Agents

| Agent | Role |
|-------|------|
| [web-csv-reporter](../../agents/web-csv-reporter.md) | Internal agent that generates the CSV files |
| [web-accessibility-wizard](../../agents/web-accessibility-wizard.md) | Orchestrator that can trigger CSV export after an audit |

## Related Prompts

- [audit-web-page](audit-web-page.md) - run a full audit first, then export to CSV
- [audit-web-multi-page](audit-web-multi-page.md) - multi-page audit with cross-page patterns
- [fix-web-issues](fix-web-issues.md) - apply fixes from the audit report
- [compare-web-audits](compare-web-audits.md) - track remediation progress between audits
