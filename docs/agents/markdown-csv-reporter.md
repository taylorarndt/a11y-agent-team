# markdown-csv-reporter

> **Internal sub-agent.** This agent is not user-invokable. It is orchestrated automatically by [markdown-a11y-assistant](markdown-a11y-assistant.md) during CSV export workflows. You do not need to invoke it directly - use the `export-markdown-csv` prompt instead.

## What It Does

`markdown-csv-reporter` reads a completed `MARKDOWN-ACCESSIBILITY-AUDIT.md` report and generates structured CSV files optimized for reporting, tracking, and remediation workflows. Every finding includes WCAG understanding document links and markdownlint rule references.

It generates three CSV files:

1. **MARKDOWN-ACCESSIBILITY-FINDINGS.csv** - one row per issue instance with severity scoring, WCAG criteria, and help links
2. **MARKDOWN-ACCESSIBILITY-SCORECARD.csv** - one row per audited markdown file with score (0-100) and grade (A-F)
3. **MARKDOWN-ACCESSIBILITY-REMEDIATION.csv** - prioritized remediation plan sorted by ROI score (highest impact first)

## When It Runs

This agent is called by:

- `export-markdown-csv` prompt - the primary user-facing CSV export workflow
- The markdown-a11y-assistant during Phase 6 when the user selects "Export findings as CSV"

## Rule ID Mapping

The agent maps markdown audit findings to rule IDs using markdownlint rules where available, with custom domain-based identifiers for issues without a standard rule:

| Domain | Issue | Rule ID |
|--------|-------|---------|
| Alt Text | Image missing alt text | `MD045` |
| Diagrams | Mermaid without text alternative | `DIAG-MERMAID` |
| Diagrams | ASCII without text description | `DIAG-ASCII` |
| Links | Broken anchor link | `LINK-ANCHOR` |
| Links | Ambiguous link text | `LINK-AMBIGUOUS` |
| Headings | Skipped heading level | `MD001` |
| Headings | Multiple H1s | `MD025` |
| Emoji | Emoji in heading | `EMO-HEADING` |
| Emoji | Consecutive emoji | `EMO-CONSECUTIVE` |
| Emoji | Emoji as bullet | `EMO-BULLET` |
| Formatting | Em-dash in prose | `DASH-EM` |
| Tables | Missing description | `TBL-DESC` |
| Links | Bare URL | `MD034` |
| Headings | Bold used as heading | `HDG-BOLD` |
| Emoji | Emoji for meaning | `EMO-MEANING` |

## CSV Formatting

All CSV files follow these conventions:

- UTF-8 encoding with BOM (Excel compatibility)
- CRLF line endings
- All text fields double-quoted
- Internal quotes escaped by doubling
- ISO 8601 dates
- Header row always included

## Platforms

| Platform | File |
|----------|------|
| VS Code / GitHub Copilot | `.github/agents/markdown-csv-reporter.agent.md` |
| Claude Code | `.claude/agents/markdown-csv-reporter.md` |

## Related

- [markdown-a11y-assistant](markdown-a11y-assistant.md) - the orchestrating wizard that invokes this agent
- [markdown-scanner](markdown-scanner.md) - per-file scanning sub-agent
- [markdown-fixer](markdown-fixer.md) - interactive fix sub-agent
- [web-csv-reporter](web-csv-reporter.md) - equivalent CSV exporter for web audits
- [document-csv-reporter](document-csv-reporter.md) - equivalent CSV exporter for document audits
