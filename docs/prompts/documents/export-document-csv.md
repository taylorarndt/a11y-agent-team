# export-document-csv

Export document accessibility audit findings to CSV files with Microsoft Office and Adobe PDF help documentation links. Opens in Excel, Google Sheets, or any spreadsheet tool. Import into issue trackers for team-based remediation workflows.

## When to Use It

- You have a completed document audit report and need to share findings with content teams who prefer spreadsheets
- You want to import document accessibility issues into a tracking system
- You need a prioritized remediation tracker with application-specific fix steps
- You want every issue linked to its Microsoft or Adobe help page for quick reference

## How to Launch It

**In GitHub Copilot Chat:**

```text
/export-document-csv
```

Or specify the report path:

```text
/export-document-csv DOCUMENT-ACCESSIBILITY-AUDIT.md
```

## What to Expect

### Step 1: Configuration

The agent asks two questions:

1. **Report path** - which audit report to export (default: `DOCUMENT-ACCESSIBILITY-AUDIT.md`)
2. **Which CSV files** - all three, or just findings, scorecard, or remediation tracker

### Step 2: Export

The agent reads the audit report, extracts all findings, and generates CSV files with:

- UTF-8 encoding with BOM for Excel compatibility
- Microsoft support URLs for Office documents, Adobe help URLs for PDFs
- Application-specific fix steps (Word, Excel, PowerPoint, or Acrobat Pro)
- WCAG success criterion mapping
- Severity and confidence levels

### Step 3: Output

Files are saved alongside the audit report.

## Output Files

| File | Contents |
|------|----------|
| `document-findings.csv` | One row per issue - rule ID, document, WCAG SC, severity, help URL, fix steps |
| `document-scorecard.csv` | One row per document - score (0-100), grade (A-F), error/warning/tip counts |
| `document-remediation.csv` | Prioritized action items with effort estimates and fix steps |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-csv-reporter](../../agents/document-csv-reporter.md) | Internal agent that generates the CSV files |
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Orchestrator that can trigger CSV export after an audit |

## Related Prompts

- [audit-single-document](audit-single-document.md) - audit one document first, then export to CSV
- [audit-document-folder](audit-document-folder.md) - recursive folder scan
- [generate-vpat](generate-vpat.md) - generate a VPAT/ACR compliance report instead
- [compare-audits](compare-audits.md) - track remediation progress between audits
