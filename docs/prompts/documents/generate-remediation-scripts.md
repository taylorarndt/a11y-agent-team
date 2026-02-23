# generate-remediation-scripts

Create PowerShell and Bash scripts to batch-fix automatable document accessibility issues. Scripts include dry-run mode, automatic backups, and a change log — safe to run on large document libraries.

## When to Use It

- You have many documents with the same fixable issues (missing titles, missing language settings) and want to fix them all at once
- You want to automate the mechanical parts of remediation before tackling the judgment-based fixes manually
- You are setting up a CI pipeline that auto-remediates common issues on every merge
- You want to provide your team with a one-command fix script

## How to Launch It

**In GitHub Copilot Chat:**
```
/generate-remediation-scripts
```

Then provide the audit report path when prompted. Or specify directly:

```
/generate-remediation-scripts DOCUMENT-ACCESSIBILITY-AUDIT.md
```

## What to Expect

### Step 1: Report Analysis

The agent reads the audit report and divides findings into two categories:

**Automatable fixes:**
- Setting document title from filename
- Setting the document language property
- Removing Office lock/temp files (`~$*`)
- Renaming generic Excel sheet tabs (Sheet1, Sheet2)
- Adding bookmark structure to PDFs from heading tags

**Non-automatable fixes (manual attention required):**
- Writing meaningful alt text for images
- Correcting heading hierarchy
- Fixing reading order in PowerPoint
- Rewriting ambiguous link text

### Step 2: Script Format Selection

The agent asks which format to generate:
- PowerShell (`.ps1`) — recommended for Windows environments
- Bash (`.sh`) — recommended for macOS/Linux environments
- Both

### Step 3: Safety Features

Every generated script includes:

| Safety Feature | Implementation |
|---------------|----------------|
| **Dry-run mode** | `-WhatIf` (PowerShell) or `--dry-run` (Bash) — preview changes without modifying files |
| **Automatic backups** | Copies all target files to `_backup/` folder before any modifications |
| **Change log** | Writes every modification to `remediation-log.txt` with timestamp and file path |
| **Clear comments** | Each fix section explains what it does and the WCAG criterion it addresses |

### Step 4: Script Generation

Scripts are written to `scripts/remediation/`:

```
scripts/
└── remediation/
    ├── fix-document-titles.ps1
    ├── fix-document-titles.sh
    ├── fix-language-settings.ps1
    ├── fix-language-settings.sh
    └── README.md            ← instructions for running the scripts
```

### Running the Scripts

```powershell
# Preview changes (dry run — no files modified)
.\fix-document-titles.ps1 -WhatIf -Path "C:\documents"

# Apply changes with backup
.\fix-document-titles.ps1 -Path "C:\documents" -Backup

# Check what was changed
Get-Content remediation-log.txt
```

## Example Variations

```
/generate-remediation-scripts DOCUMENT-ACCESSIBILITY-AUDIT.md
→ Format: Both PowerShell and Bash

/generate-remediation-scripts reports/library-audit.md
→ Format: PowerShell only
→ Target: the entire SharePoint library export folder
```

## Output Files

| File | Contents |
|------|----------|
| `scripts/remediation/*.ps1` | PowerShell fix scripts |
| `scripts/remediation/*.sh` | Bash fix scripts |
| `scripts/remediation/README.md` | Usage instructions |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Analyzes the audit and generates the scripts |

## Related Prompts

- [audit-single-document](audit-single-document.md) — generate the audit report first
- [audit-document-folder](audit-document-folder.md) — audit the whole library before scripting
- [compare-audits](compare-audits.md) — verify improvement after running the scripts
