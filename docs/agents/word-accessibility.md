# word-accessibility — Microsoft Word (DOCX) Accessibility

> Scans Microsoft Word documents for accessibility issues. Uses the `scan_office_document` MCP tool to parse DOCX files (ZIP/XML structure) and check for tagged content, alt text on images, heading structure, table markup, reading order, language settings, and color-only formatting.

## When to Use It

- Reviewing Word documents before publishing or distributing
- Checking templates for accessibility compliance
- Auditing existing DOCX files as part of a document accessibility program
- Preparing documents for PDF conversion (accessibility issues carry over)

## What It Catches

| Rule | Severity | Description |
|------|----------|-------------|
| DOCX-E001 | Error | Images without alt text |
| DOCX-E002 | Error | Missing document title in properties |
| DOCX-E003 | Error | No headings used for document structure |
| DOCX-E004 | Error | Tables without header rows |
| DOCX-E005 | Error | Missing document language |
| DOCX-E006 | Error | Color-only formatting conveying meaning |
| DOCX-W001 | Warning | Very long alt text that needs summarization |
| DOCX-W002 | Warning | Skipped heading levels |
| DOCX-W003 | Warning | Merged cells in tables |
| DOCX-W004 | Warning | Small font sizes below 10pt |
| DOCX-W005 | Warning | Empty paragraphs used for spacing |

## Example Prompts

```
/word-accessibility scan report.docx for accessibility issues
@word-accessibility review the quarterly report template
@word-accessibility check all Word documents in the docs/ directory
```
