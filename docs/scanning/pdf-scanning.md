# PDF Document Scanning

The `scan_pdf_document` MCP tool scans PDF files by parsing their binary structure. It checks against three rule layers aligned with the PDF/UA standard (ISO 14289) and the Matterhorn Protocol.

## Rule Layers

| Layer | Rules | Purpose |
|-------|-------|---------|
| **PDFUA.*** | 30 rules | PDF/UA conformance — tagged structure, metadata, navigation, forms, tables, fonts |
| **PDFBP.*** | 22 rules | Best practices beyond PDF/UA requirements |
| **PDFQ.*** | 4 rules | Pipeline quality — file size limits, scan detection, encryption checks |

## Key Detections

- Missing tagged structure (no structure tree)
- Suspect flags indicating scanned-image PDFs
- Missing or empty document title and language
- Figures without `/Alt` text in the tag tree
- Tables without `/TH` header cells
- Unlabeled form fields
- Missing bookmarks for navigation
- Non-embedded fonts
- Encryption that restricts assistive technology access

## Usage

```
# Claude Code
/pdf-accessibility scan legal/contract.pdf
/pdf-accessibility check all PDFs in the docs/ directory

# Copilot
@pdf-accessibility review the annual report PDF
@pdf-accessibility scan contract.pdf for PDF/UA conformance
```

## CI/CD Script

The CI scanner at `.github/scripts/pdf-a11y-scan.mjs`:
- Discovers PDFs recursively (skipping `node_modules`, `.git`, `vendor`)
- Applies `.a11y-pdf-config.json` if present
- Outputs SARIF 2.1.0 reports
- Emits GitHub Actions annotations
- Exits with code 1 if error-severity findings are detected

```yaml
- name: Scan PDF documents for accessibility
  run: node .github/scripts/pdf-a11y-scan.mjs
```
