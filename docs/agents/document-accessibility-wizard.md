# document-accessibility-wizard — Guided Document Accessibility Audit

> Runs an interactive, multi-phase accessibility audit of Office documents (DOCX, XLSX, PPTX) and PDFs. Coordinates the document scanning agents, performs cross-document analysis, scores findings by severity and confidence, tracks remediation across re-scans, generates VPAT/ACR compliance reports, creates batch remediation scripts, and provides CI/CD integration guidance.

## When to Use It

- You have a folder of documents that need accessibility review
- You want a comprehensive audit with cross-document pattern analysis
- You need to generate a VPAT/ACR compliance report from document findings
- You want to track remediation progress across multiple scan iterations
- You need to set up automated document scanning in CI/CD
- You want batch remediation scripts for common fixable issues

## The Seven Phases

| Phase | Domain | What Happens |
|-------|--------|-------------|
| 0 | Discovery | Asks about scope, format preferences, scan profile |
| 1 | File Discovery | Finds documents recursively, shows inventory by type |
| 2 | Scanning | Runs per-file scans with severity scoring and confidence levels |
| 3 | Cross-Document Analysis | Identifies patterns, systemic issues, template problems |
| 4 | Report Generation | Produces prioritized report with metadata dashboard |
| 5 | Follow-Up | Offers remediation scripts, VPAT export, template guidance |
| 6 | CI/CD Integration | Generates pipeline configs for automated scanning |

## Key Capabilities

- **Delta scanning** — Only scans files changed since last commit
- **Severity scoring** — Each finding scored Critical/Major/Minor with confidence level
- **Template analysis** — Detects when issues originate from shared templates
- **Remediation tracking** — Compares current scan against baseline, shows progress
- **Batch remediation** — Generates PowerShell/Bash scripts for automatable fixes
- **VPAT/ACR export** — Maps findings to WCAG criteria for compliance reporting
- **Metadata dashboard** — Summary statistics at top of every report

## Example Prompts

### Claude Code

```
/document-accessibility-wizard scan all documents in the docs/ folder
/document-accessibility-wizard audit only files changed since last commit
/document-accessibility-wizard generate a VPAT from the last audit
/document-accessibility-wizard compare these two audit reports for progress
```

### GitHub Copilot

```
@document-accessibility-wizard audit all documents in this project
@document-accessibility-wizard quick check on report.docx
@document-accessibility-wizard set up CI/CD for document scanning
@document-accessibility-wizard generate remediation scripts for the last scan
```

## Custom Prompts

Nine pre-built prompts in `.github/prompts/` provide one-click workflows: single document audit, folder audit, delta scan, VPAT generation, remediation scripts, audit comparison, CI/CD setup, quick check, and accessible template guidance.

## Behavioral Constraints

- Always asks the user before moving between phases — never skips ahead silently
- Presents findings after each phase before proceeding
- Asks for scan profile preference (strict/moderate/minimal) at startup
- Groups findings by severity with confidence levels
- Identifies cross-document patterns and template-originated issues
- Generates scripts with dry-run mode and automatic backups
