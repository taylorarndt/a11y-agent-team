---
description: Audit markdown files for accessibility issues - links, alt text, headings, tables, emoji, mermaid diagrams, dashes, and anchor links
mode: agent
agent: markdown-a11y-assistant
---

Run a comprehensive markdown accessibility audit on the files or directory I specify.

## What This Audit Covers

- Ambiguous and non-descriptive link text (WCAG 2.4.4)
- Missing or inadequate image alt text (WCAG 1.1.1)
- Broken anchor links within files
- Skipped heading levels and multiple H1s (WCAG 1.3.1)
- Tables missing preceding descriptions (WCAG 1.3.1)
- Emoji used as bullets, in headings, or as consecutive sequences
- Mermaid diagrams with no accessible text alternative (WCAG 1.1.1)
- Em-dash and en-dash normalization for screen reader compatibility
- Plain language and list structure issues

## How to Use

Start the audit by telling the agent what to scan:

- Single file: `audit README.md`
- Directory: `audit all markdown files in this repo`
- Specific files: `audit CONTRIBUTING.md and ROADMAP.md`

The agent will ask a few configuration questions (emoji handling, dash normalization, diagram replacement preferences), then scan, present issues with before/after diffs, and apply fixes with your approval.

## Output

At the end of the audit you will receive:

1. A complete issue inventory by file and domain
2. A summary table showing found / fixed / flagged counts per issue type
3. A list of any remaining items that need manual review

To begin, invoke the `markdown-a11y-assistant` agent and tell it which files to audit.
