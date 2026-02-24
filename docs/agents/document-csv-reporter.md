# document-csv-reporter

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [document-accessibility-wizard](document-accessibility-wizard.md) and [cross-document-analyzer](cross-document-analyzer.md) during CSV export workflows. You do not need to invoke it directly - use the `export-document-csv` prompt instead.

## What It Does

`document-csv-reporter` converts document accessibility audit findings into structured CSV files with help documentation links for every issue. For Office documents (Word, Excel, PowerPoint), links point to Microsoft support pages. For PDF documents, links point to Adobe accessibility documentation.

Each row includes application-specific fix steps so teams can resolve issues directly from the spreadsheet without searching for remediation guidance.

## When It Runs

This agent is called by:

- `export-document-csv` prompt - the primary user-facing CSV export workflow
- `document-accessibility-wizard` - when CSV export is requested after an audit
- `cross-document-analyzer` - when exporting cross-document comparison data

## CSV Schemas

The agent produces three CSV file types:

### Findings CSV (`document-findings.csv`)

One row per issue found in the audit:

| Column | Description |
|--------|-------------|
| Document | Filename of the scanned document |
| Format | DOCX, XLSX, PPTX, or PDF |
| Location | Where in the document the issue occurs (page, slide, sheet, section) |
| Rule ID | Rule identifier (e.g., `DOCX-E001`, `PDFUA.Headings`) |
| Rule Description | Human-readable description of the violation |
| WCAG SC | WCAG success criterion (e.g., `1.3.1`) |
| Severity | Error, Warning, or Tip |
| Confidence | High, Medium, or Low |
| Help URL | Microsoft or Adobe documentation link for the rule |
| Fix Steps | Application-specific remediation steps |

### Scorecard CSV (`document-scorecard.csv`)

One row per audited document:

| Column | Description |
|--------|-------------|
| Document | Filename |
| Format | File format |
| Score | Numeric score (0-100) |
| Grade | Letter grade (A-F) |
| Errors | Count of error-severity findings |
| Warnings | Count of warning-severity findings |
| Tips | Count of tip-severity findings |
| Top Issue | Most impactful finding in this document |

### Remediation CSV (`document-remediation.csv`)

Prioritized action items:

| Column | Description |
|--------|-------------|
| Priority | Immediate, Soon, or When Possible |
| Rule ID | Rule identifier |
| Affected Documents | Count of documents with this issue |
| Severity | Error, Warning, or Tip |
| Effort | Estimated effort (Low, Medium, High) |
| Help URL | Documentation link |
| Fix Steps | Application-specific remediation steps |

## Help URL Sources

### Microsoft Office Documents

| Format | Help URL Base |
|--------|--------------|
| Word (.docx) | `https://support.microsoft.com/en-us/office/...` (accessibility checker topics) |
| Excel (.xlsx) | `https://support.microsoft.com/en-us/office/...` (spreadsheet accessibility topics) |
| PowerPoint (.pptx) | `https://support.microsoft.com/en-us/office/...` (presentation accessibility topics) |

### PDF Documents

| Source | Help URL Base |
|--------|--------------|
| Adobe PDF | `https://helpx.adobe.com/acrobat/using/...` (PDF accessibility topics) |

## Fix Step Examples

Fix steps are tailored to the application. For example:

**Word - Missing alt text (DOCX-E001):**
> Right-click the image, select Edit Alt Text, and enter a description that conveys the image's purpose. Mark decorative images as decorative.

**Excel - Missing sheet title (XLSX-E002):**
> Right-click the sheet tab, select Rename, and enter a descriptive name. Avoid generic names like "Sheet1".

**PDF - Missing document title (PDFUA.Title):**
> File, Properties, Description tab, set Title field. Check "Display document title" in Initial View.

## CSV Conventions

- **Encoding:** UTF-8 with BOM (byte order mark) for Excel compatibility
- **Line endings:** CRLF
- **Text fields:** Double-quoted
- **Internal quotes:** Escaped by doubling (`""`)

## Connections

| Component | Role |
|-----------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | Parent orchestrator that triggers CSV export |
| [cross-document-analyzer](cross-document-analyzer.md) | Provides cross-document data for export |
| [help-url-reference](../skills/help-url-reference.md) | Skill providing Microsoft and Adobe URL mappings |
| [export-document-csv](../prompts/documents/export-document-csv.md) | User-facing prompt that invokes this agent |
