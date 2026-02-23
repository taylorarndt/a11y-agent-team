# document-scanning Skill

> Document discovery, inventory building, and metadata extraction for accessibility audits. Covers PowerShell and Bash file discovery commands, supported file types, delta detection via git diff and timestamps, files to skip, scan configuration file format, and the context-passing format used when delegating to sub-agents.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [document-accessibility-wizard](../agents/document-accessibility-wizard.md) | Discovery and delegation for all document scans |
| [document-inventory](../agents/document-inventory.md) | Building file inventories and detecting changed files |

## Supported File Types

| Extension | Type | Sub-Agent |
|-----------|------|-----------|
| `.docx` | Word document | word-accessibility |
| `.xlsx` | Excel workbook | excel-accessibility |
| `.pptx` | PowerPoint presentation | powerpoint-accessibility |
| `.pdf` | PDF document | pdf-accessibility |
| `.epub` | ePub publication | epub-accessibility |

## File Discovery Commands

### PowerShell (Windows)

```powershell
# Non-recursive
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf,*.epub

# Recursive - excluding temp and lock files
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf,*.epub -Recurse |
  Where-Object { $_.Name -notlike '~$*' -and $_.Name -notlike '*.tmp' -and $_.Name -notlike '*.bak' } |
  Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules|__pycache__|\.vscode)[\\/]' }
```

### Bash (macOS / Linux)

```bash
# Recursive
find "<folder>" -type f \( -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.pdf" -o -name "*.epub" \) \
  ! -name "~\$*" ! -name "*.tmp" ! -name "*.bak" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/__pycache__/*"
```

## Files to Always Skip

- `~$*` - Office lock files (created when a document is open)
- `*.tmp` - Temporary files
- `*.bak` - Backup files
- Anything inside `.git/`, `node_modules/`, `.vscode/`, `__pycache__/`

## Delta Detection

### Git-based (preferred for CI)

```bash
# Changed since last commit
git diff --name-only HEAD~1 HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf' '*.epub'

# Changed since a specific tag
git diff --name-only <tag> HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf' '*.epub'
```

### Timestamp-based (PowerShell)

```powershell
Get-ChildItem -Path "<folder>" -Recurse -File -Include *.docx,*.xlsx,*.pptx,*.pdf,*.epub |
  Where-Object { $_.LastWriteTime -gt [datetime]"2025-01-01" }
```

## Scan Profiles

| Profile | Severities Reported | Use Case |
|---------|---------------------|----------|
| **Strict** | Error, Warning, Tip | Public-facing or legally required documents |
| **Moderate** | Error, Warning | Most organizations (default) |
| **Minimal** | Error only | Triaging large document libraries |

## Configuration Files

| File | Controls |
|------|---------|
| `.a11y-office-config.json` | Word, Excel, PowerPoint rule settings |
| `.a11y-pdf-config.json` | PDF rule settings |
| `.a11y-epub-config.json` | ePub rule settings |

## Context-Passing Format

When delegating to a format-specific sub-agent, always provide:

```text
## Document Scan Context
- File: [full path]
- Scan Profile: [strict | moderate | minimal]
- Severity Filter: [error, warning, tip]
- Disabled Rules: [list or "none"]
- User Notes: [any specifics]
- Part of Batch: [yes/no - if yes, X of Y]
```

## Skill Location

`.github/skills/document-scanning/SKILL.md`
