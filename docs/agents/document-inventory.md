# document-inventory

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [document-accessibility-wizard](document-accessibility-wizard.md) as the first step of every document audit. You do not need to invoke it directly.

## What It Does

`document-inventory` is the discovery layer for all document accessibility audits. Before anything can be scanned, the wizard needs to know which files exist, where they are, and which ones have changed. This agent handles all three.

Its responsibilities:

1. **File discovery** - recursively scans folders for `.docx`, `.xlsx`, `.pptx`, and `.pdf` files, filtering out temporary and system files
2. **Delta detection** - uses `git diff` to identify only the files changed since the last commit, tag, or audit
3. **Metadata extraction** - reads document properties (title, author, language, template references) to populate the inventory
4. **Inventory report** - returns a structured file list with counts, paths, and metadata flags that the wizard uses to plan the scan

## When It Runs

This agent is called at the start of every multi-document audit mode:

- `audit-document-folder` prompt - discovers all documents in the specified folder
- `audit-changed-documents` prompt - finds only the git-diff'd files to scan
- `generate-vpat` prompt - builds the file inventory for a library-wide compliance report
- `setup-document-cicd` prompt - discovers the document structure to infer the CI configuration

## File Discovery

The agent runs platform-appropriate commands depending on the environment.

### Windows (PowerShell)

```powershell
# Non-recursive scan
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf

# Recursive scan
Get-ChildItem -Path "<folder>" -File -Include *.docx,*.xlsx,*.pptx,*.pdf -Recurse |
  Where-Object { $_.Name -notlike '~$*' -and $_.Name -notlike '*.tmp' -and $_.Name -notlike '*.bak' } |
  Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules|__pycache__|\.vscode)[\\/]' }
```

### macOS/Linux (Bash)

```bash
# Non-recursive scan
find "<folder>" -maxdepth 1 -type f \
  \( -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.pdf" \) \
  ! -name "~\$*"

# Recursive scan
find "<folder>" -type f \
  \( -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.pdf" \) \
  ! -name "~\$*" ! -name "*.tmp" ! -name "*.bak" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/__pycache__/*" ! -path "*/.vscode/*"
```

### What Gets Skipped

The agent automatically skips:

| Pattern | Reason |
|---------|--------|
| `~$*.docx`, `~$*.xlsx` | Office temporary/lock files (open document artifacts) |
| `*.tmp`, `*.bak` | Backup and temporary files |
| `.git/` directory | Version control internals |
| `node_modules/` | Package dependencies (never contain user documents) |
| `.vscode/` | Editor configuration |
| `__pycache__/` | Python bytecode cache |

## Delta Detection

For the `audit-changed-documents` workflow, the agent uses git to find only modified files:

```bash
# Files changed since last commit
git diff --name-only HEAD~1 HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf'

# Files changed since a specific tag or release
git diff --name-only v2.0 HEAD -- '*.docx' '*.xlsx' '*.pptx' '*.pdf'

# Files changed in the last N days (for scheduled CI scans)
git log --since="7 days ago" --name-only --diff-filter=ACMR --pretty="" \
  -- '*.docx' '*.xlsx' '*.pptx' '*.pdf' | sort -u
```

The `--diff-filter=ACMR` flag includes Added, Copied, Modified, and Renamed files - excluding Deleted files (nothing to scan) and Type-changed files (rare edge case).

## Metadata Extraction

For Word, Excel, and PowerPoint files, the agent reads core document properties:

| Property | Source | What It Flags |
|----------|--------|---------------|
| Title | `docProps/core.xml` -> `dc:title` | Missing title (DOCX-E001 / PPTX-E001 / XLSX-E001) |
| Language | `word/settings.xml` -> `w:themeFontLang` | Missing or inconsistent language |
| Author | `docProps/core.xml` -> `dc:creator` | Informational only |
| Template | Word `AttachedTemplate`, PPT slide master name | Used for template grouping |

Properties are extracted by reading the XML inside the ZIP-format Office files. No third-party tool is required.

## Inventory Output

The agent returns a structured inventory that the wizard uses throughout the scan:

```text
Document Inventory: /path/to/folder
==================================================
  Word (.docx):        12 files
  Excel (.xlsx):        4 files
  PowerPoint (.pptx):   8 files
  PDF (.pdf):           3 files
  
  Total:               27 files

Files:
  /path/to/folder/report-q1.docx         [title: missing] [lang: en-US]
  /path/to/folder/training/module-1.pptx [title: OK]      [lang: missing]
  ...
```

Metadata flags in brackets tell the wizard which documents have property issues before scanning even begins.

## Connections

| Component | Role |
|-----------|------|
| [document-accessibility-wizard](document-accessibility-wizard.md) | Orchestrating wizard; calls this agent first in every multi-document flow |
| [cross-document-analyzer](cross-document-analyzer.md) | Receives the inventory after scanning to perform pattern detection and scoring |
| [audit-document-folder prompt](../prompts/documents/audit-document-folder.md) | User-facing prompt that triggers recursive file discovery |
| [audit-changed-documents prompt](../prompts/documents/audit-changed-documents.md) | User-facing prompt that triggers delta detection |
| [document-scanning skill](../../.github/skills/document-scanning/SKILL.md) | Full file discovery command reference and configuration details |
