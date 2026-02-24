---
description: Generate PowerShell and Bash scripts to batch-fix automatable document accessibility issues. Creates safe scripts with dry-run mode and backups.
mode: agent
tools:
  - askQuestions
---

# Generate Batch Remediation Scripts

Create automated fix scripts for document accessibility issues that can be safely scripted.

## Source audit report

**Path:** `${input:auditReportPath}`

## Instructions

Use the **document-accessibility-wizard** agent to:

1. Read the audit report at the specified path
2. Identify all **automatable** fixes:
   - Setting document title from filename
   - Setting document language property
   - Removing Office lock files (~$*)
   - Renaming generic Excel sheet names
   - Adding bookmark structure to PDFs from heading tags
3. Identify **non-automatable** fixes that need human judgment:
   - Writing meaningful alt text
   - Fixing heading hierarchy
   - Correcting reading order
   - Rewriting ambiguous link text
4. Ask which script format to generate:
   - PowerShell (.ps1)
   - Bash (.sh)
   - Both
5. Generate the scripts with these safety features:
   - **Dry-run mode** (`-WhatIf` / `--dry-run`) - preview changes without modifying files
   - **Automatic backups** - copy originals to a `_backup/` folder before any changes
   - **Change log** - write a summary of every modification to `remediation-log.txt`
   - **Clear comments** - explain what each fix does and why
6. Write scripts to `scripts/remediation/`
7. Report which issues can be auto-fixed and which need manual attention

## Handoff Transparency

Announce script generation progress:
- **Start:** "Generating remediation scripts from audit findings..."
- **Completion:** "Scripts written to scripts/remediation/ - [N] auto-fixable, [N] manual"
- **On failure:** "Script generation failed: [reason]. Check that the audit report exists."
