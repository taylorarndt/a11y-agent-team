# pdf-accessibility — PDF Document Accessibility

> Scans PDF documents for conformance with PDF/UA (ISO 14289) and the Matterhorn Protocol. Uses the `scan_pdf_document` MCP tool to parse PDF files and check tagged structure, metadata (title, language), bookmarks, form field labels, figure alt text, table structure, font embedding, and encryption restrictions.

## When to Use It

- Reviewing PDFs before publishing or distributing
- Checking PDF conformance for procurement (Section 508, EN 301 549)
- Auditing scanned documents for basic structural accessibility
- Verifying PDF/UA compliance after conversion from Office documents

## Rule Layers

| Layer | Rules | Purpose |
|-------|-------|---------|
| **PDFUA.*** | 30 rules | PDF/UA conformance — tagged structure, metadata, navigation, forms, tables, fonts |
| **PDFBP.*** | 22 rules | Best practices beyond PDF/UA requirements |
| **PDFQ.*** | 4 rules | Pipeline quality — file size limits, scan detection, encryption checks |

## Key Checks

- Missing tagged structure (PDFUA.TAGS.001)
- No document title in metadata (PDFUA.META.001)
- Missing document language (PDFUA.META.002)
- Figures without alt text (PDFUA.TAGS.004)
- Tables without headers (PDFUA.TAGS.005)
- Unlabeled form fields (PDFUA.FORM.001)
- Missing bookmarks (PDFUA.NAV.001)
- Non-embedded fonts (PDFUA.FONT.001)
- Scanned image PDFs (PDFQ.SCAN.001)
- Encryption restricting assistive technology (PDFQ.ENC.001)

## Example Prompts

```
/pdf-accessibility scan contract.pdf for PDF/UA compliance
@pdf-accessibility review the annual report PDF
@pdf-accessibility check all PDFs in the legal/ directory
@pdf-accessibility what PDFUA rules does this file violate?
```
