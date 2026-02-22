# excel-accessibility — Microsoft Excel (XLSX) Accessibility

> Scans Microsoft Excel spreadsheets for accessibility issues. Uses the `scan_office_document` MCP tool to parse XLSX files and check for sheet naming, table structure, merged cells, chart alt text, input messages on data-entry cells, and defined names.

## When to Use It

- Reviewing spreadsheets before publishing or sharing
- Checking budget/data templates for accessibility
- Auditing XLSX files that will be distributed externally
- Preparing spreadsheets for users who rely on screen readers

## What It Catches

| Rule | Severity | Description |
|------|----------|-------------|
| XLSX-E001 | Error | Default sheet names like "Sheet1" |
| XLSX-E002 | Error | Missing defined names for data ranges |
| XLSX-E003 | Error | Merged cells that confuse screen readers |
| XLSX-E004 | Error | Missing sheet tab color differentiation |
| XLSX-E005 | Error | No header row in data tables |
| XLSX-E006 | Error | Charts without alt text or descriptions |
| XLSX-W001 | Warning | Blank cells in data ranges |
| XLSX-W002 | Warning | Very wide rows beyond column Z |
| XLSX-W003 | Warning | Hidden sheets that may hide important content |
| XLSX-W004 | Warning | Missing input messages on data validation cells |

## Example Prompts

```
/excel-accessibility scan budget.xlsx for accessibility
@excel-accessibility review the quarterly data spreadsheet
@excel-accessibility check all spreadsheets in the finance/ directory
```
