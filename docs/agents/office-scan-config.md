# office-scan-config — Office Scan Configuration

> Manages `.a11y-office-config.json` configuration files that control which rules the `scan_office_document` MCP tool enforces. Supports per-format rule enabling/disabling, severity filters, and three preset profiles.

## When to Use It

- Setting up scanning rules for a project's Office documents
- Creating a baseline configuration for a team
- Adjusting scan strictness (e.g., ignoring tips, only showing errors)
- Applying a preset profile (strict, moderate, or minimal)

## Preset Profiles

| Profile | Description |
|---------|-------------|
| **strict** | All rules enabled, all severities reported |
| **moderate** | All rules enabled, only errors and warnings (tips suppressed) |
| **minimal** | Only errors reported, warnings and tips suppressed |

## Example Prompts

```
/office-scan-config create a moderate config for this project
@office-scan-config disable DOCX-W005 (empty paragraphs) for this repo
@office-scan-config switch to strict profile
```
