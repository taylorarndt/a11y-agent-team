# pdf-scan-config — PDF Scan Configuration

> Manages `.a11y-pdf-config.json` configuration files that control which rules the `scan_pdf_document` MCP tool enforces. Supports rule enabling/disabling, severity filters, max file size limits, and three preset profiles.

## When to Use It

- Setting up scanning rules for a project's PDF documents
- Adjusting which rule layers to enforce (PDFUA, PDFBP, PDFQ)
- Setting file size limits for scan performance
- Applying a preset profile (strict, moderate, or minimal)

## Preset Profiles

| Profile | Rules | Description |
|---------|-------|-------------|
| **strict** | All 56 rules | All rules enabled, all severities |
| **moderate** | PDFUA + PDFBP | Errors and warnings only |
| **minimal** | PDFUA only | Errors only |

## Example Prompts

```
/pdf-scan-config create a strict config for this project
@pdf-scan-config disable PDFBP rules and only check PDF/UA
@pdf-scan-config set max file size to 50MB
```
