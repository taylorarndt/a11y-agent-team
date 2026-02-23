# audit-document-folder

Recursively scan an entire folder for document accessibility issues. Discovers all `.docx`, `.xlsx`, `.pptx`, and `.pdf` files, audits each one, identifies cross-document patterns, groups issues by shared template, and produces a single scored report for the whole set.

## When to Use It

- You have a library of documents and need to understand the overall accessibility state
- You are onboarding a new content library and need a baseline
- You want to identify template-level issues that can be fixed at the source
- You are preparing a department-wide accessibility remediation project

## How to Launch It

**In GitHub Copilot Chat:**
```
/audit-document-folder
```

Then provide the folder path when prompted. Or specify directly:

```
/audit-document-folder C:\sharepoint\policy-documents
/audit-document-folder /Users/name/Documents/training-materials
```

## What to Expect

### Step 1: Document Discovery

The [document-inventory](../../agents/document-inventory.md) agent recursively scans the folder and presents an inventory before scanning begins:

```
Document Inventory: C:\sharepoint\policy-documents
==================================================
  Word (.docx):       18 files
  Excel (.xlsx):       4 files
  PowerPoint (.pptx):  7 files
  PDF (.pdf):          3 files
  ─────────────────────────────
  Total:              32 files

  (3 Word documents are missing the title property)
```

### Step 2: Confirmation

The agent asks for confirmation before starting the scan — especially important for large folders. You can also narrow the scope at this point (e.g., "just scan the PDFs").

### Step 3: Per-Document Scan

Each file is delegated to the appropriate format specialist using the moderate profile (errors and warnings — tips are skipped for speed).

### Step 4: Cross-Document Pattern Analysis

The [cross-document-analyzer](../../agents/cross-document-analyzer.md) analyzes findings across all files:

- **Systemic issues** — failing the same rule in 90%+ of documents (e.g., no document has a title)
- **Folder-level patterns** — issues clustered in one subdirectory
- **Template-level issues** — same problem in all documents sharing a template
- **Per-document scores** — 0–100 with A–F grade for each file

### Step 5: Report Generation

The full report is written to `DOCUMENT-ACCESSIBILITY-AUDIT.md` with:

- **Metadata dashboard** — aggregate stats across all files
- **Scorecard table** — every file with its score, grade, and issue counts
- **Pattern summary** — systemic → template → isolated findings ordered by ROI
- **Remediation priority list** — fix template issues first, then isolated

## Example Variations

```
/audit-document-folder C:\reports                            # All files in folder
/audit-document-folder /docs/legal --types docx,pdf          # Word and PDF only
/audit-document-folder C:\training                           # Recursive (includes subfolders)
```

## Output Files

| File | Contents |
|------|----------|
| `DOCUMENT-ACCESSIBILITY-AUDIT.md` | Full multi-document report with scorecard and pattern analysis |

## Connected Agents

| Agent | Role |
|-------|------|
| [document-accessibility-wizard](../../agents/document-accessibility-wizard.md) | Orchestrates this prompt |
| [document-inventory](../../agents/document-inventory.md) | Discovers and catalogs the files |
| [cross-document-analyzer](../../agents/cross-document-analyzer.md) | Detects patterns and scores across documents |

## Related Prompts

- [audit-single-document](audit-single-document.md) — deep dive on a single file
- [audit-changed-documents](audit-changed-documents.md) — re-scan only what changed
- [compare-audits](compare-audits.md) — track improvement after fixing
- [generate-vpat](generate-vpat.md) — export as a compliance conformance report
