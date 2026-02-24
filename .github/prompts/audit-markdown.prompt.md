---
description: Full guided markdown accessibility audit - links, alt text, headings, tables, emoji (remove or translate), Mermaid/ASCII diagrams replaced with accessible text alternatives, em-dashes, and anchor link validation. Produces a scored MARKDOWN-ACCESSIBILITY-AUDIT.md report with per-file grades.
mode: agent
agent: markdown-a11y-assistant
---

# Markdown Accessibility Audit

Run a comprehensive, guided accessibility audit of your markdown documentation. The `markdown-a11y-assistant` orchestrates `markdown-scanner` sub-agents in parallel across all discovered files, then runs `markdown-fixer` with a review gate before applying any changes.

## What This Audit Covers

| Domain | WCAG | Auto-fix? |
|--------|------|-----------|
| Ambiguous and non-descriptive link text | 2.4.4 | Yes |
| Missing or inadequate image alt text | 1.1.1 | No - needs visual judgment |
| Skipped heading levels and multiple H1s | 1.3.1 | Yes |
| Tables missing preceding descriptions | 1.3.1 | Yes |
| Emoji in headings, bullets, or consecutive sequences | 1.3.3 | Yes (remove or translate per your choice) |
| Mermaid diagrams with no accessible text alternative | 1.1.1 | Partial (simple: auto; complex: draft + your approval) |
| ASCII art without a text description | 1.1.1 | Partial (auto-wrap; description author-approved) |
| Em-dash and en-dash normalization | Cognitive | Yes |
| Broken anchor links | 2.4.4 | No - confirm which end changes |
| Plain language and list structure | Cognitive | Partial |

## How to Use

Start the audit by telling the agent what to scan:

- Single file: `audit README.md`
- Directory: `audit all markdown files in this repo`
- Specific files: `audit CONTRIBUTING.md and ROADMAP.md`
- Changed files only: `audit only markdown files changed since the last commit`

## Configuration (Phase 0)

The agent will ask a few configuration questions:

1. **Emoji handling:** Remove all | Remove decorative (default) | Translate to English | Leave unchanged
2. **Mermaid/ASCII diagrams:** Replace with text alternative (recommended) | Flag only | Leave unchanged
3. **Em-dash normalization:** Normalize to ` - ` (recommended) | Leave unchanged
4. **Anchor validation:** Yes (recommended) | No
5. **Fix mode:** Auto-fix safe issues + review the rest (recommended) | Flag everything first | Fix everything

## Output

At the end of the audit you receive:

1. A `MARKDOWN-ACCESSIBILITY-AUDIT.md` report saved to the workspace root with:
   - Executive summary with overall score and grade (A-F)
   - Per-file scorecards with issue counts by severity
   - Complete issue inventory by file and domain
   - Summary table: found / auto-fixed / fixed-after-review / flagged counts per issue type
   - Remaining items list with file:line for future action
2. Applied fixes with before/after diffs for each change
3. Handoff options: `fix-markdown-issues`, `compare-markdown-audits`, or `quick-markdown-check`

## Handoff Transparency

This workflow orchestrates `markdown-scanner` and `markdown-fixer` sub-agents. Announce each transition:
- **Scanner dispatch:** "Scanning [filename] for accessibility issues ([N/total])..."
- **Scanner complete:** "[filename]: [N] issues found, score [score]/100 ([grade])"
- **Fixer dispatch:** "Applying [N] approved fixes to [filename]..."
- **Fixer complete:** "[filename]: [N] fixed, [N] skipped, [N] need review"
- **On failure:** "[Agent] failed on [filename]: [reason]. Continuing with remaining files."

