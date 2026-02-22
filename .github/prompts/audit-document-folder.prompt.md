---
description: Recursively scan an entire folder for document accessibility issues. Finds all .docx, .xlsx, .pptx, and .pdf files and audits them with cross-document pattern analysis.
mode: agent
tools:
  - askQuestions
---

# Folder Document Accessibility Audit

Run a comprehensive recursive accessibility audit on all documents in the folder below. Use the **document-accessibility-wizard** agent.

## Target folder

**Path:** `${input:folderPath}`

## Settings

- **Scan mode:** Folder (recursive — include all subfolders)
- **Document types:** All supported (.docx, .xlsx, .pptx, .pdf)
- **Scan profile:** Moderate (errors and warnings — skip tips for speed)
- **Report path:** `DOCUMENT-ACCESSIBILITY-AUDIT.md`
- **Organization:** By file
- **Remediation steps:** Summary only

## Instructions

1. Discover all documents recursively in the folder
2. Skip temp files (~$*, *.tmp, *.bak) and ignored directories (.git, node_modules)
3. Present the inventory with counts by type and subfolder
4. Ask for confirmation before scanning
5. Scan all files, delegating each to the appropriate sub-agent
6. Run cross-document pattern analysis
7. Compute severity scores for every file
8. Detect shared templates and flag template-level issues
9. Build the metadata dashboard
10. Generate the full report with scorecard
11. Offer follow-up actions
