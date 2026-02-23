# pdf-scan-config - PDF Scan Configuration

> Manages `.a11y-pdf-config.json` configuration files that control which rules the `scan_pdf_document` MCP tool enforces. Supports rule enabling/disabling, severity filters, max file size limits, and three preset profiles.

## When to Use It

- Setting up scanning rules for a project's PDF documents
- Adjusting which rule layers to enforce (PDFUA, PDFBP, PDFQ)
- Setting file size limits for scan performance
- Applying a preset profile (strict, moderate, or minimal)

## Preset Profiles

<details>
<summary>Expand profile descriptions</summary>

| Profile | Rules | Description |
|---------|-------|-------------|
| **strict** | All 56 rules | All rules enabled, all severities |
| **moderate** | PDFUA + PDFBP | Errors and warnings only |
| **minimal** | PDFUA only | Errors only |

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```text
/pdf-scan-config create a strict config for this project
@pdf-scan-config disable PDFBP rules and only check PDF/UA
@pdf-scan-config set max file size to 50MB
```

</details>

## How to Launch It

**In Claude Code:**

```text
/pdf-scan-config create a moderate config for this project
/pdf-scan-config disable PDFBP rules, only check PDF/UA compliance
/pdf-scan-config set max file size to 50MB
```

**In GitHub Copilot Chat:**

```text
@pdf-scan-config set up PDF scanning for our procurement documents
@pdf-scan-config we only need PDF/UA checks, skip best practices
```

**Via VS Code tasks:** Use the built-in task `A11y: Init PDF Scan Config (Moderate)` to copy the moderate template to your project root as `.a11y-pdf-config.json`.

## Step-by-Step: Configuring PDF Scanning

**Step 1: Identify your compliance target.**

Different use cases require different rule layers:

- **Government/procurement (Section 508, EN 301 549):** Use strict profile - all 56 rules
- **Internal documents:** Use moderate profile - PDFUA + PDFBP, errors and warnings
- **Quick CI/CD gate, legacy document backlog:** Use minimal profile - PDFUA errors only

**Step 2: Create the config.**

```text
/pdf-scan-config create a moderate config
```

This creates `.a11y-pdf-config.json` in your project root.

**Step 3: Set performance limits if needed.**

For large PDF libraries, scanning very large files can be slow. Set a file size limit:

```text
/pdf-scan-config set max file size to 25MB
```

Files exceeding the limit are flagged in the inventory but skipped during scanning.

**Step 4: Disable rule layers you do not need.**
If your organization cares only about PDF/UA structural conformance and not best practices:

```text
/pdf-scan-config disable the PDFBP layer
```

## The Configuration File

`.a11y-pdf-config.json` controls which rule layers and individual rules run. Here is a complete annotated example:

<details>
<summary>Expand full PDF configuration reference</summary>

```json
{
  "version": "1.0",
  "profile": "moderate",
  "maxFileSizeMB": 100,
  "layers": {
    "PDFUA": {
      "enabled": true,
      "rules": {
        "PDFUA.TAGS.001": { "enabled": true, "severity": "error" },
        "PDFUA.TAGS.002": { "enabled": true, "severity": "error" },
        "PDFUA.TAGS.003": { "enabled": true, "severity": "error" },
        "PDFUA.TAGS.004": { "enabled": true, "severity": "error" },
        "PDFUA.TAGS.005": { "enabled": true, "severity": "error" },
        "PDFUA.META.001": { "enabled": true, "severity": "error" },
        "PDFUA.META.002": { "enabled": true, "severity": "error" },
        "PDFUA.NAV.001":  { "enabled": true, "severity": "error" },
        "PDFUA.FORM.001": { "enabled": true, "severity": "error" },
        "PDFUA.FONT.001": { "enabled": true, "severity": "error" }
      }
    },
    "PDFBP": {
      "enabled": true,
      "rules": {}
    },
    "PDFQ": {
      "enabled": true,
      "rules": {
        "PDFQ.SCAN.001": { "enabled": true, "severity": "error" },
        "PDFQ.ENC.001":  { "enabled": true, "severity": "error" }
      }
    }
  }
}
```

To disable an entire layer, set `"enabled": false` on the layer. To disable a specific rule, set its `"enabled": false`. To change severity, update the `"severity"` value.

</details>

## Rule Layer Guide

| Layer | Rules | Use When |
|-------|-------|----------|
| **PDFUA** | 30 rules | Always - these are the conformance requirements |
| **PDFBP** | 22 rules | When distributing externally or for public sector compliance |
| **PDFQ** | 4 rules | Always - these catch pipeline issues (scanned PDFs, encryption) |

## Connections

| Connect to | When |
|------------|------|
| [pdf-accessibility](pdf-accessibility.md) | The config controls which rules pdf-accessibility enforces |
| [document-accessibility-wizard](document-accessibility-wizard.md) | The wizard reads the PDF config when running batch PDF scans |
| [office-scan-config](office-scan-config.md) | Use alongside pdf-scan-config when auditing mixed Office + PDF collections |
