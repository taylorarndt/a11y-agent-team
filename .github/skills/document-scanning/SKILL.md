---
name: document-scanning
description: Document discovery, inventory building, and metadata extraction for accessibility audits. Use when scanning folders for Office documents (.docx, .xlsx, .pptx) and PDFs, building file inventories, detecting changes via git diff, or extracting document properties like title, author, and language.
---

# Document Scanning

## Supported File Types

| Extension | Type | Sub-Agent |
|-----------|------|-----------|
| .docx | Word document | word-accessibility |
| .xlsx | Excel workbook | excel-accessibility |
| .pptx | PowerPoint presentation | powerpoint-accessibility |
| .pdf | PDF document | pdf-accessibility |

## File Discovery Commands

### PowerShell (Windows)
```powershell
# Non-recursive scan
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf

# Recursive scan
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf -Recurse |
  Where-Object { $_.Name -notlike '~$*' -and $_.Name -notlike '*.tmp' -and $_.Name -notlike '*.bak' } |
  Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules|__pycache__|\.vscode)[\\/]' }
```

### Bash (macOS/Linux)
```bash
# Non-recursive scan
find "<folder>" -maxdepth 1 -type f \( -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.pdf" \) ! -name "~\$*"

# Recursive scan
find "<folder>" -type f \( -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.pdf" \) \
  ! -name "~\$*" ! -name "*.tmp" ! -name "*.bak" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/__pycache__/*" ! -path "*/.vscode/*"
```

## Delta Detection

### Git-based
```bash
# Files changed since last commit
git diff --name-only HEAD~1 HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf'

# Files changed since a specific tag
git diff --name-only <tag> HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf'

# Files changed in the last N days
git log --since="N days ago" --name-only --diff-filter=ACMR --pretty="" -- '*.docx' '*.xlsx' '*.pptx' '*.pdf' | sort -u
```

### Timestamp-based (PowerShell)
```powershell
# Files modified since a specific date
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf -Recurse |
  Where-Object { $_.LastWriteTime -gt [datetime]"2025-01-01" }
```

## Files to Skip

Always exclude these patterns during scanning:
- `~$*` - Office lock/temp files (created when a document is open)
- `*.tmp` - Temporary files
- `*.bak` - Backup files
- Files inside `.git/`, `node_modules/`, `.vscode/`, `__pycache__/` directories

## Scan Configuration Files

| File | Purpose |
|------|---------|
| `.a11y-office-config.json` | Rule enable/disable for Word, Excel, PowerPoint |
| `.a11y-pdf-config.json` | Rule enable/disable for PDF scanning |

### Scan Profiles

| Profile | Rules | Severities | Use Case |
|---------|-------|------------|----------|
| Strict | All | Error, Warning, Tip | Public-facing, legally required documents |
| Moderate | All | Error, Warning | Most organizations |
| Minimal | All | Error only | Triaging large document libraries |

## Context Passing Format

When delegating to a sub-agent, always provide this context block:

```text
## Document Scan Context
- **File:** [full path]
- **Scan Profile:** [strict | moderate | minimal]
- **Severity Filter:** [error, warning, tip]
- **Disabled Rules:** [list or "none"]
- **User Notes:** [any specifics]
- **Part of Batch:** [yes/no - if yes, indicate X of Y]
```
