# Office Document Scanning

The `scan_office_document` MCP tool scans DOCX, XLSX, and PPTX files by parsing their ZIP/XML structure. No external dependencies required.

## Rules by Format

| Format | Rules | Key Checks |
|--------|-------|------------|
| **DOCX** | 16 rules (DOCX-E*, DOCX-W*, DOCX-T*) | Alt text, headings, table headers, language, document title, color-only formatting, empty paragraphs, font sizes |
| **XLSX** | 14 rules (XLSX-E*, XLSX-W*, XLSX-T*) | Sheet names, merged cells, header rows, chart alt text, defined names, hidden sheets, input messages |
| **PPTX** | 16 rules (PPTX-E*, PPTX-W*, PPTX-T*) | Slide titles, reading order, alt text, table headers, audio/video, language, font sizes, speaker notes |

## Usage

```
# Claude Code
/word-accessibility scan docs/report.docx
/excel-accessibility check data/budget.xlsx
/powerpoint-accessibility review slides/deck.pptx

# Copilot
@word-accessibility scan the annual report
@excel-accessibility check the spreadsheet template
@powerpoint-accessibility review the training presentation
```

## Output Formats

- **SARIF** (default) — Machine-readable, compatible with GitHub Code Scanning
- **Markdown** — Human-readable report with severity, rule explanations, and remediation guidance

## CI/CD Script

The CI scanner at `.github/scripts/office-a11y-scan.mjs`:
- Discovers documents recursively (skipping `node_modules`, `.git`, `vendor`)
- Applies `.a11y-office-config.json` if present
- Outputs SARIF 2.1.0 reports
- Emits GitHub Actions `::error::` and `::warning::` annotations
- Exits with code 1 if error-severity findings are detected

```yaml
- name: Scan Office documents for accessibility
  run: node .github/scripts/office-a11y-scan.mjs
```
