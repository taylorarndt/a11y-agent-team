# epub-scan-config - ePub Scan Configuration

> Internal configuration manager for `.a11y-epub-config.json`. Not user-invokable. Invoked by `document-accessibility-wizard` during Phase 0 when `.epub` files are in scope and no config file exists, or when the user wants to customise which EPUB-* rules are enforced.

## When It Is Invoked

This agent is called internally - you will not invoke it directly. It is activated by `document-accessibility-wizard` when:

- `.epub` files are in the scan scope and `.a11y-epub-config.json` does not exist in the workspace root
- The user asks to enable, disable, or change the severity of specific EPUB rules
- The user asks to switch scan profiles (strict / moderate / minimal)

## Configuration File

Default location: `.a11y-epub-config.json` in the workspace root.

```json
{
  "$schema": "https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/schemas/epub-scan-config.schema.json",
  "version": "1.0",
  "description": "Moderate profile - errors and warnings",
  "epub": {
    "enabled": true,
    "disabledRules": [],
    "severityFilter": ["error", "warning"],
    "maxFileSize": 104857600
  }
}
```

### Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `epub.enabled` | boolean | `true` | Master toggle for ePub scanning |
| `epub.disabledRules` | string[] | `[]` | Rule IDs to skip (e.g., `["EPUB-T001"]`) |
| `epub.severityFilter` | string[] | `["error","warning"]` | Which severity levels to report |
| `epub.maxFileSize` | number | `104857600` | Max file size in bytes (default: 100 MB) |

## Scan Profiles

Three pre-built templates are available in the `templates/` directory:

| Profile | File | `severityFilter` | Use Case |
|---------|------|-----------------|----------|
| **Strict** | `epub-config-strict.json` | `["error","warning","tip"]` | EPUB Accessibility 1.1 / Section 508 compliance |
| **Moderate** | `epub-config-moderate.json` | `["error","warning"]` | Default for most organizations |
| **Minimal** | `epub-config-minimal.json` | `["error"]` | Quick triage of large ePub libraries |

Copy the desired template to your workspace root:

```powershell
# Windows
Copy-Item templates\epub-config-moderate.json .a11y-epub-config.json
```

```bash
# macOS / Linux
cp templates/epub-config-moderate.json .a11y-epub-config.json
```

## All Configurable Rules

| Rule ID | Name | Default Severity | WCAG SC |
|---------|------|-----------------|---------|
| EPUB-E001 | missing-title | error | 2.4.2 |
| EPUB-E002 | missing-unique-identifier | error | - |
| EPUB-E003 | missing-language | error | 3.1.1 |
| EPUB-E004 | missing-nav-toc | error | 2.4.1 |
| EPUB-E005 | missing-alt-text | error | 1.1.1 |
| EPUB-E006 | unordered-spine | error | 1.3.2 |
| EPUB-E007 | missing-a11y-metadata | error | - |
| EPUB-W001 | missing-page-list | warning | 2.4.1 |
| EPUB-W002 | missing-landmarks | warning | 1.3.1 |
| EPUB-W003 | heading-hierarchy | warning | 1.3.1 |
| EPUB-W004 | table-missing-headers | warning | 1.3.1 |
| EPUB-W005 | ambiguous-link-text | warning | 2.4.4 |
| EPUB-W006 | color-only-info | warning | 1.4.1 |
| EPUB-T001 | incomplete-a11y-summary | tip | - |
| EPUB-T002 | missing-author | tip | - |
| EPUB-T003 | missing-description | tip | - |

## Example: Disabling a Rule

To exclude EPUB-T002 and EPUB-T003 from all scans:

```json
{
  "epub": {
    "enabled": true,
    "disabledRules": ["EPUB-T002", "EPUB-T003"],
    "severityFilter": ["error", "warning"]
  }
}
```

## Related Agents

| Agent | Relationship |
|-------|-------------|
| [epub-accessibility](epub-accessibility.md) | Reads this config during every ePub scan |
| [document-accessibility-wizard](document-accessibility-wizard.md) | Invokes this agent during Phase 0 config setup |
