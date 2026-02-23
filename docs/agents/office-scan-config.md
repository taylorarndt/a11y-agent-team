# office-scan-config — Office Scan Configuration

> Manages `.a11y-office-config.json` configuration files that control which rules the `scan_office_document` MCP tool enforces. Supports per-format rule enabling/disabling, severity filters, and three preset profiles.

## When to Use It

- Setting up scanning rules for a project's Office documents
- Creating a baseline configuration for a team
- Adjusting scan strictness (e.g., ignoring tips, only showing errors)
- Applying a preset profile (strict, moderate, or minimal)

## Preset Profiles

<details>
<summary>Expand profile descriptions</summary>

| Profile | Description |
|---------|-------------|
| **strict** | All rules enabled, all severities reported |
| **moderate** | All rules enabled, only errors and warnings (tips suppressed) |
| **minimal** | Only errors reported, warnings and tips suppressed |

</details>

## Example Prompts

<details>
<summary>Show example prompts</summary>

```
/office-scan-config create a moderate config for this project
@office-scan-config disable DOCX-W005 (empty paragraphs) for this repo
@office-scan-config switch to strict profile
```

</details>

## How to Launch It

**In Claude Code:**
```
/office-scan-config create a moderate config for this project
/office-scan-config disable DOCX-W005 for this repo
/office-scan-config switch to strict profile
```

**In GitHub Copilot Chat:**
```
@office-scan-config set up scanning rules for our compliance documents
@office-scan-config we only care about errors, not warnings
```

**Via VS Code tasks:** Use the built-in task `A11y: Init Office Scan Config (Moderate)` from the task runner to copy the moderate template to your project root as `.a11y-office-config.json`.

## Step-by-Step: Configuring Your First Scan

If you are setting up Office document accessibility scanning for the first time, here is the recommended path:

**Step 1: Start with the moderate profile.**
The moderate profile runs all rules but suppresses informational tips. It is the best starting point because it gives you a complete picture without noise.
```
/office-scan-config create a moderate config for this project
```

This creates `.a11y-office-config.json` in your project root.

**Step 2: Run your first scan.**
Invoke `word-accessibility`, `excel-accessibility`, or `powerpoint-accessibility` on your documents. Review the output.

**Step 3: Tune based on your context.**
If certain rules create false-positive noise for your use case, disable them:
```
@office-scan-config disable DOCX-W005 — we intentionally use empty paragraphs for spacing
@office-scan-config disable XLSX-W003 — hidden sheets are used for reference data
```

**Step 4: Tighten for regulated documents.**
For documents that will be submitted to government procurement or published externally, switch to strict:
```
/office-scan-config switch to strict profile
```

## The Configuration File

`.a11y-office-config.json` controls which rules run and at what threshold. Here is a complete annotated example:

<details>
<summary>Expand full configuration reference</summary>

```json
{
  "version": "1.0",
  "profile": "moderate",
  "formats": {
    "docx": {
      "enabled": true,
      "rules": {
        "DOCX-E001": { "enabled": true, "severity": "error" },
        "DOCX-E002": { "enabled": true, "severity": "error" },
        "DOCX-E003": { "enabled": true, "severity": "error" },
        "DOCX-E004": { "enabled": true, "severity": "error" },
        "DOCX-E005": { "enabled": true, "severity": "error" },
        "DOCX-E006": { "enabled": true, "severity": "error" },
        "DOCX-W001": { "enabled": true, "severity": "warning" },
        "DOCX-W002": { "enabled": true, "severity": "warning" },
        "DOCX-W003": { "enabled": true, "severity": "warning" },
        "DOCX-W004": { "enabled": true, "severity": "warning" },
        "DOCX-W005": { "enabled": true, "severity": "warning" }
      }
    },
    "xlsx": {
      "enabled": true,
      "rules": {
        "XLSX-E001": { "enabled": true, "severity": "error" },
        "XLSX-E002": { "enabled": true, "severity": "error" },
        "XLSX-E003": { "enabled": true, "severity": "error" },
        "XLSX-E004": { "enabled": true, "severity": "error" },
        "XLSX-E005": { "enabled": true, "severity": "error" },
        "XLSX-E006": { "enabled": true, "severity": "error" },
        "XLSX-W001": { "enabled": true, "severity": "warning" },
        "XLSX-W002": { "enabled": true, "severity": "warning" },
        "XLSX-W003": { "enabled": true, "severity": "warning" },
        "XLSX-W004": { "enabled": true, "severity": "warning" }
      }
    },
    "pptx": {
      "enabled": true,
      "rules": {
        "PPTX-E001": { "enabled": true, "severity": "error" },
        "PPTX-E002": { "enabled": true, "severity": "error" },
        "PPTX-E003": { "enabled": true, "severity": "error" },
        "PPTX-E004": { "enabled": true, "severity": "error" },
        "PPTX-E005": { "enabled": true, "severity": "error" },
        "PPTX-E006": { "enabled": true, "severity": "error" },
        "PPTX-W001": { "enabled": true, "severity": "warning" },
        "PPTX-W002": { "enabled": true, "severity": "warning" },
        "PPTX-W003": { "enabled": true, "severity": "warning" },
        "PPTX-W004": { "enabled": true, "severity": "warning" },
        "PPTX-W005": { "enabled": true, "severity": "warning" }
      }
    }
  }
}
```

To disable a rule, set `"enabled": false`. To change a rule from error to warning, change `"severity"`. To skip an entire format, set the top-level `"enabled": false` for that format.

</details>

## When to Override Defaults

| Situation | Recommended override |
|-----------|---------------------|
| Internal-only documents, no AT users | Use minimal profile (errors only) |
| Documents for government/procurement | Use strict profile (all rules, all severities) |
| Legacy documents with intentional empty paragraphs | Disable DOCX-W005 |
| Spreadsheets with intentional hidden reference sheets | Disable XLSX-W003 |
| Presentations where speaker notes are not yet written | Disable PPTX-W004 until content is ready |
| CI/CD gate with zero-tolerance policy | Use strict profile + fail build on any error |

## Connections

| Connect to | When |
|------------|------|
| [word-accessibility](word-accessibility.md) | The config controls which DOCX rules this agent enforces |
| [excel-accessibility](excel-accessibility.md) | The config controls which XLSX rules this agent enforces |
| [powerpoint-accessibility](powerpoint-accessibility.md) | The config controls which PPTX rules this agent enforces |
| [document-accessibility-wizard](document-accessibility-wizard.md) | The wizard reads the config when running batch scans |
