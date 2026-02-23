# Scan Configuration

Both Office and PDF scanning tools support project-level configuration files that control which rules are enforced.

## Office Configuration

**File:** `.a11y-office-config.json`

<details>
<summary>Expand Office configuration JSON example</summary>

```json
{
  "docx": {
    "enabled": true,
    "disabledRules": ["DOCX-W005"],
    "severityFilter": ["error", "warning"]
  },
  "xlsx": {
    "enabled": true,
    "disabledRules": [],
    "severityFilter": ["error", "warning", "tip"]
  },
  "pptx": {
    "enabled": true,
    "disabledRules": [],
    "severityFilter": ["error", "warning"]
  }
}
```

</details>

## PDF Configuration

**File:** `.a11y-pdf-config.json`

<details>
<summary>Expand PDF configuration JSON example</summary>

```json
{
  "enabled": true,
  "disabledRules": [],
  "severityFilter": ["error", "warning"],
  "maxFileSize": 104857600
}
```

</details>

Both config files are searched upward from the scanned file's directory. Use the `office-scan-config` and `pdf-scan-config` agents to generate configurations interactively.

## Preset Profiles

<details>
<summary>Expand preset profile descriptions</summary>

The `templates/` directory contains pre-built profiles:

| Profile | Office Config | PDF Config | Description |
|---------|--------------|-----------|-------------|
| **strict** | `office-config-strict.json` | `pdf-config-strict.json` | All rules, all severities |
| **moderate** | `office-config-moderate.json` | `pdf-config-moderate.json` | Errors and warnings only |
| **minimal** | `office-config-minimal.json` | `pdf-config-minimal.json` | Errors only |

</details>

**Quick setup with VS Code tasks:**

Use `A11y: Init Office Scan Config` and `A11y: Init PDF Scan Config` from the command palette to copy a moderate profile into your project root.

**Manual setup:**

```bash
cp templates/office-config-moderate.json .a11y-office-config.json
cp templates/pdf-config-moderate.json .a11y-pdf-config.json
```

See [templates/README.md](../../templates/README.md) for customization guidance.
