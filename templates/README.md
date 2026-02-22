# Scan Configuration Templates

Ready-to-use configuration files for the document accessibility wizard.

## How to Use

Copy the appropriate template to your project root and rename it:

### Office Documents (.docx, .xlsx, .pptx)

```bash
# Pick one:
cp templates/office-config-strict.json .a11y-office-config.json
cp templates/office-config-moderate.json .a11y-office-config.json
cp templates/office-config-minimal.json .a11y-office-config.json
```

### PDF Documents

```bash
# Pick one:
cp templates/pdf-config-strict.json .a11y-pdf-config.json
cp templates/pdf-config-moderate.json .a11y-pdf-config.json
cp templates/pdf-config-minimal.json .a11y-pdf-config.json
```

## Profiles

| Profile | Severities | Best For |
|---------|-----------|----------|
| **Strict** | Error + Warning + Tip | Public-facing documents, government (Section 508, EN 301 549), legal compliance |
| **Moderate** | Error + Warning | Most organizations, internal document standards |
| **Minimal** | Error only | Initial triage of large document libraries, quick health checks |

## Customization

After copying, edit the config to disable specific rules:

```json
{
  "docx": {
    "enabled": true,
    "disabledRules": ["DOCX-T001", "DOCX-T002"],
    "severityFilter": ["error", "warning"]
  }
}
```

See the [office-scan-config agent](../.github/agents/office-scan-config.agent.md) and [pdf-scan-config agent](../.github/agents/pdf-scan-config.agent.md) for the full rule reference.
