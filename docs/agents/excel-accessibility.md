# excel-accessibility — Microsoft Excel (XLSX) Accessibility

> Scans Microsoft Excel spreadsheets for accessibility issues. Uses the `scan_office_document` MCP tool to parse XLSX files and check for sheet naming, table structure, merged cells, chart alt text, input messages on data-entry cells, and defined names.

## When to Use It

- Reviewing spreadsheets before publishing or sharing
- Checking budget/data templates for accessibility
- Auditing XLSX files that will be distributed externally
- Preparing spreadsheets for users who rely on screen readers

## What It Catches

<details>
<summary>Expand — 10 Excel accessibility rules (XLSX-E001 – XLSX-W004)</summary>

| Rule | Severity | Description |
|------|----------|--------------|
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

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```
/excel-accessibility scan budget.xlsx for accessibility
@excel-accessibility review the quarterly data spreadsheet
@excel-accessibility check all spreadsheets in the finance/ directory
```

</details>

## How to Launch It

**In Claude Code (terminal):**
```
/excel-accessibility scan budget.xlsx
/excel-accessibility review the data dashboard template
/excel-accessibility check all .xlsx files in /finance
```

**In GitHub Copilot Chat:**
```
@excel-accessibility scan budget.xlsx for accessibility issues
@excel-accessibility check the procurement tracker
```

**Via the prompt picker:** Select `audit-single-document` and enter the `.xlsx` file path. This runs the full strict profile and saves a `DOCUMENT-ACCESSIBILITY-AUDIT.md` report.

**Via document-accessibility-wizard:** For large collections of spreadsheets, the wizard handles inventory, scanning, and cross-document analysis automatically.

## Step-by-Step: What a Scan Session Looks Like

**You say:**
```
/excel-accessibility scan quarterly-data.xlsx
```

**What the agent does:**

1. **Parses the XLSX file** using the `scan_office_document` MCP tool. XLSX files are ZIP archives containing XML worksheets, styles, and shared strings. The agent walks every sheet.

2. **Runs all 10 accessibility rules**. For example:
   - Checks every sheet tab name against the pattern `Sheet[0-9]+` to catch XLSX-E001
   - Scans for merged cells in data regions (XLSX-E003)
   - Checks for table definitions (`<tableStyleInfo>` elements) to catch XLSX-E005
   - Inspects chart objects for `<c:title>` elements and `<xdr:sp>` alt text (XLSX-E006)

3. **Computes the score** using the standard weighted formula.

4. **Returns a finding report.** Here is a real example:

```
XLSX-E001 [Error] — High Confidence
Default sheet name used
Location: Sheet tab "Sheet3" (3rd worksheet)
Remediation: Right-click the tab in Excel → Rename → use a descriptive name
that communicates the sheet's content (e.g., "Q3 Revenue by Region").
Screen readers announce the tab name when a user navigates between sheets.
```

5. **Presents score, grade, and next steps.**

## Understanding Your Results

### Score Interpretation

| Score | Grade | What it means |
|-------|-------|---------------|
| 90–100 | A | Excellent — safe to distribute externally |
| 75–89 | B | Good — minor improvements recommended |
| 50–74 | C | Needs work — multiple errors affecting screen reader users |
| 25–49 | D | Poor — significant barriers to access |
| 0–24 | F | Failing — largely inaccessible with screen readers |

### What to Fix First

1. **XLSX-E001** (Default sheet names) — Every tab named "Sheet1" is navigation deadweight. Screen reader users cycle through tabs by name.
2. **XLSX-E003** (Merged cells in data regions) — Merged cells destroy the column/row header mapping that screen readers depend on. This is the single most damaging Excel anti-pattern.
3. **XLSX-E005** (No table header row) — Without a defined header row, assistive technology cannot announce column context as it moves through data cells.
4. **XLSX-E006** (Charts without alt text) — Charts are opaque to screen readers when alt text is absent. A brief description of the trend or key takeaway is sufficient.
5. **XLSX-W001** (Blank cells in data ranges) — Blank cells can interrupt screen reader table navigation, making it unclear whether the data region continues.

### A Note on Merged Cells

Merged cells (XLSX-E003) are the hardest Excel accessibility issue to fix because the merge is often intentional for aesthetic spacing in headers or labels. The accessible alternative is to use "Center Across Selection" instead of Merge Cells for visual spanning without breaking the data grid. For data regions, avoid merging entirely.

## Connections

| Connect to | When |
|------------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | For folder-wide Excel audits, cross-document analysis, and VPAT generation |
| [office-scan-config](office-scan-config.md) | To suppress XLSX-W003 (hidden sheets) or other rules that do not apply to your workbooks |
| [word-accessibility](word-accessibility.md) | When auditing mixed Office document collections |
| [pdf-accessibility](pdf-accessibility.md) | Spreadsheets exported to PDF need a separate PDF/UA audit — the Excel scan does not cover exported PDFs |
