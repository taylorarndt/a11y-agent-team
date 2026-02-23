# markdown-a11y-assistant - Guided Markdown Accessibility Audit

> Runs an interactive, multi-phase accessibility audit of Markdown documentation files. Dispatches `markdown-scanner` sub-agents in parallel across all discovered files, aggregates findings by domain and severity, scores each file with an A-F grade, presents a review gate before applying fixes, and produces a saved `MARKDOWN-ACCESSIBILITY-AUDIT.md` report.

## When to Use It

- You want a comprehensive accessibility audit of one or more Markdown files
- You need to fix ambiguous links, missing alt text, heading structure, or table descriptions
- You need to replace Mermaid or ASCII diagrams with accessible text alternatives
- You want to remove or translate emoji from documentation
- You want to track remediation progress across audit runs
- You want a scored, saved report suitable for compliance tracking

## The Six Phases

<details>
<summary>Expand phase details</summary>

| Phase | Domain | What Happens |
|-------|--------|--------------|
| 0 | Configuration | Asks scope, emoji mode, diagram preference, dash normalization, anchor validation |
| 1 | Discovery | Finds all in-scope Markdown files; shows count and list |
| 2 | Parallel Scanning | Dispatches `markdown-scanner` for each file simultaneously; collects structured findings |
| 3 | Report Generation | Aggregates findings; computes per-file scores; produces ranked issue inventory |
| 4 | Fix Review Gate | Shows auto-fixable items and human-judgment items; confirms before applying |
| 5 | Fix Application | Dispatches `markdown-fixer` per file; applies fixes; produces before/after diff |

</details>

## Key Capabilities

<details>
<summary>Expand capabilities</summary>

- **Parallel scanning** - All files scanned simultaneously using sub-agent delegation
- **9 accessibility domains** - Links, alt text, headings, tables, emoji, diagrams, em-dashes, anchors, plain language
- **Emoji modes** - Remove all / Remove decorative only (default) / Translate to English / Leave unchanged
- **Diagram replacement** - Mermaid and ASCII diagrams replaced with accessible text alternatives; originals preserved in collapsible `<details>` blocks
- **Per-file scoring** - 0-100 score with A-F grade using weighted severity penalties
- **Review gate** - You see and approve all changes before any file is modified
- **Saved report** - `MARKDOWN-ACCESSIBILITY-AUDIT.md` written to workspace root with full findings, scores, and fix summary

</details>

## Scoring Formula

```text
File Score = 100 - (Critical×15 + Serious×7 + Moderate×3 + Minor×1)
Floor: 0
```

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - minor or no issues |
| 75-89 | B | Good - mostly accessible documentation |
| 50-74 | C | Needs Work - several accessibility gaps |
| 25-49 | D | Poor - significant barriers |
| 0-24 | F | Failing - major structural problems |

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Claude Code

```text
/markdown-a11y-assistant audit README.md
/markdown-a11y-assistant audit all markdown files in the repo
/markdown-a11y-assistant audit only files changed since the last commit
/markdown-a11y-assistant translate emoji to English in CONTRIBUTING.md
/markdown-a11y-assistant replace Mermaid diagrams in ARCHITECTURE.md with accessible alternatives
```

### GitHub Copilot

```text
@markdown-a11y-assistant audit README.md
@markdown-a11y-assistant audit all markdown files in this repo
@markdown-a11y-assistant remove emoji from CONTRIBUTING.md
@markdown-a11y-assistant fix anchor links in ROADMAP.md
@markdown-a11y-assistant compare this audit with the previous one
```

</details>

## Custom Prompts

Four pre-built prompts in `.github/prompts/` provide one-click workflows:

| Prompt | What It Does |
|--------|-------------|
| [audit-markdown](../../.github/prompts/audit-markdown.prompt.md) | Full guided audit with Phase 0 config, parallel scan, saved report |
| [quick-markdown-check](../../.github/prompts/quick-markdown-check.prompt.md) | Fast triage - errors only, no report file |
| [fix-markdown-issues](../../.github/prompts/fix-markdown-issues.prompt.md) | Interactive fix mode from saved report or fresh scan |
| [compare-markdown-audits](../../.github/prompts/compare-markdown-audits.prompt.md) | Track remediation progress between two audit snapshots |

## Handoffs

After completing an audit the agent offers these handoffs:

| Handoff | When to Use |
|---------|------------|
| **Fix Issues** - routes to `markdown-fixer` | You want to apply fixes immediately |
| **Compare Audits** - routes to `compare-markdown-audits` prompt | You have a baseline report to compare against |
| **Quick Check** - routes to `quick-markdown-check` prompt | You want a fast re-scan after fixes |
| **Run Web Audit** - routes to `accessibility-lead` | Your Markdown files are part of a web project |

## Sub-Agents Used

| Agent | Role |
|-------|------|
| [markdown-scanner](markdown-scanner.md) | Scans one file across all 9 domains; called in parallel for all files |
| [markdown-fixer](markdown-fixer.md) | Applies fixes to one file; called after review gate approval |

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Always asks configuration questions in Phase 0 before scanning
- Never modifies any file without presenting a review gate first
- Uses `remove-decorative` emoji mode by default unless the user specifies differently
- Always preserves original Mermaid/ASCII source in a `<details>` block when replacing with text alternatives
- Always writes the audit report to `MARKDOWN-ACCESSIBILITY-AUDIT.md` before offering handoffs
- For complex diagram replacements, produces a draft description and asks the author to verify accuracy

</details>
